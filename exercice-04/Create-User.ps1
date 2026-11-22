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
	[string]$code,
	[string]$program	= ''
)

#-----------------------------------------------------------------[ VARIABLE.S ]

$script:main_directory	= 'C:\programmes'
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

# This function assumes that no user is being deleted.
# It also assumes that the provided 'username' is regex ready/safe:
#	ex: 'user.name' --> 'user\.name'
# Returns the amount of user(s) that have the same name.
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
		[string]$user_type,
		[string]$code,
		[string]$program
	)
	if ($script:user_types -notcontains $user_type) {
		Write-Error "${user_type} : invalid user type."
		return $false
	}
	if (
		$script:programs -notcontains $program -and `
		$program -ne ''
	){
		Write-Error "${program}: invalid program."
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
	if (
		$user_type -eq 'Etudiant' -and `
		$code -notmatch '^[a-zA-Z]{4}[0-9]{4}$'
	){
		Write-Error "'Etudiant' user needs a valid code for the account password."
		return $false
	}
	return $true
}

function Create-UserDirectory {
	[CmdletBinding(SupportsShouldProcess=$true)]
	param(
		[Parameter(Mandatory=$true)]
		[string]$username,
		[string]$program
	)
	if ( (Test-Path -Path $script:main_directory) -eq $false ) {
		$output = New-Item -ItemType Directory -Path $script:main_directory
	}
	if ($program -eq '') {
		$program = 'misc'
	}
	$child_path = Join-Path $program -ChildPath $username
	$user_directory = Join-Path $script:main_directory -ChildPath $child_path
	if ( (Test-Path -Path $user_directory) -eq $false ) {
		$output = New-Item -ItemType Directory -Path $user_directory
		Write-Debug "Created '${user_directory}'."
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
		[string]$code,
		[string]$program
	)
	if (
		(Validate-Parameters `
			-last_name	$last_name `
			-first_name	$first_name `
			-user_type	$user_type `
			-code		$code `
			-program	$program
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
		Write-Host "Etudiant: Pas besoin de modifier votre mot de passe lors de la premiere connexion."
		$password	= (ConvertTo-SecureString $code -AsPlainText -Force)
	} else {
		Write-Host "${username}: Veuillez modifier votre mot de passe lors de la premiere connexion."
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

	$output = New-LocalUser `
		-Name			$username `
		-Password		$password `
		-Description	$script:description `
		-Confirm:$false
	Write-Debug "Create new user: '${username}'."

	$output = Add-LocalGroupMember `
		-Group	$user_type `
		-Member	$username `
		-Confirm:$false
	Write-Debug "Added '${username}' to '${user_type}' group."

	Create-UserDirectory `
		-program	$program `
		-username	$username `
		-Confirm:$false
	return
}

#-----------------------------------------------------------------------[ MAIN ]

function main {
	Create-User `
		-first_name	$first_name `
		-last_name	$last_name `
		-user_type	$user_type `
		-program	$program `
		-code		$code			-Confirm
}

main
