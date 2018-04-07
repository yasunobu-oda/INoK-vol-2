# ---物理ドライブの容量を取得（監視用）---

# 変数宣言
[string]$sPath
[string]$sLogName
[string]$sLogFullpath
[string]$dispStr

# ログファイルの設定
$sPath = Split-Path $MyInvocation.MyCommand.Path -parent
$sLogName = (Get-Date -Format "yyyyMMdd") + ".log"
$sLogFullpath = "$sPath\Log\$sLogName"  # 文字列内の変数展開

# ログ出力用変数書き込み（タイトル行）
$dispStr = "`t使用領域(GB)`t空き領域(GB)`t最大容量(GB)`t使用率(%)`r`n"

# 文字数が8文字未満の場合タブ文字入れるスクリプトブロック
$tab = {param($s); if ($s.Length -lt 8) {"`t"} else {""} }

# Windowsシステム情報取得
$disks = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }

# ディスク容量取得
foreach ($disk in $disks)
{
	# 変数宣言 ＆ 初期化
    [double]$parcentUsedSize = 0
    [double]$parcentSize = 0
    [double]$percentFreeSpace = 0
    [string]$lineStr = ""
 
    # ドライブID
    $lineStr += $disk.DeviceID
 
    # 使用領域
    $usedSize = [long]$disk.Size - [long]$disk.FreeSpace
    $displayUsedSize = [System.Math]::Floor([double](($usedSize / 1GB)) * 10) / 10
 
    $parcentUsedSize = ("{0:N2}" -f $displayUsedSize)
    $wStr = ("{0:N2}" -f $displayUsedSize)
    $lineStr += "`t$wStr"
 
    # 空き領域
    $displayFreeSpace = [System.Math]::Floor([double](($disk.FreeSpace / 1GB)) * 10) / 10
 
	# スクリプトブロックを利用し必要に応じてタブを入れる
	$lineStr += & $tab $wStr

	$wStr = ("{0:N2}" -f $displayFreeSpace)
    $lineStr += "`t$wStr"
    
    # 容量
    $displaySize = [System.Math]::Floor([double](($disk.Size / 1GB)) * 10) / 10
 
    $parcentSize = ("{0:N2}" -f $displaySize)

	# スクリプトブロックを利用し必要に応じてタブを入れる
	$lineStr += & $tab $wStr

	$wStr = ("{0:N2}" -f $displaySize)
    $lineStr += "`t$wStr"
 
    # 使用割合
    $percentFreeSpace = $parcentUsedSize / $parcentSize * 100
 
	# スクリプトブロックを利用し必要に応じてタブを入れる
	$lineStr += & $tab $wStr

	$wStr = ("{0:N2}" -f $percentFreeSpace)
    $lineStr += "`t$wStr"

    # 閾値判断 80以上：△、90以上：！、95以上：×
    if ([double]$percentFreeSpace -ge 95.00)
    {
        $lineStr = "× $lineStr"
    }elseif([double]$percentFreeSpace -ge 90.00)
    {
        $lineStr = "！ $lineStr" 
    }elseif([double]$percentFreeSpace -ge 80.00)
    {
        $lineStr = "△ $lineStr" 
    }else
    {
        $lineStr = "　 $lineStr" 
    }

    $dispStr += "$lineStr`r`n"
}

# コンソール出力
#Write-Host $dispStr

# ログファイルに出力
Write-Output $dispStr | Out-File ${sLogFullpath} -Force -Encoding Default
