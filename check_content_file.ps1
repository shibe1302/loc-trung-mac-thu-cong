#================= Kiem tra FTU ========================
function is_FTU_correct {
    param (
        [string]$path,
        [string]$ftu
    )
    $content = Get-Content -Path $path -Raw
    $pattern = "FTU version *: *(FTU_.*)"
    if ($content -match $pattern) {
        $ftu_in_file = $matches[1].Trim() 
        return $ftu_in_file -eq $ftu
    }
    else {
        Write-Output "No match found" ForegroundColor Orange
        return $false
    }
    return $false
    
}

function check_ftu_in_folder {
    param (
        [string]$path,
        [string]$ftu
    )
    
    
}


$path_test_fun="C:\Users\shibe\Desktop\test_cp\UXGFIBERT01_86pcs_2643011691_log_1\UXGFIBERT01_86pcs_2643011691_log\PASS\FT2\PASS_1C0B8B1EA6B8_UXGFIBERT01_FT2_UXGFIBEFT201_20250719095407_2643011691.log"
is_FTU_correct -path $path_test_fun -ftu "FTU_a6aa_1.0.26_4.1.7_UXG-Fiber" #FTU_a6aa_1.0.26_4.1.7_UXG-Fiber

