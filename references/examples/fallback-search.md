# 回退搜索示例

## 概述

本文档包含回退搜索场景的示例，展示智能搜索路由器在websearch失败时如何自动回退到开放搜索。

## 示例1：websearch返回空结果

### 场景
用户搜索一个冷门话题，websearch返回空结果。

### 触发方式
```
用户：搜索"量子计算在生物信息学中的应用"
```

### 路由决策
1. **websearch尝试**：返回空结果
2. **自动触发**：检测到websearch失败
3. **回退到开放搜索**：使用OpenCLI或Browser Harness

### 执行流程
```
1. 用户请求搜索
2. websearch工具执行
3. websearch返回空结果
4. 检测到websearch失败
5. 自动触发开放搜索
6. 路由决策：选择OpenCLI或Browser Harness
7. 执行搜索
8. 返回结果
```

### 执行命令
```bash
# websearch尝试（模拟失败）
websearch "量子计算在生物信息学中的应用"
# 返回：空结果

# 自动回退到开放搜索
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
    "timestamp": "2026-06-24T11:35:00Z",
    "duration": 2.1,
    "fallback_reason": "websearch返回空结果"
  }
}
```

## 示例2：websearch超时

### 场景
用户搜索一个话题，websearch请求超时。

### 触发方式
```
用户：搜索"最新的人工智能研究进展"
```

### 路由决策
1. **websearch尝试**：请求超时
2. **自动触发**：检测到websearch超时
3. **回退到开放搜索**：使用OpenCLI或Browser Harness

### 执行流程
```
1. 用户请求搜索
2. websearch工具执行
3. websearch请求超时
4. 检测到websearch超时
5. 自动触发开放搜索
6. 路由决策：选择OpenCLI或Browser Harness
7. 执行搜索
8. 返回结果
```

### 执行命令
```bash
# websearch尝试（模拟超时）
websearch "最新的人工智能研究进展"
# 返回：超时错误

# 自动回退到开放搜索
opencli google search "最新的人工智能研究进展" --limit 10 -f json
```

### 预期输出
```json
{
  "source": "opencli",
  "query": "最新的人工智能研究进展",
  "site": "google",
  "results": [
    {
      "title": "AI Research Progress 2026",
      "url": "https://example.com/ai-progress",
      "snippet": "This report summarizes the latest advances in AI research...",
      "metadata": {
        "date": "2026-06-15"
      }
    }
  ],
  "metadata": {
    "total": 8,
    "engine": "opencli",
    "trigger": "auto",
    "timestamp": "2026-06-24T11:40:00Z",
    "duration": 3.5,
    "fallback_reason": "websearch请求超时"
  }
}
```

## 示例3：websearch网络错误

### 场景
用户搜索时遇到网络错误。

### 触发方式
```
用户：搜索"机器学习最新应用"
```

### 路由决策
1. **websearch尝试**：网络错误
2. **自动触发**：检测到websearch网络错误
3. **回退到开放搜索**：使用OpenCLI或Browser Harness

### 执行流程
```
1. 用户请求搜索
2. websearch工具执行
3. websearch网络错误
4. 检测到websearch网络错误
5. 自动触发开放搜索
6. 路由决策：选择OpenCLI或Browser Harness
7. 执行搜索
8. 返回结果
```

### 执行命令
```bash
# websearch尝试（模拟网络错误）
websearch "机器学习最新应用"
# 返回：网络错误

# 自动回退到开放搜索
opencli google search "机器学习最新应用" --limit 10 -f json
```

### 预期输出
```json
{
  "source": "opencli",
  "query": "机器学习最新应用",
  "site": "google",
  "results": [
    {
      "title": "Latest Applications of Machine Learning",
      "url": "https://example.com/ml-applications",
      "snippet": "This article discusses the latest applications of machine learning...",
      "metadata": {
        "date": "2026-06-18"
      }
    }
  ],
  "metadata": {
    "total": 12,
    "engine": "opencli",
    "trigger": "auto",
    "timestamp": "2026-06-24T11:45:00Z",
    "duration": 2.8,
    "fallback_reason": "websearch网络错误"
  }
}
```

