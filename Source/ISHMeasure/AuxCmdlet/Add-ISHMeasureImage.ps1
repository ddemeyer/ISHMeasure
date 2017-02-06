function Add-ISHMeasureImage
{
<#
.SYNOPSIS
    Create the test folder of the various types and returns an ISHRemotePubResult object.

.DESCRIPTION
    Create the test folder of the various types and returns an ISHRemotePubResult object.

.EXAMPLE
    Set-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession) -Value (New-IshSession -WsBaseUrl 'https://example.com/ISHWS/' -IshUserName 'admin' -IshPassword 'admin')
    $ishRemotePubResult = Add-ISHMeasureFolder -MeasureFolderName ([String]$MyInvocation.MyCommand + "-" + [String](Get-Date -Format "yyyyMMddHHmmss"))
	Add-ISHMeasureImage -ISHRemotePubResult $ishRemotePubResult -Count 2
#>
Param(
    $ISHRemotePubResult,
    [int]$Count
)

Begin
{
    $script:tempFilePath = (New-TemporaryFile).FullName
    Add-Type -AssemblyName "System.Drawing"
}

Process
{
    Write-Debug ("MyCommand[" + $MyInvocation.MyCommand + "] Loading...")
    $ishFolderImage = $ISHRemotePubResult.IshFolderImageArray[0] #TODO# if there are more folders, create the requested $Count content objects across those folders
    $ishSession = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession)
    $ishLanguageElement = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshLanguageElement)
    $ishResolutionElement = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshResolutionElement)
    $ishInitialStatusElement = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshInitialStatusElement)
    $ishUserAuthorElement = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshUserAuthorElement)
    #TODO# $ishImageMetadata = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshImageMetadata)
    $timestamp = (Get-Date -Format "yyyyMMddHHmmss")

    Write-Debug ("MyCommand[" + $MyInvocation.MyCommand + "] Creating images...")
	for ($i = 0; $i -lt $Count; $i++)
    { 
        $ishImageMetadata = Set-IshMetadataField -IshSession $ishSession -Name "FTITLE" -Level Logical -Value ("$timestamp Image " + ("{0:D6}" -f $i)) |
					        Set-IshMetadataField -IshSession $ishSession -Name "FAUTHOR" -Level Lng -ValueType Element -Value $ishUserAuthorElement |
			    	        Set-IshMetadataField -IshSession $ishSession -Name "FSTATUS" -Level Lng -ValueType Element -Value $ishInitialStatusElement
		# generating image from scratch
		$bmp = New-Object -TypeName System.Drawing.Bitmap(100,100)
		for ($x = 0; $x -lt 100; $x++)
		{
			for ($y = 0; $y -lt 100; $y++)
			{
				$bmp.SetPixel($x, $y, 'Red')
			}
		}
		$bmp.Save($tempFilePath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        $ishObject = Add-IshDocumentObj -IshSession $ishSession -IshFolder $ishFolderImage -IshType ISHIllustration -Lng $ishLanguageElement -Resolution $ishResolutionElement -Metadata $ishImageMetadata -Edt "EDTJPEG" -FilePath $tempFilePath
        $ISHRemotePubResult.IshDocumentObjImageArray += $ishObject
    }

    Write-Output $ishRemotePubResult
}

End
{
    try { Remove-Item $script:tempFilePath -Force } catch { }
}
}