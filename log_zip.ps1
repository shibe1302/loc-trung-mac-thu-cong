#Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
param (
    [string]$zipFile,
    [string]$FCD,
    [string]$FTU
)

# thay link fike zip hoac folder sau khi giai nen tai day


Set-StrictMode -Version Latest

#================= Ham print ===================
function pr {
    param (
        [string]$p
    )
    Write-Host "=========== $p ============" -ForegroundColor Cyan
}




#================= giai nen file va don dep ===================
$nameFolder = [System.IO.Path]::GetFileNameWithoutExtension($zipFile)
$folder_containing_zip = Split-Path $zipFile
Get-ChildItem -Path $folder_containing_zip -Directory | Remove-Item -Recurse -Force
pr -p $zipFile
pr -p $nameFolder
& "C:\Program Files\7-Zip\7z.exe" x $zipFile -aoa -o"$folder_containing_zip" -y

#================= Tim folder LOG ===================
$final_LOG_FOLDER = "cac"
$LOG_DIR=(Get-Item $zipFile).DirectoryName
$found = Get-ChildItem -Path $LOG_DIR -Recurse -Directory -ErrorAction SilentlyContinue |
Where-Object { $_.Name -imatch "^log$" }

if ($found) {
    $final_LOG_FOLDER = $found[0].FullName
    Write-Host "Da tim thay folder log !" -ForegroundColor Green
}
else {
    Write-Host "Khong tim thay folder log !" -ForegroundColor Yellow
    Write-Host "Hay dat ten folder chua file LOG thanh LOG hoac log !" -ForegroundColor Yellow
    exit
}

$parent_of_log = (Get-Item $final_LOG_FOLDER).Parent.FullName
Write-Output $parent_of_log
$Tong_file_log=(Get-Item $final_LOG_FOLDER).GetFiles().Count





#================= Tao cac folder cua cac tram test ===================
$passFolder = Join-Path $parent_of_log "PASS"
$failFolder = Join-Path $parent_of_log "FAIL"
$sai_ftu_Folder = Join-Path $parent_of_log "SAI_FTU"
New-Item -Path $sai_ftu_Folder -ItemType Directory -Force | Out-Null
New-Item -Path $passFolder -ItemType Directory -Force | Out-Null
New-Item -Path $failFolder -ItemType Directory -Force | Out-Null
$cac_tram_test = @("DL", "PT", "PT1", "PT2", "BURN", "FT1", "FT2", "FT3", "FT4", "FT5", "FT6")
$cac_tram_test | ForEach-Object {
    New-Item -Path (Join-Path $passFolder $_) -ItemType Directory -Force | Out-Null
    New-Item -Path (Join-Path $failFolder $_) -ItemType Directory -Force | Out-Null
}


#================= Kiem tra FTU ========================
function is_FTU_correct {
    param (
        [string]$path,
        [string]$ftu
    )
    $content = Get-Content -Path $path -Raw
    $pattern = "FTU version *: *(FTU_.*)"
    if ($content -match $pattern) {
        $ftu_in_file = $matches[1].Trim() 
        return $ftu_in_file -eq $ftu
    }
    else {
        Write-Output "No match found" ForegroundColor Orange
        return $false
    }
    return $false
    
}

$all_path_log = Get-ChildItem -Path $final_LOG_FOLDER -Recurse -File -Include *.log, *.txt | Select-Object -ExpandProperty FullName
$all_path_log | Out-File -FilePath (Join-Path $parent_of_log "file_sai_FTU.txt")
Write-Host "Found: $($all_path_log.Count)" -ForegroundColor Green
#     FTU_a6aa_1.0.22_4.1.7_UXG-Fiber
$FTU="FTU_a6aa_1.0.26_4.1.7_UXG-Fiber"
$count_invalid_FTU = 0
foreach ($log_file1 in $all_path_log) {
    if (-not (is_FTU_correct -path $log_file1 -ftu $FTU)) {
        Write-Host "$([System.IO.Path]::GetFullPath($log_file1))" -ForegroundColor Magenta
        $count_invalid_FTU += 1
        Move-Item -Path $log_file1 -Destination $sai_ftu_Folder
    }
}

