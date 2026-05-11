param()

$defaultUser = [Environment]::GetEnvironmentVariable("ARTISTSION_DB_USER", "User")
if ([string]::IsNullOrWhiteSpace($defaultUser)) {
    $defaultUser = "root"
}

$defaultHost = [Environment]::GetEnvironmentVariable("ARTISTSION_DB_HOST", "User")
if ([string]::IsNullOrWhiteSpace($defaultHost)) {
    $defaultHost = "127.0.0.1"
}

$defaultPort = [Environment]::GetEnvironmentVariable("ARTISTSION_DB_PORT", "User")
if ([string]::IsNullOrWhiteSpace($defaultPort)) {
    $defaultPort = "3306"
}

$defaultDb = [Environment]::GetEnvironmentVariable("ARTISTSION_DB_NAME", "User")
if ([string]::IsNullOrWhiteSpace($defaultDb)) {
    $defaultDb = "artistsion"
}

$userInput = Read-Host "MySQL username [$defaultUser]"
if ([string]::IsNullOrWhiteSpace($userInput)) {
    $userInput = $defaultUser
}

$passwordSecure = Read-Host "MySQL password" -AsSecureString
$passwordBstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordSecure)
try {
    $passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordBstr)
}
finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordBstr)
}

if ([string]::IsNullOrWhiteSpace($passwordPlain)) {
    Write-Error "Password cannot be empty."
    exit 1
}

$hostInput = Read-Host "MySQL host [$defaultHost]"
if ([string]::IsNullOrWhiteSpace($hostInput)) {
    $hostInput = $defaultHost
}

$portInput = Read-Host "MySQL port [$defaultPort]"
if ([string]::IsNullOrWhiteSpace($portInput)) {
    $portInput = $defaultPort
}

$dbInput = Read-Host "MySQL database [$defaultDb]"
if ([string]::IsNullOrWhiteSpace($dbInput)) {
    $dbInput = $defaultDb
}

[Environment]::SetEnvironmentVariable("ARTISTSION_DB_USER", $userInput, "User")
[Environment]::SetEnvironmentVariable("ARTISTSION_DB_PASS", $passwordPlain, "User")
[Environment]::SetEnvironmentVariable("ARTISTSION_DB_HOST", $hostInput, "User")
[Environment]::SetEnvironmentVariable("ARTISTSION_DB_PORT", $portInput, "User")
[Environment]::SetEnvironmentVariable("ARTISTSION_DB_NAME", $dbInput, "User")

Write-Host "Saved ARTISTSION_DB_USER, ARTISTSION_DB_PASS, ARTISTSION_DB_HOST, ARTISTSION_DB_PORT, and ARTISTSION_DB_NAME to your user environment."
