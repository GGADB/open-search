# Browser Harness交互模式

## 概述

Browser Harness通过Chrome DevTools Protocol直接控制浏览器，模拟用户交互。以下是常见的搜索交互模式。

## 基础搜索模式

### 模式1：标准搜索框
```python
# 适用于：Google、Bing、百度等标准搜索引擎
new_tab("https://www.google.com")
wait_for_load()

# 定位搜索框
search_box = find_element("[name='q']")
click(search_box)

# 输入查询
type_text(search_box, "browser automation")

# 提交搜索
submit_btn = find_element("[type='submit']")
click(submit_btn)
wait_for_load()

# 提取结果
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
    "[placeholder*='搜索']",
    "[placeholder*='search']"
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
        ".search-btn",
        "button:contains('搜索')",
        "button:contains('search')"
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

# 定位搜索框（可能需要等待）
search_box = wait_for_element("#search-box", timeout=10)
click(search_box)
type_text(search_box, "test query")

# 等待自动补全或搜索结果
time.sleep(1)

# 提交或选择建议
try:
    # 尝试点击搜索按钮
    submit_btn = find_element("#search-button")
    click(submit_btn)
except:
    # 或按Enter键
    keys("Enter")

wait_for_load()

# 等待结果加载
time.sleep(2)
results = extract_search_results()
```

## 高级交互模式

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
# 价格范围
price_min = find_element("#price-min")
click(price_min)
type_text(price_min, "1000")

price_max = find_element("#price-max")
click(price_max)
type_text(price_max, "5000")

# 品牌选择
brand_select = find_element("#brand-select")
click(brand_select)
brand_option = find_element("option[value='apple']")
click(brand_option)

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

## 结果提取模式

### 提取搜索结果
```python
def extract_search_results():
    """提取搜索结果 - 通用函数"""
    results = []
    
    # 尝试多种结果选择器
    result_selectors = [
        ".search-result",
        ".result-item",
        ".video-list .item",
        ".post-list .post",
        "[data-testid='search-result']",
        ".g",  # Google
        ".result"  # 通用
    ]
    
    for selector in result_selectors:
        try:
            items = find_elements(selector)
            if items:
                for item in items:
                    try:
                        title = item.find_element("h2, h3, .title, [data-testid='title']")
                        link = item.find_element("a")
                        snippet = item.find_element(".snippet, .description, p")
                        
                        results.append({
                            "title": title.text if title else "",
                            "url": link.get_attribute("href") if link else "",
                            "snippet": snippet.text if snippet else ""
                        })
                    except:
                        continue
                break
        except:
            continue
    
    return results
```

### 使用JavaScript提取
```python
def extract_with_js():
    """使用JavaScript提取结果"""
    js_code = """
    (() => {
        const results = [];
        const items = document.querySelectorAll('.search-result, .result-item, .video-list .item');
        
        items.forEach(item => {
            const title = item.querySelector('h2, h3, .title');
            const link = item.querySelector('a');
            const snippet = item.querySelector('.snippet, .description, p');
            
            if (title && link) {
                results.push({
                    title: title.textContent.trim(),
                    url: link.href,
                    snippet: snippet ? snippet.textContent.trim() : ''
                });
            }
        });
        
        return JSON.stringify(results);
    })()
    """
    
    results_json = js(js_code)
    return json.loads(results_json)
```

## 错误处理模式

### 元素未找到
```python
try:
    search_box = find_element("#search-box")
except ElementNotFound:
    # 尝试替代选择器
    search_box = find_element("[name='q']")
```

### 页面加载超时
```python
try:
    wait_for_load(timeout=10)
except TimeoutError:
    # 页面加载超时，尝试刷新
    refresh_page()
    wait_for_load(timeout=15)
```

### 搜索无结果
```python
results = extract_search_results()
if not results:
    # 尝试不同的搜索词
    # 或返回空结果
    pass
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
6. **文本内容**：`button:contains('搜索')`

### 3. 错误恢复
```python
def search_with_fallback(url, query):
    """带错误恢复的搜索"""
    try:
        new_tab(url)
        wait_for_load()
        
        # 尝试搜索
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

## 常见网站示例

### Google搜索
```python
new_tab("https://www.google.com")
wait_for_load()
search_box = find_element("[name='q']")
click(search_box)
type_text(search_box, "browser automation")
keys("Enter")
wait_for_load()
results = extract_search_results()
```

### Bing搜索
```python
new_tab("https://www.bing.com")
wait_for_load()
search_box = find_element("[name='q']")
click(search_box)
type_text(search_box, "browser automation")
keys("Enter")
wait_for_load()
results = extract_search_results()
```

### 自定义网站
```python
new_tab("https://custom-site.com")
wait_for_load()
# 使用通用搜索模式
search_with_fallback("https://custom-site.com", "test query")
```

## 更新日期
2026-06-24
