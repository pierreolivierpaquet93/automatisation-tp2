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
	- https://stackoverflow.com/questions/69868053/how-can-i-get-the-number-of-cpu-cores-in-powershell
	- https://www.tutorialpedia.org/blog/windows-11-how-to-check-graphics-card-in-1-minute/#query-the-graphics-card-with-powershell
#>

function Section-Title {
	param(
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

	return $section
}

function Section-Processor {
	$title				= Section-Title		-title		'PROCESSEUR'
	$cpu				= Get-CimInstance	-ClassName	Win32_Processor
	$cpu_name			= $cpu[0].Name
	$n_core				= $cpu.NumberOfCores # Returns the number of core for each CPU
	$cpu_manufacturer	= $cpu[0].Manufacturer
	$total_core			= ($n_core | Measure-Object -Sum).sum

	$section = $title
	$section += "Nom du processeur: $cpu_name`n"
	$section += "Manufacturier du processeur: ${cpu_manufacturer}`n"
	$section += "Nombre de coeurs du processeur: ${total_core}`n"

	return $section
}

function Section-Graphic {
	$title				= Section-Title		-title		'CARTE GRAPHIQUE'
	$video_controller	= Get-CimInstance	-ClassName	'Win32_VideoController'
	
	$section	= $title
	$section	+= "Nom de la carte: $($video_controller.Name)`n"
	$section	+= "Version des drivers: $($video_controller.DriverVersion)`n"

	return $section
}

function Section-Disk {
	$title		= Section-Title		-title		'DISQUE'
	$hard_disks	= Get-CimInstance	-ClassName	"Win32_DiskDrive"
	$section = $title
	$first	= $true
	foreach ($disk in $hard_disks) {
		if ( -not $first ) {
			$section += Section-Title -char '-' -width 50
		} else { $first = $false }
		$section	+= "Modele du disque: $($disk.model)`n"
		$size = [Math]::round($disk.size/[Math]::Pow(1024,3),2 )
		$section	+= "Taille en GB du disque: ${size}`n"
	}
	return $section
}

function Section-OS {
	$title	= Section-Title		-title		'OS'
	$os		= Get-CimInstance	-ClassName	'Win32_OperatingSystem'

	$section	= $title
	$section	+= "Systeme d'exploitation: $($os.Caption)`n"
	$section	+= "Version du systeme d'exploitation: $($os.Version)`n"
	$edition	= (Get-ComputerInfo).WindowsEditionId 
	$section	+= "Edition du systeme d'exploitation: $edition`n"

	return $section
}

function main {
	WRite-Host (Section-Motherboard)
	WRite-Host (Section-Processor)
	Write-Host (Section-Graphic)
	Write-Host (Section-Disk)
	Write-Host (Section-OS)
}

main
