<#
.SYNOPSIS
	Réalisez un script qui présentera à l’écran la configuration matérielle de
	la machine virtuelle sur laquelle il s’exécute (testez-le sur votre Windows
	Server 2025 ou vos Windows 11). Votre script doit extraire : 
		- Le modèle et le manufacturier de la carte mère ainsi que la version
			du BIOS. 
		- Le nom, le manufacturier et le nombre de cœurs du processeur. 
		- Le nom et la version des pilotes de la carte graphique. 
			- Trouvez une façon d’ignorer les cartes graphiques virtuel de
			Citrix si nécessaire. 
		- Le modèle du disque et sa taille en Go (afficher tous les disques). 
		- Le nom du Système d’exploitation, sa version et son édition. 
	
.NOTES
	- https://www.techtutsonline.com/get-motherboard-information-using-windows-powershell/#google_vignette
#>

function Section-Title {
	param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$title,
		[string]$char	= '=',
		[int]$width		= 80,
		[switch]$no_new_line
	)
	[string]$section = ""
	$lpad = [int]($width * 0.5) - [int]($title.Length * 0.5)
	for ($i = 0; $i -lt $lpad; $i++) {
		$section += $char
	}
	$section += $title
	for ($i = $section.Length; $i -lt $width; $i++){
		$section += $char
	}
	if (-not $no_new_line) {
		$section += "`n"
	}
	return $section
}

function Section-Motherboard {
	$title	= Section-Title		-title		'CARTE MERE'
	$board	= Get-CimInstance	-ClassName	'Win32_BaseBoard'
	$bios	= Get-CimInstance	-ClassName	'Win32_BIOS'
	
	$section	= $title
	$section	+= "Carte mere: $($board.product)`n"
	$section	+= "Manufacturier de la carte mere: $($board.manufacturer)`n"
	$section	+= "Version du bios: $($bios.Version)`n"
	Write-Host $section
}

function main {
	Section-Motherboard
}

main
