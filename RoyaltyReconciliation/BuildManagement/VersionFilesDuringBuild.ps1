<#-----------------------------------------------------------#
 |                     Prebuild Script                       |
 |                       DO NOT EDIT                         |
 #-----------------------------------------------------------#>
#Note: This file must be encoded as UCS-2 Little endian for 
#      the copyright symbols to work in the assembly-info files

param(
    [string]$buildConfig = 'Release',
    [string]$isvNextBuildStr = 'Not Set'
)

Invoke-Expression "c:\BuildManagement\Scripts\IMOPreBuildScript.ps1 $buildConfig $isvNextBuildStr"
