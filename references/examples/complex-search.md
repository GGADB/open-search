# 复杂搜索示例

## 概述

本文档包含复杂搜索场景的示例，展示如何使用智能搜索路由器处理需要JavaScript渲染、复杂交互或登录态的网站。

## 示例1：SPA网站搜索

### 场景
用户想要搜索一个使用React构建的现代Web应用。

### 触发方式
```
/open search https://spa-site.com/search?q=test
```

### 路由决策
- 网站：spa-site.com
- 检查：无OpenCLI适配器
- 分析：SPA网站需要JavaScript渲染
- 决策：使用Browser Harness

### 执行脚本
```python
browser-harness <<'PY'
# 打开网站
new_tab("https://spa-site.com")
wait_for_load()

# 等待JavaScript渲染
time.sleep(2)

# 定位搜索框（尝试多种选择器）
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
    
    # 提交搜索
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
    
    # 等待结果加载
    time.sleep(2)
    
    # 提取结果
    results = extract_search_results()
    print(json.dumps(results, ensure_ascii=False))
else:
    print(json.dumps([]))
PY
```

### 预期输出
```json
{
  "source": "browser-harness",
  "query": "test query",
  "site": "spa-site.com",
  "results": [
    {
      "title": "Search Result 1",
      "url": "https://spa-site.com/result/1",
      "snippet": "This is the first search result...",
      "metadata": {}
    }
  ],
  "metadata": {
    "total": 10,
    "engine": "browser-harness",
    "trigger": "manual",
    "timestamp": "2026-06-24T11:00:00Z",
    "duration": 8.5
  }
}
```

## 示例2：需要登录的网站

### 场景
用户想要搜索LinkedIn上的职位信息。

### 触发方式
```
/open search linkedin "software engineer"
```

### 路由决策
- 网站：linkedin
- 检查：linkedin有OpenCLI适配器
- 分析：需要登录态才能搜索
- 决策：使用Browser Harness（模拟登录）

### 执行脚本
```python
browser-harness <<'PY'
# 打开LinkedIn
new_tab("https://www.linkedin.com")
wait_for_load()

# 检查是否已登录
try:
    # 尝试找到搜索框（已登录状态）
    search_box = find_element("[name='q']")
    click(search_box)
    type_text(search_box, "software engineer")
    keys("Enter")
    wait_for_load()
except:
    # 未登录，提示用户
    print(json.dumps({
        "error": {
            "code": "AUTH_REQUIRED",
            "message": "需要登录LinkedIn",
            "suggestion": "请先登录LinkedIn，然后重试"
        }
    }))
    exit(1)

# 提取搜索结果
results = extract_search_results()
print(json.dumps(results, ensure_ascii=False))
PY
```

### 预期输出（已登录）
```json
{
  "source": "browser-harness",
  "query": "software engineer",
  "site": "linkedin.com",
  "results": [
    {
      "title": "Software Engineer at Google",
      "url": "https://www.linkedin.com/jobs/view/xxx",
      "snippet": "We are looking for a software engineer to join our team...",
      "metadata": {
        "company": "Google",
        "location": "Mountain View, CA",
        "posted_date": "2026-06-20"
      }
    }
  ],
  "metadata": {
    "total": 15,
    "engine": "browser-harness",
    "trigger": "manual",
    "timestamp": "2026-06-24T11:05:00Z",
    "duration": 12.3
  }
}
```

### 预期输出（未登录）
```json
{
  "error": {
    "code": "AUTH_REQUIRED",
    "message": "需要登录LinkedIn",
    "engine": "browser-harness",
    "details": {
      "site": "linkedin.com",
      "query": "software engineer",
      "suggestion": "请先登录LinkedIn，然后重试"
    }
  },
  "metadata": {
    "trigger": "manual",
    "timestamp": "2026-06-24T11:05:00Z",
    "duration": 5.2
  }
}
```

## 示例3：复杂交互网站

### 场景
用户想要在电商网站搜索商品并筛选。

