<#
.NOTES
	- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_regular_expressions?view=powershell-7.6
	- https://lazyadmin.nl/powershell/create-local-user/
	- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-random?view=powershell-7.6
	- https://stackoverflow.com/questions/56930864/check-if-an-string-exists-in-a-list-of-strings-using-powershell
	- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.localaccounts/add-localgroupmember?view=powershell-5.1
	- https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-shouldprocess?view=powershell-7.6
#>

param(
	[string]$last_name	= 'paquet',
	[string]$first_name	= 'pierre',
	[string]$user_type	= 'Etudiant',
	[string]$code		= 'ABCD1234'
)

#-----------------------------------------------------------------[ VARIABLE.S ]

$script:main_directory	= 'C:\LeProgramme\'
$script:description		= "#automatisation-tp2"
$script:password_policy	= [PSCustomObject]@{
	min	= 10000000
	max	= 99999999
}
$script:max_len	= 25
[string[]]$script:user_types	= @(
	'Enseignant',
	'Etudiant',
	'Personnel'
)
[string[]]$script:programs = @(
	'Telecommunication',
	'Gestion',
	'Informatique'
)

#-----------------------------------------------------------------[ FUNCTION.S ]

function Existing-User {
	param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$username
	)
	$count = (
		Get-LocalUser | `
			Select-Object `
				-Property Name | Where-Object {
					$_.Name -match "^$username[0-9]*$"
				} | `
			Measure-Object
	).Count
	if ( $count -eq 0 ) {
		return ''
	}
	return [string]$count
}

function Create-Username {
	param(
		[string]$last_name,
		[string]$first_name
	)
	$new_username		= "${last_name}.${first_name}"
	$new_username_regex	= "${last_name}\.${first_name}"
	$new_username += [string](Existing-User -username $new_username_regex)
	return $new_username
}

function Validate-Parameters {
	param(
		[string]$last_name,
		[string]$first_name,
		[string]$user_type
	)
	if ($script:user_types -notcontains $user_type) {
		Write-Error "${user_type} : invalid user type."
		return $false
	}
	if ($last_name.Length -gt $script:max_len) {
		Write-Error "${last_name} : too long."
		return $false
	}
	if ($first_name.Length -gt $script:max_len) {
		Write-Error "${first_name} : too long."
		return $false
	}
	return $true
}

function Create-UserDirectory {
	param(
		[Parameter(Mandatory=$true)]
		[string]$username
	)
	if ( (Test-Path -Path $script:main_directory) -eq $false ) {
		New-Item -ItemType Directory -Path $script:main_directory
	}
	$user_directory = Join-Path $script:main_directory -ChildPath $username
	if ( (Test-Path -Path $user_directory) -eq $false ) {
		New-Item -ItemType Directory -Path $user_directory
	}
	return
}

function Create-User {
	[CmdletBinding(SupportsShouldProcess=$true)]
	param(
		[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
		[string]$last_name,
		[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
		[string]$first_name,
		[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
		[string]$user_type,
		[ValidateNotNullOrEmpty()]
		[ValidatePattern('^[a-zA-Z]{4}[0-9]{4}$')]
		[string]$code
	)
	if (
		(Validate-Parameters `
			-last_name $last_name `
			-first_name $first_name `
			-user_type $user_type
		) -eq $false
	) {
		return
	}
	$username	= Create-Username -first_name $first_name -last_name $last_name
	if ($PSCmdlet.ShouldProcess($username, "Creation de l'utilisateur et ajout au groupe '${user_type}'") -eq $false) {
		return
	}
	Write-Debug "USERNAME=$username"
	$password	= ''
	if ($user_type -eq 'Etudiant') {
		Write-Debug "PW=$code"
		$password	= (ConvertTo-SecureString $code -AsPlainText -Force)
	} else {
		$rand = (
				Get-Random `
					-Minimum $script:password_policy.min `
					-Maximum $script:password_policy.max
		)
		Write-Debug "PW=$rand"
		$password	= `
			ConvertTo-SecureString `
			$rand `
			-AsPlainText `
			-Force
	}

	New-LocalUser `
		-Name			$username `
		-Password		$password `
		-Description	$script:description `
		-Confirm:$false

	Add-LocalGroupMember `
		-Group	$user_type `
		-Member	$username `
		-Confirm:$false

	Create-UserDirectory -username $username
	return
}

#-----------------------------------------------------------------------[ MAIN ]

function main {
	Create-User `
		-first_name	$first_name `
		-last_name	$last_name `
		-user_type	$user_type `
		-code		$code			-Confirm
}

main
