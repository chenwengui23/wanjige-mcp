# 万机阁 Wanjige MCP Server

[![MCP](https://img.shields.io/badge/MCP-streamable--http-blue)](https://modelcontextprotocol.io/)
[![Tools](https://img.shields.io/badge/tools-15%2C552-brightgreen)](https://qianjige.app.workbuddy.host/)
[![Website](https://img.shields.io/badge/website-qianjige.app.workbuddy.host-orange)](https://qianjige.app.workbuddy.host/)

**一个 MCP，一万种本事。** 中文 AI 工具市场 —— 一次接入获得 **15,552 个可真实调用**的工具：天气路线 POI、A股港股美股行情、930 组货币汇率、arXiv/世界银行学术与宏观数据、PDF/Word/Excel 解析、TTS 配音、AI 生图生视频、个税房贷等确定性计算。

> 所有工具在服务端**真实执行**（无占位假工具），结果标注数据来源可复核。按次扣积分，**调用失败不扣**。

---

## 为什么需要它

AI 平台最怕两件事：**工具装多了模型变笨，工具不够活干不动。**

- 装 15 个 MCP 各付一份订阅是「最贵的错误」；实测超过约 40 个工具，智能体可靠性明显下降
- 模型心算必翻车的场景（日期、个税、房贷、进制、时区、汇率换算）需要**确定性计算层**
- 中国数据（A股行情、备案、全国天气、POI、热搜）海外工具市场基本空白

万机阁把 15,552 个工具装进**一个连接**：智能体默认只加载精选工具，长尾用内置检索（`qj_search_tools`，免费）按需调用 —— 上下文永远干净。

---

## 快速开始

### 1. 获取 API Key

在 [qianjige.app.workbuddy.host/account.html](https://qianjige.app.workbuddy.host/account.html) 注册，自动生成 `qj-sk-` 开头的 Key，**赠送 1000 积分**。

### 2. 配置 MCP 客户端

**通用配置（Claude Code / Cursor / WorkBuddy / Dify / Coze 等）：**

```json
{
  "mcpServers": {
    "wanjige": {
      "type": "streamableHttp",
      "url": "https://qianjige.app.workbuddy.host/mcp?key=你的KEY",
      "timeout": 30000
    }
  }
}
```

> Key 支持三种携带方式：**推荐 `?key=` 查询参数**、`_meta.api_key`、`X-Api-Key` 请求头。
> ⚠️ 注意：部分托管网关会剥离自定义请求头，**请优先使用 `?key=` 查询参数**，它最稳定。

### 3. 直接对话

```
用户：查一下广州今天的天气

AI：（自动调用 qj_weather_now_cn_c195）
    广州当前 26°C，体感 28°C，湿度 78%，东南风 2 级，多云。
    数据来源：Open-Meteo
```

---

## 能力概览（15,552 工具 / 10 大类）

| 分类 | 数量 | 代表能力 |
|---|---:|---|
| 🗺️ 位置天气出行 | 8,798 | 中国 340+ 城市与国际 60 城市天气/空气质量、任意两地驾车路线、餐厅/酒店/银行等 POI 检索、时区与时差、地名转经纬度、IP 归属 |
| 🎨 内容与媒体 | 2,684 | 抖音/小红书/公众号爆款标题、开头钩子、口播脚本框架、关键词库、标签库、平台尺寸规格与变现规则（含 40+ 行业垂直模板） |
| 📈 金融数据 | 1,875 | A股/港股/美股实时行情与涨跌榜、930 组货币对实时与历史汇率、基金净值 |
| 🛒 电商与营销 | 720 | 淘宝/拼多多/抖音/亚马逊单件利润测算、跨境定价反推、大促节点日历、直播 ROI、保本售价、库存账期现金流 |
| 🔍 搜索与研究 | 664 | 全网网页检索、arXiv/Crossref/PubMed/OpenAlex 学术文献、世界银行 400+ 宏观指标、多国公共假日、微博/百度/抖音/知乎/B站热搜、Stack Overflow、npm/GitHub |
| 🧮 计算工具 | 438 | 个税（年终奖单独计税对比）、房贷（等额本息/本金）、BMI、年龄、复利、420 组单位换算对、任意进制转换 |
| 📝 文本处理 | 251 | 清洗、手机号/邮箱/身份证抽取、字数统计、敏感信息脱敏、Base64/十六进制编解码、CSV/JSON 转换 |
| 🛠️ 开发工具 | 70 | MD5/SHA 哈希、Base16/32/64/85 编解码、UUID/NanoID、JWT 解码、正则测试、时间戳转换、GitHub 查询 |
| 📄 文档与数据 | 43 | PDF 正文提取、Word 正文提取、Excel 工作表统计与透视、CSV 处理、图片 OCR、Markdown/HTML 转换 |
| ✨ AI 生成 | 9 | 文字转语音（14 中文音色含粤语/台湾腔，返回 MP3 直链）、AI 文生图（7 种画幅）、图片转视频/GIF、双人对话配音 |

数据来源：Open-Meteo、OpenStreetMap、OSRM、Photon、新浪财经、天天基金、欧洲央行、ExchangeRate-API、arXiv、Crossref、PubMed、OpenAlex、世界银行、Stack Exchange、Nager.Date、RDAP、GitHub、npm 等公开权威数据源。

---

## 核心机制：渐进式披露

大工具库最大的坑是「工具全塞给模型 → 上下文爆炸 → 模型变傻」。万机阁的解法：

1. **首页只返回 34 个工具**：3 个元工具 + 31 个高频精选，客户端不会被上万工具拖垮
2. **长尾按需检索调用**：
   - `qj_search_tools`（**免费**）— 中文关键词检索全部 15,552 个工具
   - `qj_call` — 通用调用器，调用任意工具（含未展示的长尾）
   - `qj_tool_detail`（**免费**）— 查看工具参数与调用示例
3. **instructions 内置强制规则**：凡涉及实时数据与精确计算，禁止凭记忆作答，必须调用工具取数

```
用户：帮我算个月薪 2 万的个税
AI：→ qj_search_tools{"query":"个税"}
    → qj_call{"tool":"qj_tax_calc","args":{"monthly_salary":20000}}
```

---

## 计费

- **注册送 1000 积分**
- 按次扣积分，明码标价：纯计算 10 积分/次、内容电商 20–30、行情 200、抓取 300
- **调用失败不扣积分**（含参数错误、上游限流、超时）
- 充值：¥19=3000 / ¥99=18000 / ¥299=60000 / ¥699=160000

---

## 常见问题

**Q：工具是真实可调用的吗？**
是。目录里每一条都在服务端真实执行，`/api/stats` 实时统计可复核，**无「接入中」占位工具**。

**Q：和单挂一个 MCP 有什么区别？**
单挂一个 MCP 只解决一种数据。万机阁是市场 —— 一次接入获得 15,552 个工具，并用渐进式披露解决了大工具库的模型卡顿问题。

**Q：为什么要用它而不是让 AI 直接答？**
实时数据（天气、汇率、股价、时差）模型记忆会过时；精确计算（个税、房贷、单位、进制）模型心算会错。万机阁强制模型调用工具取数，结果带来源可复核。

**Q：需要本地安装吗？**
不需要。纯远程 Streamable HTTP 服务，任何支持 MCP 的客户端直连 URL 即用。

**Q：支持开票吗？**
暂不支持。由无夜之境工作室（广东广州）提供服务。

---

## 链接

- 官网：https://qianjige.app.workbuddy.host/
- 接入文档：https://qianjige.app.workbuddy.host/docs.html
- LLM 入口：https://qianjige.app.workbuddy.host/llms.txt
- 定价：https://qianjige.app.workbuddy.host/pricing.html
- 服务条款：https://qianjige.app.workbuddy.host/terms.html
- 客服：微信 nanfeng2074 ｜ 邮箱 977742166@qq.com

---

## 关于本仓库

本仓库只包含万机阁 MCP 的**公开元数据与接入文档**（`server.json`、配置示例、使用说明），用于在 [MCP 官方注册表](https://registry.modelcontextprotocol.io/) 上架与客户端发现。

服务端实现、积分与账户系统为本项目私有部分，不在此仓库公开。