#================= Ham di chuyen file ===================
function join_and_move_fail {
    param (
        [string]$log_dir,
        [string]$file_name,
        [string]$state  
    )
    $path_to_file = Join-Path $log_dir $file_name
    $path_to_des = [System.IO.Path]::Combine($failFolder, $state, $file_name)
    try {
        Move-Item -Path $path_to_file -Destination $path_to_des
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "Error moving file $path_to_file to $state : " -ForegroundColor Red
    }

}
function join_and_move_pass {
    param (
        [string]$log_dir,
        [string]$file_name,
        [string]$state  
    )
    $path_to_file = Join-Path $log_dir $file_name
    $path_to_des = [System.IO.Path]::Combine($passFolder, $state, $file_name)
    try {
        Move-Item -Path $path_to_file -Destination $path_to_des
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "Error moving file $path_to_file to $state : " -ForegroundColor Red
    }

}

#================= Phan loai log fail ===================
$count_fail = 0
$log_files= Get-ChildItem -Path $final_LOG_FOLDER -File
foreach ($_ in $log_files) {
    
    switch -regex ($_) {
        "^FAIL.*DOWNLOAD" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "DL"
            $count_fail += 1
            break
        }
        "^FAIL.*PT1" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "PT1"
            $count_fail += 1
            break
        }
        "^FAIL.*PT2" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "PT2"  
            $count_fail += 1
            break
        }
        "^FAIL.*PT_" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "PT"
            $count_fail += 1
            break
        }
        "^FAIL.*BURN" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "BURN"
            $count_fail += 1
            break
        }
        "^FAIL.*FT1" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "FT1"
            $count_fail += 1
            break
        }
        "^FAIL.*FT2" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "FT2"
            $count_fail += 1
            break
        }
        "^FAIL.*FT3" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "FT3"
            $count_fail += 1
            break
        }
        "^FAIL.*FT4" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "FT4"
            $count_fail += 1
            break
        }
        "^FAIL.*FT5" {

            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "FT5"
            $count_fail += 1
            break
        }
        "^FAIL.*FT6" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "FT6"
            $count_fail += 1
            break
        }
    }
}

#================= Phan loai log pass ===================
$count_pass = 0
foreach ($_ in $log_files) {
    
    switch -regex ($_) {
        "^PASS.*DOWNLOAD" {
            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "DL"
            $count_pass += 1
            break
        }
        "^PASS.*PT1" {
            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "PT1"
            $count_pass += 1
            break
        }
        "^PASS.*PT2" {
            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "PT2"
            $count_pass += 1
            break
        }
        "^PASS.*PT" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "PT"
            $count_pass += 1
            break
        }
        "^PASS.*BURN" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "BURN"
            $count_pass += 1
            break
        }
        "^PASS.*FT1" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "FT1"
            $count_pass += 1
            break
        }
        "^PASS.*FT2" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "FT2"
            $count_pass += 1
            break
        }
        "^PASS.*FT3" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "FT3"
            $count_pass += 1
            break
        }
        "^PASS.*FT4" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "FT4"
            $count_pass += 1
            break
        }
        "^PASS.*FT5" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "FT5"
            $count_pass += 1
            break
        }
        "^PASS.*FT6" {
            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "FT6"
            $count_pass += 1
            break
        }
    }
}
try {
    pr -p "pass: $count_pass"
    pr -p "fail: $count_fail"
    pr -p "sai FTU: $count_invalid_FTU"
    pr -p "So file log truoc khi xu li : $Tong_file_log"
    pr -p "Tong so file fail, pass, sai FTU : $($count_fail + $count_pass + $count_invalid_FTU)"
}
catch {
    Write-Host "Error when printing summary: $_" -ForegroundColor Red
}
#================ Kiểm tra nếu folder rỗng thì xóa ===============
foreach ($tram in $cac_tram_test) {
    $folderPath_P = Join-Path $passFolder $tram
    $folderPath_F = Join-Path $failFolder $tram
    $items_P = Get-ChildItem -Path $folderPath_P -ErrorAction SilentlyContinue
    $items_F = Get-ChildItem -Path $folderPath_F -ErrorAction SilentlyContinue

    if (-not $items_P) {
        Remove-Item -Path $folderPath_P -Recurse -Force
    }
    if (-not $items_F) {
        Remove-Item -Path $folderPath_F -Recurse -Force
    }
}

# =================== FIX NUỐT LOG CUỐI ======================
[System.Console]::Out.Flush()
Start-Sleep -Milliseconds 300