### 触发方式
```
/open search https://ecommerce-site.com/search?q=laptop
```

### 路由决策
- 网站：ecommerce-site.com
- 检查：无OpenCLI适配器
- 分析：需要复杂交互（筛选条件）
- 决策：使用Browser Harness

### 执行脚本
```python
browser-harness <<'PY'
# 打开电商网站
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

# 提取结果
results = extract_search_results()
print(json.dumps(results, ensure_ascii=False))
PY
```

### 预期输出
```json
{
  "source": "browser-harness",
  "query": "laptop",
  "site": "ecommerce-site.com",
  "results": [
    {
      "title": "Apple MacBook Pro 14-inch",
      "url": "https://ecommerce-site.com/product/xxx",
      "snippet": "Apple MacBook Pro with M3 chip...",
      "metadata": {
        "price": "$1999",
        "brand": "Apple",
        "rating": "4.8"
      }
    }
  ],
  "metadata": {
    "total": 20,
    "engine": "browser-harness",
    "trigger": "manual",
    "timestamp": "2026-06-24T11:10:00Z",
    "duration": 15.7
  }
}
```

## 示例4：分页搜索

### 场景
用户想要搜索并获取多页结果。

### 触发方式
```
/open search https://search-site.com/search?q=test
```

### 路由决策
- 网站：search-site.com
- 检查：无OpenCLI适配器
- 分析：需要分页获取结果
- 决策：使用Browser Harness

### 执行脚本
```python
browser-harness <<'PY'
# 打开网站
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

# 输出结果
print(json.dumps({
    "results": all_results,
    "total_pages": page,
    "total_results": len(all_results)
}, ensure_ascii=False))
PY
```

### 预期输出
```json
{
  "source": "browser-harness",
  "query": "test",
  "site": "search-site.com",
  "results": [
    {
      "title": "Result 1",
      "url": "https://search-site.com/result/1",
      "snippet": "First result..."
    },
    {
      "title": "Result 2",
      "url": "https://search-site.com/result/2",
      "snippet": "Second result..."
    }
  ],
  "metadata": {
    "total": 50,
    "engine": "browser-harness",
    "trigger": "manual",
    "timestamp": "2026-06-24T11:15:00Z",
    "duration": 25.4,
    "pagination": {
      "current_page": 3,
      "total_pages": 3,
      "has_next": false
    }
  }
}
```

## 示例5：动态加载网站

### 场景
用户想要搜索一个使用无限滚动加载的网站。

### 触发方式
```
/open search https://infinite-scroll-site.com/search?q=test
```

### 路由决策
- 网站：infinite-scroll-site.com
- 检查：无OpenCLI适配器
- 分析：需要处理无限滚动
- 决策：使用Browser Harness

### 执行脚本
```python
browser-harness <<'PY'
# 打开网站
new_tab("https://infinite-scroll-site.com")
wait_for_load()

# 执行搜索
search_box = find_element("#search-box")
click(search_box)
type_text(search_box, "test")
keys("Enter")
wait_for_load()

# 滚动加载更多结果
all_results = []
last_height = 0

while True:
    # 提取当前可见结果
    current_results = extract_search_results()
    all_results.extend(current_results)
    
    # 滚动到页面底部
    js("window.scrollTo(0, document.body.scrollHeight)")
    time.sleep(2)
    
    # 检查是否有新内容加载
    new_height = js("document.body.scrollHeight")
    if new_height == last_height:
        break
    last_height = new_height

# 去重
unique_results = []
seen_urls = set()
for result in all_results:
    if result["url"] not in seen_urls:
        unique_results.append(result)
        seen_urls.add(result["url"])

print(json.dumps(unique_results, ensure_ascii=False))
PY
```

### 预期输出
```json
{
  "source": "browser-harness",
  "query": "test",
  "site": "infinite-scroll-site.com",
  "results": [
    {
      "title": "Result 1",
      "url": "https://infinite-scroll-site.com/result/1",
      "snippet": "First result..."
    }
  ],
  "metadata": {
    "total": 100,
    "engine": "browser-harness",
    "trigger": "manual",
    "timestamp": "2026-06-24T11:20:00Z",
    "duration": 30.2
  }
}
```

