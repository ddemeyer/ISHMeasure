class ISHRemotePubResult
{
    # ISHMeasure root IshFolder
    $RootISHMeasureIshFolder
    # root IshFolder that can recursively be removed, so holds the test assets
    $SubRootISHMeasureIshFolder
    # array in order of creation per folder type, allowing removal
    $IshFolderTopicArray = @()
    $IshFolderMapArray = @()
    $IshFolderLibArray = @()
    $IshFolderImageArray = @()
    $IshFolderOtherArray = @()
    $IshFolderPubArray = @()
	# array in order of creation per object type, allowing removal
    $IshDocumentObjTopicArray = @()
    $IshDocumentObjMapArray = @()
    $IshDocumentObjLibArray = @()
    $IshDocumentObjImageArray = @()
    $IshDocumentObjOtherArray = @()
    $IshPublicationOutputPubArray = @()
}