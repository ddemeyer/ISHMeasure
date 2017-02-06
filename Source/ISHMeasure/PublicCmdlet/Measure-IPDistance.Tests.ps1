$cmdletName = "Measure-IPDistance"
try {

Describe "Measure-IPDistance" {

	Context "Measure-IPDistance DistanceOnly returns int" {
		It "ClientIp matches ServerIp" {
            # retrieving your own public ip where you go to the internet on
            $webClient = New-Object system.Net.WebClient
			$clientIp = $webClient.downloadString("http://icanhazip.com")
			Measure-IpDistance -ServerIp $clientIp -DistanceOnly | Should Be 0
		}
		It "ServerIp is google name server" {
			(Measure-IpDistance -ServerIp "8.8.8.8" -DistanceOnly) -ge 0 | Should Be $True
		}
        It "ServerHost is google name server" {
			(Measure-IpDistance -ServerHost "www.google.be" -DistanceOnly) -ge 0 | Should Be $True
		}
		It "ServerHost doesn't exist, so -1" {
			(Measure-IpDistance -ServerHost "something-that-does-not-exist-I-think.nowhere" -DistanceOnly -ErrorAction SilentlyContinue) -eq -1 | Should Be $True
		}
	}

    Context "Measure-IPDistance returns PSObject" {
        It "ClientIp matches ServerIp" {
            $webClient = New-Object system.Net.WebClient
			$clientIp = $webClient.downloadString("http://icanhazip.com")
			$result = Measure-IpDistance -ServerIp $clientIp
            $result.ClientIp -eq $result.ServerIp | Should Be $true
            $result.ClientLocation -eq $result.ServerLocation | Should Be $true
            $result.DistanceKM / 1.6103 | Should Be $result.DistanceMI
        }
    }

}


} finally {
}
