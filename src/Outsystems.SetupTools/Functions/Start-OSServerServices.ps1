function Start-OSServerServices
{
    <#
    .SYNOPSIS
    Starts the OutSystems platform services.

    .DESCRIPTION
    This will start all OutSystems platform services by the recommended order.

    .EXAMPLE
    Start-OSServerServices

    #>

    [CmdletBinding()]
    param()

    begin
    {
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 0 -Stream 0 -Message "Starting"
        SendFunctionStartEvent -InvocationInfo $MyInvocation
    }

    process
    {
        if (-not $(IsAdmin))
        {
            LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 3 -Message "The current user is not Administrator or not running this script in an elevated session"
            WriteNonTerminalError -Message "The current user is not Administrator or not running this script in an elevated session"

            return
        }

        foreach ($OSService in $OSServices)
        {
            if ($(Get-Service -Name $OSService -ErrorAction SilentlyContinue | Where-Object {$_.StartType -ne "Disabled"}))
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Starting OS service: $OSService"
                try
                {
                    Get-Service -Name $OSService | Start-Service -WarningAction SilentlyContinue -ErrorAction Stop
                }
                catch
                {
                    LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Exception $_.Exception -Stream 3 -Message "Error starting the service $OSService"
                    WriteNonTerminalError -Message "Error starting the service $OSService"

                    return
                }
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service started"
            }
            else
            {
                LogMessage -Function $($MyInvocation.Mycommand) -Phase 1 -Stream 0 -Message "Service $OSService not found or is disabled. Skipping..."
            }
        }
    }

    end
    {
        SendFunctionEndEvent -InvocationInfo $MyInvocation
        LogMessage -Function $($MyInvocation.Mycommand) -Phase 2 -Stream 0 -Message "Ending"
    }
}
