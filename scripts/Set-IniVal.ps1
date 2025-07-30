<#
===============================================================
Copyright (c) Meta Platforms, Inc. and affiliates.
All rights reserved.

This source code is licensed under the MIT license found in the
LICENSE file in the root directory of this source tree.
===============================================================

.SYNOPSIS
  Set or add the PackageName entry in an Unreal DefaultEngine.ini file.

.EXAMPLE
  PS> .\Set-PackageName.ps1 com.mycompany.mygame
  -- edits .\DefaultEngine.ini in the current folder

.EXAMPLE
  PS> .\Set-PackageName.ps1 MyGame 'C:\Project\Config\DefaultEngine.ini'
  -- edits a specific file
#>

param (
	[Parameter(Mandatory = $true, Position = 0)]
	[string]$IniKey,                      # becomes the left-hand side of Foo=Bar
    [Parameter(Mandatory = $true,  Position = 1)]
    [string]$IniValue,                 # becomes the right-hand side of Foo=Bar
    [Parameter(Mandatory = $true, Position = 2)]
    [string]$IniPath
)

$pattern      = "^$IniKey=.*"
$replacement  = "$IniKey=$IniValue"

# Read, modify (or add), then write back
$content = Get-Content -LiteralPath $IniPath

if ($content -match $pattern) {
    $content = $content -replace $pattern, $replacement
} else {
    $content += $replacement
}

# Write in-place (UTF-8 without BOM keeps Unreal happy)
$content | Set-Content -LiteralPath $IniPath -Encoding utf8
