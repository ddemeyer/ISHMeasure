Function Invoke-ISHMeasure {
<#
.SYNOPSIS
	Runs the chosen ISHMeasure set on the chosen environment.

.DESCRIPTION
	ISHMeasure is an ISHRemote based benchmarking tool kit. It relies mostly on simple data sets, and focusses on measuring network and simple web/app API write operations.
	
	The ISHMeasure cmdlets stored in a specific folder are versioned (ending digit), this way we don't have to trace the parameters they were called with in the TestSet results. By defaulting the a lot of the variables via 'EnumISHMeasureVariable.ps1', we simplify setup. Do note that two variables are required.
			
	Set-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession) -Value (New-IshSession -WsBaseUrl 'https://example.com/ISHWS/' -IshUserName 'admin' -IshPassword 'admin') should hold a valid IshSession object.
	
	The system targetted throug IshSession, should have a manually created measure root folder. By default we expect "\General\__ISHMeasure" but this can be overwritten by 
	Set-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshFolderTestRootPath) -Value '\General\Benchmarking'
	To create it: Add-IshFolder -IshSession $ishSession -FolderName "__ISHMeasure" -FolderType ISHNone -ParentFolderId (Get-IshFolder -IshSession $ishSession -BaseFolder Data).IshFolderRef
	
	Option -MeasureName array explicitly allows you to run tests, while -MeasureType allows 'all' or 'readonly' to get you going.

.PARAMETER TestDescription
	Mandatory parameter where you should describe what you are trying to get out of the test. Suggestions are client and source descriptions, hardware changes, network changes, etc

.PARAMETER MeasureName
	An array containing PS1 script names stored in MeasureCmdlet subfolder of ISHMeasure. These scripts are versioned and should be kept as constant as possible. Any change inside the script should result in the ending version number to be raised, to still allow apples to apples comparison.
	
.PARAMETER MeasureType
	Quick alternative of MeasureName that runs all scripts or the ReadOnly ones only, to quickly get you going.

.PARAMETER Count
	By default all MeasureName entries are triggered 3 times. This allows easy validation of calculated statistics min/median/max of the raw data.
	
.PARAMETER CsvFilePath
	Full file path that will be altered from ".CSV" to "-Loop$Count.CSV". Simply because the Export-Csv complains when appending records with different column dimensions.
	
.PARAMETER SleepBetweenCount
	If you would run these a lot, you might want to have some downtime in between test runs.

.EXAMPLE
	Provides a valid ISHRemote IshSession. Triggers all available 'MeasureCmdlet' tests available and export them to a CSV file.

	Set-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession) -Value (New-IshSession -WsBaseUrl 'https://example.com/ISHWS/' -IshUserName 'admin' -IshPassword 'admin')
	Invoke-ISHMeasure -TestDescription "All localhost testing" -MeasureType 'All' -CsvFilePath "C:\temp\ISHMeasure.csv"
	
.EXAMPLE
	Provides a valid ISHRemote IshSession. Triggers all available 'MeasureCmdlet' tests available and export them to the PowerShell ISE GridView.
	
	Set-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession) -Value (New-IshSession -WsBaseUrl 'https://example.com/ISHWS/' -IshUserName 'admin' -IshPassword 'admin')
	Invoke-ISHMeasure -TestDescription "All localhost read testing" -MeasureName @("Test-ISHMeasureTestConnection1xReadOnly","Test-ISHMeasure500msSleep1xReadOnly","Get-ISHMeasureGetIshTimeZone1xReadOnly") | Out-GridView

.EXAMPLE
	Provides a valid ISHRemote IshSession. Triggers all ReadOnly available 'MeasureCmdlet' tests available and export them to the PowerShell ISE GridView.
	
	Set-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession) -Value (New-IshSession -WsBaseUrl 'https://example.com/ISHWS/' -IshUserName 'admin' -IshPassword 'admin')
	Invoke-ISHMeasure -TestDescription "All localhost ReadOnly testing" -MeasureType 'ReadOnly' -CsvFilePath "C:\temp\ISHMeasure.csv"

.EXAMPLE
	Provides a valid ISHRemote IshSession. These calls do add and later remove data on your repository, the -Count makes sure we have 10 raw data entries in the result.

	Set-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession) -Value (New-IshSession -WsBaseUrl 'https://example.com/ISHWS/' -IshUserName 'admin' -IshPassword 'admin')
	Invoke-ISHMeasure -TestDescription "All localhost write testing" -MeasureName @("Add-ISHMeasure0010Images1") -Count 10 -CsvFilePath "C:\temp\ISHMeasure.csv"

