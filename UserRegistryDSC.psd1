@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'UserRegistryDSC.psm1'
    
    # Version number of this module.
    ModuleVersion = '0.1.2'
    
    # ID used to uniquely identify this module
    GUID = '40493cb6-0390-4515-a8da-ae005f1d43c7'
    
    # Author of this module
    Author = 'Crombell95'
    
    # Company or vendor of this module
    CompanyName = ''
    
    # Copyright statement for this module
    Copyright = ''
    
    # Description of the functionality provided by this module
    Description = 'DSC resource for configuring user registry settings.' 
    
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @()
    
    # Functions to export from this module
    FunctionsToExport = @()
    
    # DSC resources to export from this module
    DscResourcesToExport = @(
        'UserRegistry'
    )
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
    
        PSData = @{
    
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @(
                'PSModule'
                'Registry'
                'DSC'
                'DesiredStateConfiguration'
                'DSCResource'
            )
    
            # A URL to the license for this module.
            LicenseUri = 'https://github.com/Crombell95/UserRegistryDSC/blob/main/LICENSE'
    
            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/Crombell95/UserRegistryDSC'
    
            # A URL to an icon representing this module.
            # IconUri = ''
    
            # ReleaseNotes of this module
            # ReleaseNotes = ''
    
        } # End of PSData hashtable
    
    } 
}