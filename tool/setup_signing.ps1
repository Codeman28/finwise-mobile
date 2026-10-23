# setup_signing.ps1 - creates the Android release ("upload") key for FinWise
# and stores it as GitHub Actions secrets. Run ONCE, from the project folder:
#     powershell -ExecutionPolicy Bypass -File tool\setup_signing.ps1
#
# What it does:
#   1. Generates a strong random password (never printed on screen).
#   2. Creates upload-keystore.jks with the JDK's keytool.
#   3. Writes android/key.properties so local release builds are signed too.
#      (Both files are in android/.gitignore - they are never committed.)
#   4. Saves a BACKUP (keystore + password) in %USERPROFILE%\finwise-keys.
#   5. Uploads the keystore and password as encrypted GitHub repository secrets.
#
# KEEP THE BACKUP SAFE. If you lose this key, you cannot publish updates of
# the same app on Google Play (unless you use Play App Signing key reset).

$ErrorActionPreference = 'Stop'
$repo = 'Codeman28/finwise-mobile'
$alias = 'upload'
$projectAndroid = Join-Path $PSScriptRoot '..\android' | Resolve-Path
$backupDir = Join-Path $env:USERPROFILE 'finwise-keys'
$keystore = Join-Path $backupDir 'upload-keystore.jks'

# --- find tools ------------------------------------------------------------
$keytool = Get-ChildItem 'C:\Program Files\Java', 'C:\Program Files\Eclipse Adoptium', 'C:\Program Files\Android\Android Studio\jbr' `
    -Filter keytool.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
if (-not $keytool) { throw 'keytool.exe not found - install a JDK (Java 17+).' }
$gh = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\GitHub.cli_Microsoft.Winget.Source_8wekyb3d8bbwe\bin\gh.exe'
if (-not (Test-Path $gh)) { $gh = 'gh' }

if (Test-Path $keystore) {
    throw "A key already exists at $keystore - not overwriting it. Delete it yourself first if you really want a new key."
}
New-Item -ItemType Directory -Force $backupDir | Out-Null

# --- 1. random password (32 letters/digits) ---------------------------------
$chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789'
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$password = -join ($bytes | ForEach-Object { $chars[$_ % $chars.Length] })

# --- 2. create the keystore (valid ~27 years, RSA 2048) ----------------------
& $keytool -genkeypair -v -keystore $keystore -storetype PKCS12 -keyalg RSA -keysize 2048 `
    -validity 10000 -alias $alias -storepass $password -keypass $password `
    -dname 'CN=Codeman28, OU=FinWise, O=FinWise, L=Ha Noi, C=VN' | Out-Null
Write-Host "Created keystore: $keystore" -ForegroundColor Green

# --- 3. local signing for builds on this computer ---------------------------
Copy-Item $keystore (Join-Path $projectAndroid 'upload-keystore.jks') -Force
@"
storeFile=upload-keystore.jks
storePassword=$password
keyAlias=$alias
keyPassword=$password
"@ | Set-Content -Encoding ASCII (Join-Path $projectAndroid 'key.properties')
Write-Host 'Wrote android/key.properties (ignored by git).' -ForegroundColor Green

# --- 4. backup of the password next to the keystore -------------------------
@"
FinWise Android upload key
Keystore : $keystore
Alias    : $alias
Password : $password   (store password = key password)
Created  : $(Get-Date -Format 'yyyy-MM-dd HH:mm')

Back up this folder somewhere safe (USB / password manager). Do NOT share it.
"@ | Set-Content -Encoding UTF8 (Join-Path $backupDir 'README-KEY.txt')
Write-Host "Backup + password saved in $backupDir" -ForegroundColor Yellow

# --- 5. GitHub secrets ------------------------------------------------------
$base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($keystore))
$base64 | & $gh secret set ANDROID_KEYSTORE_BASE64 -R $repo
$password | & $gh secret set ANDROID_KEYSTORE_PASSWORD -R $repo
$alias | & $gh secret set ANDROID_KEY_ALIAS -R $repo
$password | & $gh secret set ANDROID_KEY_PASSWORD -R $repo
Write-Host 'Uploaded 4 encrypted secrets to GitHub.' -ForegroundColor Green

# Print only the certificate fingerprint (public, safe to share) - useful for
# Google Play / Firebase setup later.
& $keytool -list -keystore $keystore -storepass $password -alias $alias | Select-String 'SHA-256|SHA256'
Write-Host "`nDONE. You can close this window." -ForegroundColor Green
