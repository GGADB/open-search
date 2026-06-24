# 路由规则详细说明

## 概述

智能搜索路由器的路由决策基于一系列规则，自动选择最合适的搜索引擎。本文档详细说明路由规则、决策逻辑和特殊情况处理。

## 路由决策流程

### 完整决策树
```
搜索请求进入
    │
    ├── 1. 检查触发方式
    │   ├── 自动触发（websearch失败）
    │   │   └── 进入开放搜索路由
    │   └── 手动触发（/open search 或 使用开放搜索）
    │       └── 进入开放搜索路由
    │
    ├── 2. 解析请求
    │   ├── 提取网站名（如有）
    │   ├── 提取搜索词
    │   └── 提取参数（limit、format等）
    │
    ├── 3. 路由决策
    │   ├── 网站有OpenCLI适配器？
    │   │   ├── 是 → 使用OpenCLI
    │   │   └── 否 → 使用Browser Harness
    │   └── OpenCLI失败？
    │       └── 是 → 回退到Browser Harness
    │
    └── 4. 执行搜索
        ├── OpenCLI路径
        │   ├── 构建命令
        │   ├── 执行命令
        │   └── 解析输出
        └── Browser Harness路径
            ├── 生成脚本
            ├── 执行脚本
            └── 提取结果
```

## 路由规则

### 规则1：优先使用OpenCLI
**条件**：
- 网站在OpenCLI支持列表中
- OpenCLI命令执行成功
- 输出格式正确

**逻辑**：
```python
def should_use_opencli(site, query):
    """判断是否应该使用OpenCLI"""
    # 检查网站是否有适配器
    if not has_opencli_adapter(site):
        return False
    
    # 检查适配器是否支持搜索命令
    if not supports_search_command(site):
        return False
    
    # 检查是否有登录态要求
    if requires_auth(site) and not has_auth(site):
        return False
    
    return True
```

### 规则2：回退到Browser Harness
**条件**：
- OpenCLI无对应适配器
- OpenCLI执行失败
- 需要JavaScript渲染
- 需要复杂交互

**逻辑**：
```python
def should_use_browser_harness(site, query, opencli_failed=False):
    """判断是否应该使用Browser Harness"""
    # 如果OpenCLI失败，回退到Browser Harness
    if opencli_failed:
        return True
    
    # 检查是否需要JavaScript渲染
    if requires_js_rendering(site):
        return True
    
    # 检查是否需要复杂交互
    if requires_complex_interaction(site):
        return True
    
    return False
```

### 规则3：混合模式
**条件**：
- 需要探索网站结构
- 需要发现API端点
- 需要验证数据

**逻辑**：
```python
def use_hybrid_mode(site, query):
    """使用混合模式"""
    # 阶段1：用Browser Harness探索
    api_endpoint = discover_api_with_browser_harness(site)
    
    # 阶段2：用OpenCLI提取数据
    results = extract_with_opencli(api_endpoint, query)
    
    return results
```

## 网站分类

### 类别1：标准搜索网站
**特征**：
- 有标准搜索框
- 支持URL参数搜索
- 有OpenCLI适配器

**示例**：
- bilibili、Google、Reddit、Twitter

**路由**：优先使用OpenCLI

### 类别2：SPA网站
**特征**：
- 使用React、Vue、Angular等框架
- 需要JavaScript渲染
- 动态加载内容

**示例**：
- 现代Web应用、单页应用

**路由**：使用Browser Harness

### 类别3：需要登录的网站
**特征**：
- 需要登录态才能搜索
- 有cookie/session要求
- 有私有内容

**示例**：
- LinkedIn、Twitter（私有内容）、企业内部系统

**路由**：使用Browser Harness（模拟登录）

### 类别4：复杂交互网站
**特征**：
- 有复杂的筛选条件
- 有多步交互流程
- 有动态表单

**示例**：
- 电商网站、招聘网站、预订系统

**路由**：使用Browser Harness

### 类别5：静态网站
**特征**：
- 纯HTML页面
- 无JavaScript渲染
- 简单的搜索功能

**示例**：
- 老旧网站、文档网站

**路由**：优先使用OpenCLI（如有适配器）

## 特殊情况处理

### 情况1：网站不在OpenCLI支持列表
**处理**：
1. 检查是否有类似网站的适配器
2. 尝试使用Browser Harness
3. 记录网站信息，便于后续添加适配器

**代码**：
```python
def handle_unsupported_site(site, query):
    """处理不支持的网站"""
    # 检查是否有类似网站
    similar_site = find_similar_site(site)
    if similar_site:
        return search_with_opencli(similar_site, query)
    
    # 使用Browser Harness
    return search_with_browser_harness(site, query)
```

