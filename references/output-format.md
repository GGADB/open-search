# 输出格式规范

## 概述

智能搜索路由器使用统一的JSON输出格式，无论使用OpenCLI还是Browser Harness，输出结构保持一致。

## 标准输出格式

### 成功响应
```json
{
  "source": "opencli" | "browser-harness",
  "query": "搜索词",
  "site": "网站名",
  "results": [
    {
      "title": "结果标题",
      "url": "结果链接",
      "snippet": "结果摘要",
      "metadata": {
        "author": "作者（可选）",
        "date": "日期（可选）",
        "score": "评分（可选）",
        "comments": "评论数（可选）"
      }
    }
  ],
  "metadata": {
    "total": 20,
    "engine": "opencli" | "browser-harness",
    "trigger": "auto" | "manual",
    "timestamp": "2026-06-24T00:00:00Z",
    "duration": 1.5,
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "has_next": true
    }
  }
}
```

### 错误响应
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "错误信息",
    "engine": "opencli" | "browser-harness",
    "details": {
      "site": "网站名",
      "query": "搜索词",
      "exit_code": 1,
      "stderr": "错误输出"
    }
  },
  "metadata": {
    "trigger": "auto" | "manual",
    "timestamp": "2026-06-24T00:00:00Z",
    "duration": 0.5
  }
}
```

## 字段说明

### 顶层字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `source` | string | 是 | 搜索引擎来源：`opencli` 或 `browser-harness` |
| `query` | string | 是 | 用户搜索词 |
| `site` | string | 否 | 目标网站名（如有） |
| `results` | array | 是 | 搜索结果列表 |
| `metadata` | object | 是 | 元数据信息 |
| `error` | object | 否 | 错误信息（仅错误响应） |

### results数组元素

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `title` | string | 是 | 结果标题 |
| `url` | string | 是 | 结果链接 |
| `snippet` | string | 否 | 结果摘要 |
| `metadata` | object | 否 | 额外元数据 |

### results.metadata对象

| 字段 | 类型 | 说明 |
|------|------|------|
| `author` | string | 作者 |
| `date` | string | 发布日期 |
| `score` | number | 评分/点赞数 |
| `comments` | number | 评论数 |
| `views` | number | 浏览数 |
| `tags` | array | 标签列表 |

### metadata对象

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `total` | number | 是 | 结果总数 |
| `engine` | string | 是 | 使用的引擎 |
| `trigger` | string | 是 | 触发方式：`auto` 或 `manual` |
| `timestamp` | string | 是 | ISO 8601时间戳 |
| `duration` | number | 是 | 搜索耗时（秒） |
| `pagination` | object | 否 | 分页信息 |

### pagination对象

| 字段 | 类型 | 说明 |
|------|------|------|
| `current_page` | number | 当前页码 |
| `total_pages` | number | 总页数 |
| `has_next` | boolean | 是否有下一页 |
| `has_prev` | boolean | 是否有上一页 |

### error对象

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `code` | string | 是 | 错误代码 |
| `message` | string | 是 | 错误信息 |
| `engine` | string | 是 | 发生错误的引擎 |
| `details` | object | 否 | 错误详情 |

### error.details对象

| 字段 | 类型 | 说明 |
|------|------|------|
| `site` | string | 目标网站 |
| `query` | string | 搜索词 |
| `exit_code` | number | 退出码 |
| `stderr` | string | 标准错误输出 |
| `url` | string | 请求URL |
| `selector` | string | 失败的CSS选择器 |

## 错误代码

### 通用错误
| 代码 | 说明 |
|------|------|
| `ENGINE_NOT_FOUND` | 引擎不可用 |
| `TIMEOUT` | 请求超时 |
| `NETWORK_ERROR` | 网络错误 |
| `INVALID_QUERY` | 无效的搜索词 |
| `UNKNOWN_ERROR` | 未知错误 |

### OpenCLI错误
| 代码 | 说明 |
|------|------|
| `ADAPTER_NOT_FOUND` | 适配器不存在 |
| `ADAPTER_FAILED` | 适配器执行失败 |
| `AUTH_REQUIRED` | 需要登录态 |
| `RATE_LIMITED` | 频率限制 |
| `OPENCLI_NOT_INSTALLED` | OpenCLI未安装 |

### Browser Harness错误
| 代码 | 说明 |
|------|------|
| `BROWSER_NOT_CONNECTED` | 浏览器未连接 |
| `ELEMENT_NOT_FOUND` | 元素未找到 |
| `PAGE_LOAD_TIMEOUT` | 页面加载超时 |
| `JS_EXECUTION_ERROR` | JavaScript执行错误 |
| `BROWSER_HARNESS_NOT_INSTALLED` | Browser Harness未安装 |

## 输出示例

### 示例1：OpenCLI成功响应
```json
{
  "source": "opencli",
  "query": "机器学习",
  "site": "bilibili",
  "results": [
    {
      "title": "机器学习入门教程",
      "url": "https://www.bilibili.com/video/BV1xxx",
      "snippet": "本视频介绍机器学习的基础概念...",
      "metadata": {
        "author": "UP主",
        "date": "2026-06-20",
        "views": 15000,
        "score": 980
      }
    }
  ],
  "metadata": {
    "total": 20,
    "engine": "opencli",
    "trigger": "manual",
    "timestamp": "2026-06-24T10:30:00Z",
    "duration": 1.2,
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "has_next": true
    }
  }
}
```

### 示例2：Browser Harness成功响应
```json
{
  "source": "browser-harness",
  "query": "browser automation",
  "site": "google.com",
  "results": [
    {
      "title": "Browser Automation - Google Search",
      "url": "https://www.google.com/search?q=browser+automation",
      "snippet": "Browser automation refers to the use of software to control web browsers...",
      "metadata": {}
    }
  ],
  "metadata": {
    "total": 10,
    "engine": "browser-harness",
    "trigger": "manual",
    "timestamp": "2026-06-24T10:35:00Z",
    "duration": 5.8
  }
}
```

### 示例3：错误响应
```json
{
  "error": {
    "code": "ADAPTER_NOT_FOUND",
    "message": "OpenCLI适配器不存在",
    "engine": "opencli",
    "details": {
      "site": "custom-site",
      "query": "test",
      "exit_code": 1,
      "stderr": "Error: adapter not found for custom-site"
    }
  },
  "metadata": {
    "trigger": "manual",
    "timestamp": "2026-06-24T10:40:00Z",
    "duration": 0.3
  }
}
```

### 示例4：websearch回退响应
```json
{
  "source": "opencli",
  "query": "冷门话题",
  "site": "google",
  "results": [
    {
      "title": "冷门话题介绍",
      "url": "https://example.com/cold-topic",
      "snippet": "这是一个关于冷门话题的介绍..."
    }
  ],
  "metadata": {
    "total": 5,
    "engine": "opencli",
    "trigger": "auto",
    "timestamp": "2026-06-24T10:45:00Z",
    "duration": 2.1,
    "fallback_reason": "websearch返回空结果"
  }
}
```

## 格式转换

### 转换为CSV
```bash
# 使用jq转换JSON为CSV
cat results.json | jq -r '.results[] | [.title, .url, .snippet] | @csv'
```

### 转换为Markdown
```bash
# 使用jq转换JSON为Markdown
cat results.json | jq -r '.results[] | "- [\\(.title)](\\(.url))\\n  \\(.snippet)"'
```

### 转换为表格
```bash
# 使用jq转换JSON为表格
cat results.json | jq -r '.results[] | [.title, .url] | @tsv'
```

## 兼容性

### 与websearch格式兼容
- 字段命名保持一致
- 支持相同的结果结构
- 便于无缝回退

### 跨平台兼容
- 使用标准JSON格式
- 避免平台特定字段
- 支持所有主流JSON解析器

## 更新日期
2026-06-24
