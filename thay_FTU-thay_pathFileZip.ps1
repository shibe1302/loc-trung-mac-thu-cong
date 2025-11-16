# --------------------------------- LƯU Ý ------------------------------------------------------------
# để lấy đường dẫn file zip thì vào folder chứa file zip mở CMD kéo thẳng file vào CMD sẽ hiện đường dẫn đầy đủ của file zip
# để lấy đường dẫn folder thì sau khi giải nén xong thì mở folder vừa giải nén và copy đường dẫn
# Nếu bị lỗi unauthorized access thì chạy lệnh này 'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser'





# link đến file zip hoặc link folder sau khi giải nén filezip(vào bên trong folder rồi copy link)
$FilePath= "C:\Users\shibe\Desktop\test_cp\USWPM48PT01-giet-tool.7z"
$FTU="FTU_USW_PROMAX-SERIES_1.0.3_7.0.50"
$FCD="FCD_USW_PROMAX-SERIES_1.0.2_7.0.50"
if (Test-Path $FilePath -PathType Container) {
    & .\log_no_zip.ps1 -LOG_DIR $FilePath -FCD $FCD -FTU $FTU
}
elseif (Test-Path $FilePath -PathType Leaf) {
    & .\log_zip.ps1 -zipFile $FilePath -FCD $FCD -FTU $FTU
}else {
    Write-Host "Path khong ton tai. Vui long kiem tra lai!" -ForegroundColor Red
    exit
}


