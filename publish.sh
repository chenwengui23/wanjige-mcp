#!/usr/bin/env bash
# 万机阁 · MCP 官方注册表一键发布脚本
# 用法：把本文件与 server.json 放在同一目录，然后 bash publish.sh
# 前提：已安装 git；已有一个 GitHub 账号
set -e

GH_USER="${1:-}"
if [ -z "$GH_USER" ]; then
  echo "用法: bash publish.sh <你的GitHub用户名>"
  echo "例：  bash publish.sh chenwengui23"
  exit 1
fi

DIR="$(cd "$(dirname "$0")" && pwd)"
echo "==> 工作目录: $DIR"
echo "==> GitHub 用户名: $GH_USER"

# ---------- 1. 校验 server.json ----------
if [ ! -f "$DIR/server.json" ]; then
  echo "✗ 找不到 server.json，请与本脚本放在同一目录"
  exit 1
fi

echo "==> 替换 server.json 中的占位用户名为 $GH_USER ..."
node -e "
const fs=require('fs');
const p='$DIR/server.json';
let s=fs.readFileSync(p,'utf8');
s=s.replace(/REPLACE_WITH_YOUR_GITHUB_USERNAME/g,'$GH_USER');
fs.writeFileSync(p,s);
const j=JSON.parse(s);
console.log('  name      :',j.name);
console.log('  title     :',j.title);
console.log('  version   :',j.version);
console.log('  remote    :',j.remotes[0].type,'->',j.remotes[0].url);
const desc=j.description||'';
console.log('  description 长度:',desc.length,'（硬限制 100 字符）');
if(desc.length>100){console.error('✗ description 超过 100 字符，请缩短');process.exit(1);}
console.log('  ✓ server.json 校验通过');
"

# ---------- 2. 安装 mcp-publisher ----------
PUB="$DIR/mcp-publisher"
PUB_EXE="$PUB.exe"
if [ -x "$PUB" ] || [ -x "$PUB_EXE" ]; then
  echo "==> mcp-publisher 已存在，跳过下载"
else
  echo "==> 下载 mcp-publisher ..."
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')"
  URL="https://github.com/modelcontextprotocol/registry/releases/latest/download/mcp-publisher_${OS}_${ARCH}.tar.gz"
  echo "    $URL"
  if curl -fsSL "$URL" -o "$DIR/_pub.tar.gz"; then
    tar xzf "$DIR/_pub.tar.gz" -C "$DIR"
    rm -f "$DIR/_pub.tar.gz"
    chmod +x "$PUB" 2>/dev/null || true
    echo "    ✓ 下载完成"
  else
    echo "    ✗ 自动下载失败（可能被网络拦截）。"
    echo "    请手动访问 https://github.com/modelcontextprotocol/registry/releases/latest"
    echo "    下载对应平台的 mcp-publisher 放到本目录后重跑本脚本。"
    exit 1
  fi
fi

# 归一化可执行名
if [ -x "$PUB_EXE" ] && [ ! -x "$PUB" ]; then PUB="$PUB_EXE"; fi
echo "==> mcp-publisher 就绪: $PUB"

# ---------- 3. 登录 GitHub（会打开浏览器，仅需一次） ----------
echo ""
echo "================================================================"
echo " 接下来会打开浏览器要求你授权 GitHub（只需点一下确认）"
echo " 如果没自动打开，请手动访问终端里显示的网址并输入设备码"
echo "================================================================"
echo ""
"$PUB" login github

# ---------- 4. 发布 ----------
echo ""
echo "==> 发布到官方 MCP Registry ..."
cd "$DIR"
"$PUB" publish

# ---------- 5. 验证 ----------
echo ""
echo "==> 验证收录结果 ..."
sleep 3
curl -s "https://registry.modelcontextprotocol.io/v0.1/servers?search=$GH_USER" | node -e "
let d='';process.stdin.on('data',c=>d+=c).on('end',()=>{
  try{
    const j=JSON.parse(d);
    const list=j.servers||[];
    if(!list.length){console.log('  (暂未查到，可能是索引延迟，1-2 分钟后再试)');return;}
    list.forEach(s=>{
      const v=s.server||s;
      console.log('  ✓ '+v.name+'  v'+v.version);
      if(v.remotes&&v.remotes[0]) console.log('     endpoint: '+v.remotes[0].url);
    });
  }catch(e){console.log('  验证查询失败（不影响发布）:',e.message)}
});
"

echo ""
echo "================================================================"
echo " 完成！你的 MCP 已进入官方注册表。"
echo " 下游目录站（Smithery / Glama / PulseMCP 等）会自动抓取。"
echo " 查询地址：https://registry.modelcontextprotocol.io/v0.1/servers?search=$GH_USER"
echo "================================================================"
