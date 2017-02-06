Write-Debug ("MyCommand[" + $MyInvocation.MyCommand + "] loads default variables for ISHMeasure and ISHRemote usage...")

Add-Type -TypeDefinition @'
public enum ISHMeasureVariableEnum {
ISHMeasureIshSession,
ISHMeasureTimestamp,
ISHMeasureDitaTopicFileContent,
ISHMeasureDitaLibraryTopicFileContent,
ISHMeasureDitaMapFileContent,
ISHMeasureIshFolderTestRootPath,
ISHMeasureIshLanguageElement,
ISHMeasureIshLanguageCombination,
ISHMeasureIshResolutionElement,
ISHMeasureIshInitialStatusElement,
ISHMeasureIshUserAuthorElement,
ISHMeasureIshOutputFormatDitaXmlElement
}
'@

Set-Variable -Scope Global -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession) -Value "NotProperlyInitialized"
Set-Variable -Scope Global -Name ([ISHMeasureVariableEnum]::ISHMeasureTimestamp) -Value (Get-Date -Format "yyyyMMddHHmmss")
Set-Variable -Scope Global -Name ([ISHMeasureVariableEnum]::ISHMeasureDitaTopicFileContent) -Value @"
<?xml version="1.0" ?>
<!DOCTYPE topic PUBLIC "-//OASIS//DTD DITA Topic//EN" "topic.dtd">
<topic><title>Enter the title of your topic here.<?ish-replace-title?></title><shortdesc>Enter a short description of your topic here (optional).</shortdesc><body><p>This is the start of your topic.</p><ul><li>List item without condition</li><li ishcondition="ISHRemoteStringCond='StringOne'">ISHRemoteStringCond condition</li><li ishcondition="ISHRemoteVersionCond='12.0.1'">ISHRemoteVersionCond condition</li></ul><?ish-replace-beforeclosingbody?></body></topic>
"@
Set-Variable -Scope Global -Name ([ISHMeasureVariableEnum]::ISHMeasureDitaLibraryTopicFileContent) -Value @"
<?xml version="1.0" ?>
<!DOCTYPE topic PUBLIC "-//OASIS//DTD DITA Topic//EN" "topic.dtd">
<topic><title>Enter the title of your topic here.<?ish-replace-title?></title><shortdesc>Enter a short description of your topic here (optional).</shortdesc><body><p>This is the start of your topic.</p><ul><li>List item without condition</li><li ishcondition="ISHRemoteStringCond='StringOne'">ISHRemoteStringCond condition</li><li ishcondition="ISHRemoteVersionCond='12.0.1'">ISHRemoteVersionCond condition</li></ul><?ish-replace-beforeclosingbody?></body></topic>
"@
Set-Variable -Scope Global -Name ([ISHMeasureVariableEnum]::ISHMeasureDitaMapFileContent) -Value @"
<?xml version="1.0" ?>
<!DOCTYPE map PUBLIC "-//OASIS//DTD DITA Map//EN" "map.dtd">
<map><title>Enter the title of your map here.<?ish-replace-title?></title><?ish-replace-beforeclosingmap?></map>
"@
Set-Variable -Scope Global -Name ([ISHMeasureVariableEnum]::ISHMeasureIshFolderTestRootPath) -Value '\General\__ISHMeasure'  # requires leading FolderPathSeparator for tests to succeed
Set-Variable -Scope Global -Name ([ISHMeasureVariableEnum]::ISHMeasureIshLanguageElement) -Value 'VLANGUAGEEN'
Set-Variable -Scope Global -Name ([ISHMeasureVariableEnum]::ISHMeasureIshLanguageCombination) -Value 'en' # LanguageCombination like 'en+fr+nl' can only be expressed with labels
Set-Variable -Scope Global -Name ([ISHMeasureVariableEnum]::ISHMeasureIshResolutionElement) -Value 'VRESLOW'
Set-Variable -Scope Global -Name ([ISHMeasureVariableEnum]::ISHMeasureIshInitialStatusElement) -Value 'VSTATUSDRAFT'
Set-Variable -Scope Global -Name ([ISHMeasureVariableEnum]::ISHMeasureIshUserAuthorElement) -Value 'VUSERADMIN'
Set-Variable -Scope Global -Name ([ISHMeasureVariableEnum]::ISHMeasureIshOutputFormatDitaXmlElement) -Value 'GUID-079A324-FE52-45C4-82CD-A1A9663C2777'  # 'DITA XML' element name


foreach ($item in [enum]::GetNames([ISHMeasureVariableEnum]))
{
    Write-Debug ("MyCommand[" + $MyInvocation.MyCommand + "] Name[" + $item + "] Value[" + (Get-Variable -Scope Global -Name ($item)).Value + "]")
}
