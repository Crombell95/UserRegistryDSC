##################
## UserRegistry ##
##################

<#
.SYNOPSIS
    Returns the current value of a registry setting in all HKUSER hives.
.PARAMETER Key
    Registry key where the setting is located.
.PARAMETER ValueName
    Name of the value to get.
#>

function Get-UserRegistry {
    Param(
        [Parameter(Mandatory)][string]$Key,

        [Parameter(Mandatory)][string]$ValueName
    )

    $UserProfileList = [System.Collections.Generic.List[PSCustomObject]]::new()

    $UserProfiles = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*" | 
        Where-Object {$_.PSChildName -match "S-1-5-..-.*"} | 
            Select-Object @{Name = 'SID'     ; Expression = {$_.PSChildName}},
                          @{Name = 'UserHive'; Expression = {"$($_.ProfileImagePath)\NTuser.dat"}} |
                            ForEach-Object {$UserProfileList.Add($_) | Out-Null}

    $DefaultUser = [PSCustomObject]@{
        SID      = 'DEF'
        UserHive = "$((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList").Default)\NTuser.dat"
    }
     
    $UserProfileList.Add($DefaultUser)

    $get = foreach ($UserProfile in $UserProfileList) {
        if (Test-Path $($UserProfile.UserHive)) {
            
            $Loaded = Test-Path "Registry::HKEY_USERS\$($UserProfile.SID)"
            
            if (-not $Loaded) {
                reg.exe LOAD "HKU\$($UserProfile.SID)" "$($UserProfile.UserHive)" | Out-Null
            }

            $UserKey = $Key.Replace('HKEY_CURRENT_USER',"Registry::HKEY_USERS\$($UserProfile.SID)")

            try {
                $Value = (Get-ItemProperty -Path $UserKey -Name $ValueName -ErrorAction Stop).$ValueName
            }
            catch {
                $Value = $null
            }
            
            [PSCustomObject]@{
                SID       = $($UserProfile.SID)
                UserHive  = $($UserProfile.UserHive)
                ValueData = $Value
            }
        }
    }

    return $get
}

<#
.SYNOPSIS
    Tests the current value of a registry setting in all HKUSER hives against the desired value and returns a boolean.
    If one or more users don't have the desired value the function will return $false.
.PARAMETER Key
    Registry key where the setting is located.
.PARAMETER ValueName
    Name of the value to get.
.PARAMETER ValueData
    Desired value of the setting.
#>

function Test-UserRegistry {
    Param(
        [Parameter(Mandatory)][string]$Key,

        [Parameter(Mandatory)][string]$ValueName,

        [Parameter(Mandatory)][string]$ValueData
    )

    $get = Get-UserRegistry -Key $this.Key -ValueName $this.ValueName

    foreach ($entry in $get) {
        if ($entry.ValueData -eq $ValueData) {
            $test = $true
        }
        else {
            $test = $false
            break
        }
    }

    if ($test -eq $true) {
        Write-Verbose -Message "$(Join-Path -Path $Key -ChildPath $ValueName) is in desired state"
    }

    return $test
}

<#
.SYNOPSIS
    Changes the value of a registry setting in all necessary HKUSER hives to the desired value.
.PARAMETER Key
    Registry key where the setting is located.
.PARAMETER ValueName
    Name of the value to get.
.PARAMETER ValueData
    Desired value of the setting.
#>

function Set-UserRegistry {
    Param(
        [Parameter(Mandatory)][string]$Key,

        [Parameter(Mandatory)][string]$ValueName,

        [Parameter(Mandatory)][string]$ValueType,

        [Parameter(Mandatory)][string]$ValueData
    )

    $get = Get-UserRegistry -Key $this.Key -ValueName $this.ValueName

    $set = $get | Where-Object {$_.ValueData -ne $ValueData}

    foreach ($UserProfile in $set) {
        $UserKey = $Key.Replace('HKEY_CURRENT_USER',"Registry::HKEY_USERS\$($UserProfile.SID)")

        $Loaded = Test-Path "Registry::HKEY_USERS\$($UserProfile.SID)"
            
        if (-not $Loaded) {
            reg.exe LOAD "HKU\$($UserProfile.SID)" "$($UserProfile.UserHive)" | Out-Null
        }

        if ( -not (Test-Path $UserKey) ) {
            New-Item $UserKey -Force | Out-Null
        }

        try {
            Write-Verbose -Message "Changing Value for $(Join-Path -Path $UserKey -ChildPath $ValueName) from $($UserProfile.ValueData) to $ValueData"
            Set-Itemproperty -Path $UserKey -Name $ValueName -Value $ValueData -Type $ValueType -Force -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Verbose -Message "Creating $(Join-Path -Path $Key -ChildPath $ValueName) with value $ValueData"
            New-ItemProperty -LiteralPath $UserKey -Name $ValueName -Value $ValueData -Type $ValueType -Force | Out-Null
        }

        if (-not $Loaded) {
            reg.exe UNLOAD "HKU\$($UserProfile.SID)" | Out-Null
        }
    }
}

<#
.SYNOPSIS
    Class-based DSC resource to modify registry settings for all users in the HKEY_USERS hive.
.PARAMETER Key
    Registry key where the setting is located.
.PARAMETER ValueName
    Name of the value to get.
.PARAMETER ValueData
    Desired value of the setting.
#>

[DscResource()]
class UserRegistry {
    [DSCProperty(Key)]
    [string]$Key

    [DSCProperty(Key)]
    [string]$ValueName

    [DSCProperty(Mandatory)]
    [string]$ValueType

    [DSCProperty(Mandatory)]
    [string]$ValueData

    [DSCProperty(NotConfigurable)]
    [string]$SID

    [DSCProperty(NotCOnfigurable)]
    [string]$UserHive

    [UserRegistry] Get () {
        $get = Get-UserRegistry -Key $this.Key -ValueName $this.ValueName

        # The get method cannot return an array of UserReistry objects as UserRegistry object
        # This return construction is to ensure the get method shows if all keys are in desired state or not
        # If not, the value of the first item not in desired state is shown
        if (($get.ValueData | Select-Object -Unique) -ne $this.ValueData) {
            return [UserRegistry]@{
                UserHive = ''
                SID      = ''
                ValueData = $($get.ValueData | Where-Object {$_ -ne $this.ValueData})[0]
            }
        }
        else {
            return [UserRegistry]@{
                UserHive = ''
                SID      = ''
                ValueData = $($get.ValueData | Select-Object -Unique)
            }
        }
    }

    [void] Set () {
        $set = Set-UserRegistry -Key $this.Key -ValueName $this.ValueName -ValueType $this.ValueType -ValueData $this.ValueData
    }

    [bool] Test () {
        $test = Test-UserRegistry -Key $this.Key -ValueName $this.ValueName -ValueData $this.ValueData
        return $test
    }
}