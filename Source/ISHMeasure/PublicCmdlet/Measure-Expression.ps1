function Measure-Expression ([ScriptBlock]$Expression, [int]$Count = 1, [Switch]$Silent) {
<#
.SYNOPSIS
  Runs the given script block and returns the execution duration.
  Hat tip to StackOverflow. http://stackoverflow.com/questions/3513650/timing-a-commands-execution-in-powershell
  Hat tip to http://zduck.com/2013/benchmarking-with-Powershell/
  
.EXAMPLE
  Measure-Expression { ping -n 1 google.com }
#>
  $timingsArray = @()
  do {
    $stopwatch = New-Object Diagnostics.Stopwatch
    if ($Silent) {
      $stopwatch.Start()
      $null = & $Expression
      $stopwatch.Stop()
    }
    else {
      $stopwatch.Start()
      & $Expression
      $stopwatch.Stop()
    }
    $timingsArray += [int]$stopwatch.Elapsed.TotalMilliseconds
    
    $Count--
  }
  while ($Count -gt 0)
  $timingsArray
}
