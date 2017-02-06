$cmdletName = "Measure-Expression"
try {

Describe “Measure-Expression" {

	Context "Measure-Expression returns int[]" {
		It "Measure 1 time a single ping [0]" {
            $timingsArray = Measure-Expression -Silent -Expression { ping -n 1 google.com }
            $timingsArray[0] -ge 0 | Should Be $True
		}
        It "Measure 10 times a single ping" {
            (Measure-Expression -Count 10 -Silent -Expression { ping -n 1 google.com }).Count | Should Be 10
		}
		It "Measure 1 time a 100ms sleep" {
            $milliseconds = (Measure-Expression -Silent -Expression { Start-Sleep -Milliseconds 100 })[0]
			$milliseconds -ge 100 | Should Be $True
            $milliseconds -le 150 | Should Be $True
		}
	}

}


} finally {
}
