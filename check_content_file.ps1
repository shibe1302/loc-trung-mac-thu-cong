$a=Get-ChildItem -Path "C:\Users\shibe\Desktop\test_cp\UXGFIBERT01_86pcs_2643011691_log_1\UXGFIBERT01_86pcs_2643011691_log\log" -Include *.log, *.txt -Recurse -Exclude *_600I_*
write-Host $a.Count