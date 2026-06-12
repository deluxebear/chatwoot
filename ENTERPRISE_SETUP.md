# Chatwoot 企业版模拟功能启用指南

## 概述

本文档介绍如何在 Chatwoot 开发环境中启用企业版功能（审计日志、SLA、自定义角色、Captain AI、SAML 等）。

**仅限开发/测试环境使用，生产环境的企业功能需要有效的许可证或订阅。**

## 前提条件

- Chatwoot 项目已正确安装和配置
- 已创建至少一个账户（没有的话先跑 `bundle exec rails db:seed`）

## 功能清单来自哪里（动态获取，无需维护）

`lib/tasks/mock_enterprise.rake` 不再硬编码功能列表，而是在运行时从上游的两个权威数据源取并集：

1. `config/features.yml` 中标记 `premium: true` 的所有功能（当前 18 个，含 `disable_branding`、`audit_logs`、`sla`、`custom_roles`、`captain_integration`、`captain_integration_v2`、`channel_voice`、`saml`、`advanced_search`、`companies`、`custom_tools`、`advanced_assignment` 等）
2. `Enterprise::Billing::ReconcilePlanFeaturesService` 中的套餐分层常量（Hacker → Startups → Business → Enterprise，含 `help_center`、`campaigns`、`channel_tiktok`、`linear_integration` 等）

因此每次同步上游后，新增的企业功能会自动被纳入，无需修改脚本。

## 使用方法（一条命令）

```bash
# 启用企业功能（使用第一个账户）；同时会把 INSTALLATION_PRICING_PLAN 设为 enterprise
bundle exec rake mock:enterprise:enable

# 启用特定账户
bundle exec rake "mock:enterprise:enable[账户ID]"

# 查看状态（安装级 plan + 账户级功能逐项列出）
bundle exec rake mock:enterprise:status

# 禁用（账户回退到默认 Hacker 套餐；安装级 plan 不动）
bundle exec rake mock:enterprise:disable

# 给所有账户启用（有确认提示）
bundle exec rake mock:enterprise:enable_all
```

`enable` 任务一次完成三件事：

1. 账户套餐属性：`plan_name=Enterprise`、100 坐席、订阅有效期 1 年
2. Captain AI 配额：`limits.captain_responses/captain_documents = 100000`（避免开发时撞用量上限）
3. 安装级配置：`INSTALLATION_PRICING_PLAN=enterprise` 并清除 GlobalConfig 缓存

启用后硬刷新浏览器（`Cmd+Shift+R`）即可看到企业功能菜单（Audit Logs、SLA、Custom Roles 等）。

## 配置原理

### 双层配置系统

1. **安装级**：`InstallationConfig` 的 `INSTALLATION_PRICING_PLAN`（community/enterprise）
   - ⚠️ 这一层必须是 `enterprise`：定时任务 `Enterprise::Internal::CheckNewVersionsJob` 会调用 `Internal::ReconcilePlanConfigService`，在 community 计划下**定期强制关闭所有账户的 premium 功能**（清单见 `enterprise/config/premium_features.yml`）并重置品牌配置
   - 也可用交互式工具切换：`bundle exec rails chatwoot:dev:toggle_variant`
2. **账户级**：`Account#enabled_features`（feature flags 位存储）+ `custom_attributes`（套餐信息）+ `limits`（Captain 配额）

### 套餐层级（云端逻辑参考）

`Enterprise::Billing::ReconcilePlanFeaturesService`：Hacker（默认）→ Startups → Business → Enterprise，高层级包含低层级全部功能。

## 常见问题排查

### 界面仍显示 community edition plan / 企业菜单消失

- 运行 `bundle exec rake mock:enterprise:status` 检查两层配置；`Installation plan` 必须是 `enterprise`，否则定时任务会不断关闭功能
- 重新 `rake mock:enterprise:enable` 后硬刷新浏览器（`Cmd+Shift+R`）

### 功能已启用但仍不可用

- 清浏览器缓存、重新登录
- 重启 Rails 服务（部分配置在 boot 时读取）

## 相关文件

```
lib/tasks/mock_enterprise.rake                                        # 本工具（唯一入口）
config/features.yml                                                   # 功能定义（premium 标记）
enterprise/app/services/enterprise/billing/reconcile_plan_features_service.rb  # 套餐分层
enterprise/app/services/internal/reconcile_plan_config_service.rb     # community 计划守护逻辑
enterprise/config/premium_features.yml                                # community 下强制关闭清单
lib/tasks/dev/variant_toggle.rake                                     # 官方变体切换工具
```
