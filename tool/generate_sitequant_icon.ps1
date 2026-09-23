# Rasterize the editable SiteQuant_App_Icon geometry for pre-Android-8 launchers.
# Run from any directory: powershell -File tool/generate_sitequant_icon.ps1
Add-Type -AssemblyName System.Drawing

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$blue = [System.Drawing.ColorTranslator]::FromHtml('#0969F8')
$white = [System.Drawing.Brushes]::White

function New-IconBitmap([int]$size) {
    $supersampledSize = $size * 4
    $canvas = [System.Drawing.Bitmap]::new($supersampledSize, $supersampledSize)
    $graphics = [System.Drawing.Graphics]::FromImage($canvas)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear($blue)
    $graphics.ScaleTransform($supersampledSize / 108.0, $supersampledSize / 108.0)

    $house = [System.Drawing.Drawing2D.GraphicsPath]::new(
        [System.Drawing.Drawing2D.FillMode]::Alternate
    )
    $house.AddPolygon([System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new(54, 28),
        [System.Drawing.PointF]::new(79, 48),
        [System.Drawing.PointF]::new(79, 79),
        [System.Drawing.PointF]::new(29, 79),
        [System.Drawing.PointF]::new(29, 48)
    ))
    $house.AddRectangle([System.Drawing.RectangleF]::new(40, 57, 28, 16))
    $graphics.FillPath($white, $house)
    $graphics.FillRectangle($white, 52, 57, 4, 16)
    $graphics.Dispose()
    $house.Dispose()

    $bitmap = [System.Drawing.Bitmap]::new($size, $size)
    $output = [System.Drawing.Graphics]::FromImage($bitmap)
    $output.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $output.DrawImage(
        $canvas,
        [System.Drawing.Rectangle]::new(0, 0, $size, $size),
        0, 0, $supersampledSize, $supersampledSize,
        [System.Drawing.GraphicsUnit]::Pixel
    )
    $output.Dispose()
    $canvas.Dispose()
    return $bitmap
}

foreach ($entry in @(
    @{ Density = 'mdpi'; Size = 48 },
    @{ Density = 'hdpi'; Size = 72 },
    @{ Density = 'xhdpi'; Size = 96 },
    @{ Density = 'xxhdpi'; Size = 144 },
    @{ Density = 'xxxhdpi'; Size = 192 }
)) {
    $path = Join-Path $projectRoot "android/app/src/main/res/mipmap-$($entry.Density)/ic_launcher.png"
    $bitmap = New-IconBitmap $entry.Size
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
}

$previewPath = Join-Path $projectRoot 'assets/launcher/SiteQuant_App_Icon.png'
$preview = New-IconBitmap 512
$preview.Save($previewPath, [System.Drawing.Imaging.ImageFormat]::Png)
$preview.Dispose()
