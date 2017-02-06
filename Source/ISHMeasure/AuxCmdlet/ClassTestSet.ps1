class TestSet
{
    # Note that the order of the below Properties matters for the record/CSV-row, so append extra Properties at the back

    # TestEnvironment
    [String]$ModuleVersion # ISHMeasure version, version should differ also when default values of Get-ISHMeasureVariable change
    [String]$ClientVersion # $ishSession.ClientVersion like 0.3.2408.0
    [String]$ServerVersion # $ishSession.ServerVersion like 12.0.3725.3
    [String]$MeasureItemName # probably the name of the cmdlet, those cmdlets should be versioned
    [String]$ServerWebServicesBaseUrl # $ishSession.WebServicesBaseUrl
    [String]$IshUserName # $ishSession.IshUserName
    [String]$TestDescription # a mandatory description of why you are running the test, e.g. (like project on X size, or AWS instance sizes) is mandatory to describe and distinct the test cases

    [String]$ClientIp # like 213.224.250.111
    [String]$ClientLocation # like Antwerp, AN, Belgium
    [String]$ServerIp
    [String]$ServerLocation # derived from $ServerWebServicesBaseUrl
    [int]$ClientServerDistanceInKM
    [int]$ClientServerDistanceInMI

    [DateTime]$TestStart # for CSV, should be converted to yyyMMdd and time column
    [DateTime]$TestStop

    # TestRunStatistics
    # We run minimally twice, where the first run is to initialize/check the test and warm-up. Statistics will always throw away the first test (so Raw0)
    [int]$Count # $TestRunArray.Count
    [int]$Min # $TestRunArray, expressed in milliseconds
    [int]$Median # $TestRunArray, expressed in milliseconds
    [int]$Max # $TestRunArray, expressed in milliseconds
    [int]$Avg # $TestRunArray, expressed in milliseconds

    # TestRun, the raw data
    # so every test iteration timings should be there, like "Raw$i" column
    $TestRunArray # TestRun[], raw data expressed in milliseconds, should be available as last columns in the CSV. Empty cell if the test was unsuccessful
}

function Export-TestSet
{
    Param(
        $TestSet
    )
    $resultObjectArray = @()
    foreach ($testSetItem in $TestSet)
    {
        $object = New-Object PSObject ($testSetItem | Select-Object -ExcludeProperty TestRunArray,TestStart,TestStop -Property "*")
        $object | Add-Member Noteproperty "TestStartUTC" $testSetItem.TestStart.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:‌​ss+0000")
        $object | Add-Member Noteproperty "TestStopUTC" $testSetItem.TestStop.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:‌​ss+0000")
        for ($i = 0; $i -lt $testSetItem.TestRunArray.Count; $i++)
        { 
            $object | Add-Member Noteproperty "Raw$i" $testSetItem.TestRunArray[$i].Timing
        }
        $resultObjectArray += $object
    }
    $resultObjectArray
}

#TODO# Test could be about mock object where min <= median/avg <= max
function Set-TestSetStatistics
{
    Param(
        $TestSet,
        $SkipWarmUpTestRun = 0
    )
    $TestSet.Count = $TestSet.TestRunArray.Count
    $TestSet.Median = (($TestSet.TestRunArray | sort -Property Timing)[  [math]::Floor($TestSet.TestRunArray.count/2)  ]).Timing
    $measureObjectResult = $TestSet.TestRunArray | Select-Object Timing | Measure-Object -Property Timing -Average -Minimum -Maximum
    $TestSet.Min = $measureObjectResult.Minimum
    $TestSet.Max = $measureObjectResult.Maximum
    $TestSet.Avg = $measureObjectResult.Average
}

function New-TestSet
{
    Param(
        [Parameter(Mandatory=$True)]
        [String]$MeasureName,
        [Parameter(Mandatory=$True)]
        [String]$TestDescription
    )
    $result = New-Object -TypeName TestSet
    
    $result.ModuleVersion = (Get-Module -Name ISHMeasure).Version

    $ishSession = Get-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession)
    $result.ClientVersion = $ishSession.ClientVersion # like 0.3.2408.0
    $result.ServerVersion = $ishSession.ServerVersion # like 12.0.3725.3
    $result.ServerWebServicesBaseUrl = $ishSession.WebServicesBaseUrl
    $result.IshUserName = $ishSession.IshUserName

    $serverHost = $ishSession.WebServicesBaseUrl.Split('/')[2].Split('/')[0]
    $MeasureIPDistanceResult = Measure-IpDistance -ServerHost $serverHost
    if ($MeasureIPDistanceResult -ne $null)
    {
        $result.ClientIp = $MeasureIPDistanceResult.ClientIp # like 213.224.250.111
        $result.ClientLocation = $MeasureIPDistanceResult.ClientLocation # like Antwerp, AN, Belgium
        $result.ServerIp = $MeasureIPDistanceResult.ServerIp
        $result.ServerLocation = $MeasureIPDistanceResult.ServerLocation # derived from $ServerWebServicesBaseUrl
        $result.ClientServerDistanceInKM = $MeasureIPDistanceResult.distanceKM
        $result.ClientServerDistanceInMI = $MeasureIPDistanceResult.distanceMI
    }

    $result.TestDescription = $TestDescription
    $result.TestStart = Get-Date
    $result.TestStop = [DateTime]::MinValue

    $result.MeasureItemName = $MeasureName
    $result.TestRunArray = @()

    $result.Min = -1
    $result.Median = -1
    $result.Max = -1
    $result.Count = -1
    
    Write-Output $result
}