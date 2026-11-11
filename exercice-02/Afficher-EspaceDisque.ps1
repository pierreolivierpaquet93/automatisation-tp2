<#
	Réalisez une fonction qui permettra d’afficher l’espace disque disponible
		d’un lecteur. 

	À l’exécution sur votre machine virtuelle, la fonction affiche un menu
		interactif permettant de choisir le disque parmi une liste des disques
		disponibles.
#>

$script:disk_classname = [string]'CIM_LogicalDisk'
$script:menu	= [PSCustomObject]@{
	frame		= [PSCustomObject]@{
		header		= "Espace disque disponible"
		footer		= "Exercice 2 - Fonction PowerShell"
		directions	= "Veuillez selectionner un disque"
	}
	options	= [PSCustomObject]@{
		quit	= "Quitter"
	}
	prompts	= [PSCustomObject]@{
		select	= "Selection"
		confirm	= "Veuillez confirmer votre choix"
		quit	= "Au revoir!"
	}
	state = [PSCustomObject]@{
		display	= $true
	}
}

function Show-Menu() {
	param(
		[Parameter(Mandatory=$true)]
		[string[]]$options
	)
	Clear-Host
	Write-Host "+--------------------------------------------------------------"
	Write-Host "| " $menu.frame.header.ToUpper()
	Write-Host "| " $menu.frame.directions
	Write-Host "+--------------------------------------------------------------"
	$n_options = $options.Count
	for ($i = 0; $i -lt $n_options; $i++) {
		Write-Host "| [$($i + 1)]`t$(${options}[$i])"
	}
	Write-Host "+--------------------------------------------------------------"
	$user_input = Read-Host "| $(${menu}.prompts.select)"
	$i = 0
	if ( [int]::TryParse( $user_input, [ref]$i ) -ne $true ) {
		return ''
	}
	return $options[([int]$user_input - 1)]
}

function Quit-Menu() {
	Clear-Host
	Write-Host $script:menu.prompts.quit
	Start-Sleep 2
	Clear-Host
	$script:menu.state.display = $false
	exit( 0 )
}

function Error-Menu() {
	param(
		[Parameter(Mandatory=$true)]
		[string]$msg
	)
	Clear-Host
	Write-Host "erreur: ${msg}."
	pause
	Clear-Host
}

function Afficher-EspaceDisque() {
	$logical_disks = (Get-CimInstance -ClassName "$script:disk_classname")
	$options = [string[]]( $logical_disks | Where-Object { $_.DeviceID -ne '' } ).DeviceID
	$options += $script:menu.options.quit
	$selection = ''
	while ( $script:menu.state.display -eq $true ) {
		$logical_disks = (Get-CimInstance -ClassName "$script:disk_classname")
		$selection = Show-Menu -options $options
		if ( $selection -eq $script:menu.options.quit ) {
			Quit-Menu
		} elseif ( $selection -eq '' ) {
			Error-Menu -msg "veuillez saisir un nombre (index)"
			continue
		}
		$selected_disk = $logical_disks | Where-Object { $_.DeviceID -match $selection }
		$disk_size = [Math]::Round( $selected_disk.Size/[Math]::Pow(1024, 3), 2 )
		$disk_free = [Math]::Round( $selected_disk.FreeSpace/[Math]::Pow(1024, 3), 2 )
		Clear-Host
		Write-Host "Disque $($selected_disk.DeviceID) - Taille: ${disk_size} Go (Libre: ${disk_free} Go)"
		$selection = ''
		pause
	}
	return Clear-Host
}

function main() {
	Afficher-EspaceDisque
	return
}

main
