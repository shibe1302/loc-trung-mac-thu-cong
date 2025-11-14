# --------------------------------- LƯU Ý ------------------------------------------------------------
# để lấy đường dẫn file zip thì vào folder chứa file zip mở CMD kéo thẳng file vào CMD sẽ hiện đường dẫn đầy đủ của file zip
# để lấy đường dẫn folder thì sau khi giải nén xong thì mở folder vừa giải nén và copy đường dẫn

# Nếu bị lỗi unauthorized access thì chạy lệnh này 'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser'

$variable = "C:\Users\shibe\Desktop\test_cp\UXGFIBERT01_86pcs_2643011691_log_1.7z"
#$variable = "C:\Users\shibe\Desktop\test_cp\UXGFIBERT01_86pcs_2643011691_log_1"
$FTU="FTU_a6aa_1.0.26_4.1.7_UXG-Fiber" 
if (Test-Path $variable -PathType Container) {
    & .\log_no_zip.ps1 -LOG_DIR $variable -FCD "" -FTU $FTU
}
elseif (Test-Path $variable -PathType Leaf) {
    & .\log_zip.ps1 -zipFile $variable -FCD "" -FTU ""
}else {
    Write-Host "Path khong ton tai. Vui long kiem tra lai!" -ForegroundColor Red
    exit
}


