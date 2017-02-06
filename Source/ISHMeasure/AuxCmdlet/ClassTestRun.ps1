class TestRun
{
    [int]$Timing # raw data expressed in milliseconds, should be available as last columns in the CSV. 
    [int]$ExitCode # -ne 0 if the test was unsuccessful
    [String]$Message # if any, could be an exception or feedback
}

function New-TestRun
{
    param(
        [int]$Timing,
        [int]$ExitCode=0,
        [String]$Message=""
    )
    $result = New-Object TestRun
    $result.Timing = $Timing
    $result.ExitCode = $ExitCode
    $result.Message = $Message
    Write-Output $result
}