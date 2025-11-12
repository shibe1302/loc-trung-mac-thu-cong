# --------------------------------- LƯU Ý ------------------------------------------------------------
# để lấy đường dẫn file zip thì vào folder chứa file zip mở CMD kéo thẳng file vào CMD sẽ hiện đường dẫn đầy đủ của file zip
# để lấy đường dẫn folder thì sau khi giải nén xong thì mở folder vừa giải nén và copy đường dẫn

# --------------------------------- LƯU Ý ------------------------------------------------------------
# Cấu trúc folder log (đã giải nén hoặc trong file zip) phải đúng như sau: FolderABC/log/file_log1.log
# Đủ 3 cấp FolderABC/log/file_log.log

$variable = "C:\Users\shibe\Desktop\test_cp\UXGFIBERT01_86pcs_2643011691_log_1\UXGFIBERT01_86pcs_2643011691_log"  # Thay đổi đường dẫn file zip hoặc folder log ở đây
if (Test-Path $variable -PathType Container) {
    & .\log_no_zip.ps1 -LOG_DIR $variable -FCD "" -FTU ""
}
elseif (Test-Path $variable -PathType Leaf) {
    & .\log_zip.ps1 -zipFile $variable -FCD "" -FTU ""
}else {
    Write-Host "Path khong ton tai. Vui long kiem tra lai!" -ForegroundColor Red
    exit
}


