# Summary

`ISHMeasure` is a PowerShell module on SDL Knowledge Center Content Manager. Its goal is basic benchmarking tests on top of the Component Content Management System (InfoShare). This library is constructed close to the "Web Services API" relying on the [ISHRemote](https://github.com/sdl/ISHRemote) module.

# Features & Samples

* Test sets are created and removed in the repository.
* `Add-*` cmdlets will immediately create objects in the CMS. 
* `Test-*`, `Get-*` will immediately execute. Most likely they are marked with `xReadOnly` in their filename to indicate that they don't change your CMS repository.

# Install & Update

## Prerequisites

When you have PowerShell 5 on your client machine, the PSVersion entry in `$PSVersionTable` reads 5.0... and PackageManagement is there implicitly.
When you have a PowerShell version lower than 5 on your client machine, the PSVersion entry in `$PSVersionTable` reads 4.0 or even 3.0. Note that the latest Knowledge Center 2016SP3/12.0.3 release is only verified with PowerShell 4 (not 5 or above), so don't upgrade your servers. As ISHMeasure is about a client-side web services driven library I actually don't expect you to even install it on a server.

So either upgrade to [Windows Management Framework 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395) or stay on PowerShell 4 and install [Package Management Preview – March 2016 for PowerShell 4 & 3](https://blogs.msdn.microsoft.com/powershell/2016/03/08/package-management-preview-march-2016-for-powershell-4-3-is-now-available/).

## Install
Open a PowerShell, then you can find and install the ISHMeasure module. CurrentUser `-Scope` indicates that you don't have to run PowerShell as Administrator. The `-Force` will make you bypass some security/trust questions.

		~~Install-Module ISHMeasure -Repository PSGallery -Scope CurrentUser -Force~~
		Import-Module .\ISHMeasure -Force 

## Update

Open a PowerShell and run.

        ~~Update-Module ISHMeasure~~
		Import-Module .\ISHMeasure -Force 

 
## Uninstall

Open a PowerShell and run.

        ~~Uninstall-Module ISHMeasure -AllVersion~~

## Execute

A simple invoke would come down to, make sure a `__ISHMeasure` folder exists in the root of your CMS folder structure.

		Set-ISHMeasureVariable -Name ([ISHMeasureVariableEnum]::ISHMeasureIshSession) -Value (New-IshSession -WsBaseUrl 'https://example.com/ISHWS/' -IshUserName 'admin' -IshPassword 'admin')
		Invoke-ISHMeasure -TestDescription $testDescription -MeasureType 'ReadOnly' -CsvFilePath "C:\temp\ISHMeasure.csv"
		
# Backlog & Feedback
Any feedback is welcome. Please log a GitHub issue, make sure you submit your version number, expected and current result,...

[Backlog]

[Backlog]: BACKLOG.MD "Backlog"

# Known Issues & FAQ

## Execution Known Issues
* If you get `New-IshSession : Reference to undeclared entity 'raquo'. Line 98, position 121.`, most likely you specified an existing "Web Services API" url. Make sure your url ends with an ending slash `/`.
* If a test fails with `The communication object, System.ServiceModel.Channels.ServiceChannel, cannot be used for communication because it is in the Faulted state.`,
  it probably means you didn't provide enough (mandatory) parameters to the WCF/SVC code so passing null parameters. Typically an `-IshPassword` is missing or using an existing username.
* ISHDeploy `Enable-ISHIntegrationSTSInternalAuthentication/Disable-ISHIntegrationSTSInternalAuthentication` adds a /ISHWS/Internal/connectionconfiguration.xml that a different issuer should be used. As ISHMeasure doesn't have an app.config, all the artifacts are derived from the RelyingParty WSDL provided mex endpoint (e.g. /ISHSTS/issue/wstrust/mex).  
If you get error `New-IshSession : The communication object, System.ServiceModel.Channels.ServiceChannel, cannot be used for communication because it is in the Faulted state.`, it probably means you initialized `-WsBaseUrl` without the `/Internal/` (or `/SDL/`) segment, meaning you are using the primary configured STS.

## Testing Known Issues

N/A

## Documentation Known Issues

N/A

# Standards To Respect

## Coding Standards 

* Any code change should 
    * respect the coding standard like [Strongly Encouraged Development Guidelines](https://msdn.microsoft.com/en-us/library/dd878270(v=vs.85).aspx) and [Windows PowerShell Cmdlet Concepts](https://msdn.microsoft.com/en-us/library/dd878268(v=vs.85).aspx)
    * come with matching acceptance/unit test, to further improve stability and predictability
    * come with matching tripple-slash `///` documentation verification or adaptation. Remember `Get-Help` drives PowerShell!
    * double check backward compatibility; if you break provide an alternative through `Set-Alias`, Get-Help,...
	* Any url reference should be specified with `...example.com` in samples and Service References.
* Respect PowerShell concepts
    * parameters are Single not plural, so IshObject over IshObjects or FilePath over FilePaths
    * implement `-WhatIf`/`-Confirm` flags for write operations
* ISHMeasure-build project holds the artefacts for in-house testing, signing, and publishing the library

## Documentation Standards

* Every function should be document to allow `Get-Help` to work.

## Testing Standards

* Most Pester tests are acceptance test, enriched which some unit tests where possible.
* Data initialization and breakdown are key but also time consuming. BeforeEach/AfterEach are run for every It block, so makes things slow.

# Coding Prerequisites  

## Testing and Debugging

Refreshing all module artefacts in a PowerShell ISE session can be done using

		Import-Module .\ISHMeasure -Force 

*Module structure credits go to RamblingCookieMonster like [PSStackExchange](https://github.com/RamblingCookieMonster/PSStackExchange)*