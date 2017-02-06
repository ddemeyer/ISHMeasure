#Get public and private function definition files. Load measure last as they rely on classes and aux functions
    $PublicCmdlet  = @( Get-ChildItem -Path $PSScriptRoot\PublicCmdlet\*.ps1 -ErrorAction SilentlyContinue -Exclude *.Tests.ps1)
    $AuxCmdlet = @( Get-ChildItem -Path $PSScriptRoot\AuxCmdlet\*.ps1 -ErrorAction SilentlyContinue -Exclude *.Tests.ps1)
    $MeasureCmdlet = @( Get-ChildItem -Path $PSScriptRoot\MeasureCmdlet\*.ps1 -ErrorAction SilentlyContinue -Exclude *.Tests.ps1)

#Dot source the files
    Foreach($import in @($PublicCmdlet + $AuxCmdlet + $MeasureCmdlet))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

# Here I might...
    # Read in or create an initial config file and variable
    # Export Public functions ($Public.BaseName) for WIP modules
    # Set variables visible to the module and its functions only

Export-ModuleMember -Function ($PublicCmdlet.Basename + $MeasureCmdlet.Basename + $AuxCmdlet.Basename)