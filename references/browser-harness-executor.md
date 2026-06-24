# Browser Harness执行器规范

## 概述

Browser Harness执行器负责生成搜索脚本、模拟用户交互、提取搜索结果。本文档定义了执行器的规范和实现细节。

## 核心功能

### 1. 脚本生成
```python
# 生成搜索脚本
def generate_search_script(url, query):
    script = f"""
new_tab("{url}")
wait_for_load()
search_box = find_element("[name='q']")
click(search_box)
type_text(search_box, "{query}")
keys("Enter")
wait_for_load()
results = extract_search_results()
print(json.dumps(results))
"""
    return script
```

### 2. 用户交互模拟
```python
# 模拟用户输入
search_box = find_element("#search-box")
click(search_box)
type_text(search_box, "browser automation")

# 模拟用户点击
submit_btn = find_element("#search-button")
click(submit_btn)

# 模拟键盘操作
keys("Enter")
keys("Tab")
keys("Escape")
```

### 3. 结果提取
```python
# 提取搜索结果
def extract_search_results():
    results = []

    # 尝试多种选择器
    result_selectors = [
        ".search-result",
        ".result-item",
        ".video-list .item",
        ".post-list .post"
    ]

    for selector in result_selectors:
        try:
            items = find_elements(selector)
            if items:
                for item in items:
                    title = item.find_element("h2, h3, .title")
                    link = item.find_element("a")
                    snippet = item.find_element(".snippet, .description, p")

                    results.append({
                        "title": title.text if title else "",
                        "url": link.get_attribute("href") if link else "",
                        "snippet": snippet.text if snippet else ""
                    })
                break
        except:
            continue

    return results
```

## 交互模式

### 模式1：标准搜索框
```python
# 适用于：Google、Bing、百度等标准搜索引擎
new_tab("https://www.google.com")
wait_for_load()

search_box = find_element("[name='q']")
click(search_box)
type_text(search_box, "browser automation")

keys("Enter")
wait_for_load()

results = extract_search_results()
```

### 模式2：自定义搜索框
```python
# 适用于：自定义网站的搜索功能
new_tab("https://custom-site.com")
wait_for_load()

# 尝试多种选择器
search_selectors = [
    "#search-box",
    "[name='q']",
    "[type='search']",
    ".search-input",
    "[placeholder*='搜索']"
]

search_box = None
for selector in search_selectors:
    try:
        search_box = find_element(selector)
        if search_box:
            break
    except:
        continue

if search_box:
    click(search_box)
    type_text(search_box, "test query")

    # 尝试提交
    submit_selectors = [
        "#search-button",
        "[type='submit']",
        ".search-btn"
    ]

    for selector in submit_selectors:
        try:
            submit_btn = find_element(selector)
            if submit_btn:
                click(submit_btn)
                break
        except:
            continue

    wait_for_load()
    results = extract_search_results()
```

### 模式3：SPA搜索（JavaScript渲染）
```python
# 适用于：React、Vue、Angular等SPA应用
new_tab("https://spa-site.com")
wait_for_load()

# 等待JavaScript渲染
time.sleep(2)

# 定位搜索框
search_box = wait_for_element("#search-box", timeout=10)
click(search_box)
type_text(search_box, "test query")

# 等待自动补全
time.sleep(1)

# 提交搜索
try:
    submit_btn = find_element("#search-button")
    click(submit_btn)
except:
    keys("Enter")

wait_for_load()

# 等待结果加载
time.sleep(2)
results = extract_search_results()
```

### 模式4：带筛选条件的搜索
```python
# 适用于：电商、招聘等带筛选条件的网站
new_tab("https://ecommerce-site.com")
wait_for_load()

# 输入搜索词
search_box = find_element("#search-box")
click(search_box)
type_text(search_box, "laptop")

# 设置筛选条件
price_min = find_element("#price-min")
click(price_min)
type_text(price_min, "1000")

price_max = find_element("#price-max")
click(price_max)
type_text(price_max, "5000")

# 提交搜索
submit_btn = find_element("#search-button")
click(submit_btn)
wait_for_load()

results = extract_search_results()
```

### 模式5：分页搜索
```python
# 适用于：需要翻页获取更多结果的场景
new_tab("https://search-site.com")
wait_for_load()

# 执行初始搜索
search_box = find_element("#search-box")
click(search_box)
type_text(search_box, "test")
submit_btn = find_element("#search-button")
click(submit_btn)
wait_for_load()

# 收集所有页面的结果
all_results = []
page = 1

while True:
    # 提取当前页结果
    page_results = extract_search_results()
    all_results.extend(page_results)

    # 检查是否有下一页
    try:
        next_btn = find_element(".next-page, [aria-label='next']")
        if next_btn and not next_btn.get_attribute("disabled"):
            click(next_btn)
            wait_for_load()
            page += 1
            time.sleep(1)
        else:
            break
    except:
        break

results = all_results
```

