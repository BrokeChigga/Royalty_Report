#
#  DO NOT EDIT THIS FILE. 
#

$scriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition

function Sign-Files
{
    if (-not $filesToSign)
    {
        return $true
    }
    
    $signToolPath = "C:\Program Files (x86)\Windows Kits\8.1\bin\x64\signtool.exe"
    if (-not (Test-Path $signToolPath))
    {
        Write-Error "Cannot find signtool.exe at path $signToolPath"
        return $false
    }

    foreach($file in $filesToSign)
    {
        # Make sure the file to sign exists

        $fileToSign = Join-Path -path $releaseDirectory -childpath $file

        Write-Host "file to sign: $fileToSign"
        if (-not (Test-Path $fileToSign))
        {
            Write-Error "Cannot find file to sign $fileToSign"
            return $false
        }

        & $signToolPath sign /sha1 d0c3261b3e55f115e29dc16dd39709392db8b2ba /tr http://tsa.starfieldtech.com /td SHA256 $fileToSign

        if ($LastExitCode -ne 0)
        {
            Write-Error "Error signing file $fileToSign"
            return $false
        }
    }

    return $true
}

function Read-ProductSpecificValues
{
    $productSpecificFileName = 'ProductSpecificVersionValues.xml'
    $productSpecificFile = Join-Path -path $scriptPath -childpath $productSpecificFileName

    if (-not (Test-Path $productSpecificFile))
    {
        Write-Error 'cannot find ' $productSpecificFileName
        return $false
    }
    
    Write-Host 'Reading Product Specific Values from ' $productSpecificFile
    [xml]$xml = Get-Content $productSpecificFile

    #set the variables with Set-Variable so that they remain visible after this function ends
    [string[]] $filesToSign = @()
    foreach( $file in $xml.Values.FilesToSign.File)
    {
        $filesToSign += $file
    }
    
    Set-Variable -Name filesToSign -Value $filesToSign -Scope Global
    
    Write-Host 'filesToSign:' 
    foreach( $file in $filesToSign)
    {
        Write-Host "  " $file
    }

    return $true
}

#-------------------------------------------------------------------------------  
# main()
#-------------------------------------------------------------------------------  

# Make sure path to output directory is available
if (-not $Env:TF_BUILD_BINARIESDIRECTORY)
{
    Write-Error 'TF_BUILD_BINARIESDIRECTORY environment variable is missing.'
    Write-Host '$Env:TF_BUILD_BINARIESDIRECTORY - For example, enter something like:'
    Write-Host '$Env:TF_BUILD_BINARIESDIRECTORY = "C:\source\imo\buildmanagement\bin"'
    exit 1
}
elseif (-not (Test-Path $Env:TF_BUILD_BINARIESDIRECTORY))
{
    $msg = 'TF_BUILD_BINARIESDIRECTORY does not exist: ' + $Env:TF_BUILD_BINARIESDIRECTORY
    Write-Error $msg
    exit 1
}

$releaseDirectory = Join-Path -path $Env:TF_BUILD_BINARIESDIRECTORY -childpath "Release"
Write-Host 'Release Directory:' $releaseDirectory

if (-not (Test-Path $releaseDirectory))
{
    $msg = 'Release Directory does not exist: ' + $releaseDirectory
    Write-Error $msg
    exit 1
}


if (-not (Read-ProductSpecificValues))
{
    Write-Error 'Failed to read product specific values'
    exit 1
}

if (-not (Sign-Files))
{
    Write-Error 'ProductSpecific post-build script failed'    
    exit 1
}
