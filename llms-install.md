# Wanjige (万机阁) MCP Server — AI Installation Guide

Wanjige is a **Chinese AI tool marketplace MCP server** exposing **15,552 callable tools** through a
single connection: real-time A-share / HK / US stock quotes, FX rates, weather, hot rankings, news,
PDF / Word / Excel / OCR document parsing, TTS, image & video generation, unit / tax / loan
calculators, and e-commerce profit analytics.

All tools execute **for real on the server side** (no placeholder tools). Results are annotated with
their data source for verification. Calls are billed in credits and **failed calls are not billed**.

## 1. Get an API key (free)

Register at <https://qianjige.app.workbuddy.host/account.html> — a key starting with `wj-sk-` is
generated automatically and the account ships with **1,000 free credits**.

Without a key you can still run `initialize` / `tools/list` and **3 real tool calls per day**.

## 2. Remote connection (recommended)

Point any Streamable-HTTP-capable MCP client at:

```json
{
  "mcpServers": {
    "wanjige": {
      "type": "streamableHttp",
      "url": "https://qianjige.app.workbuddy.host/mcp?key=YOUR_WJ_SK_KEY",
      "timeout": 30000
    }
  }
}
```

The key may be supplied in three ways — **prefer the `?key=` query parameter**, it survives the most
gateways:

1. `?key=YOUR_WJ_SK_KEY` query parameter (recommended)
2. `_meta.api_key` field
3. `X-Api-Key` request header

## 3. stdio connection (Claude Desktop and other stdio-only clients)

```json
{
  "mcpServers": {
    "wanjige": {
      "command": "npx",
      "args": ["-y", "wanjige-mcp"],
      "env": { "WANJIGE_API_KEY": "YOUR_WJ_SK_KEY" }
    }
  }
}
```

The `wanjige-mcp` npm package is a zero-dependency Node bridge (Node >= 18) that forwards stdio to
the remote endpoint. Leaving the env value empty enables the free trial mode.

## 4. First call

1. `qj_search_tools` — free, does not consume credits. Search the catalogue by keyword
   (e.g. `weather`, `stock`, `tax`, `汇率`, `热搜`) and it returns exact tool names, credit prices
   and descriptions.
2. `qj_tool_detail` — free. Full parameter schema and a call example for one tool.
3. `qj_call` — run any tool: `{"tool": "<name from search>", "args": { ... }}`.

`tools/list` returns 34 curated tools; the remaining ~15,500 are reachable through `qj_search_tools`
+ `qj_call`, so the context window stays small.