.NOTE
	Parameter -CsvFilePath will by default append, so the number of columns/properties in the CSV file need to match. So in practice, make sure you run all tests with the same -Count parameter, resulting in the same amount of Raw-columns. The incoming -CsvFilePath will be adapted, so ISHMeasure.csv becomes ISHMeasure-Loop3.csv where 3 matches the incoming $Count.
	
	TODO Perhaps have -Callback switch with -CallbackUrl which posts the TestSet results to a url. This allows aggregating later and perhaps some nice anonyomus statistics. Hat tip to  http://www.aspsnippets.com/Articles/Import-Upload-CSV-file-data-to-SQL-Server-database-in-ASPNet-using-C-and-VBNet.aspx and http://joe-pruitt.sys-con.com/node/1006737/mobile
#>
[cmdletbinding()]
param(
	[Parameter(Mandatory=$True,ParameterSetName='Name')]
	[Parameter(Mandatory=$True,ParameterSetName='Type')]
	$TestDescription,
	[Parameter(Mandatory=$True,ParameterSetName='Name')]
	$MeasureName,
	[Parameter(Mandatory=$True,ParameterSetName='Type')][ValidateSet('All','ReadOnly')]
	$MeasureType,
	[Parameter(Mandatory=$False,ParameterSetName='Name')]
	[Parameter(Mandatory=$False,ParameterSetName='Type')]
	$Count = 3,
	[Parameter(Mandatory=$False,ParameterSetName='Name')]
	[Parameter(Mandatory=$False,ParameterSetName='Type')]
	$CsvFilePath,
	[Parameter(Mandatory=$False,ParameterSetName='Name')]
	[Parameter(Mandatory=$False,ParameterSetName='Type')]
	$SleepBetweenCount = 0 # ms
	#TODO# Perhaps have -Callback switch -CallbackUrl which defaults to our bastion server which will initially save the CSV, allowing aggregating later… even nicer is if that endpoint submits to CloudWatch for nice graphics… can you do it straight to cloudwatch?
)
Begin
{
	if ($MeasureType -eq 'All')
	{
		$MeasureName = (Get-ChildItem -Path $PSScriptRoot\..\MeasureCmdlet\*.ps1 -ErrorAction SilentlyContinue).BaseName
	}
	elseif ($MeasureType -eq 'ReadOnly')
	{
		$MeasureName = (Get-ChildItem -Path $PSScriptRoot\..\MeasureCmdlet\*xReadOnly.ps1 -ErrorAction SilentlyContinue).BaseName
	}
	else
	{
		# check if $MeasureName exists in the MeasureCmdlet folder, only those tests are controlled and versioned in their filename
		foreach ($item in $MeasureName)
		{
			$filePath = "$PSScriptRoot\..\MeasureCmdlet\$item.ps1"
			if ((Test-Path -Path $filePath) -eq $False)
			{
				Write-Error ("MyCommand[" + $MyInvocation.MyCommand + "] MeasureName[" + $MeasureName + "] does not exist as FilePath[" + $FilePath + "]")
			}
		}
	}
}
Process
{
	$testSetArray = @() # we should spit out pipeline records as soon as we can, e.g. Callback/PhoneHome; perhaps we need the summary of summaries later
	for ($j = 0; $j -lt $MeasureName.Count; $j++)
	{
		$script:testSet = New-TestSet -MeasureName $MeasureName[$j] -TestDescription $TestDescription
		for ($i = 0; $i -lt $Count; $i++)
		{
			Write-Progress -Activity ("MyCommand[" + $MyInvocation.MyCommand + "] MeasureName[" + $MeasureName[$j] + "] $($i+1)/$Count") -PercentComplete (100*(($Count*$j+$i)/($Count*$MeasureName.Count)))
		
			$CurrentProgressPref = $ProgressPreference
			$ProgressPreference = "SilentlyContinue"
			$testRun = & $MeasureName[$j]
			$ProgressPreference = $CurrentProgressPref
			
			$script:testSet.TestRunArray += $testRun
		}
		$script:testSet.TestStop = Get-Date
		Set-TestSetStatistics -TestSet $script:testSet
		$testSetArray += $script:testSet
		Write-Output (Export-TestSet -TestSet $script:testSet)
		Write-Verbose ("MyCommand[" + $MyInvocation.MyCommand + "] SleepBetweenCount[" + $SleepBetweenCount + "]")
		Start-Sleep -Milliseconds $SleepBetweenCount
	}

	#TODO# $testSetArray allows json-post somewhere or something csv friendly like all printed on one line inc raw0(warmup), raw1...
	if ($CsvFilePath)
	{
		$CsvFilePath = $CsvFilePath -ireplace ".csv", "-Loop$Count.csv"
		Write-Verbose ("MyCommand[" + $MyInvocation.MyCommand + "] CsvFilePath[" + $CsvFilePath + "]")
		Export-TestSet -TestSet $testSetArray | Export-Csv $CsvFilePath -NoTypeInformation -UseCulture -Encoding UTF8 -Append
		Write-Host ("Get-Content $CsvFilePath")
	}
}
}