## 示例4：websearch服务不可用

### 场景
用户搜索时websearch服务不可用。

### 触发方式
```
用户：搜索"深度学习框架比较"
```

### 路由决策
1. **websearch尝试**：服务不可用
2. **自动触发**：检测到websearch服务不可用
3. **回退到开放搜索**：使用OpenCLI或Browser Harness

### 执行流程
```
1. 用户请求搜索
2. websearch工具执行
3. websearch服务不可用
4. 检测到websearch服务不可用
5. 自动触发开放搜索
6. 路由决策：选择OpenCLI或Browser Harness
7. 执行搜索
8. 返回结果
```

### 执行命令
```bash
# websearch尝试（模拟服务不可用）
websearch "深度学习框架比较"
# 返回：服务不可用错误

# 自动回退到开放搜索
opencli google search "深度学习框架比较" --limit 10 -f json
```

### 预期输出
```json
{
  "source": "opencli",
  "query": "深度学习框架比较",
  "site": "google",
  "results": [
    {
      "title": "Comparison of Deep Learning Frameworks",
      "url": "https://example.com/dl-frameworks",
      "snippet": "This article compares popular deep learning frameworks...",
      "metadata": {
        "date": "2026-06-10"
      }
    }
  ],
  "metadata": {
    "total": 15,
    "engine": "opencli",
    "trigger": "auto",
    "timestamp": "2026-06-24T11:50:00Z",
    "duration": 4.2,
    "fallback_reason": "websearch服务不可用"
  }
}
```

## 示例5：websearch结果质量差

### 场景
用户搜索一个话题，websearch返回的结果质量差。

### 触发方式
```
用户：搜索"区块链在供应链中的应用"
```

### 路由决策
1. **websearch尝试**：返回结果质量差
2. **自动触发**：检测到websearch结果质量差
3. **回退到开放搜索**：使用OpenCLI或Browser Harness

### 执行流程
```
1. 用户请求搜索
2. websearch工具执行
3. websearch返回结果质量差
4. 检测到websearch结果质量差
5. 自动触发开放搜索
6. 路由决策：选择OpenCLI或Browser Harness
7. 执行搜索
8. 返回结果
```

### 执行命令
```bash
# websearch尝试（模拟结果质量差）
websearch "区块链在供应链中的应用"
# 返回：结果质量差

# 自动回退到开放搜索
opencli google search "区块链在供应链中的应用" --limit 10 -f json
```

### 预期输出
```json
{
  "source": "opencli",
  "query": "区块链在供应链中的应用",
  "site": "google",
  "results": [
    {
      "title": "Blockchain in Supply Chain Management",
      "url": "https://example.com/blockchain-supply",
      "snippet": "This article explores the applications of blockchain technology in supply chain management...",
      "metadata": {
        "date": "2026-06-12"
      }
    }
  ],
  "metadata": {
    "total": 10,
    "engine": "opencli",
    "trigger": "auto",
    "timestamp": "2026-06-24T11:55:00Z",
    "duration": 3.8,
    "fallback_reason": "websearch结果质量差"
  }
}
```

## 示例6：websearch回退到Browser Harness

### 场景
用户搜索一个需要JavaScript渲染的网站。

### 触发方式
```
用户：搜索"现代前端框架教程"
```

### 路由决策
1. **websearch尝试**：返回空结果
2. **自动触发**：检测到websearch失败
3. **路由决策**：需要JavaScript渲染的网站
4. **回退到Browser Harness**

### 执行流程
```
1. 用户请求搜索
2. websearch工具执行
3. websearch返回空结果
4. 检测到websearch失败
5. 自动触发开放搜索
6. 路由决策：需要JavaScript渲染
7. 使用Browser Harness
8. 执行搜索
9. 返回结果
```

