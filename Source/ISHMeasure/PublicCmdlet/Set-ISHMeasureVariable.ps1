function Set-ISHMeasureVariable
{
<#
.SYNOPSIS
	Single-Sourced Set-Variable implementation allowing defaulting and fall back to happen.

.DESCRIPTION
	Single-Sourced Set-Variable implementation allowing defaulting and fall back to happen.
	
	Some variable are initialized to "NotInitialized", for example you'll have 
	to set ISHSession explictly to avoid the ISHMeasure module to implement
	various kinds of authentication. It also allows upfront overwriting of 
	required metadata, so the module can be run on different field setups if 
	required because of mandatory fields or plugin configurations.

.EXAMPLE
	Set-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession) -Value (New-IshSession -WsBaseUrl 'https://example.com/ISHWS/' -IshUserName 'admin' -IshPassword 'admin')
	Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession)
#>
[CmdletBinding()] 
param(
	[ValidateNotNullOrEmpty()]
	[ISHMeasureVariableEnum]$Name,
	$Value
)
Process
{
	Set-Variable -Scope Global -Name $Name -Value $Value
}
}