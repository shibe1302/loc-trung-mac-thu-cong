# Đường dẫn gốc
$basePath = "C:\Users\shibe\Desktop\test_cp\UXGFIBERT01_86pcs_2643011691_log\PASS"

$dataFile = "C:\Users\shibe\Desktop\test_cp\UXGFIBERT01_86pcs_2643011691_log\data.txt"
$macDict = @{}
try {
    Get-Content -Path $dataFile | ForEach-Object {
        $mac = $_.Trim()
        if ($mac -ne "") {
            $macDict[$mac] = 0
        }
    }
}
catch {
    Write-Host "Loi khi doc file: $_" -ForegroundColor Red
}

# (Note: duplicates folder will be created per sub-folder inside the loop)


function Get-MacFromFileName {
    param ([string]$fileName)
    if ($fileName -match "PASS_([0-9A-F]{12})_") {
        return $matches[1]
    }
    return $null
}


Get-ChildItem -Path $basePath -Directory | ForEach-Object {
    $subFolder = $_.FullName
    Write-Host "`nDang xu ly thu muc: $subFolder"

    # Reset giá trị dict về 0 trước khi xử lý mỗi folder
    foreach ($k in $macDict.Keys) { $macDict[$k] = 0 }

    # Thư mục chứa file trùng (backup) cho mỗi subFolder
    $duplicatesFolder = Join-Path $subFolder 'duplicates'

    # Lấy danh sách file .txt hoặc .log (không dùng -Recurse):
    # -Include chỉ hoạt động khi Path chứa wildcard, nên thêm '*'.
    $files = Get-ChildItem -Path (Join-Path $subFolder '*') -File -Include *.txt, *.log

    foreach ($file in $files) {
        $mac = Get-MacFromFileName -fileName $file.Name
        if ($mac -and $macDict.ContainsKey($mac)) {
            if ($macDict[$mac] -eq 0) {
                # MAC chưa có log → gán đường dẫn
                $macDict[$mac] = $file.FullName
            } else {
                # MAC đã có log → xóa file cũ, gán file mới
                $oldPath = $macDict[$mac]
                if (Test-Path $oldPath) {
                    # Tạo folder duplicates nếu chưa có
                    if (-not (Test-Path $duplicatesFolder)) {
                        New-Item -ItemType Directory -Path $duplicatesFolder | Out-Null
                    }
                    $dest = Join-Path $duplicatesFolder (Split-Path $oldPath -Leaf)
                    # Di chuyển file cũ vào folder duplicates thay vì xoa
                    Move-Item -Path $oldPath -Destination $dest -Force
                    Write-Host "Da di chuyen file trung sang: $dest"
                }
                # Luu file hien tai (moi) vao dict
                $macDict[$mac] = $file.FullName
            }
        }
    }
}

# Kiểm tra MAC nào vẫn chưa có log
# Đảm bảo $missing là mảng để dùng .Count an toàn
$missing = @($macDict.GetEnumerator() | Where-Object { $_.Value -eq 0 })
if ($missing.Count -gt 0) {
    Write-Host "`n Thieu file LOG cho cac MAC sau:"
    foreach ($entry in $missing) {
        Write-Host " - $($entry.Key)"
    }
} else {
    Write-Host "`n Tat ca MAC da co file log day du."
}
