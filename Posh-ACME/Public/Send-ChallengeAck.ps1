function Send-ChallengeAck {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [string]$ChallengeUrl,
        [Parameter(Position=1)]
        [PSTypeName('PoshACME.PAAccount')]$Account
    )

    Begin {
        trap { $PSCmdlet.ThrowTerminatingError($_) }

        # make sure any account passed in is actually associated with the current server
        # or if no account was specified, that there's a current account.
        if (-not $Account) {
            if (-not ($Account = Get-PAAccount)) {
                throw "No Account parameter specified and no current account selected. Try running Set-PAAccount first."
            }
        } elseif ($Account.id -notin (Get-PAAccount -List).id) {
            throw "Specified account id $($Account.id) was not found in the current server's account list."
        }
        # make sure it's valid
        if ($Account.status -ne 'valid') {
            throw "Account status is $($Account.status)."
        }
    }

    Process {

        # build the header
        $header = @{
            alg = $Account.alg
            kid = $Account.location
            nonce = $script:Dir.nonce
            url = $ChallengeUrl
        }

        # send the notification
        try {
            Invoke-ACME $header '{}' $Account -EA Stop | Out-Null
        } catch { throw }

    }
}
