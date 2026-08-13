## Why

`spring-data-elasticsearch-2.7` 已进入 `4.4.18-nes.patch.2-SNAPSHOT` 开发线并迁移 NES Elasticsearch 客户端闭包，而当前 BOM 仍固定到已发布的 `4.4.18-nes.patch.1`。为了在 RELEASE 前完成跨仓联调，同时不覆盖已发布的 BOM `2021.2.18-nes.patch.1`，需要提前建立新的 BOM SNAPSHOT 开发线。

## What Changes

- 将 BOM 制品版本从已发布的 `2021.2.18-nes.patch.1` 递增为 `2021.2.18-nes.patch.2-SNAPSHOT`。
- 将 managed Elasticsearch 从 `4.4.18-nes.patch.1` 更新为 `4.4.18-nes.patch.2-SNAPSHOT`，其 NES groupId/artifactId 保持不变。
- 将 `bom-client` parent 对齐到新的 BOM SNAPSHOT，并继续以无显式版本的 NES Elasticsearch 依赖验证 dependency management。
- 保持根聚合项目版本 `2021.2.18` 不变；根项目不是发布制品，其版本不参与本次补丁演进。
- 更新开发态文档，明确当前 BOM 与 Elasticsearch 均为 SNAPSHOT、依赖解析前提以及官方/NES 同包名客户端和 JSON-P provider 不得混用。
- 增加本地 effective POM 和消费者解析验证，并检查 BOM 确实选择 Elasticsearch `patch.2-SNAPSHOT`。
- 在 Elasticsearch 及其他内部依赖仍为 SNAPSHOT 时明确阻断 BOM RELEASE、Nexus RELEASE deploy 和 release tag；正式发布必须另开 release change，将全部内部依赖收敛为已批准 RELEASE。

## Capabilities

### New Capabilities

- `snapshot-alignment`: 定义 BOM 在下游组件 RELEASE 前采用 SNAPSHOT 进行跨仓联调的版本、验证和发布边界。

### Modified Capabilities

- `gav-renaming`: 将当前 BOM 和 managed Elasticsearch 的开发版本推进到各自 `patch.2-SNAPSHOT`，并同步 `bom-client` parent。
- `component-release`: 明确含内部 SNAPSHOT 的 BOM 只能用于开发验证，不得进入 RELEASE 部署或打标流程。

## Impact

- 构建配置：`bom/pom.xml`、构建生成且已跟踪的 `bom/.flattened-pom.xml`、`bom-client/pom.xml`；根 `pom.xml` 不变。
- 文档：`README.adoc` 从已发布 `patch.1` 说明切换为当前 `patch.2-SNAPSHOT` 开发态说明，并保留上一 RELEASE 信息。
- 依赖解析：本地仓库或内网 Nexus 必须可解析 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:4.4.18-nes.patch.2-SNAPSHOT`。
- 下游联调：导入本 BOM SNAPSHOT 的消费者将获得 Elasticsearch `patch.2-SNAPSHOT` 及其 NES 客户端、Barsson 和日志传递闭包；显式锁定官方 Elasticsearch 客户端或 Parsson 的消费者需要清理冲突声明。
- 发布：本变更不执行 Nexus deploy、不创建 RELEASE 或 release tag，也不修改 Elasticsearch 兄弟仓库。
