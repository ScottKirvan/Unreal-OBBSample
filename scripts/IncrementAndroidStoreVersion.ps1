<#
===============================================================
Copyright (c) Meta Platforms, Inc. and affiliates.
All rights reserved.

This source code is licensed under the MIT license found in the
LICENSE file in the root directory of this source tree.
===============================================================

.SYNOPSIS
  Increments the StoreVersion in an Unreal DefaultEngine.ini file.

.DESCRIPTION
  This script locates a line in the .ini that matches StoreVersion=<integer>,
  reads the integer value, increments by 1, and overwrites that line.
  If the file has multiple StoreVersion lines, it will update only
  the first match by default.

.PARAMETER IniPath
  The full path to DefaultEngine.ini

.EXAMPLE
  PS> .\IncrementStoreVersion.ps1 -IniPath "C:\MyProject\Config\DefaultEngine.ini"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string] $IniPath
)

Write-Host "Reading from $IniPath"

# Read all lines
$lines = Get-Content -Path $IniPath

# Regex to match lines like:
#   StoreVersion=123
#   StoreVersion = 123
#   StoreVersion="123"
#   etc.
$pattern = '^\s*StoreVersion\s*=\s*"?(?<version>\d+)"?\s*$'

$found = $false
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match $pattern) {
        $found = $true
        $currentVersion = [int] $Matches['version']
        $newVersion = $currentVersion + 1

        Write-Host "Current StoreVersion is $currentVersion"
        Write-Host "New StoreVersion will be $newVersion"

        # Replace the line with the incremented version
        $lines[$i] = "StoreVersion=$newVersion"
        break
    }
}

if (-not $found) {
    Write-Warning "No StoreVersion= line found. Nothing updated."
} else {
    # Write the updated lines back to the file
    Set-Content -Path $IniPath -Value $lines
    Write-Host "Updated $IniPath with the new StoreVersion."
}
