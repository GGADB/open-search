# 标准搜索示例

## 概述

本文档包含标准搜索场景的示例，展示如何使用智能搜索路由器进行常见网站搜索。

## 示例1：bilibili视频搜索

### 场景
用户想要在bilibili搜索机器学习相关视频。

### 触发方式
```
/open search bilibili 机器学习
```

### 路由决策
- 网站：bilibili
- 检查：bilibili有OpenCLI适配器
- 决策：使用OpenCLI

### 执行命令
```bash
opencli bilibili search "机器学习" --limit 20 -f json
```

### 预期输出
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
    "duration": 1.2
  }
}
```

## 示例2：Google搜索

### 场景
用户想要搜索AI agent相关信息。

### 触发方式
```
/open search google AI agent
```

### 路由决策
- 网站：google
- 检查：google有OpenCLI适配器
- 决策：使用OpenCLI

### 执行命令
```bash
opencli google search "AI agent" --limit 10 -f json
```

### 预期输出
```json
{
  "source": "opencli",
  "query": "AI agent",
  "site": "google",
  "results": [
    {
      "title": "AI Agent: What It Is and How It Works",
      "url": "https://example.com/ai-agent",
      "snippet": "An AI agent is a software program that can perform tasks autonomously...",
      "metadata": {
        "date": "2026-06-15"
      }
    }
  ],
  "metadata": {
    "total": 10,
    "engine": "opencli",
    "trigger": "manual",
    "timestamp": "2026-06-24T10:35:00Z",
    "duration": 0.8
  }
}
```

## 示例3：Reddit搜索

### 场景
用户想要搜索browser automation相关讨论。

### 触发方式
```
/open search reddit browser automation
```

### 路由决策
- 网站：reddit
- 检查：reddit有OpenCLI适配器
- 决策：使用OpenCLI

### 执行命令
```bash
opencli reddit search "browser automation" --limit 10 -f json
```

### 预期输出
```json
{
  "source": "opencli",
  "query": "browser automation",
  "site": "reddit",
  "results": [
    {
      "title": "Best tools for browser automation in 2026?",
      "url": "https://www.reddit.com/r/automation/comments/xxx",
      "snippet": "I'm looking for recommendations on the best browser automation tools...",
      "metadata": {
        "author": "user123",
        "date": "2026-06-18",
        "score": 45,
        "comments": 23
      }
    }
  ],
  "metadata": {
    "total": 10,
    "engine": "opencli",
    "trigger": "manual",
    "timestamp": "2026-06-24T10:40:00Z",
    "duration": 1.5
  }
}
```

## 示例4：Twitter搜索

### 场景
用户想要搜索web scraping相关推文。

### 触发方式
```
/open search twitter web scraping
```

### 路由决策
- 网站：twitter
- 检查：twitter有OpenCLI适配器
- 决策：使用OpenCLI

### 执行命令
```bash
opencli twitter search "web scraping" --limit 10 -f json
```

### 预期输出
```json
{
  "source": "opencli",
  "query": "web scraping",
  "site": "twitter",
  "results": [
    {
      "title": "Just published a new guide on ethical web scraping...",
      "url": "https://twitter.com/user/status/xxx",
      "snippet": "Just published a new guide on ethical web scraping. Check it out!",
      "metadata": {
        "author": "@webscraping",
        "date": "2026-06-22",
        "score": 120,
        "comments": 15
      }
    }
  ],
  "metadata": {
    "total": 10,
    "engine": "opencli",
    "trigger": "manual",
    "timestamp": "2026-06-24T10:45:00Z",
    "duration": 1.8
  }
}
```

## 示例5：自然语言触发

### 场景
用户使用自然语言请求搜索。

### 触发方式
```
帮我用开放搜索在bilibili找机器学习视频
```

### 路由决策
- 触发方式：自然语言
- 解析：site=bilibili, query="机器学习视频"
- 检查：bilibili有OpenCLI适配器
- 决策：使用OpenCLI

### 执行命令
```bash
opencli bilibili search "机器学习视频" --limit 20 -f json
```

### 预期输出
```json
{
  "source": "opencli",
  "query": "机器学习视频",
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
    "timestamp": "2026-06-24T10:50:00Z",
    "duration": 1.3
  }
}
```

## 示例6：websearch回退

### 场景
用户搜索一个冷门话题，websearch返回空结果。

### 触发方式
```
搜索"量子计算在生物信息学中的应用"
（websearch返回空结果）
```

### 路由决策
- 触发方式：自动（websearch失败）
- 解析：query="量子计算在生物信息学中的应用"
- 决策：使用开放搜索

### 执行命令
```bash
opencli google search "量子计算在生物信息学中的应用" --limit 10 -f json
```

### 预期输出
```json
{
  "source": "opencli",
  "query": "量子计算在生物信息学中的应用",
  "site": "google",
  "results": [
    {
      "title": "Quantum Computing in Bioinformatics: A Review",
      "url": "https://example.com/quantum-bio",
      "snippet": "This paper reviews the applications of quantum computing in bioinformatics...",
      "metadata": {
        "date": "2026-05-10"
      }
    }
  ],
  "metadata": {
    "total": 5,
    "engine": "opencli",
    "trigger": "auto",
    "timestamp": "2026-06-24T10:55:00Z",
    "duration": 2.1,
    "fallback_reason": "websearch返回空结果"
  }
}
```

## 示例7：参数指定

### 场景
用户指定搜索参数。

### 触发方式
```
/open search bilibili 机器学习 --limit 5 --format csv
```

### 路由决策
- 网站：bilibili
- 检查：bilibili有OpenCLI适配器
- 决策：使用OpenCLI
- 参数：limit=5, format=csv

### 执行命令
```bash
opencli bilibili search "机器学习" --limit 5 -f csv
```

### 预期输出
```csv
title,url,snippet,author,date,views,score
机器学习入门教程,https://www.bilibili.com/video/BV1xxx,本视频介绍机器学习的基础概念...,UP主,2026-06-20,15000,980
```

## 示例8：多网站搜索

### 场景
用户想要在多个网站搜索。

### 触发方式
```
/open search bilibili 机器学习
/open search google 机器学习
/open search reddit 机器学习
```

### 路由决策
- 三个独立的搜索请求
- 每个都使用OpenCLI
- 分别返回结果

### 执行命令
```bash
# bilibili搜索
opencli bilibili search "机器学习" --limit 10 -f json

# Google搜索
opencli google search "机器学习" --limit 10 -f json

# Reddit搜索
opencli reddit search "机器学习" --limit 10 -f json
```

### 预期输出
三个独立的JSON结果，每个包含对应网站的搜索结果。

## 总结

这些示例展示了智能搜索路由器在标准搜索场景下的使用方式：

1. **标准网站搜索**：使用OpenCLI快速搜索
2. **自然语言触发**：支持多种触发方式
3. **websearch回退**：自动回退到开放搜索
4. **参数指定**：支持自定义搜索参数
5. **多网站搜索**：支持多个网站的独立搜索

所有示例都遵循统一的输出格式，便于后续处理和分析。

## 更新日期
2026-06-24
