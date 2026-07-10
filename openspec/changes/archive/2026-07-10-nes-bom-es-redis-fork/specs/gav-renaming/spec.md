## MODIFIED Requirements

### Requirement: managed 依赖反映下游 fork

BOM 的 `<dependencyManagement>` 中，已完成下游 fork 的模块坐标 MUST 反映其真实 fork 坐标；尚未 fork 的模块 MUST 保持官方坐标。当前 fork 范围为 commons、keyvalue、elasticsearch、redis 四个模块。各模块 fork 版本号 MUST 与其自身版本线一致——commons / keyvalue / redis 为 data 主线 `3.5.13`，**elasticsearch 为独立版本线 `5.5.13`**。

#### Scenario: commons / keyvalue / elasticsearch / redis 切 fork 坐标

- **WHEN** 检查 `<dependencyManagement>` 中的 commons、keyvalue、elasticsearch、redis 条目
- **THEN** commons 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:3.5.13-nes.patch.1-SNAPSHOT`
- **AND** keyvalue 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue:3.5.13-nes.patch.1-SNAPSHOT`
- **AND** elasticsearch 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:5.5.13-nes.patch.1-SNAPSHOT`（版本号 `5.5.13`，非 `3.5.13`）
- **AND** redis 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis:3.5.13-nes.patch.1-SNAPSHOT`

#### Scenario: 未 fork 模块保持官方坐标

- **WHEN** 检查其余 12 个模块（cassandra / couchbase / jdbc / r2dbc / relational / jpa / envers / mongodb / neo4j / rest-webmvc / rest-core / rest-hal-explorer / ldap）条目
- **THEN** 其 groupId 仍为 `org.springframework.data`、artifactId 仍为官方 `spring-data-*`
- **AND** BOM 不引用任何尚不存在的 fork 制品

#### Scenario: 无失效 exclusions 需清理

- **WHEN** 检查 commons / keyvalue / elasticsearch / redis 四条 managed 依赖
- **THEN** 四者均为裸依赖、原本即无 `<exclusions>`（区别于 bom-2.7）
- **AND** 本变更不涉及 exclusions 的增删

### Requirement: pom 版本一致性

三个 pom 的版本引用 MUST 相互一致且可解析：工作分支基线 MUST 抬到官方正式版 `2025.0.13`；根 parent version MUST 保持官方正式版 `2025.0.13`（公开 Maven 仓库可解析，不加 nes 后缀）；BOM 本体 version MUST 为 `2025.0.13-nes.patch.1-SNAPSHOT`；bom-client 的 `<parent>` 引用 MUST 与 BOM 本体的实际坐标与版本对齐；bom-client 中已 fork 模块的 `<dependency>` MUST 使用 fork 坐标且不写 version（由 BOM 托管）。

#### Scenario: 工作分支基线迁移

- **WHEN** 检查 `2025.0.x-bjca-patch` 的迁移落点
- **THEN** 基线为官方正式版 `2025.0.13`（commit `ca0af42`）
- **AND** 迁移为 fast-forward（该分支是 `origin/2025.0.x` 的严格祖先、无自有提交）

#### Scenario: 根 parent 版本

- **WHEN** 检查根 `pom.xml`
- **THEN** version 为官方正式版 `2025.0.13`（不加 nes 后缀，公开 Maven 仓库可解析）
- **AND** groupId/artifactId 保持官方（reactor 聚合根，不发布）

#### Scenario: bom-client parent 引用对齐

- **WHEN** 激活 `with-bom-client` profile 并检查 `bom-client/pom.xml` 的 `<parent>`
- **THEN** `<parent>` 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2025.0.13-nes.patch.1-SNAPSHOT`
- **AND** `./mvnw -Pwith-bom-client validate` 能成功解析 parent

#### Scenario: bom-client 依赖坐标同步 fork

- **WHEN** 检查 `bom-client/pom.xml` 的 commons / keyvalue / elasticsearch / redis 四条 `<dependency>`
- **THEN** 其坐标分别为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons` / `-keyvalue` / `-elasticsearch` / `-redis`（不写 version，由 BOM 托管）
- **AND** 官方坐标 `org.springframework.data:spring-data-commons/keyvalue/elasticsearch/redis` 不再出现，避免 "missing version" 校验失败
- **AND** 其余 12 个模块 bom-client 声明保持官方坐标
