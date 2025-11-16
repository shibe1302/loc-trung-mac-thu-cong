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
$LOG_DIR = (Get-Item $zipFile).DirectoryName
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
$Tong_file_log = (Get-Item $final_LOG_FOLDER).GetFiles().Count





#================= Tao cac folder cua cac tram test ===================
$passFolder = Join-Path $parent_of_log "PASS"
$failFolder = Join-Path $parent_of_log "FAIL"
New-Item -Path $passFolder -ItemType Directory -Force | Out-Null
New-Item -Path $failFolder -ItemType Directory -Force | Out-Null
$cac_tram_test = @("DL", "PT", "PT1", "PT2", "PT3", "PT4", "BURN", "FT1", "FT2", "FT3", "FT4", "FT5", "FT6")
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
        if ($ftu_in_file -eq $ftu) {
            return $true   # cùng phiên bản
        }
        else {
            return $false  # khác phiên bản
        }
    }
    else {
        return $true       # không tìm thấy pattern
    }
}
function is_FCD_correct {
    param (
        [string]$path,
        [string]$fcd
    )
    $content = Get-Content -Path $path -Raw
    $pattern = "FCD version *: *(FCD_.*)"
    if ($content -match $pattern) {
        $ftu_in_file = $matches[1].Trim()
        if ($ftu_in_file -eq $fcd) {
            return $true   # cùng phiên bản
        }
        else {
            return $false  # khác phiên bản
        }
    }
    else {
        return $true       # không tìm thấy pattern
    }
}

#================= Kiem tra file sai FTU ========================
# $all_path_log = Get-ChildItem -Path $final_LOG_FOLDER -Recurse -File -Include *.log, *.txt | Select-Object -ExpandProperty FullName
# $all_path_log | Out-File -FilePath (Join-Path $parent_of_log "file_sai_FTU.txt")
# Write-Host "Found: $($all_path_log.Count)" -ForegroundColor Green

# $count_invalid_FTU = 0
# foreach ($log_file1 in $all_path_log) {
#     if (-not (is_FTU_correct -path $log_file1 -ftu $FTU)) {
#         Write-Host "$([System.IO.Path]::GetFullPath($log_file1))" -ForegroundColor Magenta
#         $count_invalid_FTU += 1
#         Move-Item -Path $log_file1 -Destination $sai_ftu_Folder
#     }
# }

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
$log_files = Get-ChildItem -Path $final_LOG_FOLDER -File
#================= Phan loai log pass ===================
$count_pass = 0
foreach ($_ in $log_files) {
    
    switch -regex ($_) {
        "^PASS.*_DOWNLOAD_" {
            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "DL"
            $count_pass += 1
            break
        }
        "^PASS.*_PT1_" {
            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "PT1"
            $count_pass += 1
            break
        }
        "^PASS.*_PT2_" {
            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "PT2"
            $count_pass += 1
            break
        }
        "^PASS.*_PT3_" {
            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "PT3"
            $count_pass += 1
            break
        }
        "^PASS.*_PT4_" {
            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "PT4"
            $count_pass += 1
            break
        }
        "^PASS.*_PT_" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "PT"
            $count_pass += 1
            break
        }
        "^PASS.*_BURN_" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "BURN"
            $count_pass += 1
            break
        }
        "^PASS.*_FT1_" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "FT1"
            $count_pass += 1
            break
        }
        "^PASS.*_FT2_" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "FT2"
            $count_pass += 1
            break
        }
        "^PASS.*_FT3_" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "FT3"
            $count_pass += 1
            break
        }
        "^PASS.*_FT4_" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "FT4"
            $count_pass += 1
            break
        }
        "^PASS.*_FT5_" {

            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "FT5"
            $count_pass += 1
            break
        }
        "^PASS.*_FT6_" {
            join_and_move_pass -log_dir $final_LOG_FOLDER -file_name $_ -state "FT6"
            $count_pass += 1
            break
        }
    }
}


#================= Phan loai log fail ===================
$count_fail = 0

foreach ($_ in $log_files) {
    
    switch -regex ($_) {
        "^FAIL.*_DOWNLOAD_" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "DL"
            $count_fail += 1
            break
        }
        "^FAIL.*_PT1_" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "PT1"
            $count_fail += 1
            break
        }
        "^FAIL.*_PT2_" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "PT2"
            $count_fail += 1
            break
        }
        "^FAIL.*_PT3_" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "PT3"
            $count_fail += 1
            break
        }
        "^FAIL.*_PT4_" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "PT4"
            $count_fail += 1
            break
        }
        "^FAIL.*_PT_" {

            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "PT"
            $count_fail += 1
            break
        }
        "^FAIL.*_BURN_" {

            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "BURN"
            $count_fail += 1
            break
        }
        "^FAIL.*_FT1_" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "FT1"
            $count_fail += 1
            break
        }
        "^FAIL.*_FT2_" {

            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "FT2"
            $count_fail += 1
            break
        }
        "^FAIL.*_FT3_" {

            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "FT3"
            $count_fail += 1
            break
        }
        "^FAIL.*_FT4_" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "FT4"
            $count_fail += 1
            break
        }
        "^FAIL.*_FT5_" {

            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "FT5"
            $count_fail += 1
            break
        }
        "^FAIL.*_FT6_" {
            join_and_move_fail -log_dir $final_LOG_FOLDER -file_name $_ -state "FT6"
            $count_fail += 1
            break
        }
    }
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


