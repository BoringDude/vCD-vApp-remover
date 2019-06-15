Write-Host "`n######  vApp remover for vCloud Director  ######`n" -ForegroundColor Green
Write-Host "`n The script tested for vCloud director 8.x.`n" -ForegroundColor Green 
Write-Host "`n#### BEWARE OF DELETE LIVE VAPP!### `n" -ForegroundColor Red

$vcloudHost = Read-Host -Prompt "vCloud API endpoint URL"
$vcloudOrg = Read-Host -Prompt "Org name to login(default: system)"
$vcloudUser = Read-Host -Prompt "Username"
$pass = Read-Host -Prompt "Password" -AsSecureString
#Give a password from secure string
$vcloudPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))
if ($vcloudOrg -eq ""){
    $vcloudOrg = "System"
}
Write-Output  "`nConnecting to vCenter...`n"
try {
	Connect-CIServer -server "$vcloudHost" -Org $vcloudOrg -User "$vcloudUser" -Password "$vcloudPass"
}
catch{
	Write-Error "`nCannot connect to target vCloud server`n"
	Write-Output $Error
	exit
}

Write-Output "`nConnected!`n"

$targetOrg = Read-Host -Prompt "Specify an organization for search vApps"
while ($true){
$vAppList = Get-Org  -Name $targetOrg | Get-CIVApp

Write-Information  -MessageData "`nAvailable vApps: `n" -InformationAction  Continue

$info = @()
foreach($vApp in $vAppList)
{
	$res = "" | Select-Object Name,Id,Owner,Status
	$res.Name = $vApp.Name
	$res.Id = $vApp.Id
	$res.Owner = $vApp.Owner
	$res.Status = $vApp.Status
	$info +=$res
	
}
$info | Out-Host

$targetId = Read-Host -Prompt "Specify vApp ID to delete or Ctrl-C to exit"

$targetvApp = Get-CIVApp -Id $targetId

Write-Host "Following vApp has been selected to DELETE:`n" -ForegroundColor Yellow
$targetvApp | Out-String

$confirmed = Read-Host -Prompt 'Print "delete" to confirmation'
if ($confirmed -eq "delete")
{
	try {
		Remove-CIVApp -VApp $targetvApp
	}
	catch {
		Write-Host "`nvApp cannot be deleted!"
		exit
	}

	Write-Warning -Message "vAPP has been deleted!" -WarningAction  Continue
}
else {
	Write-Host "Confirmation fail, vApp will not be deleted!`n" -ForegroundColor Yellow
}
}

Disconnect-CIServer * -Confirm:$false
