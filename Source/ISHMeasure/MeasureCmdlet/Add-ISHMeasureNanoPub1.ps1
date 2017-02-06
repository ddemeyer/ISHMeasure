function Add-ISHMeasureNanoPub1
{
<#
.SYNOPSIS
    Adds the smallest publication consisting out of 1 image, 1 topic, 1 map and 1 pub

.DESCRIPTION
    Adds the smallest publication consisting out of 1 image, 1 topic, 1 map and 1 pub

.EXAMPLE
    Set-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession) -Value (New-IshSession -WsBaseUrl 'https://example.com/ISHWS/' -IshUserName 'admin' -IshPassword 'admin')
    Add-ISHMeasureNanoPub1
#>
[CmdletBinding()] 
param(
    [int]$Count = 1,
    [Switch]$Cleanup = $true
)
    
Begin
{
    # Verify and prepare for actual test run
    $script:ishRemotePubResult = Add-ISHMeasureFolder -MeasureFolderName ([String]$MyInvocation.MyCommand + "-" + [String](Get-Date -Format "yyyyMMddHHmmss"))
}

Process
{
    # Try catch around every run to make them independent, make sure to return 'empty' to not flaw the statistics upon failure
    for ($i = 0; $i -lt $Count; $i++)
    { 
        $testRun = $null
        try {
            $scriptBlock = { 
                Add-ISHMeasureImage -ISHRemotePubResult $script:ishRemotePubResult -Count 1
                Add-ISHMeasureTopic -ISHRemotePubResult $script:ishRemotePubResult -Count 1
                Add-ISHMeasureMap -ISHRemotePubResult $script:ishRemotePubResult -Count 1
            }
            $testRun = New-TestRun -Timing (Measure-Expression -Expression $scriptBlock -Count 1 -Silent) -ExitCode 0
        }
        catch
        {
            $message = ("MyCommand[" + $MyInvocation.MyCommand + "] Run[" + $i + "] exception[" + $_.Exception.Message + "]")
            Write-Warning $message
            $testRun = New-TestRun -Timing -1 -ExitCode 0 -Message $message
            # error in first iteration means probably something is quite wrong, exiting loop
            if ($i -eq 0)
            {
                Write-Warning ($message + " error in first run, exiting test loop")
                break
            }
        }
        finally
        {
            Write-Output $testRun
        }
    }
}

End
{
    if ($Cleanup -eq $true)
    {
        #TODO# Move to counterparts like Remove-ISHMeasureFolder and Remove-ISHMeasureImage
        $ishSession = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession)
        try { Get-IshFolder -IshSession $ishSession -IshFolder $script:ishRemotePubResult.SubRootISHMeasureIshFolder -Recurse |
              Get-IshFolderContent -IshSession $ishSession | Remove-IshDocumentObj -IshSession $ishSession -Force } catch { }
        try { Remove-IshFolder -IshSession $ishSession -IshFolder $script:ishRemotePubResult.SubRootISHMeasureIshFolder -Recurse } catch { }
    }
}
}