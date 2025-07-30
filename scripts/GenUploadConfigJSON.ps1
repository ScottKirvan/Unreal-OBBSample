# ===============================================================
# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
# ===============================================================

Param(
    [Parameter(Mandatory = $true)]
    [string]$InputDir,

    [Parameter(Mandatory = $true)]
    [string]$OutputFile
)

$jsonObj = [ordered]@{}

Get-ChildItem -Path $InputDir -File | ForEach-Object {
    $jsonObj[$_.Name] = [ordered]@{ required = $true }
}

$jsonObj['optional_file.txt'] = @{ }
$json = $jsonObj | ConvertTo-Json
# $json | Set-Content -Path $OutputFile -Encoding utf8NoBOM

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# write the file without BOM
[System.IO.File]::WriteAllText($OutputFile, $json, $utf8NoBom)

Write-Host "Wrote JSON to $OutputFile"
