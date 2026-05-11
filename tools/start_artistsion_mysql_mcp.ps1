param(
    [ValidateSet("ReadOnly", "ReadWrite")]
    [string]$Mode = "",
    [switch]$AllowDdl
)

function Get-ScopedValue {
    param(
        [string[]]$Names,
        [string]$Default = ""
    )

    foreach ($scope in @("Process", "User", "Machine")) {
        foreach ($name in $Names) {
            $value = [Environment]::GetEnvironmentVariable($name, $scope)
            if (-not [string]::IsNullOrWhiteSpace($value)) {
                return $value
            }
        }
    }

    return $Default
}

function Get-BooleanString {
    param(
        [string[]]$Names,
        [bool]$Default = $false
    )

    $value = Get-ScopedValue -Names $Names
    if ([string]::IsNullOrWhiteSpace($value)) {
        if ($Default) {
            return "true"
        }

        return "false"
    }

    switch -Regex ($value.Trim().ToLowerInvariant()) {
        "^(1|true|yes|y|on)$" {
            return "true"
        }
        "^(0|false|no|n|off)$" {
            return "false"
        }
        default {
            [Console]::Error.WriteLine("Invalid boolean value '$value'. Use true or false.")
            exit 1
        }
    }
}

function Resolve-McpMode {
    param(
        [string]$RequestedMode
    )

    if (-not [string]::IsNullOrWhiteSpace($RequestedMode)) {
        return $RequestedMode
    }

    $configuredMode = Get-ScopedValue -Names @("ARTISTSION_MCP_MODE", "MCP_MODE") -Default "ReadWrite"
    switch ($configuredMode.Trim().ToLowerInvariant()) {
        "readonly" {
            return "ReadOnly"
        }
        "readwrite" {
            return "ReadWrite"
        }
        default {
            [Console]::Error.WriteLine("Invalid MCP mode '$configuredMode'. Use ReadOnly or ReadWrite.")
            exit 1
        }
    }
}

function Get-Node20Executable {
    $nodePath = & npx -y -p node@20 node -p "process.execPath"
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($nodePath)) {
        [Console]::Error.WriteLine("Unable to resolve a Node.js 20 runtime via npx.")
        exit 1
    }

    return $nodePath.Trim()
}

$env:MYSQL_HOST = Get-ScopedValue -Names @("ARTISTSION_DB_HOST", "DB_HOST") -Default "127.0.0.1"
$env:MYSQL_PORT = Get-ScopedValue -Names @("ARTISTSION_DB_PORT", "DB_PORT") -Default "3306"
$env:MYSQL_DB = Get-ScopedValue -Names @("ARTISTSION_DB_NAME", "DB_NAME") -Default "artistsion"
$env:MYSQL_USER = Get-ScopedValue -Names @("ARTISTSION_DB_USER", "DB_USERNAME")
$env:MYSQL_PASS = Get-ScopedValue -Names @("ARTISTSION_DB_PASS", "DB_PASSWORD")

if ([string]::IsNullOrWhiteSpace($env:MYSQL_USER)) {
    [Console]::Error.WriteLine("Missing database username. Set ARTISTSION_DB_USER or DB_USERNAME in your user environment.")
    exit 1
}

if ([string]::IsNullOrWhiteSpace($env:MYSQL_PASS)) {
    [Console]::Error.WriteLine("Missing database password. Set ARTISTSION_DB_PASS or DB_PASSWORD in your user environment.")
    exit 1
}

$resolvedMode = Resolve-McpMode -RequestedMode $Mode
$allowWrites = $resolvedMode -eq "ReadWrite"

if ($allowWrites) {
    $env:ALLOW_INSERT_OPERATION = "true"
    $env:ALLOW_UPDATE_OPERATION = "true"
    $env:ALLOW_DELETE_OPERATION = "true"
}
else {
    $env:ALLOW_INSERT_OPERATION = "false"
    $env:ALLOW_UPDATE_OPERATION = "false"
    $env:ALLOW_DELETE_OPERATION = "false"
}

if ($AllowDdl.IsPresent) {
    $env:ALLOW_DDL_OPERATION = "true"
}
else {
    $env:ALLOW_DDL_OPERATION = Get-BooleanString -Names @("ARTISTSION_MCP_ALLOW_DDL", "MCP_ALLOW_DDL") -Default $false
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$localServerEntry = Join-Path $repoRoot ".runtime\mcp-mysql-pkg\package\dist\index.js"

if (Test-Path $localServerEntry) {
    $node20Executable = Get-Node20Executable
    & $node20Executable $localServerEntry
    exit $LASTEXITCODE
}

& npx -y -p node@20 -p @benborla29/mcp-server-mysql -p dotenv mcp-server-mysql
exit $LASTEXITCODE