# =================== Gom file 600I vào folder riêng ======================
foreach ($tram in $cac_tram_test) {
    $folderPath_P = Join-Path $passFolder $tram
    if (Test-Path $folderPath_P) {
        $files600I = Get-ChildItem -Path $folderPath_P -File -Filter "*_600I_*" -ErrorAction SilentlyContinue
        if ($files600I -and $files600I.Count -gt 0) {
            
            $newFolder = Join-Path $folderPath_P "600I_Files"
            New-Item -Path $newFolder -ItemType Directory -Force | Out-Null
            foreach ($f in $files600I) {
                try {
                    Move-Item -Path $f.FullName -Destination $newFolder -Force
                }
                catch {
                    Write-Host "Error moving file $($f.FullName) to $newFolder" -ForegroundColor Red
                }
            }
            Write-Host "Moved $($files600I.Count) file 600I  $tram to 600I_Files folder " -ForegroundColor Green
        }
    }
}
# =================== Gom file khác loại (.log/.txt) vào folder riêng ======================
foreach ($tram in $cac_tram_test) {
    $folderPath_P = Join-Path $passFolder $tram
    if (Test-Path $folderPath_P) {
        $otherFiles = Get-ChildItem -Path $folderPath_P -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -notin @(".log", ".txt") }
        if ($otherFiles -and $otherFiles.Count -gt 0) {

            $newFolder = Join-Path $folderPath_P "Other_Files"
            New-Item -Path $newFolder -ItemType Directory -Force | Out-Null
            foreach ($f in $otherFiles) {
                try {
                    Move-Item -Path $f.FullName -Destination $newFolder -Force
                }
                catch {
                    Write-Host "Error moving file $($f.FullName) to $newFolder" -ForegroundColor Red
                }
            }
            Write-Host "Move $($otherFiles.Count) file(png,wav) $tram folder Other_Files" -ForegroundColor Green
        }
    }
}

#================= Folder chứa file sai version ===================
$wrongVersionFolder = Join-Path $parent_of_log "WRONG_VERSION"
New-Item -Path $wrongVersionFolder -ItemType Directory -Force | Out-Null

#================= Kiểm tra FTU/FCD trong PASS ===================
foreach ($tram in $cac_tram_test) {
    $folderPath_P = Join-Path $passFolder $tram
    if (Test-Path $folderPath_P) {
        $logFiles = Get-ChildItem -Path $folderPath_P -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.Extension -in @(".log", ".txt") }

        foreach ($f in $logFiles) {
            $isCorrect = $true

            if ($tram -eq "DL") {
                # Chỉ check FCD
                $isCorrect = is_FCD_correct -path $f.FullName -fcd $FCD
            }
            else {
                # Các trạm khác chỉ check FTU
                $isCorrect = is_FTU_correct -path $f.FullName -ftu $FTU
            }

            if (-not $isCorrect) {
                try {
                    Move-Item -Path $f.FullName -Destination $wrongVersionFolder -Force
                    Write-Host "Moved wrong version file $($f.Name) from $tram to WRONG_VERSION" -ForegroundColor Magenta
                }
                catch {
                    Write-Host "Error moving file $($f.FullName)" -ForegroundColor Red
                }
            }
        }
    }
}



#================= Folder chứa file trùng MAC ===================
$duplicateMacFolder = Join-Path $parent_of_log "DUPLICATE_MAC"
New-Item -Path $duplicateMacFolder -ItemType Directory -Force | Out-Null

function remove_duplicate_mac {
    param (
        [string]$tramFolder
    )

    if (-not (Test-Path $tramFolder)) { return }

    # Lấy tất cả file log/txt trong trạm
    $logFiles = Get-ChildItem -Path $tramFolder -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Extension -in @(".log", ".txt") }

    # Nhóm theo MAC (regex: PASS_([0-9A-F]{12})_)
    $groups = $logFiles | Group-Object {
        if ($_.Name -match "PASS_([0-9A-F]{12})_") {
            $matches[1]
        } else {
            "NO_MAC"
        }
    }

    foreach ($g in $groups) {
        if ($g.Count -gt 1 -and $g.Name -ne "NO_MAC") {
            # Sắp xếp theo timestamp trong tên file (ví dụ: 20251101055141)
            $sorted = $g.Group | Sort-Object {
                if ($_.Name -match "_(\d{14})_") {
                    [int64]$matches[1]
                } else {
                    0
                }
            } -Descending

            # Giữ file mới nhất, move các file cũ hơn
            $keep = $sorted[0]
            $duplicates = $sorted | Select-Object -Skip 1

            foreach ($dup in $duplicates) {
                try {
                    Move-Item -Path $dup.FullName -Destination $duplicateMacFolder -Force
                    Write-Host "Moved duplicate MAC file $($dup.Name) (tram $tramFolder)" -ForegroundColor Yellow
                }
                catch {
                    Write-Host "Error moving duplicate file $($dup.FullName)" -ForegroundColor Red
                }
            }
        }
    }
}

#================= Áp dụng cho tất cả trạm PASS ===================
foreach ($tram in $cac_tram_test) {
    $folderPath_P = Join-Path $passFolder $tram
    remove_duplicate_mac -tramFolder $folderPath_P
}



# =================== Đếm số file log/txt trong từng trạm ======================
foreach ($tram in $cac_tram_test) {
    $folderPath_P = Join-Path $passFolder $tram
    if (Test-Path $folderPath_P) {

    $logFiles = Get-ChildItem -Path $folderPath_P -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -in @(".log", ".txt") }
    # Ensure $logFiles is treated as an array so .Count works for $null, single item, or multiple items
    $countLogs = @($logFiles).Count

        Write-Host "Tram $tram : $countLogs file log/txt" -ForegroundColor Cyan
    }
}
Write-Host "`n"

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

# =================== FIX NUỐT LOG CUỐI ======================
[System.Console]::Out.Flush()
Start-Sleep -Milliseconds 300
