function Add-ISHMeasureMap
{
<#
.SYNOPSIS
    Create the test folder of the various types and returns an ISHRemotePubResult object.

.DESCRIPTION
    Create the test folder of the various types and returns an ISHRemotePubResult object.

.EXAMPLE
    Set-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession) -Value (New-IshSession -WsBaseUrl 'https://example.com/ISHWS/' -IshUserName 'admin' -IshPassword 'admin')
    $ishRemotePubResult = Add-ISHMeasureFolder -MeasureFolderName ([String]$MyInvocation.MyCommand + "-" + [String](Get-Date -Format "yyyyMMddHHmmss"))
	Add-ISHMeasureMap -ISHRemotePubResult $ishRemotePubResult -Count 2
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
    $ishFolderMap = $ISHRemotePubResult.ishFolderMapArray[0] #TODO# if there are more folders, create the requested $Count content objects across those folders
    $ishSession = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession)
    $ishLanguageElement = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshLanguageElement)
    $ishInitialStatusElement = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshInitialStatusElement)
    $ishUserAuthorElement = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshUserAuthorElement)
	$ditaMapFileContent = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureDitaMapFileContent)
    $timestamp = (Get-Date -Format "yyyyMMddHHmmss")

    Write-Debug ("MyCommand[" + $MyInvocation.MyCommand + "] Creating Maps...")
	for ($i = 0; $i -lt $Count; $i++)
    { 
        $ishMapMetadata = Set-IshMetadataField -IshSession $ishSession -Name "FTITLE" -Level Logical -Value ("$timestamp Map " + ("{0:D6}" -f $i)) |
					      Set-IshMetadataField -IshSession $ishSession -Name "FAUTHOR" -Level Lng -ValueType Element -Value $ishUserAuthorElement |
			    	      Set-IshMetadataField -IshSession $ishSession -Name "FSTATUS" -Level Lng -ValueType Element -Value $ishInitialStatusElement
        $fileContent = $ditaMapFileContent
        if ($ISHRemotePubResult.IshDocumentObjTopicArray.Count -gt 0)
        {
		    #TODO# when Topics available, inserting all of them evenly among the number of requested maps
            foreach ($item in $ISHRemotePubResult.IshDocumentObjTopicArray)
            {
                $logicalId = $item.IshRef
		        $fileContent = $fileContent -replace '<\?ish-replace-beforeclosingmap\?>', ('<topicref href="' + $logicalId +'"><topicmeta><navtitle>Navtitle of ' + $logicalId +'</navtitle></topicmeta></topicref><?ish-replace-beforeclosingmap?>')
            }    
        }
		$ishObject = Add-IshDocumentObj -IshSession $ishSession -IshFolder $ishFolderMap -IshType ISHMasterDoc -Lng $ishLanguageElement -Metadata $ishMapMetadata -FileContent $fileContent
        $ISHRemotePubResult.IshDocumentObjMapArray += $ishObject
    }

    Write-Output $ishRemotePubResult
}

End
{
}
}