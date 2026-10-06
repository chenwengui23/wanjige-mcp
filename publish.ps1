# 万机阁 · MCP 官方注册表一键发布脚本（Windows PowerShell 版）
# 用法：右键"使用 PowerShell 运行"，或执行
#       .\publish.ps1 -GitHubUser 你的用户名
param(
  [Parameter(Mandatory=$true)][string]$GitHubUser
)

$ErrorActionPreference = "Stop"
$Dir = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "==> 工作目录: $Dir"
Write-Host "==> GitHub 用户名: $GitHubUser" -ForegroundColor Cyan

# ---------- 1. 校验 server.json ----------
$ServerJson = Join-Path $Dir "server.json"
if (-not (Test-Path $ServerJson)) {
  Write-Host "✗ 找不到 server.json，请与本脚本放在同一目录" -ForegroundColor Red
  exit 1
}

Write-Host "==> 替换 server.json 中的占位用户名 ..."
$raw = Get-Content $ServerJson -Raw -Encoding UTF8
$raw = $raw -replace "REPLACE_WITH_YOUR_GITHUB_USERNAME", $GitHubUser
[System.IO.File]::WriteAllText($ServerJson, $raw, (New-Object System.Text.UTF8Encoding($false)))

$j = $raw | ConvertFrom-Json
Write-Host "  name      : $($j.name)"
Write-Host "  title     : $($j.title)"
Write-Host "  version   : $($j.version)"
Write-Host "  remote    : $($j.remotes[0].type) -> $($j.remotes[0].url)"
$descLen = $j.description.Length
Write-Host "  description 长度: $descLen （硬限制 100 字符）"
if ($descLen -gt 100) { Write-Host "✗ description 超过 100 字符，请缩短" -ForegroundColor Red; exit 1 }
Write-Host "  ✓ server.json 校验通过" -ForegroundColor Green

# ---------- 2. 获取 mcp-publisher ----------
$Pub = Join-Path $Dir "mcp-publisher.exe"
if (-not (Test-Path $Pub)) {
  Write-Host "==> 下载 mcp-publisher (Windows amd64) ..."
  $url = "https://github.com/modelcontextprotocol/registry/releases/latest/download/mcp-publisher_windows_amd64.tar.gz"
  $tar = Join-Path $Dir "_pub.tar.gz"
  try {
    Invoke-WebRequest -Uri $url -OutFile $tar -UseBasicParsing
    tar xzf $tar -C $Dir
    Remove-Item $tar -Force
    Write-Host "    ✓ 下载完成" -ForegroundColor Green
  } catch {
    Write-Host "    ✗ 自动下载失败：$_" -ForegroundColor Red
    Write-Host "    请手动访问 https://github.com/modelcontextprotocol/registry/releases/latest"
    Write-Host "    下载 mcp-publisher_windows_amd64.tar.gz，解压出 mcp-publisher.exe 放到本目录后重跑。"
    exit 1
  }
}
Write-Host "==> mcp-publisher 就绪: $Pub" -ForegroundColor Green

# ---------- 3. 登录 GitHub ----------
Write-Host ""
Write-Host "================================================================" -ForegroundColor Yellow
Write-Host " 接下来会打开浏览器要求授权 GitHub（只需点一下确认）"
Write-Host " 如果没自动打开，请手动访问终端显示的网址并输入设备码"
Write-Host "================================================================" -ForegroundColor Yellow
Write-Host ""
& $Pub login github

# ---------- 4. 发布 ----------
Write-Host ""
Write-Host "==> 发布到官方 MCP Registry ..."
Push-Location $Dir
& $Pub publish
Pop-Location

# ---------- 5. 验证 ----------
Write-Host ""
Write-Host "==> 验证收录结果 ..."
Start-Sleep -Seconds 3
try {
  $r = Invoke-RestMethod -Uri "https://registry.modelcontextprotocol.io/v0.1/servers?search=$GitHubUser" -UseBasicParsing
  if ($r.servers -and $r.servers.Count -gt 0) {
    foreach ($s in $r.servers) {
      Write-Host "  ✓ $($s.server.name)  v$($s.server.version)" -ForegroundColor Green
      if ($s.server.remotes) { Write-Host "     endpoint: $($s.server.remotes[0].url)" }
    }
  } else {
    Write-Host "  (暂未查到，可能是索引延迟，1-2 分钟后再试)"
  }
} catch {
  Write-Host "  验证查询失败（不影响发布）：$_"
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host " 完成！你的 MCP 已进入官方注册表。"
Write-Host " 下游目录站（Smithery / Glama / PulseMCP 等）会自动抓取。"
Write-Host " 查询：https://registry.modelcontextprotocol.io/v0.1/servers?search=$GitHubUser"
Write-Host "================================================================" -ForegroundColor Green
