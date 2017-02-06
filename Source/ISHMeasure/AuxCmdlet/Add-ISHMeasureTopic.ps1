function Add-ISHMeasureTopic
{
<#
.SYNOPSIS
    Create the test folder of the various types and returns an ISHRemotePubResult object.

.DESCRIPTION
    Create the test folder of the various types and returns an ISHRemotePubResult object.

.EXAMPLE
    Set-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession) -Value (New-IshSession -WsBaseUrl 'https://example.com/ISHWS/' -IshUserName 'admin' -IshPassword 'admin')
    $ishRemotePubResult = Add-ISHMeasureFolder -MeasureFolderName ([String]$MyInvocation.MyCommand + "-" + [String](Get-Date -Format "yyyyMMddHHmmss"))
	Add-ISHMeasureTopic -ISHRemotePubResult $ishRemotePubResult -Count 2

.NOTES
    Defaults to the $prefixName prefix (ISHMeasure)

    Optionally make the -Name parameter an enumeration or controlled values.

.FUNCTIONALITY
    PowerShell Language
#>
Param(
    $ISHRemotePubResult,
    [int]$Count
)

Begin
{
}

Process
{
    Write-Debug ("MyCommand[" + $MyInvocation.MyCommand + "] Loading...")
    $ishFolderTopic = $ISHRemotePubResult.ishFolderTopicArray[0] #TODO# if there are more folders, create the requested $Count content objects across those folders
    $ishSession = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession)
    $ishLanguageElement = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshLanguageElement)
    $ishInitialStatusElement = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshInitialStatusElement)
    $ishUserAuthorElement = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshUserAuthorElement)
	$ditaTopicFileContent = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureDitaTopicFileContent)
    $timestamp = (Get-Date -Format "yyyyMMddHHmmss")

    Write-Debug ("MyCommand[" + $MyInvocation.MyCommand + "] Creating topics...")
	for ($i = 0; $i -lt $Count; $i++)
    { 
        $ishTopicMetadata = Set-IshMetadataField -IshSession $ishSession -Name "FTITLE" -Level Logical -Value ("$timestamp Topic " + ("{0:D6}" -f $i)) |
					        Set-IshMetadataField -IshSession $ishSession -Name "FAUTHOR" -Level Lng -ValueType Element -Value $ishUserAuthorElement |
			    	        Set-IshMetadataField -IshSession $ishSession -Name "FSTATUS" -Level Lng -ValueType Element -Value $ishInitialStatusElement
        $fileContent = $ditaTopicFileContent
        if ($ISHRemotePubResult.IshDocumentObjImageArray.Count -gt 0)
        {
		    # when images available, inserting using a 1-1 ratio
		    $logicalId = $ISHRemotePubResult.IshDocumentObjImageArray[ $i % $ISHRemotePubResult.IshDocumentObjImageArray.Length ].IshRef
		    $fileContent = $ditaTopicFileContent -replace '<\?ish-replace-beforeclosingbody\?>', ('<image href="' + $logicalId +'"/><?ish-replace-beforeclosingbody?>')
        }
		$ishObject = Add-IshDocumentObj -IshSession $ishSession -IshFolder $ishFolderTopic -IshType ISHModule -Lng $ishLanguageElement -Metadata $ishTopicMetadata -FileContent $fileContent
        $ISHRemotePubResult.IshDocumentObjTopicArray += $ishObject
    }

    Write-Output $ishRemotePubResult
}

End
{
}
}