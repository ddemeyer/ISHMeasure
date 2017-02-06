function Get-ISHMeasureGetIshTimeZone1xReadOnly
{
<#
.SYNOPSIS
    Use ISHRemote's Get-IshTimeZone to do client timing for a call which goes over the WebApp server to the database

.DESCRIPTION
    Use ISHRemote's Get-IshTimeZone to do client timing for a call which goes over the WebApp server to the database

.EXAMPLE
    Get-ISHMeasureGetIshTimeZone1
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
    for ($i = 0; $i -lt $Count; $i++)
    { 
        $testRun = $null
        try {
            # Get-IshTimeZone has proper timing itself, so not using Measure-Expression
            $timeZoneResult = Get-IshTimeZone -IshSession $ishSession -Count 1 # with 2 counts means that $timeZoneResult holds a two test results, min and max
            # The call returns localized string looking like "22,7037 ms", so shopping of the European decimal seperator ',' and the US one '.'
            $testRun = New-TestRun -Timing $timeZoneResult.MaxClientElapsed.Split(".")[0].Split(",")[0] -ExitCode 0
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