### 情况2：OpenCLI执行失败
**处理**：
1. 记录错误信息
2. 分析失败原因
3. 尝试Browser Harness回退
4. 如果Browser Harness也失败，返回错误

**代码**：
```python
def handle_opencli_failure(site, query, error):
    """处理OpenCLI失败"""
    # 记录错误
    log_error(error)
    
    # 分析失败原因
    if error.code == "ADAPTER_NOT_FOUND":
        # 适配器不存在，使用Browser Harness
        return search_with_browser_harness(site, query)
    elif error.code == "AUTH_REQUIRED":
        # 需要登录，使用Browser Harness
        return search_with_browser_harness(site, query)
    elif error.code == "RATE_LIMITED":
        # 频率限制，等待后重试
        time.sleep(60)
        return search_with_opencli(site, query)
    else:
        # 其他错误，尝试Browser Harness
        return search_with_browser_harness(site, query)
```

### 情况3：Browser Harness执行失败
**处理**：
1. 记录错误信息
2. 分析失败原因
3. 尝试修复或重试
4. 如果仍然失败，返回错误

**代码**：
```python
def handle_browser_harness_failure(site, query, error):
    """处理Browser Harness失败"""
    # 记录错误
    log_error(error)
    
    # 分析失败原因
    if error.code == "BROWSER_NOT_CONNECTED":
        # 浏览器未连接，提示用户
        raise BrowserNotConnectedError("请启动浏览器并启用远程调试")
    elif error.code == "ELEMENT_NOT_FOUND":
        # 元素未找到，尝试其他选择器
        return search_with_alternative_selectors(site, query)
    elif error.code == "PAGE_LOAD_TIMEOUT":
        # 页面加载超时，重试
        return search_with_browser_harness(site, query, timeout=30)
    else:
        # 其他错误，返回错误
        raise
```

### 情况4：websearch回退触发
**处理**：
1. 检测websearch状态
2. 如果websearch失败，自动触发开放搜索
3. 记录回退原因
4. 执行开放搜索

**代码**：
```python
def handle_websearch_fallback(query):
    """处理websearch回退"""
    # 检测websearch状态
    websearch_status = check_websearch_status()
    
    if websearch_status == "failed":
        # 记录回退原因
        fallback_reason = "websearch返回空结果或错误"
        
        # 执行开放搜索
        result = search_with_open_search(query)
        
        # 添加回退信息
        result.metadata.fallback_reason = fallback_reason
        
        return result
```

## 路由优化

### 优化1：缓存适配器信息
```python
# 缓存OpenCLI适配器列表
adapter_cache = {}

def get_adapter_list():
    """获取适配器列表（带缓存）"""
    if not adapter_cache:
        adapters = run_command("opencli list -f yaml")
        adapter_cache = parse_adapters(adapters)
    return adapter_cache
```

### 优化2：预测性路由
```python
def predict_best_engine(site, query):
    """预测最佳引擎"""
    # 基于历史记录预测
    history = get_search_history(site, query)
    
    if history:
        # 使用历史记录中的成功引擎
        return history.most_successful_engine
    
    # 基于网站特征预测
    if is_spa_site(site):
        return "browser-harness"
    elif has_opencli_adapter(site):
        return "opencli"
    else:
        return "browser-harness"
```

### 优化3：并行探索
```python
def parallel_explore(site, query):
    """并行探索两个引擎"""
    # 同时启动两个引擎
    opencli_future = submit_to_thread_pool(search_with_opencli, site, query)
    browser_future = submit_to_thread_pool(search_with_browser_harness, site, query)
    
    # 等待第一个成功的结果
    result = wait_for_first_success([opencli_future, browser_future])
    
    return result
```

## 路由决策示例

### 示例1：标准网站搜索
```
用户请求：/open search bilibili 机器学习
解析：site=bilibili, query="机器学习"
检查：bilibili有OpenCLI适配器
决策：使用OpenCLI
执行：opencli bilibili search "机器学习" -f json
```

### 示例2：自定义网站搜索
```
用户请求：/open search https://custom-site.com/search?q=test
解析：site=custom-site.com, query="test"
检查：custom-site.com无OpenCLI适配器
决策：使用Browser Harness
执行：browser-harness脚本
```

### 示例3：websearch回退
```
用户请求：搜索冷门话题
websearch：返回空结果
触发：自动回退到开放搜索
决策：使用OpenCLI（如有适配器）或Browser Harness
执行：相应引擎
```

### 示例4：复杂交互网站
```
用户请求：/open search linkedin "software engineer"
解析：site=linkedin, query="software engineer"
检查：linkedin需要登录态
决策：使用Browser Harness（模拟登录）
执行：browser-harness脚本
```

## 更新日期
2026-06-24
