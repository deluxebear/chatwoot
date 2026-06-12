# Chatwoot 系统功能与价值梳理

> 本文档基于 Chatwoot 官方帮助中心（chatwoot.com/help-center）、官方功能页与本代码库（develop 分支，含企业版代码）整理。
> 本项目为 Chatwoot 的二次开发 fork，开发环境已通过 `rake mock:enterprise:enable` 启用全部企业功能（见 `ENTERPRISE_SETUP.md`）。

## 一、系统定位

Chatwoot 是一个**开源、可自托管的全渠道客户支持平台**，对标 Intercom、Zendesk、Freshdesk 等商业产品。核心理念：把分散在网站聊天、邮件、WhatsApp、社交媒体等各个渠道的客户对话，汇聚到一个统一的客服工作台中处理，并用 AI 和自动化降低人工成本。

## 二、核心价值

1. **数据主权**：可完全自托管部署，客户数据、对话记录全部留在自己的基础设施内（这也是本 fork 的部署形态），满足 GDPR 等合规要求；官方云服务通过 SOC 2 Type II 认证。
2. **全渠道统一**：十余种渠道的消息进入同一个收件箱，客服不用在多个后台之间切换；同一客户跨渠道的历史会话自动归并到统一的联系人档案。
3. **开源可定制**：MIT 风格开源（社区版），代码完全可控，可以像本项目一样做二次开发（自定义功能、汉化、品牌替换等）。
4. **AI 原生**：内置 Captain AI 套件，从"机器人先答、人工兜底"到坐席侧 AI 辅助写作，覆盖售前售后全流程。
5. **成本优势**：自托管社区版免费；企业功能按需购买，远低于同类 SaaS 按坐席收费的总成本。

## 三、功能全景

### 1. 全渠道接入（Channels）

| 渠道 | 说明 |
|------|------|
| 网站实时聊天（Live Chat） | 可定制的聊天挂件，支持品牌色、暗黑模式、预聊表单、身份验证（identity validation）、50+ 语言；提供 SDK 传入用户属性，支持 WordPress/React/Vue/Next.js 等各种站点安装方式 |
| 邮件（Email） | IMAP/SMTP 接入支持邮箱，邮件与聊天同框处理，支持品牌化邮件模板、会话经邮件延续 |
| WhatsApp | 官方 Business API（内嵌注册/手动接入/Twilio 三种方式），支持消息模板、WhatsApp CSAT 调查 |
| Facebook Messenger / Instagram DM | 接管主页私信和 IG 私信，支持 Human Agent 标签延长响应窗口 |
| TikTok | TikTok 私信接入（较新渠道） |
| Telegram / LINE | 机器人方式接入 |
| SMS | Twilio 等短信服务商 |
| 语音（Voice） | 电话客服渠道（本分支已含创建流程，基于 Twilio，含 WhatsApp 语音），属最新功能 |
| API 渠道 | 自定义渠道：任何系统都可以通过 API 把消息送进来，构建自有 App 内客服 |
| 共享收件箱 | 团队协作处理同一队列 |

### 2. 会话处理与团队协作

- **分配体系**：手动/自动分配、轮询（round-robin）分配、**高级分配策略**（企业）、**坐席容量上限**（Agent Capacity Policies，防止单个客服过载）
- **团队（Teams）**：按业务线/职能划分内部团队，会话可指派给团队
- **标签（Labels）**：给会话打标签做分类与统计
- **私有备注（Private Notes）**：会话内的内部讨论，客户不可见（Captain 也能读取私有备注辅助理解上下文）
- **优先级（Priority）**：紧急程度标记
- **防撞车（Collision Detection）**：实时显示谁在查看/输入，避免两个客服同时回复
- **会话过滤器与文件夹**：高级条件过滤，保存为自定义文件夹
- **必填会话属性**（企业）：解决会话前强制填写指定字段，保证数据质量
- **全渠道签名**、已读回执、消息排序规则

### 3. Captain AI 套件（企业功能，本环境已启用）

- **AI Assistant（机器人坐席）**：基于你的帮助中心文章、历史会话和 FAQ 训练，自动接待并回答常见问题，搞不定时转人工
- **Copilot（坐席副驾）**：帮客服起草、润色、翻译回复；用自然语言检索客户历史和知识库
- **Smart FAQs**：自动识别"高频但知识库没覆盖"的问题，建议新建文章
- **Memories（记忆）**：自动总结客户关键信息，跨会话保持上下文，实现个性化服务
- **文档训练**：抓取网站/上传文档作为知识源（含**文档自动同步**，企业）
- **Custom Tools（自定义工具）**（企业）：让 AI 助手调用你自己的 API 完成查订单、查物流等动作
- 多语言自然翻译；自托管版可接入自有 OpenAI 兼容模型

### 4. 自动化与效率工具

