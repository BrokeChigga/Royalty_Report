param(
  [string]$buildLabel,
  [string]$v,
  [string]$r,
  [string]$m,
  [string]$f,
  [string]$sourceRoot
)

Write-Host 'Running Team Pre-Build Script with arguments' $buildLabel $v $r $m $f $sourceRoot

#
#Do prebuild work here
#
#make sure to set retval appropriately
#

$retval = false

return $retval

