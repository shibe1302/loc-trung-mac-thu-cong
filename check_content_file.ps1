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

$all_path_log = Get-ChildItem -Path "C:\Users\shibe\Desktop\test_cp\UXGFIBERT01_86pcs_2643011691_log_1\UXGFIBERT01_86pcs_2643011691_log\log" -Recurse -File -Include *.log, *.txt | Select-Object -ExpandProperty FullName
$all_path_log | Out-File -FilePath "C:\Users\shibe\Desktop\ps_learn\log_file_list.txt"
Write-Host "Found: $($all_path_log.Count)" -ForegroundColor Green
#     FTU_a6aa_1.0.22_4.1.7_UXG-Fiber
$FTU="FTU_a6aa_1.0.26_4.1.7_UXG-Fiber"
foreach ($log_file in $all_path_log) {
    if (-not (is_FTU_correct -path $log_file -ftu $FTU)) {
        Write-Host "File $([System.IO.Path]::GetFileName($log_file)) sai FTU, di chuyen den folder SAI_FTU" -ForegroundColor Cyan
    }
}



