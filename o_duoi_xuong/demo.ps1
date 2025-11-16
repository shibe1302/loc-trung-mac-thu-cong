
$pt="C:\Users\shibe\Desktop\ps_learn\o_duoi_xuong\LOG\USWPM48PT01_109pcs_2643013075_log\PASS\PT\PASS_58D61F507773_USWPM48PT01_PT_USWPM48PT01_20251031-135609_.txt"
$ft4="C:\Users\shibe\Desktop\ps_learn\o_duoi_xuong\LOG\USWPM48PT01_109pcs_2643013075_log\PASS\FT4\PASS_58D61F507767_USWPM48PT01_FT4_USWPM48FT401_20251103085742_2643013075.log"
function is_FTU_correct {
    param (
        [string]$path,
        [string]$ftu
    )
    $content = Get-Content -Path $path -Raw
    $pattern = "FTU version *: *(FTU_.*)"

    if ($content -match $pattern) {
        $ftu_in_file = $matches[1].Trim()
        if ($ftu_in_file -eq $ftu) {
            return $true   # cùng phiên bản
        }
        else {
            return $false  # khác phiên bản
        }
    }
    else {
        return $true       # không tìm thấy pattern
    }
}

$a=is_FTU_correct -path $ft4 -ftu "FTU_USW_PROMAX-SERIES_1.0.3_7.0.50"
$a