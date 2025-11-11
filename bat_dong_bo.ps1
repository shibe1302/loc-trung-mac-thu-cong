# Job 1
$job1 = Start-Job -ScriptBlock {
    for ($i = 1; $i -le 5; $i++) {
        Write-Host "Job 1: $i" -ForegroundColor Green
        Start-Sleep -Seconds 1
    }
}

# Job 2
$job2 = Start-Job -ScriptBlock {
    for ($j = 1; $j -le 5; $j++) {
        Write-Host "Job 2: $j" -ForegroundColor Red
        Start-Sleep -Seconds 1
    }
}

# Chờ cả 2 job hoàn thành
Wait-Job $job1, $job2

# Lấy output
Receive-Job $job1
Receive-Job $job2

# Xoá job
Remove-Job $job1, $job2
