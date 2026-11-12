Add-Type -AssemblyName System.Drawing

function New-AppIcon([int]$size, [string]$path) {
    $bitmap = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $scale = $size / 1024.0
    $graphics.ScaleTransform([single]$scale, [single]$scale)

    $background = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.Rectangle]::new(0, 0, 1024, 1024),
        [System.Drawing.Color]::FromArgb(255, 7, 93, 112),
        [System.Drawing.Color]::FromArgb(255, 21, 155, 155), 45.0)
    $graphics.FillRectangle($background, 0, 0, 1024, 1024)

    $rayPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 255, 224, 138), 28)
    $rayPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $rayPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $rays = @(@(704,205,704,150), @(820,250,859,211), @(865,365,921,365), @(820,480,859,519), @(704,525,704,580), @(588,480,549,519), @(543,365,487,365), @(588,250,549,211))
    foreach ($ray in $rays) { $graphics.DrawLine($rayPen, $ray[0], $ray[1], $ray[2], $ray[3]) }

    $sunBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.Rectangle]::new(562, 223, 284, 284),
        [System.Drawing.Color]::FromArgb(255, 255, 226, 138),
        [System.Drawing.Color]::FromArgb(255, 255, 198, 92), 90.0)
    $graphics.FillEllipse($sunBrush, 562, 223, 284, 284)

    $cloudBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $graphics.FillEllipse($cloudBrush, 220, 520, 710, 305)
    $graphics.FillEllipse($cloudBrush, 132, 498, 300, 300)
    $graphics.FillEllipse($cloudBrush, 304, 300, 390, 390)
    $graphics.FillEllipse($cloudBrush, 600, 442, 320, 320)
    $graphics.FillEllipse($cloudBrush, 770, 552, 205, 205)

    $dropPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 102, 201, 196), 25)
    $dropPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $dropPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $graphics.DrawLine($dropPen, 384, 760, 347, 851)
    $graphics.DrawLine($dropPen, 535, 760, 498, 851)
    $graphics.DrawLine($dropPen, 686, 760, 649, 851)

    $directory = [System.IO.Path]::GetDirectoryName($path)
    [System.IO.Directory]::CreateDirectory($directory) | Out-Null
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $background.Dispose(); $rayPen.Dispose(); $sunBrush.Dispose(); $cloudBrush.Dispose(); $dropPen.Dispose(); $graphics.Dispose(); $bitmap.Dispose()
}

$root = Split-Path -Parent $PSScriptRoot
$androidSizes = @{
    'mipmap-mdpi' = 48; 'mipmap-hdpi' = 72; 'mipmap-xhdpi' = 96;
    'mipmap-xxhdpi' = 144; 'mipmap-xxxhdpi' = 192
}
foreach ($folder in $androidSizes.Keys) {
    New-AppIcon $androidSizes[$folder] (Join-Path $root "android/app/src/main/res/$folder/ic_launcher.png")
}

$iosFolder = Join-Path $root 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
$catalog = Get-Content (Join-Path $iosFolder 'Contents.json') -Raw | ConvertFrom-Json
foreach ($entry in $catalog.images) {
    $file = $entry.filename
    if ($null -eq $file) { continue }
    $dimension = [double]($entry.size -split 'x')[0] * [double]($entry.scale -replace 'x', '')
    New-AppIcon ([int][Math]::Round($dimension)) (Join-Path $iosFolder $file)
}
