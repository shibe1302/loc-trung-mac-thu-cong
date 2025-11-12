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


#================= lay ten folder vua giai nen ===================
$list_folder = Get-ChildItem -Path $folder_containing_zip -Directory
$LOG_FOLDER = $list_folder[0].Name
$LOG_DIR = Join-Path $folder_containing_zip $LOG_FOLDER
pr -p " log dir $LOG_DIR"






#================= Tao cac folder cua cac tram test ===================
$passFolder = Join-Path $LOG_DIR "PASS"
$failFolder = Join-Path $LOG_DIR "FAIL"
$sai_ftu_Folder = Join-Path $LOG_DIR "SAI_FTU"
New-Item -Path $sai_ftu_Folder -ItemType Directory -Force | Out-Null
New-Item -Path $passFolder -ItemType Directory -Force | Out-Null
New-Item -Path $failFolder -ItemType Directory -Force | Out-Null
$cac_tram_test = @("DL", "PT", "PT1", "PT2", "BURN", "FT1", "FT2", "FT3", "FT4", "FT5", "FT6")
$cac_tram_test | ForEach-Object {
    New-Item -Path (Join-Path $passFolder $_) -ItemType Directory -Force | Out-Null
    New-Item -Path (Join-Path $failFolder $_) -ItemType Directory -Force | Out-Null
}


#================= Tim folder log ===================


$final_LOG_FOLDER = "123"
$exit_loop = $true
$rename_check = $true
while ($exit_loop -eq $true) {
    $list_dir_LOG_FOLDER = Get-ChildItem -Path $LOG_DIR -Directory
    pr -p $list_dir_LOG_FOLDER
    foreach ($folder in $list_dir_LOG_FOLDER) {
        if ($folder.Name -imatch "log") {
            try {
                $final_LOG_FOLDER = Join-Path $LOG_DIR $folder.Name
                $exit_loop = $false
                break
            }
            catch {
                Write-Host "Error when setting final_LOG_FOLDER: $_" -ForegroundColor Red
                exit
            }
        
        }

    }
    if ($exit_loop -eq $true) {
        Write-Host "Khong tim thay log folder!
Hoac doi lai ten folder chua file Log thanh LOG hoac log" -ForegroundColor Red
        write-Host "DOI TEN folder sau do bam [y] de tiep tuc, nhap ky tu bat ki de thoat " -ForegroundColor Yellow
        $key_presses = Read-Host
        if ($key_presses -imatch "y") {
            $rename_check = $true
        }
        else {
            write-Host "Thoat chuong trinh" -ForegroundColor Yellow
            start-sleep -Seconds 1
            exit
        }
    }

}




#================= Tim folder Log ==========================
$log_files = Get-ChildItem -Path $final_LOG_FOLDER -File
if ($log_files) {
    Write-Host "Da tim thay log files!" -ForegroundColor Green
}
else {
    Write-Host "Khong tim thay log files!" -ForegroundColor Red
    exit
}
$final_LOG_FOLDER
#================= Kiem tra FTU ========================
function is_FTU_correct {
    param (
        [string]$path,
        [string]$ftu
    )
    $content = Get-Content -Path $filePath -Raw
    $pattern = "FTU version *: *(FTU_.*)"
    if ($content -match $pattern) {
        $ftu_in_file = $matches[1].Trim() 
        Write-Host "Correct FTU !" -ForegroundColor Green
        return $ftu_in_file -eq $ftu
    }
    else {
        Write-Output "No match found"
        return $false
    }
    return $false
    
}
# $path_test_fun="C:\Users\shibe\Desktop\test_cp\UXGFIBERT01_86pcs_2643011691_log\PASS\FT1\PASS_1C0B8B1EA930_UXGFIBERT01_FT1_UXGFIBEFT102_20250719011027_2643011691.log"
# is_FTU_correct -path $path_test_fun -ftu "FTU_a6aa_1.0.26_4.1.7_UXG-Fiber"

$log_file_list = Get-ChildItem -Path $final_LOG_FOLDER -File 
foreach ($log_file in $log_file_list) {
    $full_path_log_file = Join-Path $final_LOG_FOLDER $log_file.Name
    if (-not (is_FTU_correct -path $full_path_log_file -ftu $FTU)) {
        $path_to_des_sai_ftu = [System.IO.Path]::Combine($sai_ftu_Folder, $log_file.Name)
        try {
            Move-Item -Path $full_path_log_file -Destination $path_to_des_sai_ftu
            Write-Host "Da chuyen file $($log_file.Name) vao folder SAI_FTU" -ForegroundColor Yellow
        }
        catch {
            <#Do this if a terminating exception happens#>
            Write-Host "Error moving file $full_path_log_file to SAI_FTU : " -ForegroundColor Red
        }
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
    pr -p "Tong so file fail va pass : $($count_fail + $count_pass)"
    pr -p "so file thuc te : $($log_files.Count)"
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