## 示例6：多步骤搜索

### 场景
用户想要执行多步骤搜索流程。

### 触发方式
```
/open search https://multi-step-site.com/search?q=test
```

### 路由决策
- 网站：multi-step-site.com
- 检查：无OpenCLI适配器
- 分析：需要多步骤交互
- 决策：使用Browser Harness

### 执行脚本
```python
browser-harness <<'PY'
# 步骤1：选择搜索类别
new_tab("https://multi-step-site.com")
wait_for_load()

category_select = find_element("#category-select")
click(category_select)
category_option = find_element("option[value='technology']")
click(category_option)

# 步骤2：输入搜索词
search_box = find_element("#search-box")
click(search_box)
type_text(search_box, "test")

# 步骤3：选择时间范围
time_select = find_element("#time-select")
click(time_select)
time_option = find_element("option[value='last-week']")
click(time_option)

# 步骤4：提交搜索
submit_btn = find_element("#search-button")
click(submit_btn)
wait_for_load()

# 步骤5：提取结果
results = extract_search_results()
print(json.dumps(results, ensure_ascii=False))
PY
```

### 预期输出
```json
{
  "source": "browser-harness",
  "query": "test",
  "site": "multi-step-site.com",
  "results": [
    {
      "title": "Technology Result 1",
      "url": "https://multi-step-site.com/result/1",
      "snippet": "First technology result from last week...",
      "metadata": {
        "category": "technology",
        "time_range": "last-week"
      }
    }
  ],
  "metadata": {
    "total": 15,
    "engine": "browser-harness",
    "trigger": "manual",
    "timestamp": "2026-06-24T11:25:00Z",
    "duration": 18.9
  }
}
```

## 示例7：错误处理

### 场景
用户搜索一个不存在的网站。

### 触发方式
```
/open search https://nonexistent-site.com/search?q=test
```

### 路由决策
- 网站：nonexistent-site.com
- 检查：无OpenCLI适配器
- 决策：使用Browser Harness
- 结果：网站不存在

### 执行脚本
```python
browser-harness <<'PY'
try:
    new_tab("https://nonexistent-site.com")
    wait_for_load(timeout=10)
except TimeoutError:
    print(json.dumps({
        "error": {
            "code": "PAGE_LOAD_TIMEOUT",
            "message": "页面加载超时",
            "details": {
                "site": "nonexistent-site.com",
                "suggestion": "请检查网站URL是否正确"
            }
        }
    }))
except Exception as e:
    print(json.dumps({
        "error": {
            "code": "UNKNOWN_ERROR",
            "message": str(e),
            "details": {
                "site": "nonexistent-site.com"
            }
        }
    }))
PY
```

### 预期输出
```json
{
  "error": {
    "code": "PAGE_LOAD_TIMEOUT",
    "message": "页面加载超时",
    "engine": "browser-harness",
    "details": {
      "site": "nonexistent-site.com",
      "query": "test",
      "suggestion": "请检查网站URL是否正确"
    }
  },
  "metadata": {
    "trigger": "manual",
    "timestamp": "2026-06-24T11:30:00Z",
    "duration": 10.5
  }
}
```

## 总结

这些示例展示了智能搜索路由器在复杂搜索场景下的使用方式：

1. **SPA网站**：处理JavaScript渲染的现代Web应用
2. **需要登录的网站**：处理需要登录态的网站
3. **复杂交互网站**：处理带筛选条件的电商网站
4. **分页搜索**：处理需要翻页获取结果的网站
5. **动态加载网站**：处理无限滚动加载的网站
6. **多步骤搜索**：处理需要多步骤交互的网站
7. **错误处理**：处理各种错误情况

所有示例都展示了Browser Harness的强大功能，能够处理OpenCLI无法处理的复杂场景。

## 更新日期
2026-06-24
