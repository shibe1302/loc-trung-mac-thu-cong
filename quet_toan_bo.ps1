
$all_path_log = Get-ChildItem -Path "C:\Users\shibe\Desktop\test_cp\UXGFIBERT01_86pcs_2643011691_log_1\UXGFIBERT01_86pcs_2643011691_log\log" -Recurse -File -Include *.log, *.txt | Select-Object -ExpandProperty FullName


$all_path_log | Out-File -FilePath "C:\Users\shibe\Desktop\ps_learn\log_file_list.txt"

Write-Host "Found: $($all_path_log.Count)" -ForegroundColor Green