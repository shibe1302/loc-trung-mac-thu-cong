# --------------------------------- LƯU Ý ------------------------------------------------------------
# để lấy đường dẫn file zip thì vào folder chứa file zip mở CMD và gõ lệnh     dir /b /s   sau đó copy đường dẫn file zip
# để lấy đường dẫn folder thì sau khi giải nén xong thì mở folder vừa giải nén và copy đường dẫn
# https://pastecode.io/s/4u8jjgcj
# https://pastecode.io/s/3q2pbduu
$variable = Read-Host "Nhap link file zip hoac folder sau khi giai nen " 
if (Test-Path $variable -PathType Container) {
    & .\log_no_zip.ps1 -LOG_DIR $variable -FCD "" -FTU ""
}
elseif (Test-Path $variable -PathType Leaf) {
    & .\log_zip.ps1 -zipFile $variable -FCD "" -FTU ""
}else {
    Write-Host "Path khong ton tai. Vui long kiem tra lai!" -ForegroundColor Red
    exit
}

