# OpenCLI支持的网站列表

## 社交媒体
- **bilibili** - 视频搜索、热门、历史、下载等
- **xiaohongshu** - 小红书搜索、笔记、评论等
- **zhihu** - 知乎搜索、问题、回答等
- **reddit** - Reddit搜索、帖子、评论等
- **twitter** - Twitter搜索、趋势、帖子等
- **linkedin** - LinkedIn搜索、职位、个人资料等

## 搜索引擎
- **google** - Google搜索
- **bing** - Bing搜索（通过web read）

## 技术社区
- **github** - GitHub搜索（通过gh命令）
- **stackoverflow** - Stack Overflow搜索（通过web read）

## 新闻资讯
- **hackernews** - Hacker News搜索、热门、最新等
- **news** - 新闻搜索（通过web read）

## 购物电商
- **amazon** - Amazon搜索、商品、评论等
- **1688** - 1688搜索、商品等
- **taobao** - 淘宝搜索（通过web read）

## 视频平台
- **youtube** - YouTube搜索（通过web read）
- **douyin** - 抖音搜索（通过web read）

## 学术资源
- **google-scholar** - Google Scholar搜索（通过web read）
- **arxiv** - arXiv搜索（通过web read）

## 其他平台
- **claude** - Claude对话、历史等
- **gemini** - Gemini对话、图像等
- **notebooklm** - NotebookLM笔记、来源等
- **geogebra** - GeoGebra几何、图形等
- **slock** - Slock消息、任务等
- **huodongxing** - 活动行活动等

## 使用示例

### bilibili搜索
```bash
opencli bilibili search "机器学习" --limit 10 -f json
```

### Google搜索
```bash
opencli google search "AI agent" --limit 10 -f json
```

### Reddit搜索
```bash
opencli reddit search "browser automation" --limit 10 -f json
```

### Twitter搜索
```bash
opencli twitter search "web scraping" --limit 10 -f json
```

## 检查适配器

### 列出所有适配器
```bash
opencli list -f yaml
```

### 检查特定网站
```bash
opencli bilibili -h
opencli google -h
opencli reddit -h
```

### 检查特定命令
```bash
opencli bilibili search -h
opencli google search -h
```

## 注意事项

1. **登录态要求**：部分网站需要登录态（如LinkedIn、Twitter）
2. **频率限制**：遵循各站点的频率限制
3. **输出格式**：支持JSON、CSV、Markdown等格式
4. **错误处理**：检查退出码和错误信息

## 更新日期
2026-06-24
