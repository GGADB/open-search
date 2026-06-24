# OpenCLI执行器规范

## 概述

OpenCLI执行器负责调用OpenCLI命令、解析JSON输出、处理错误情况。本文档定义了执行器的规范和实现细节。

## 核心功能

### 1. 命令调用
```bash
# 标准搜索命令
opencli <site> search "<query>" --limit <limit> -f json

# 示例
opencli bilibili search "机器学习" --limit 20 -f json
opencli google search "AI agent" --limit 10 -f json
opencli reddit search "browser automation" --limit 10 -f json
```

### 2. 参数支持
- **query**：搜索词（必需）
- **limit**：结果数量限制（默认20）
- **format**：输出格式（json、csv、md、table）
- **sort**：排序方式（可选）

### 3. 输出解析
OpenCLI返回标准JSON格式：
```json
{
  "source": "opencli",
  "query": "机器学习",
  "site": "bilibili",
  "results": [...],
  "metadata": {
    "total": 20,
    "engine": "opencli",
    "trigger": "manual",
    "timestamp": "2026-06-24T10:30:00Z",
    "duration": 1.2
  }
}
```

## 错误处理

### 错误类型
1. **适配器不存在** (ADAPTER_NOT_FOUND)
   - 退出码：1
   - 处理：回退到Browser Harness

2. **网络错误** (NETWORK_ERROR)
   - 退出码：非0
   - 处理：重试或回退

3. **频率限制** (RATE_LIMITED)
   - 退出码：75
   - 处理：等待后重试

4. **需要登录** (AUTH_REQUIRED)
   - 退出码：77
   - 处理：回退到Browser Harness

### 错误处理脚本
```bash
# 执行OpenCLI命令
opencli bilibili search "机器学习" -f json > result.json 2> error.json
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  # 读取错误信息
  ERROR_CODE=$(cat error.json | jq -r '.error.code')
  ERROR_MESSAGE=$(cat error.json | jq -r '.error.message')

  # 根据错误类型处理
  case $ERROR_CODE in
    "ADAPTER_NOT_FOUND")
      echo "适配器不存在，回退到Browser Harness"
      # 执行Browser Harness逻辑
      ;;
    "NETWORK_ERROR")
      echo "网络错误，重试..."
      # 重试逻辑
      ;;
    "RATE_LIMITED")
      echo "频率限制，等待..."
      sleep 60
      # 重试逻辑
      ;;
    "AUTH_REQUIRED")
      echo "需要登录，回退到Browser Harness"
      # 执行Browser Harness逻辑
      ;;
    *)
      echo "未知错误: $ERROR_MESSAGE"
      ;;
  esac
fi
```

## 支持的网站

### Top 20网站
1. bilibili - 视频搜索
2. google - 搜索引擎
3. reddit - 社区讨论
4. twitter - 社交媒体
5. zhihu - 知识问答
6. xiaohongshu - 生活分享
7. github - 代码仓库
8. linkedin - 职业社交
9. hackernews - 技术新闻
10. amazon - 电商购物
11. youtube - 视频平台
12. douban - 影评书评
13. weibo - 社交媒体
14. juejin - 技术社区
15. csdn - 技术博客
16. stackoverflow - 技术问答
17. medium - 写作平台
18. producthunt - 产品发现
19. devto - 开发者社区
20. hashnode - 技术博客

### 检查适配器
```bash
# 检查适配器是否存在
opencli <site> -h

# 检查搜索命令
opencli <site> search -h

# 列出所有适配器
opencli list -f yaml
```

## 性能优化

### 1. 缓存适配器列表
```bash
# 缓存适配器列表到文件
opencli list -f yaml > ~/.opencli/cache/adapters.yaml

# 使用缓存
if [ -f ~/.opencli/cache/adapters.yaml ]; then
  # 使用缓存
else
  # 重新获取
fi
```

### 2. 并发请求
```bash
# 并发执行多个搜索
opencli bilibili search "query1" -f json &
opencli google search "query2" -f json &
wait
```

### 3. 超时控制
```bash
# 设置超时
timeout 30 opencli bilibili search "query" -f json

# 检查超时
if [ $? -eq 124 ]; then
  echo "请求超时"
fi
```

## 集成示例

### 示例1：标准搜索
```bash
# 搜索bilibili
opencli bilibili search "机器学习" --limit 10 -f json

# 解析结果
cat result.json | jq '.results[] | {title, url, snippet}'
```

### 示例2：错误处理
```bash
# 带错误处理的搜索
search_with_opencli() {
  local site=$1
  local query=$2
  local limit=${3:-20}

  opencli "$site" search "$query" --limit "$limit" -f json > result.json 2> error.json
  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    ERROR_CODE=$(cat error.json | jq -r '.error.code')
    echo "错误: $ERROR_CODE"
    return 1
  fi

  cat result.json
  return 0
}
```

### 示例3：批量搜索
```bash
# 批量搜索多个网站
sites=("bilibili" "google" "reddit")
query="机器学习"

for site in "${sites[@]}"; do
  echo "搜索 $site..."
  opencli "$site" search "$query" --limit 5 -f json > "result_$site.json"
done
```

## 测试用例

### 测试1：标准搜索
```bash
# 测试bilibili搜索
opencli bilibili search "机器学习" --limit 5 -f json

# 验证输出格式
cat result.json | jq '.source'
# 预期输出："opencli"
```

### 测试2：错误处理
```bash
# 测试不存在的适配器
opencli nonexistent search "test" -f json 2> error.json

# 验证错误信息
cat error.json | jq '.error.code'
# 预期输出："ADAPTER_NOT_FOUND"
```

### 测试3：参数传递
```bash
# 测试limit参数
opencli bilibili search "test" --limit 5 -f json | jq '.results | length'
# 预期输出：≤5

# 测试format参数
opencli bilibili search "test" -f csv | head -5
# 预期输出：CSV格式
```

## 最佳实践

### 1. 优先使用JSON格式
- 便于解析和处理
- 支持结构化数据
- 错误信息完整

### 2. 处理所有错误类型
- 适配器不存在
- 网络错误
- 频率限制
- 需要登录

### 3. 使用适当的limit值
- 避免请求过多结果
- 考虑性能和响应时间
- 根据需求调整

### 4. 记录搜索日志
- 记录搜索词
- 记录使用的网站
- 记录成功/失败状态
- 记录响应时间

## 更新日期
2026-06-24
