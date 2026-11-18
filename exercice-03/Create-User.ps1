<#
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
#>

function Section-Title {
	param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$title,
		[string]$char	= '=',
		[int]$width		= 80
	)
	[string]$section = ""
	$title_offset = [int]($title.Length * 0.5)
	$half_width = [int]($width * 0.5)
	$lpad = [int]($width * 0.5) - [int]($title.Length * 0.5)
	#Write-Host "TITLE-LENGTH = $($title.Length)"
	#Write-Host "TITLE-OFFSET = $title_offset"
	#Write-Host "HALF-WIDTH = $half_width"
	#Write-Host "LEFT-PAD = $lpad"

	for ($i = 0; $i -lt $lpad; $i++) {
		$section += $char
	}
	$section += $title
	for ($i = $section.Length; $i -lt $width; $i++){
		$section += $char
	}
	Write-Host $section
}

function Create-User {
	Section-Title -title 'CARTE MERE'
}

function main {
	Create-User
}

main