- **Automation**：基于"事件 + 条件 → 动作"的自动化规则（自动打标、自动分配、自动回复等）
- **Macros（宏）**：一键执行一串动作（如：回复模板 + 打标 + 标记已解决）
- **Canned Responses（快捷回复）**：`/` 唤出的预存回复模板
- **营业时间与自动回复**：非工作时间自动应答
- **SLA 管理**（企业）：定义首响/解决时限，超时升级提醒，配套 SLA 报表
- **聊天机器人集成**：Dialogflow、Rasa，或通过 Agent Bot API 自建
- **命令面板 + 键盘快捷键**：全键盘操作工作台
- **批量操作**：多会话一键处理

### 5. 客户数据与轻量 CRM

- **联系人档案**：跨渠道统一客户视图 + 完整互动时间线
- **自定义属性**：给联系人/会话加任意业务字段
- **客户分群（Segments)**：按条件分组，配合营销触达
- **预聊表单**：聊天前收集姓名/邮箱等信息
- **CSV 批量导入**、Contacts API 与外部系统双向同步
- **Companies（公司维度）**（企业）：B2B 场景下按公司组织联系人

### 6. 帮助中心与自助服务（Help Center / Portal）

- 多语言知识库门户，支持自定义域名 + SSL
- 文章可嵌入聊天挂件内（widget 内自助查阅）
- 语义搜索（**Embedding Search**，企业）提升检索质量
- 同时是 Captain AI 的核心知识源——写好帮助文档 = 训练好 AI

### 7. 主动触达（Campaigns）

- **网站定向消息**：按 URL（支持通配符）、停留时长等条件主动弹出消息，促转化
- **一次性群发**：对短信等渠道按分群批量推送

### 8. 报表与分析

- **实时 Live View**：当前排队/服务中会话、在线坐席总览
- 会话量、首响/解决时长等核心指标报表
- 坐席/团队/收件箱/标签四个维度的绩效分析
- **CSAT 满意度报表**（含**评价备注复核**，企业）、机器人报表、**SLA 达标报表**（企业）
- 报表可导出 CSV

### 9. 集成与开放平台

- **Slack**：在 Slack 里直接回复客户会话
- **Webhooks**：全事件实时回调，对接任意系统
- **REST API**：平台级/账户级/客户端三套完整 API（本仓库 swagger/ 下有完整定义）
- **Dashboard Apps**：把内部系统（订单后台等）嵌入客服工作台侧边栏
- **Linear**：从会话直接创建产品 issue（startup 层级功能）
- **Google Translate** 消息翻译、**Dyte** 视频通话、OpenAI 集成
- iOS / Android 官方移动端 App

### 10. 安全、合规与企业级管理

- **审计日志（Audit Logs）**（企业）：账户内全操作留痕
- **自定义角色（Custom Roles）**（企业）：超出默认 Agent/Administrator 的细粒度权限
- **SAML 单点登录**（企业）：对接企业 IdP
- **去品牌化（Disable Branding）**（企业）：移除 "Powered by Chatwoot"，配合安装级品牌配置实现完整白标
- 数据传输/存储加密、双因素认证、API Token 管理

## 四、版本与功能分层

代码库分 OSS（`app/`）与企业覆盖层（`enterprise/`）两棵树。套餐层级（高层包含低层全部功能）：

| 层级 | 代表功能 |
|------|---------|
| **Community（免费自托管）** | 全渠道收件箱（除 Voice 等）、自动化、宏、帮助中心基础、报表、API、Slack/Webhook 集成 |
| **Startups** | 邮件入站、帮助中心、营销活动、团队管理、FB/IG/Email/TikTok 渠道、Captain 基础、高级搜索、Linear、语音渠道 |
| **Business** | SLA、自定义角色、CSAT 复核备注、必填会话属性、高级分配、Custom Tools、Companies |
| **Enterprise** | 审计日志、去品牌化、SAML |

> 本 fork 的开发环境通过 `bundle exec rake mock:enterprise:enable` 已启用全部 27 个高级功能（动态清单跟随上游），验证方式见 `ENTERPRISE_SETUP.md`。

## 五、本 Fork 的定制现状

- **企业功能模拟工具**：`lib/tasks/mock_enterprise.rake`（开发/测试环境一键启用企业功能）
- **与上游同步机制**：定期合并 `upstream/develop`，冲突处理原则见 `AGENTS.md`
- **规划中**：中文翻译补全（overlay 覆盖层架构）、超管后台汉化（administrate 自带 zh-CN 激活方案）

## 六、参考资源

- 官方帮助中心：https://www.chatwoot.com/help-center
- 用户指南（全文目录）：https://chatwoot.help/hc/user-guide/en
- Captain AI：https://www.chatwoot.com/captain
- 功能总览：https://www.chatwoot.com/features
- 开发者文档 / API：https://developers.chatwoot.com
