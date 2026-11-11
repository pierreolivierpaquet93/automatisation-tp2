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
	prompts	= @{
		select	= "Selection: "
		confirm	= "Veuillez confirmer votre choix: "
		quit	= "Au revoir!"
	}
}

function Show-Menu() {
	param(
		[Parameter(Mandatory=$true)]
		[string[]]$options
	)
	Clear-Host
	Write-Host "+=============================================================="
	Write-Host "| " $menu.frame.header.ToUpper()
	Write-Host "+=============================================================="
	Write-Host "| " $menu.frame.directions
	Write-Host "+--------------------------------------------------------------"
	$n_options = $options.Count
	for ($i = 0; $i -lt $n_options; $i++) {
		Write-Host "| [$($i + 1)]`tDisque $(${options}[$i])"
	}
	return
}

function Afficher-EspaceDisque() {
	$logical_disks = (Get-CimInstance -ClassName "$script:disk_classname")
	$options = [string[]]($logical_disks | Select-Object -Property DeviceID).DeviceID
	Show-Menu -options $options
	return
}

function main() {
	Afficher-EspaceDisque
	return
}

main
