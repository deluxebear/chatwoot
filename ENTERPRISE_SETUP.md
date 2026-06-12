# Chatwoot 企业版模拟功能启用指南

## 概述

本文档介绍如何在 Chatwoot 开发环境中启用企业版功能，包括审计日志、SLA、自定义角色等高级功能。

## 前提条件

- Chatwoot 项目已正确安装和配置
- 开发服务器正在运行（`make run` 或 `overmind start -f Procfile.dev`）
- 已创建至少一个账户

## 企业版功能列表

### 核心企业功能
- `disable_branding` - 移除品牌标识
- `audit_logs` - 审计日志跟踪
- `sla` - 服务等级协议管理
- `captain_integration` - Captain AI 集成
- `custom_roles` - 自定义用户角色

### 启动版功能
- `inbound_emails` - 入站邮件处理
- `help_center` - 帮助中心
- `campaigns` - 营销活动
- `team_management` - 团队管理
- `channel_twitter` - Twitter 集成
- `channel_facebook` - Facebook 集成
- `channel_email` - 邮件渠道
- `channel_instagram` - Instagram 集成

## 启用步骤

### 步骤 1: 启用账户企业功能

有三种方法可以启用账户级别的企业功能：

#### 方法一：使用 Rake 任务（推荐）

```bash
# 启用企业功能（使用第一个账户）
bundle exec rake mock:enterprise:enable

# 启用特定账户的企业功能
bundle exec rake mock:enterprise:enable[账户ID]

# 查看当前状态
bundle exec rake mock:enterprise:status

# 禁用企业功能
bundle exec rake mock:enterprise:disable
```

#### 方法二：直接运行 Ruby 脚本

```bash
# 启用企业功能
ruby mock_enterprise_features.rb enable

# 启用特定账户的企业功能
ruby mock_enterprise_features.rb enable 账户ID

# 查看状态
ruby mock_enterprise_features.rb status

# 禁用企业功能
ruby mock_enterprise_features.rb disable
```

#### 方法三：运行测试脚本

```bash
# 直接运行测试脚本（会自动启用所有企业功能）
ruby test_enterprise_mock.rb
```

### 步骤 2: 更新系统配置

仅启用账户功能还不够，还需要将系统配置从 "community" 更改为 "enterprise"：

#### 方法一：使用开发工具（推荐）

```bash
bundle exec rails chatwoot:dev:toggle_variant
```

然后选择选项 2（Enterprise）。

#### 方法二：手动更新数据库配置

创建临时脚本：

```ruby
#!/usr/bin/env ruby
require_relative 'config/environment'

# 更新安装配置为企业版
config = InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN')
if config
  config.update!(value: 'enterprise')
  puts "✅ 已更新 INSTALLATION_PRICING_PLAN 为: enterprise"
else
  InstallationConfig.create!(name: 'INSTALLATION_PRICING_PLAN', value: 'enterprise')
  puts "✅ 已创建 INSTALLATION_PRICING_PLAN: enterprise"
end

puts "🎉 配置已更新！请重启应用程序。"
```

保存为 `set_enterprise.rb` 并运行：

```bash
ruby set_enterprise.rb
```

### 步骤 3: 重启应用程序

配置更改后，必须重启应用程序以使更改生效：

1. 在运行 `make run` 的终端中按 `Ctrl+C` 停止服务
2. 重新运行 `make run` 启动服务

### 步骤 4: 验证启用状态

#### 后端验证

```bash
# 检查账户企业功能状态
bundle exec rake mock:enterprise:status
```

应该显示类似输出：
```
📊 Feature Status for Account: Acme Inc (ID: 1)
Plan: Enterprise
Enterprise Features:
  disable_branding: ✅ Enabled
  audit_logs: ✅ Enabled
  sla: ✅ Enabled
  captain_integration: ✅ Enabled
  custom_roles: ✅ Enabled
```

#### 前端验证

1. 打开浏览器并访问 Chatwoot 管理界面
2. 导航到 **Settings** 页面
3. 确认显示企业版计划而不是 "community edition plan"
4. 检查侧边栏是否出现以下企业功能：
   - **Audit Logs** (审计日志)
   - **SLA** (服务等级协议)
   - **Custom Roles** (自定义角色)

#### 浏览器开发者工具验证

在浏览器控制台中运行：

```javascript
// 检查当前配置
console.log('isEnterprise:', window.chatwootConfig.isEnterprise);
console.log('enterprisePlanName:', window.chatwootConfig.enterprisePlanName);

// 检查账户功能
console.log('Current account:', this.$store.getters.getCurrentAccount);
console.log('Features:', this.$store.getters.getCurrentAccount?.features);
```

预期输出：
- `isEnterprise: "true"`
- `enterprisePlanName: "enterprise"`

## 常见问题排查

### 问题 1: 界面仍显示 "community edition plan"

**原因**：系统配置未更新为企业版

**解决方案**：
1. 执行步骤 2 更新系统配置
2. 重启应用程序
3. 硬刷新浏览器（`Ctrl+F5` 或 `Cmd+Shift+R`）

### 问题 2: 企业功能菜单不显示

**原因**：账户级别的企业功能未启用

**解决方案**：
1. 运行 `bundle exec rake mock:enterprise:status` 检查状态
2. 如果功能未启用，运行 `bundle exec rake mock:enterprise:enable`
3. 重启应用程序

### 问题 3: 功能已启用但仍不可用

**原因**：浏览器缓存或会话问题

**解决方案**：
1. 清除浏览器缓存
2. 硬刷新页面（`Ctrl+F5` 或 `Cmd+Shift+R`）
3. 重新登录账户

## 配置原理

### 双层配置系统

Chatwoot 使用双层配置系统来控制企业功能：

1. **系统级配置**：`InstallationConfig` 表中的 `INSTALLATION_PRICING_PLAN`
   - 控制整个安装的版本类型（community/enterprise）
   - 影响前端 `window.chatwootConfig.enterprisePlanName`

2. **账户级配置**：Account 模型的 `enabled_features` 和 `custom_attributes`
   - 控制特定账户的功能启用状态
   - 存储订阅计划信息

### 功能检查流程

前端检查企业功能的流程：

1. 检查 `window.chatwootConfig.isEnterprise` 是否为 `"true"`
2. 检查 `window.chatwootConfig.enterprisePlanName` 是否为 `"enterprise"`
3. 检查账户的 `enabled_features` 中是否包含特定功能
4. 根据以上条件决定是否显示和启用功能

## 文件结构

相关文件位置：

```
project/
├── lib/tasks/mock_enterprise.rake          # Rake 任务
├── mock_enterprise_features.rb             # 企业功能启用脚本
├── test_enterprise_mock.rb                 # 测试脚本
├── app/models/installation_config.rb       # 系统配置模型
├── lib/global_config.rb                    # 全局配置管理
├── config/installation_config.yml          # 默认配置值
└── lib/tasks/dev/variant_toggle.rake       # 开发环境变体切换
```

## 重要提醒

1. **开发环境专用**：此配置仅适用于开发和测试环境
2. **生产环境**：生产环境的企业功能需要有效的许可证或订阅
3. **数据持久性**：企业功能配置会保存在数据库中，重启后仍然有效
4. **安全性**：不要在生产环境中使用这些模拟脚本

## 完整启用命令

```bash
# 一键启用企业版功能
bundle exec rake mock:enterprise:enable && \
bundle exec rails chatwoot:dev:toggle_variant
# 选择选项 2 (Enterprise)

# 然后重启服务
# Ctrl+C 停止当前服务
make run
```

启用成功后，你将拥有完整的 Chatwoot 企业版功能用于开发和测试。