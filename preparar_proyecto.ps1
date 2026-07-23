$ErrorActionPreference = 'Stop'

function Ejecutar-Flutter {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Argumentos
    )

    & flutter @Argumentos
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter terminó con el código de error $LASTEXITCODE al ejecutar: flutter $($Argumentos -join ' ')"
    }
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter no está instalado o no está agregado a PATH. Ejecuta 'flutter doctor' para comprobarlo."
}

$Raiz = Split-Path -Parent $MyInvocation.MyCommand.Path
$Respaldo = Join-Path ([System.IO.Path]::GetTempPath()) ("bingo_sport_" + [guid]::NewGuid().ToString('N'))

New-Item -ItemType Directory -Path $Respaldo | Out-Null

try {
    Copy-Item (Join-Path $Raiz 'lib') (Join-Path $Respaldo 'lib') -Recurse
    Copy-Item (Join-Path $Raiz 'test') (Join-Path $Respaldo 'test') -Recurse
    Copy-Item (Join-Path $Raiz 'pubspec.yaml') $Respaldo
    Copy-Item (Join-Path $Raiz 'analysis_options.yaml') $Respaldo
    Copy-Item (Join-Path $Raiz 'README.md') $Respaldo

    Push-Location $Raiz
    try {
        # En Windows se generan Android y Web. iOS solo puede compilarse desde macOS.
        Ejecutar-Flutter -Argumentos @('create', '--platforms=android,web', '.')

        Remove-Item (Join-Path $Raiz 'lib') -Recurse -Force
        Remove-Item (Join-Path $Raiz 'test') -Recurse -Force

        Copy-Item (Join-Path $Respaldo 'lib') (Join-Path $Raiz 'lib') -Recurse
        Copy-Item (Join-Path $Respaldo 'test') (Join-Path $Raiz 'test') -Recurse
        Copy-Item (Join-Path $Respaldo 'pubspec.yaml') (Join-Path $Raiz 'pubspec.yaml') -Force
        Copy-Item (Join-Path $Respaldo 'analysis_options.yaml') (Join-Path $Raiz 'analysis_options.yaml') -Force
        Copy-Item (Join-Path $Respaldo 'README.md') (Join-Path $Raiz 'README.md') -Force

        $AndroidManifest = Join-Path $Raiz 'android\app\src\main\AndroidManifest.xml'
        if (Test-Path $AndroidManifest) {
            $Contenido = Get-Content $AndroidManifest -Raw
            if ($Contenido -notmatch 'android\.permission\.CAMERA') {
                $InicioManifest = '<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
                $PermisoCamara = '    <uses-permission android:name="android.permission.CAMERA" />'
                $Contenido = $Contenido.Replace($InicioManifest, "$InicioManifest`r`n$PermisoCamara")
                Set-Content -Path $AndroidManifest -Value $Contenido -Encoding utf8
            }
        }

        Ejecutar-Flutter -Argumentos @('pub', 'get')

        Write-Host ''
        Write-Host 'Proyecto preparado correctamente.' -ForegroundColor Green
        Write-Host 'Siguiente paso: flutter run'
    }
    finally {
        Pop-Location
    }
}
finally {
    if (Test-Path $Respaldo) {
        Remove-Item $Respaldo -Recurse -Force
    }
}
