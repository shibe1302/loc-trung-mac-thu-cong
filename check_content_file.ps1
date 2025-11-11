$filePath = "C:\Users\shibe\Desktop\test_cp\UXGFIBERT01_86pcs_2643011691_log\PASS\FT1\PASS_1C0B8B1EA6A0_UXGFIBERT01_FT1_UXGFIBEFT102_20250719083727_2643011691.log"
$keyword = "FTU_a6aa_1.0.22_4.1.7_UXG-Fiber"

if (Get-Content $filePath | Select-String -Pattern $keyword) {
    Write-Host "Dung FCD" -ForegroundColor Green
} else {
    Write-Host "Sai FCD" -ForegroundColor Red
}