### 执行脚本
```python
# websearch尝试（模拟失败）
# websearch "现代前端框架教程"
# 返回：空结果

# 自动回退到开放搜索
browser-harness <<'PY'
new_tab("https://modern-frontend-site.com")
wait_for_load()
time.sleep(2)  # 等待JavaScript渲染

search_box = find_element("#search-box")
click(search_box)
type_text(search_box, "现代前端框架教程")
keys("Enter")
wait_for_load()

time.sleep(2)  # 等待结果加载
results = extract_search_results()
print(json.dumps(results, ensure_ascii=False))
PY
```

### 预期输出
```json
{
  "source": "browser-harness",
  "query": "现代前端框架教程",
  "site": "modern-frontend-site.com",
  "results": [
    {
      "title": "Modern Frontend Framework Tutorial",
      "url": "https://modern-frontend-site.com/tutorial/1",
      "snippet": "This tutorial covers modern frontend frameworks...",
      "metadata": {
        "framework": "React",
        "difficulty": "intermediate"
      }
    }
  ],
  "metadata": {
    "total": 8,
    "engine": "browser-harness",
    "trigger": "auto",
    "timestamp": "2026-06-24T12:00:00Z",
    "duration": 12.5,
    "fallback_reason": "websearch返回空结果"
  }
}
```

## 示例7：多次回退尝试

### 场景
用户搜索一个话题，websearch和OpenCLI都失败。

### 触发方式
```
用户：搜索"量子机器学习算法"
```

### 路由决策
1. **websearch尝试**：返回空结果
2. **自动触发**：检测到websearch失败
3. **OpenCLI尝试**：适配器不存在
4. **回退到Browser Harness**

### 执行流程
```
1. 用户请求搜索
2. websearch工具执行
3. websearch返回空结果
4. 检测到websearch失败
5. 自动触发开放搜索
6. OpenCLI尝试
7. OpenCLI适配器不存在
8. 回退到Browser Harness
9. 执行搜索
10. 返回结果
```

### 执行脚本
```python
# websearch尝试（模拟失败）
# websearch "量子机器学习算法"
# 返回：空结果

# 自动回退到开放搜索
# OpenCLI尝试
# opencli quantum-ml search "量子机器学习算法"
# 返回：适配器不存在

# 回退到Browser Harness
browser-harness <<'PY'
new_tab("https://quantum-ml-site.com")
wait_for_load()

search_box = find_element("#search-box")
click(search_box)
type_text(search_box, "量子机器学习算法")
keys("Enter")
wait_for_load()

results = extract_search_results()
print(json.dumps(results, ensure_ascii=False))
PY
```

### 预期输出
```json
{
  "source": "browser-harness",
  "query": "量子机器学习算法",
  "site": "quantum-ml-site.com",
  "results": [
    {
      "title": "Quantum Machine Learning Algorithms",
      "url": "https://quantum-ml-site.com/algorithm/1",
      "snippet": "This article introduces quantum machine learning algorithms...",
      "metadata": {
        "algorithm_type": "quantum",
        "complexity": "high"
      }
    }
  ],
  "metadata": {
    "total": 5,
    "engine": "browser-harness",
    "trigger": "auto",
    "timestamp": "2026-06-24T12:05:00Z",
    "duration": 18.3,
    "fallback_reason": "websearch返回空结果",
    "fallback_chain": ["websearch", "opencli", "browser-harness"]
  }
}
```

## 总结

这些示例展示了智能搜索路由器在回退搜索场景下的使用方式：

1. **websearch返回空结果**：自动回退到开放搜索
2. **websearch超时**：自动回退到开放搜索
3. **websearch网络错误**：自动回退到开放搜索
4. **websearch服务不可用**：自动回退到开放搜索
5. **websearch结果质量差**：自动回退到开放搜索
6. **websearch回退到Browser Harness**：处理需要JavaScript渲染的网站
7. **多次回退尝试**：websearch和OpenCLI都失败时的处理

所有示例都展示了智能搜索路由器的自动回退机制，确保用户在websearch失败时仍能获得搜索结果。

## 更新日期
2026-06-24
