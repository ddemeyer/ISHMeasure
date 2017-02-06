function Get-ISHMeasureVariable
{
<#
.SYNOPSIS
	Single-Sourced Get-Variable implementation allowing defaulting and fall back to happen.

.DESCRIPTION
	Get the Set-Variable or fall back to the default set by this cmdlet ps1 file.
	The matching Set-ISHMeasureVariable can be used to set stuff up front.

.EXAMPLE
	Get-ISHMeasureVariable -Name [ISHMeasureVariableEnum]::ISHMeasureIshSession
#>
[CmdletBinding()] 
param(
	[ISHMeasureVariableEnum]$Name
)
Process
{
	Write-Output (Get-Variable -Name ($Name)).Value
}
}
