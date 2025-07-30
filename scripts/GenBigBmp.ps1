<#
===============================================================
Copyright (c) Meta Platforms, Inc. and affiliates.
All rights reserved.

This source code is licensed under the MIT license found in the
LICENSE file in the root directory of this source tree.
===============================================================

.SYNOPSIS
    Creates a ~600MB 24-bit BMP file with random pixel data.

.DESCRIPTION
    This script builds a valid BMP header (54 bytes) for a 16,384 x 16,384
    24-bit image and writes random bytes for the pixel data. The resulting
    file will be slightly under 600MB.

.PARAMETER OutputPath
    The output file path for the generated BMP.

.EXAMPLE
    .\GenBigBmp.ps1 -OutputPath "C:\temp\BigRandom.bmp"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

# -- Configuration --
$Width = 16384
$Height = 16384
$BitsPerPixel = 24

# For 24-bit BMP, row size must be padded to a multiple of 4 bytes.
# rowSize = ceil((Width * BitsPerPixel) / 32) * 4
# But for 24 bits, it’s effectively (3*Width), plus padding if not multiple of 4.
# For 16384 width and 24 bits, 3*16384/4 = 49152 which is already a multiple of 4.
$rowSize = 3 * $Width

# Total image size in bytes (just the pixel data).
$pixelDataSize = $rowSize * $Height

# Total file size = pixelDataSize + size of headers (54 bytes)
$fileSize = 54 + $pixelDataSize

Write-Host "Generating a BMP of size $Width x $Height (24-bit) ..."
Write-Host "Total file size will be approximately $($fileSize / 1GB) GB"

# -- Create and open a file stream --
$fileStream = New-Object System.IO.FileStream($OutputPath, 'Create')

# ----------------------------------------------------
# Build BMP Header (BITMAPFILEHEADER + BITMAPINFOHEADER)
# ----------------------------------------------------
# BITMAPFILEHEADER (14 bytes)
#   WORD bfType = 'BM' (2 bytes)
#   DWORD bfSize (4 bytes)
#   WORD bfReserved1 = 0 (2 bytes)
#   WORD bfReserved2 = 0 (2 bytes)
#   DWORD bfOffBits = 54 (4 bytes) [14 + 40 for 24-bit BMP]

# "BM" in ASCII
$bfType = [System.Text.Encoding]::ASCII.GetBytes("BM")

# Convert 32-bit integers to little-endian bytes
$bfSize = [BitConverter]::GetBytes($fileSize)
$bfReserved = [BitConverter]::GetBytes(0)
$bfOffBits = [BitConverter]::GetBytes(54)  # 14 (file header) + 40 (info header)

# Combine to form the 14-byte BITMAPFILEHEADER
$bitmapFileHeader = New-Object Byte[] 14
$bfType.CopyTo($bitmapFileHeader, 0)       # 'BM'
$bfSize.CopyTo($bitmapFileHeader, 2)       # file size
$bfReserved.CopyTo($bitmapFileHeader, 6)   # reserved
$bfOffBits.CopyTo($bitmapFileHeader, 10)   # start of pixel data

# ----------------------------------------------------
# BITMAPINFOHEADER (40 bytes)
#   DWORD biSize = 40
#   LONG  biWidth
#   LONG  biHeight
#   WORD  biPlanes = 1
#   WORD  biBitCount = 24
#   DWORD biCompression = 0 (BI_RGB, uncompressed)
#   DWORD biSizeImage = 0 (okay for uncompressed)
#   LONG  biXPelsPerMeter = 2835 (approx 72 DPI)
#   LONG  biYPelsPerMeter = 2835 (approx 72 DPI)
#   DWORD biClrUsed = 0
#   DWORD biClrImportant = 0

$biSize = [BitConverter]::GetBytes(40)
$biWidth = [BitConverter]::GetBytes($Width)
$biHeight = [BitConverter]::GetBytes($Height)
$biPlanes = [BitConverter]::GetBytes(1)
$biBitCount = [BitConverter]::GetBytes($BitsPerPixel)
$biCompression = [BitConverter]::GetBytes(0)
$biSizeImage = [BitConverter]::GetBytes(0)
# 2835 pixels per meter ~ 72 DPI
$biXPelsPerMeter = [BitConverter]::GetBytes(2835)
$biYPelsPerMeter = [BitConverter]::GetBytes(2835)
$biClrUsed = [BitConverter]::GetBytes(0)
$biClrImportant = [BitConverter]::GetBytes(0)

# Build the 40-byte BITMAPINFOHEADER
$bitmapInfoHeader = New-Object Byte[] 40
$biSize.CopyTo($bitmapInfoHeader, 0)
$biWidth.CopyTo($bitmapInfoHeader, 4)
$biHeight.CopyTo($bitmapInfoHeader, 8)
$biPlanes.CopyTo($bitmapInfoHeader, 12)
$biBitCount.CopyTo($bitmapInfoHeader, 14)
$biCompression.CopyTo($bitmapInfoHeader, 16)
$biSizeImage.CopyTo($bitmapInfoHeader, 20)
$biXPelsPerMeter.CopyTo($bitmapInfoHeader, 24)
$biYPelsPerMeter.CopyTo($bitmapInfoHeader, 28)
$biClrUsed.CopyTo($bitmapInfoHeader, 32)
$biClrImportant.CopyTo($bitmapInfoHeader, 36)

# Write the 54-byte header (BMP file + info headers)
$fileStream.Write($bitmapFileHeader, 0, $bitmapFileHeader.Length)
$fileStream.Write($bitmapInfoHeader, 0, $bitmapInfoHeader.Length)

# -----------------------------
# Write the random pixel data
# -----------------------------
Write-Host "Writing random pixel data (~$($pixelDataSize / 1GB) GB). Please wait..."

# We will write row-by-row. For 24-bit, each row is $rowSize bytes.
# Typically BMP is bottom-to-top for positive height, but since it's random,
# we don't really care about the order. We'll just write in a loop $Height times.

# Use RNGCryptoServiceProvider (or RandomNumberGenerator in new .NET versions)
$rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider

# We can create a buffer for one row, then fill it with random data each time.
$rowBuffer = New-Object Byte[] ($rowSize)

for ($row = 0; $row -lt $Height; $row++) {
    $rng.GetBytes($rowBuffer)
    $fileStream.Write($rowBuffer, 0, $rowSize)

    # Occasionally show progress:
    if ($row % 1000 -eq 0 -and $row -ne 0) {
        $percent = [Math]::Round($row / $Height * 100, 2)
        Write-Host "  Wrote row $row/$Height ($percent %)"
    }
}

Write-Host "Completed! BMP file '$OutputPath' created."
