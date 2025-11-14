param (
    [string]$folder_path,
    [string]$path_chua_tram_test
)

$file = Get-ChildItem -Path $folder_path -Recurse -File -Filter "data.txt" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($file) {
    Write-Host "Da tim thay file MAC : $($file.FullName)" -ForegroundColor Green
}
else {
    Write-Host "Deo tim thay file MAC !" -ForegroundColor Red
}

$macDict = @{}

try {
    Get-Content $file.FullName | ForEach-Object {
        $mac = $_.Trim()
        if ($mac -ne "") {
            $macDict[$mac] = 0
        }
    }
}
catch {
    Write-Host "Loi khi doc file: $_" -ForegroundColor Red
}


Write-Host "So luong MAC : $($macDict.Count)" -ForegroundColor Green

function LayMacTuFileName {
    param (
        [string]$fileName
    )
    if ($fileName -match "PASS_([0-9A-F]{12})_") {
        $mac = $matches[1]
        Write-Host "MAC : [$mac]"
    }
    else {
        Write-Host "Khong tim thay Mac trong ten file."
    }
    
}