## 错误处理

### 错误类型
1. **浏览器未连接** (BROWSER_NOT_CONNECTED)
   - 处理：提示用户启动浏览器

2. **元素未找到** (ELEMENT_NOT_FOUND)
   - 处理：尝试其他选择器

3. **页面加载超时** (PAGE_LOAD_TIMEOUT)
   - 处理：增加超时时间，重试

4. **JavaScript执行错误** (JS_EXECUTION_ERROR)
   - 处理：检查脚本，修复错误

### 错误处理脚本
```python
try:
    new_tab("https://site.com")
    wait_for_load()

    search_box = find_element("#search-box")
    click(search_box)
    type_text(search_box, "query")

    submit_btn = find_element("#search-button")
    click(submit_btn)
    wait_for_load()

    results = extract_search_results()
    print(json.dumps(results))

except ElementNotFound as e:
    print(json.dumps({
        "error": {
            "code": "ELEMENT_NOT_FOUND",
            "message": str(e),
            "engine": "browser-harness"
        }
    }))

except TimeoutError as e:
    print(json.dumps({
        "error": {
            "code": "PAGE_LOAD_TIMEOUT",
            "message": str(e),
            "engine": "browser-harness"
        }
    }))

except Exception as e:
    print(json.dumps({
        "error": {
            "code": "UNKNOWN_ERROR",
            "message": str(e),
            "engine": "browser-harness"
        }
    }))
```

## 集成示例

### 示例1：Google搜索
```python
browser-harness <<'PY'
new_tab("https://www.google.com")
wait_for_load()
search_box = find_element("[name='q']")
click(search_box)
type_text(search_box, "browser automation")
keys("Enter")
wait_for_load()
results = extract_search_results()
print(json.dumps(results))
PY
```

### 示例2：自定义网站搜索
```python
browser-harness <<'PY'
new_tab("https://custom-site.com")
wait_for_load()
search_box = find_element("#search-box")
click(search_box)
type_text(search_box, "test query")
keys("Enter")
wait_for_load()
results = extract_search_results()
print(json.dumps(results))
PY
```

### 示例3：带错误处理的搜索
```python
browser-harness <<'PY'
try:
    new_tab("https://site.com")
    wait_for_load()

    search_box = find_element("#search-box")
    click(search_box)
    type_text(search_box, "query")

    submit_btn = find_element("#search-button")
    click(submit_btn)
    wait_for_load()

    results = extract_search_results()
    print(json.dumps(results))

except Exception as e:
    print(json.dumps({
        "error": {
            "code": "UNKNOWN_ERROR",
            "message": str(e),
            "engine": "browser-harness"
        }
    }))
PY
```

## 最佳实践

### 1. 等待策略
```python
# 等待页面加载
wait_for_load()

# 等待特定元素
wait_for_element("#search-box", timeout=10)

# 等待JavaScript渲染
time.sleep(2)
```

### 2. 选择器优先级
1. **ID选择器**：`#search-box`（最可靠）
2. **name属性**：`[name='q']`
3. **type属性**：`[type='search']`
4. **class选择器**：`.search-input`
5. **placeholder**：`[placeholder*='搜索']`

### 3. 错误恢复
```python
def search_with_fallback(url, query):
    """带错误恢复的搜索"""
    try:
        new_tab(url)
        wait_for_load()

        search_box = find_element("#search-box")
        click(search_box)
        type_text(search_box, query)

        submit_btn = find_element("#search-button")
        click(submit_btn)
        wait_for_load()

        results = extract_search_results()
        return results

    except Exception as e:
        print(f"搜索失败: {e}", file=sys.stderr)
        return []
```

## 测试用例

### 测试1：标准搜索
```bash
browser-harness <<'PY'
new_tab("https://www.google.com")
wait_for_load()
search_box = find_element("[name='q']")
click(search_box)
type_text(search_box, "test")
keys("Enter")
wait_for_load()
results = extract_search_results()
print(json.dumps(results))
PY
```

### 测试2：自定义网站
```bash
browser-harness <<'PY'
new_tab("https://custom-site.com")
wait_for_load()
search_box = find_element("#search-box")
click(search_box)
type_text(search_box, "test")
keys("Enter")
wait_for_load()
results = extract_search_results()
print(json.dumps(results))
PY
```

### 测试3：错误处理
```bash
browser-harness <<'PY'
try:
    new_tab("https://nonexistent-site.com")
    wait_for_load()
except TimeoutError:
    print(json.dumps({
        "error": {
            "code": "PAGE_LOAD_TIMEOUT",
            "message": "页面加载超时",
            "engine": "browser-harness"
        }
    }))
PY
```

## 更新日期
2026-06-24
