# 错误代码对照表

## 概述

智能搜索路由器使用标准化的错误代码，便于错误处理和调试。错误代码分为通用错误、OpenCLI错误和Browser Harness错误三类。

## 通用错误代码

| 代码 | HTTP状态码 | 说明 | 建议处理方式 |
|------|-----------|------|-------------|
| `ENGINE_NOT_FOUND` | 503 | 引擎不可用 | 检查引擎安装，尝试其他引擎 |
| `TIMEOUT` | 408 | 请求超时 | 增加超时时间，重试请求 |
| `NETWORK_ERROR` | 502 | 网络错误 | 检查网络连接，重试请求 |
| `INVALID_QUERY` | 400 | 无效的搜索词 | 检查搜索词格式，重新输入 |
| `UNKNOWN_ERROR` | 500 | 未知错误 | 查看错误详情，联系支持 |

## OpenCLI错误代码

| 代码 | 退出码 | 说明 | 建议处理方式 |
|------|-------|------|-------------|
| `ADAPTER_NOT_FOUND` | 1 | 适配器不存在 | 使用Browser Harness回退 |
| `ADAPTER_FAILED` | 1 | 适配器执行失败 | 检查适配器配置，重试 |
| `AUTH_REQUIRED` | 77 | 需要登录态 | 提示用户登录，重试 |
| `RATE_LIMITED` | 75 | 频率限制 | 等待后重试，减少请求频率 |
| `OPENCLI_NOT_INSTALLED` | 127 | OpenCLI未安装 | 安装OpenCLI |
| `BROWSER_NOT_CONNECTED` | 69 | 浏览器未连接 | 启动浏览器，检查连接 |
| `EMPTY_RESULT` | 66 | 空结果 | 检查搜索词，尝试其他网站 |
| `CONFIG_ERROR` | 78 | 配置错误 | 检查配置文件，修复错误 |
| `TIMEOUT` | 75 | 超时 | 增加超时时间，重试 |
| `INTERRUPTED` | 130 | 中断 | 重新执行命令 |

## Browser Harness错误代码

| 代码 | 说明 | 建议处理方式 |
|------|------|-------------|
| `BROWSER_NOT_CONNECTED` | 浏览器未连接 | 启动浏览器，检查远程调试 |
| `ELEMENT_NOT_FOUND` | 元素未找到 | 检查选择器，等待元素加载 |
| `PAGE_LOAD_TIMEOUT` | 页面加载超时 | 增加超时时间，重试 |
| `JS_EXECUTION_ERROR` | JavaScript执行错误 | 检查脚本，修复错误 |
| `BROWSER_HARNESS_NOT_INSTALLED` | Browser Harness未安装 | 安装Browser Harness |
| `TAB_NOT_FOUND` | 标签页未找到 | 创建新标签页，重试 |
| `SELECTOR_INVALID` | 选择器无效 | 检查选择器语法，修复 |
| `INTERACTION_FAILED` | 交互失败 | 检查元素状态，重试 |
| `EXTRACTION_FAILED` | 提取失败 | 检查提取逻辑，重试 |

## 错误处理策略

### 自动重试
```python
def search_with_retry(query, max_retries=3):
    """带重试的搜索"""
    for attempt in range(max_retries):
        try:
            result = search(query)
            return result
        except TimeoutError:
            if attempt < max_retries - 1:
                time.sleep(2 ** attempt)  # 指数退避
                continue
            else:
                raise
        except Exception as e:
            if attempt < max_retries - 1:
                continue
            else:
                raise
```

### 引擎回退
```python
def search_with_fallback(query):
    """带引擎回退的搜索"""
    try:
        # 尝试OpenCLI
        result = search_with_opencli(query)
        return result
    except AdapterNotFound:
        # 回退到Browser Harness
        result = search_with_browser_harness(query)
        return result
    except Exception as e:
        # 两个引擎都失败
        raise
```

### 错误报告
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
      "stderr": "Error: adapter not found for custom-site",
      "suggestion": "使用Browser Harness回退"
    }
  },
  "metadata": {
    "trigger": "manual",
    "timestamp": "2026-06-24T10:40:00Z",
    "duration": 0.3,
    "retry_count": 0,
    "fallback_used": false
  }
}
```

## 调试技巧

### 查看详细错误
```bash
# OpenCLI详细错误
opencli bilibili search "test" -f json -v

# Browser Harness详细错误
browser-harness --doctor
```

### 检查连接状态
```bash
# 检查OpenCLI连接
opencli doctor

# 检查Browser Harness连接
browser-harness --doctor

# 检查浏览器状态
curl localhost:19825/status
```

### 查看日志
```bash
# OpenCLI日志
opencli bilibili search "test" -f json --log-level debug

# Browser Harness日志
browser-harness --verbose
```

## 常见问题解决

### 问题1：适配器不存在
**错误**：`ADAPTER_NOT_FOUND`
**解决**：
1. 检查网站是否在OpenCLI支持列表中
2. 使用Browser Harness回退
3. 考虑创建自定义适配器

### 问题2：浏览器未连接
**错误**：`BROWSER_NOT_CONNECTED`
**解决**：
1. 启动Chrome/Chromium浏览器
2. 启用远程调试：`chrome://inspect/#remote-debugging`
3. 检查防火墙设置

### 问题3：频率限制
**错误**：`RATE_LIMITED`
**解决**：
1. 减少请求频率
2. 等待一段时间后重试
3. 使用缓存减少请求

### 问题4：登录态失效
**错误**：`AUTH_REQUIRED`
**解决**：
1. 重新登录目标网站
2. 检查cookie是否过期
3. 使用Browser Harness模拟登录

### 问题5：页面加载超时
**错误**：`PAGE_LOAD_TIMEOUT`
**解决**：
1. 增加超时时间
2. 检查网络连接
3. 尝试刷新页面

## 错误代码命名规范

### 命名规则
- 使用大写字母和下划线
- 简洁明了，易于理解
- 避免缩写（除非广泛接受）

### 示例
- ✅ `ADAPTER_NOT_FOUND`
- ✅ `BROWSER_NOT_CONNECTED`
- ❌ `ADPTR_NF`
- ❌ `BRWSR_NC`

### 分类前缀
- `OPENCLI_`：OpenCLI特定错误
- `BROWSER_`：Browser Harness特定错误
- 无前缀：通用错误

## 更新日期
2026-06-24
