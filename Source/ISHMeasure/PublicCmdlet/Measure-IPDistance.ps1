function Measure-IpDistance
{
<#
.SYNOPSIS
	Does an attempt to roughly calculate the distance between two ip addresses based on a free longitude/latitude service and a basic direct distance calucation.

.DESCRIPTION
	Does an attempt to roughly calculate the distance between two ip addresses based on a free longitude/latitude service and a basic direct distance calucation.

	The longitude/latitude service is http://getcitydetails.geobytes.com which offers 16000 requests per day for free. Note that the service is not considered very accurate.
	
	To know your client's public IP address, a simple call to http://icanhazip.com returns it

.EXAMPLE
	Measure-IpDistance -ServerIp "8.8.8.8"
	
	Does a rough estimate in kilometers of the distance of your client's ip address versus this server's ip addresss.
	
.EXAMPLE
	Measure-IpDistance -ServerHost "www.sdl.com"

.LINKS
	Hat tips to http://geobytes.com/get-city-details-api/ and http://stackoverflow.com/questions/19412462/getting-distance-between-two-points-based-on-latitude-longitude-python

.FUNCTIONALITY
	PowerShell Language
#>
[CmdletBinding()] 
Param(
	[Parameter(Mandatory=$True, ParameterSetName='ip')]
	$ServerIp,
	[Parameter(Mandatory=$True, ParameterSetName='host')]
	$ServerHost,
	[Parameter(Mandatory=$False)]
	$ClientIp = $null,
	[Parameter(Mandatory=$False)]
	[Switch]$DistanceOnly = $False
)
End
{
	# clientGeocityDetails defaults to $ClientIp, no explicit lookup required
	#if ($ClientIp -eq $null)
	#{
	#	$webClient = New-Object system.Net.WebClient
	#	$ClientIp = $obj.downloadString("http://icanhazip.com")
	#}
	if ($ServerHost)
	{
		if (Test-Connection -ComputerName $ServerHost -Count 1 -Quiet)
		{
			$ServerIp = (Test-Connection -ComputerName $ServerHost -Count 1).IPV4Address.IPAddressToString
		}
        elseif ($null -ne (Resolve-DnsName -Name $ServerHost))
        {
            $ServerIp = ((Resolve-DnsName -Name $ServerHost).IpAddress -match "\b(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}\b")[0]
        }
        else
        {
			Write-Verbose ("MyCommand[" + $MyInvocation.MyCommand + "] Resolving ServerHost[" + $ServerHost + "] failed")
			Write-Output -1
			Return
		}
	}
	Write-Verbose ("MyCommand[" + $MyInvocation.MyCommand + "] Loading ClientIp[" + $ClientIp + "] ServerIp[" + $ServerIp + "] ServerHost[" + $ServerHost + "]")

	# Client
	$clientUri = "http://getcitydetails.geobytes.com/GetCityDetails"
	$clientGeocityDetails = (Invoke-WebRequest -Uri $clientUri).Content
	$clientGeocityDetails = $clientGeocityDetails | ConvertFrom-Json
	$ClientIp = $clientGeocityDetails.geobytesipaddress
	Write-Verbose ("MyCommand[" + $MyInvocation.MyCommand + "] ipaddress[" + $clientGeocityDetails.geobytesipaddress + "] fqcn[" + $clientGeocityDetails.geobytesfqcn + "] latitude[" + $clientGeocityDetails.geobyteslatitude + "] longitude[" + $clientGeocityDetails.geobyteslongitude + "] certainty[" + $clientGeocityDetails.geobytescertainty + "]")
	
	# Server
	$serverUri = "http://getcitydetails.geobytes.com/GetCityDetails?fqcn=$ServerIp"
	$serverGeocityDetails = (Invoke-WebRequest -Uri $serverUri).Content
	$serverGeocityDetails = $serverGeocityDetails | ConvertFrom-Json
	Write-Verbose ("MyCommand[" + $MyInvocation.MyCommand + "] ipaddress[" + $serverGeocityDetails.geobytesipaddress + "] fqcn[" + $serverGeocityDetails.geobytesfqcn + "] latitude[" + $serverGeocityDetails.geobyteslatitude + "] longitude[" + $serverGeocityDetails.geobyteslongitude + "] certainty[" + $serverGeocityDetails.geobytescertainty + "]")
	
	if ($clientGeocityDetails.geobyteslatitude -and $clientGeocityDetails.geobyteslongitude -and $serverGeocityDetails.geobyteslatitude -and $serverGeocityDetails.geobyteslongitude)
	{
		# Converting degrees to radians for simple globe distance
		$ipFromLat1 = [System.Math]::PI/180 * ($clientGeocityDetails.geobyteslatitude)
		$ipFromlon1 = [System.Math]::PI/180 * ($clientGeocityDetails.geobyteslongitude)
		$ipToLat2   = [System.Math]::PI/180 * ($serverGeocityDetails.geobyteslatitude)
		$ipToLon2   = [System.Math]::PI/180 * ($serverGeocityDetails.geobyteslongitude)
		# approximate radius of earth in km
		$earthRadius = 6373.0
		$deltaLongitude = $ipToLon2 - $ipFromlon1
		$deltaLatitude = $ipToLat2 - $ipFromLat1
		$a = [System.Math]::pow([System.Math]::sin($deltaLatitude/2),2) + [System.Math]::cos($ipFromLat1) * [System.Math]::cos($ipToLat2) * [System.Math]::pow([System.Math]::sin($deltaLongitude/2),2)
		$c = 2 * [System.Math]::atan2([System.Math]::sqrt($a), [System.Math]::sqrt(1-$a))
		$distanceKM = [System.Math]::round($earthRadius * $c)
	}
	else
	{
		$distanceKM = -1
	}

	if ($DistanceOnly)
	{
		Write-Verbose ("MyCommand[" + $MyInvocation.MyCommand + "] ClientIp[" + $ClientIp + "] ServerIp[" + $ServerIp + "] distanceKM[" + $distanceKM +"]")
		Write-Output $distanceKM
	}
	else
	{
		$result = New-Object PSObject -Property @{
					ClientIp = $clientGeocityDetails.geobytesipaddress
					ClientLocation = $clientGeocityDetails.geobytesfqcn
					ServerIp = $serverGeocityDetails.geobytesipaddress
					ServerLocation = $serverGeocityDetails.geobytesfqcn
					DistanceKM = $distanceKM
					DistanceMI = $distanceKM / 1.6103
					}
		Write-Output $result
	}
}
}
<#
lat1 = 52.2296756
lon1 = 21.0122287
lat2 = 52.406374
lon2 = 16.9251681

pester test should result in 278.546, "km"
#>