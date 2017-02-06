function Test-ISHMeasureTestConnection1xReadOnly
{
<#
.SYNOPSIS
    Using Test-Connection (similar to ping) to test network latency

.DESCRIPTION
    Using Test-Connection (similar to ping) to test network latency

.EXAMPLE
    Test-ISHMeasureTestConnection1
#>
[CmdletBinding()] 
param(
    [int]$Count = 1,
    [Switch]$Cleanup = $true
)
    
Begin
{
}

Process
{
    # Try catch around every run to make them independent, make sure to return 'empty' to not flaw the statistics upon failure
    $ishSession = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession)
    $serverHost = $ishSession.WebServicesBaseUrl.Split('/')[2].Split('/')[0]
    for ($i = 0; $i -lt $Count; $i++)
    { 
        $testRun = $null
        try {
            $scriptBlock = { 
                Test-Connection $serverHost -Count 1
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
    }
}
}