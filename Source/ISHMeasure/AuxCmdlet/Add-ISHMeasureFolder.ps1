function Add-ISHMeasureFolder
{
<#
.SYNOPSIS
    Create the test folder of the various types and returns an ISHRemotePubResult object.

.DESCRIPTION
    Create the test folder of the various types and returns an ISHRemotePubResult object.

.EXAMPLE
	Set-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession) -Value (New-IshSession -WsBaseUrl 'https://example.com/ISHWS/' -IshUserName 'admin' -IshPassword 'admin')
    Add-ISHMeasureFolder -MeasureFolderName ([String]$MyInvocation.MyCommand + "-" + [String](Get-Date -Format "yyyyMMddHHmmss"))
#>
Param(
    [String]$MeasureFolderName
)
Process
{
    Write-Debug ("MyCommand[" + $MyInvocation.MyCommand + "] Loading...")
    $ishRemotePubResult = New-Object ISHRemotePubResult
    $ishSession = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession)
    $folderTestRootPath = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshFolderTestRootPath)
    
    Write-Debug ("MyCommand[" + $MyInvocation.MyCommand + "] Reading root folder...")
	$requestedMetadata = Set-IshRequestedMetadataField -IshSession $ishSession -Name "FNAME" |
	                     Set-IshRequestedMetadataField -IshSession $ishSession -Name "FDOCUMENTTYPE" |
	                     Set-IshRequestedMetadataField -IshSession $ishSession -Name "READ-ACCESS" -ValueType Element |
	                     Set-IshRequestedMetadataField -IshSession $ishSession -Name "FUSERGROUP" -ValueType Element 
	$ishRemotePubResult.RootISHMeasureIshFolder = Get-IshFolder -IShSession $ishSession -FolderPath $folderTestRootPath -RequestedMetadata $requestedMetadata
	$folderIdTestRootOriginal = $ishRemotePubResult.RootISHMeasureIshFolder.IshFolderRef
	$folderTypeTestRootOriginal = $ishRemotePubResult.RootISHMeasureIshFolder.IshFolderType
	$ownedByTestRootOriginal = Get-IshMetadataField -IshSession $ishSession -Name "FUSERGROUP" -ValueType Element -IshField $ishRemotePubResult.RootISHMeasureIshFolder.IshField
	$readAccessTestRootOriginal = (Get-IshMetadataField -IshSession $ishSession -Name "READ-ACCESS" -ValueType Element -IshField $ishRemotePubResult.RootISHMeasureIshFolder.IshField).Split($ishSession.Seperator)

    Write-Debug ("MyCommand[" + $MyInvocation.MyCommand + "] Creating object folders...")
	# smart 0, 1, 2... folder names allow sorted top-down removal, so pub before map before topic
	$ishRemotePubResult.SubRootISHMeasureIshFolder = Add-IshFolder -IShSession $ishSession -ParentFolderId $folderIdTestRootOriginal -FolderType $folderTypeTestRootOriginal -FolderName $MeasureFolderName -OwnedBy $ownedByTestRootOriginal -ReadAccess $readAccessTestRootOriginal
	$ishRemotePubResult.IshFolderPubArray += Add-IshFolder -IshSession $ishSession -ParentFolderId ($ishRemotePubResult.SubRootISHMeasureIshFolder.IshFolderRef) -FolderType ISHPublication -FolderName "0-Pub" -OwnedBy $ownedByTestRootOriginal -ReadAccess $readAccessTestRootOriginal
	$ishRemotePubResult.IshFolderMapArray += Add-IshFolder -IshSession $ishSession -ParentFolderId ($ishRemotePubResult.SubRootISHMeasureIshFolder.IshFolderRef) -FolderType ISHMasterDoc -FolderName "1-Map" -OwnedBy $ownedByTestRootOriginal -ReadAccess $readAccessTestRootOriginal
	$ishRemotePubResult.IshFolderTopicArray += Add-IshFolder -IshSession $ishSession -ParentFolderId ($ishRemotePubResult.SubRootISHMeasureIshFolder.IshFolderRef) -FolderType ISHModule -FolderName "2-Topic" -OwnedBy $ownedByTestRootOriginal -ReadAccess $readAccessTestRootOriginal
		$ishRemotePubResult.IshFolderLibArray += Add-IshFolder -IshSession $ishSession -ParentFolderId ($ishRemotePubResult.SubRootISHMeasureIshFolder.IshFolderRef) -FolderType ISHLibrary -FolderName "3-Library" -OwnedBy $ownedByTestRootOriginal -ReadAccess $readAccessTestRootOriginal
    $ishRemotePubResult.IshFolderImageArray += Add-IshFolder -IshSession $ishSession -ParentFolderId ($ishRemotePubResult.SubRootISHMeasureIshFolder.IshFolderRef) -FolderType ISHIllustration -FolderName "4-Image" -OwnedBy $ownedByTestRootOriginal -ReadAccess $readAccessTestRootOriginal
    $ishRemotePubResult.IshFolderOtherArray += Add-IshFolder -IshSession $ishSession -ParentFolderId ($ishRemotePubResult.SubRootISHMeasureIshFolder.IshFolderRef) -FolderType ISHTemplate -FolderName "5-Other" -OwnedBy $ownedByTestRootOriginal -ReadAccess $readAccessTestRootOriginal
    

    Write-Output $ishRemotePubResult
}
}