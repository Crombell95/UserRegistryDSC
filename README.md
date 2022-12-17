
# UserRegistryDSC
This module contains a custom DSC resource for configuring user registry settings. Normally the DSC configuration will only change the HKCU setting under the SYSTEM account. This resource works around this limitation by enumerating all registered users from the ProfileList and sets the value in each HKU.

## DSC Resources

### UserRegistry
Apply a registry setting in the user registry key of all registerd users on the server. 

## Examples
```Powershell 
Configuration UserRegistry {
    Import-DscResource -ModuleName UserRegistryDSC

    # Example from CIS Microsoft Windows Server 2019 Benchmark - V1.3.0
    # 19.7.47.2.1 (L2) Ensure 'Prevent Codec Download' is set to 'Enabled'
    node localhost {
        UserRegistry PreventCodecDownload {
            Key       = "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer"
            ValueName = 'PreventCodecDownload'
            ValueType = 'Dword'
            ValueData = 1
        }
    }
}
```