Get-Module Outsystems.SetupTools | Remove-Module -Force
Import-Module $PSScriptRoot\..\..\src\Outsystems.SetupTools -Force -ArgumentList $false, '', '', $false

InModuleScope -ModuleName OutSystems.SetupTools {
    Describe 'Install-OSServerPreReqs Tests' {
        #TODO installed / not installed console
        # Global mocks
        Mock IsAdmin { return $true }
        Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $False; 'HasMSBuild2015u3' = $False ; 'HasMSBuild2017' = $False; 'LatestVersionInstalled' = $Null; 'RebootNeeded' = $False } }
        Mock GetDotNet4Version { return $null }
        Mock GetWindowsServerHostingVersion { return $null }

        Mock InstallDotNet { return 0 }
        Mock InstallBuildTools { return 0 }
        Mock InstallWindowsFeatures { return @{ 'Output' = 'All good'; 'ExitCode' = @{ 'value__' = 0 }; 'RestartNeeded' = @{ 'value__' = 1 }; 'Success' = $true } }
        Mock InstallDotNetCore { return 0 }
        Mock ConfigureServiceWMI {}
        Mock ConfigureServiceWindowsSearch {}
        Mock DisableFIPS {}
        Mock ConfigureWindowsEventLog {}
        Mock ConfigureMSMQDomainServer {}

        $assRunInstallDotNet = @{ 'CommandName' = 'InstallDotNet'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunInstallDotNet = @{ 'CommandName' = 'InstallDotNet'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunInstallBuildTools = @{ 'CommandName' = 'InstallBuildTools'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunInstallBuildTools = @{ 'CommandName' = 'InstallBuildTools'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunInstallWindowsFeatures = @{ 'CommandName' = 'InstallWindowsFeatures'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunInstallWindowsFeatures = @{ 'CommandName' = 'InstallWindowsFeatures'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunInstallDotNetCore = @{ 'CommandName' = 'InstallDotNetCore'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunInstallDotNetCore = @{ 'CommandName' = 'InstallDotNetCore'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunConfigureServiceWMI = @{ 'CommandName' = 'ConfigureServiceWMI'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunConfigureServiceWMI = @{ 'CommandName' = 'ConfigureServiceWMI'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunConfigureServiceWindowsSearch = @{ 'CommandName' = 'ConfigureServiceWindowsSearch'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunConfigureServiceWindowsSearch = @{ 'CommandName' = 'ConfigureServiceWindowsSearch'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunDisableFIPS = @{ 'CommandName' = 'DisableFIPS'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunDisableFIPS = @{ 'CommandName' = 'DisableFIPS'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunConfigureWindowsEventLog = @{ 'CommandName' = 'ConfigureWindowsEventLog'; 'Times' = 3; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunConfigureWindowsEventLog = @{ 'CommandName' = 'ConfigureWindowsEventLog'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}
        $assRunConfigureMSMQDomainServer = @{ 'CommandName' = 'ConfigureMSMQDomainServer'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
        $assNotRunConfigureMSMQDomainServer = @{ 'CommandName' = 'ConfigureMSMQDomainServer'; 'Times' = 0; 'Exactly' = $true; 'Scope' = 'Context'}

        Context 'When installing OS 10 on a clean machine and everything succeed' {

            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the .NET installation' { Assert-MockCalled @assRunInstallDotNet }
            It 'Should run the BuildToold installation' { Assert-MockCalled @assRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should not run the .NET core installation' { Assert-MockCalled @assNotRunInstallDotNetCore }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should disable the FIPS' { Assert-MockCalled @assRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }
            It 'Should configure the MSMQ' { Assert-MockCalled @assRunConfigureMSMQDomainServer }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When installing OS 10 on a machine with all prereqs installed' {

            Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $True; 'HasMSBuild2015u3' = $False ; 'HasMSBuild2017' = $False; 'LatestVersionInstalled' = 'MS Build Tools 2015'; 'RebootNeeded' = $False } }
            Mock GetDotNet4Version { return 461308 }

            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the .NET installation' { Assert-MockCalled @assNotRunInstallDotNet }
            It 'Should not run the BuildToold installation' { Assert-MockCalled @assNotRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should not run the .NET core installation' { Assert-MockCalled @assNotRunInstallDotNetCore }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should disable the FIPS' { Assert-MockCalled @assRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }
            It 'Should configure the MSMQ' { Assert-MockCalled @assRunConfigureMSMQDomainServer }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When installing OS 11 on a clean machine and everything succeed' {

            $result = Install-OSServerPreReqs -MajorVersion '11.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run the .NET installation' { Assert-MockCalled @assRunInstallDotNet }
            It 'Should run the BuildToold installation' { Assert-MockCalled @assRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should run the .NET core installation' { Assert-MockCalled @assRunInstallDotNetCore }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should disable the FIPS' { Assert-MockCalled @assRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }
            It 'Should not configure the MSMQ' { Assert-MockCalled @assNotRunConfigureMSMQDomainServer }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When installing OS 11 with all prereqs installed' {

            Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $True; 'HasMSBuild2015u3' = $False ; 'HasMSBuild2017' = $False; 'LatestVersionInstalled' = 'MS Build Tools 2015'; 'RebootNeeded' = $False } }
            Mock GetDotNet4Version { return 461808 }
            Mock GetWindowsServerHostingVersion { return '2.1.12' }

            $result = Install-OSServerPreReqs -MajorVersion '11.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the .NET installation' { Assert-MockCalled @assNotRunInstallDotNet }
            It 'Should not run the BuildToold installation' { Assert-MockCalled @assNotRunInstallBuildTools }
            It 'Should install the windows features installation' { Assert-MockCalled @assRunInstallWindowsFeatures }
            It 'Should not run the .NET core installation' { Assert-MockCalled @assNotRunInstallDotNetCore }
            It 'Should configure the WMI service' { Assert-MockCalled @assRunConfigureServiceWMI }
            It 'Should configure the Windows search service' { Assert-MockCalled @assRunConfigureServiceWindowsSearch }
            It 'Should disable the FIPS' { Assert-MockCalled @assRunDisableFIPS }
            It 'Should configure the windows event log' { Assert-MockCalled @assRunConfigureWindowsEventLog }
            It 'Should not configure the MSMQ' { Assert-MockCalled @assNotRunConfigureMSMQDomainServer }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 0
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When user is not admin' {

            Mock IsAdmin { return $false }
            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run anything' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallBuildTools
                Assert-MockCalled @assNotRunInstallWindowsFeatures
                Assert-MockCalled @assNotRunInstallDotNetCore
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'The current user is not Administrator or not running this script in an elevated session'
            }
            It 'Should output an error' { $err[-1] | Should Be 'The current user is not Administrator or not running this script in an elevated session' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET installation fails to start' {

            Mock InstallDotNet { throw 'Big error' }
            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assNotRunInstallDotNetCore
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error downloading or starting the .NET installation'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error downloading or starting the .NET installation' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET reports a reboot' {

            Mock InstallDotNet { return 3010 }
            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run every action' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assNotRunInstallDotNetCore
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
                Assert-MockCalled @assRunConfigureWindowsEventLog
                Assert-MockCalled @assRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $true
                $result.ExitCode | Should Be 3010
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed but a reboot is required'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET reports an error' {

            Mock InstallDotNet { return 10 }
            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assNotRunInstallDotNetCore
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 10
                $result.Message | Should Be 'Error installing .NET 4.7.2'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing .NET 4.7.2. Exit code: 10' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'Build tools versions are correctly validated' {

            Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $False; 'HasMSBuild2015u3' = $False ; 'HasMSBuild2017' = $True; 'LatestVersionInstalled' = 'Build Tools 2017'; 'RebootNeeded' = $False } }

            $Major10 = '10.0'
            $result = IsMSBuildToolsVersionValid -MajorVersion $Major10 -InstallInfo (GetMSBuildToolsInstallInfo)

            It "MS Build 2017 is not supported in major version '$Major10'" {
                $result | Should Be $False
            }

            Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $False; 'HasMSBuild2015u3' = $True ; 'HasMSBuild2017' = $False; 'LatestVersionInstalled' = 'Build Tools 2015 Update 3'; 'RebootNeeded' = $False } }

            $result = IsMSBuildToolsVersionValid -MajorVersion $Major10 -InstallInfo (GetMSBuildToolsInstallInfo)

            It "MS Build 2015 Update 3 is supported in major version '$Major10'" {
                $result | Should Be $True
            }

            $Major11 = '11.0'

            Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $True; 'HasMSBuild2015u3' = $True ; 'HasMSBuild2017' = $False; 'LatestVersionInstalled' = 'Build Tools Update 3'; 'RebootNeeded' = $False } }

            $result = IsMSBuildToolsVersionValid -MajorVersion $Major11 -InstallInfo (GetMSBuildToolsInstallInfo)

            It "All 2015 version MS Build are supported in major version '$Major11'" {
                $result | Should Be $True
            }

            Mock GetMSBuildToolsInstallInfo { return @{ 'HasMSBuild2015' = $True; 'HasMSBuild2015u3' = $True ; 'HasMSBuild2017' = $True; 'LatestVersionInstalled' = 'Build Tools 2017'; 'RebootNeeded' = $False } }

            $result = IsMSBuildToolsVersionValid -MajorVersion $Major11 -InstallInfo (GetMSBuildToolsInstallInfo)

            It "All MS Build version are supported in major version '$Major11'" {
                $result | Should Be $True
            }
        }

        Context 'When build tools installation fails to start' {

            Mock InstallBuildTools { throw 'Big error' }
            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assNotRunInstallDotNetCore
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error downloading or starting the Build Tools installation'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error downloading or starting the Build Tools installation' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When build tools a reboot' {

            Mock InstallBuildTools { return 3010 }
            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run every action' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assNotRunInstallDotNetCore
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
                Assert-MockCalled @assRunConfigureWindowsEventLog
                Assert-MockCalled @assRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $true
                $result.ExitCode | Should Be 3010
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed but a reboot is required'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When build tools reports an error' {

            Mock InstallBuildTools { return 10 }
            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assNotRunInstallDotNetCore
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 10
                $result.Message | Should Be 'Error installing Build Tools 2015'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing Build Tools 2015. Exit code: 10' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When windows features installation fails to start' {

            Mock InstallWindowsFeatures { throw 'Some error' }
            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assNotRunInstallDotNetCore
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error starting the windows features installation'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error starting the windows features installation' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When windows features reports a reboot' {

            Mock InstallWindowsFeatures { return @{ 'Output' = 'All good'; 'ExitCode' = @{ 'value__' = 0 }; 'RestartNeeded' = @{ 'value__' = 2 }; 'Success' = $true} }
            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run every action' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assNotRunInstallDotNetCore
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
                Assert-MockCalled @assRunConfigureWindowsEventLog
                Assert-MockCalled @assRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $true
                $result.ExitCode | Should Be 3010
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed but a reboot is required'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When windows features reports an error' {

            Mock InstallWindowsFeatures { return @{ 'Output' = 'All good'; 'ExitCode' = @{ 'value__' = 10 }; 'RestartNeeded' = @{ 'value__' = 1 }; 'Success' = $false} }
            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assNotRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assNotRunInstallDotNetCore
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 10
                $result.Message | Should Be 'Error installing windows features'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing windows features. Exit code: 10' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET core installation fails to start' {

            Mock InstallDotNetCore { throw 'Big error' }
            $result = Install-OSServerPreReqs -MajorVersion '11.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunInstallDotNetCore
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error downloading or starting the .NET Core installation'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error downloading or starting the .NET Core installation' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET core reports a reboot' {

            Mock InstallDotNetCore { return 3010 }
            $result = Install-OSServerPreReqs -MajorVersion '11.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should run every action' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunInstallDotNetCore
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
                Assert-MockCalled @assRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $true
                $result.RebootNeeded | Should Be $true
                $result.ExitCode | Should Be 3010
                $result.Message | Should Be 'Outsystems platform server pre-requisites successfully installed but a reboot is required'
            }
            It 'Should not output an error' { $err.Count | Should Be 0 }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When .NET core reports an error' {

            Mock InstallDotNetCore { return 10 }
            $result = Install-OSServerPreReqs -MajorVersion '11.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the next actions' {
                Assert-MockCalled @assNotRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetCore
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assNotRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be 10
                $result.Message | Should Be 'Error installing .NET Core Windows Server Hosting bundle'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error installing .NET Core Windows Server Hosting bundle. Exit code: 10' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When configure WMI reports an error' {

            Mock ConfigureServiceWMI { throw 'Big Error' }
            $result = Install-OSServerPreReqs -MajorVersion '11.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetCore
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assNotRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error configuring the WMI service'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error configuring the WMI service' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When configure windows search reports an error' {

            Mock ConfigureServiceWindowsSearch { throw 'Big Error' }
            $result = Install-OSServerPreReqs -MajorVersion '11.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetCore
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assNotRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error configuring the Windows search service'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error configuring the Windows search service' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When configure FIPS reports an error' {

            Mock DisableFIPS { throw 'Big Error' }
            $result = Install-OSServerPreReqs -MajorVersion '11.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetCore
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
                Assert-MockCalled @assNotRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error disabling FIPS compliant algorithms checks'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error disabling FIPS compliant algorithms checks' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When configure Event Log reports an error' {

            Mock ConfigureWindowsEventLog { throw 'Big Error' }
            $assRunConfigureWindowsEventLog = @{ 'CommandName' = 'ConfigureWindowsEventLog'; 'Times' = 1; 'Exactly' = $true; 'Scope' = 'Context'}
            $result = Install-OSServerPreReqs -MajorVersion '11.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assRunInstallDotNetCore
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
                Assert-MockCalled @assRunConfigureWindowsEventLog
                Assert-MockCalled @assNotRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error configuring Security Event Log'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error configuring Security Event Log' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '11.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }

        Context 'When configure MSMQ reports an error' {

            Mock ConfigureMSMQDomainServer { throw 'Big Error' }
            $result = Install-OSServerPreReqs -MajorVersion '10.0' -ErrorVariable err -ErrorAction SilentlyContinue

            It 'Should not run the next actions' {
                Assert-MockCalled @assRunInstallDotNet
                Assert-MockCalled @assRunInstallBuildTools
                Assert-MockCalled @assNotRunInstallDotNetCore
                Assert-MockCalled @assRunInstallWindowsFeatures
                Assert-MockCalled @assRunConfigureServiceWMI
                Assert-MockCalled @assRunConfigureServiceWindowsSearch
                Assert-MockCalled @assRunDisableFIPS
                Assert-MockCalled @assRunConfigureWindowsEventLog
                Assert-MockCalled @assRunConfigureMSMQDomainServer
            }
            It 'Should return the right result' {
                $result.Success | Should Be $false
                $result.RebootNeeded | Should Be $false
                $result.ExitCode | Should Be -1
                $result.Message | Should Be 'Error configuring the Message Queuing service'
            }
            It 'Should output an error' { $err[-1] | Should Be 'Error configuring the Message Queuing service' }
            It 'Should not throw' { { Install-OSServerPreReqs -MajorVersion '10.0' -ErrorAction SilentlyContinue } | Should Not throw }
        }
    }
}
