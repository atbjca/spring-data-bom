# snapshot-alignment Specification

## Purpose
TBD - created by archiving change align-elasticsearch-patch-2-snapshot. Update Purpose after archive.
## Requirements
### Requirement: BOM 支持下游组件 SNAPSHOT 前置联调

BOM MUST 能在下游组件 RELEASE 前通过新的 BOM SNAPSHOT 开发线托管已批准的组件 SNAPSHOT，且 MUST 保持上一已发布 BOM 版本不可变。

#### Scenario: Elasticsearch patch.2 前置联调

- **WHEN** Elasticsearch 组件正在以 `4.4.18-nes.patch.2-SNAPSHOT` 实施和验证
- **THEN** BOM 使用 `2021.2.18-nes.patch.2-SNAPSHOT` 托管该 Elasticsearch SNAPSHOT
- **AND** 已发布的 BOM `2021.2.18-nes.patch.1` 及其标签不被修改或覆盖

#### Scenario: 兄弟 SNAPSHOT 尚不可解析

- **WHEN** 本地仓库和配置的只读 Nexus 均不能解析 Elasticsearch `4.4.18-nes.patch.2-SNAPSHOT`
- **THEN** 完整消费者验证 MUST 明确失败或标记为受外部前置条件阻断
- **AND** BOM MUST NOT 静默回退到 Elasticsearch `patch.1` 或官方坐标

### Requirement: SNAPSHOT 联调验证保持依赖所有权边界

BOM MUST 只托管 Spring Data Elasticsearch 顶层制品；NES Elasticsearch 客户端、Barsson 和日志闭包 MUST 由 Spring Data Elasticsearch 的生成 POM 提供。

#### Scenario: BOM managed 依赖边界

- **WHEN** 检查 BOM effective POM
- **THEN** Spring Data Elasticsearch 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:4.4.18-nes.patch.2-SNAPSHOT`
- **AND** BOM 不因本次变更新增 HLRC、REST Client、Java Client、Barsson 或 JCL 的直接 managed 条目

#### Scenario: 独立消费者解析

- **WHEN** 独立消费者导入 BOM SNAPSHOT 并只声明无版本的 NES Spring Data Elasticsearch GA
- **THEN** Maven 选择 `4.4.18-nes.patch.2-SNAPSHOT`
- **AND** 在兄弟制品完整可用时，依赖树不得同时包含官方/NES Elasticsearch 客户端入口或官方 Parsson/NES Barsson provider
