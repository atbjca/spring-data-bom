## ADDED Requirements

### Requirement: BOM 制品 GAV 去特征化

发布制品 `spring-data-bom`（`bom/pom.xml`）的坐标 MUST 从官方 `org.springframework.data:spring-data-bom` 重命名为 NES fork 坐标 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom`，version 为 `2025.0.13-nes.patch.1-SNAPSHOT`，使 BOM 制品与全家桶 fork 命名空间一致、私服制品坐标不残留官方自产坐标。

#### Scenario: BOM 坐标重命名

- **WHEN** 检查 `bom/pom.xml` 的 `<groupId>` / `<artifactId>` / `<version>`
- **THEN** groupId 为 `cn.bjca.footstone.bpring.data`、artifactId 为 `bjca-footstone-bpring-data-bom`、version 为 `2025.0.13-nes.patch.1-SNAPSHOT`

#### Scenario: 下游 import 坐标切换

- **WHEN** 下游以 `import` 作用域引用本 BOM
- **THEN** 使用 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom` 坐标即可托管全家桶版本
- **AND** Java 包名 `org.springframework.data.*` 无需修改

### Requirement: managed 依赖反映下游 fork

BOM 的 `<dependencyManagement>` 中，已完成下游 fork 的模块坐标 MUST 反映其真实 fork 坐标；尚未 fork 的模块 MUST 保持官方坐标。当前范围为 commons 与 keyvalue 两个模块。

#### Scenario: commons / keyvalue 切 fork 坐标

- **WHEN** 检查 `<dependencyManagement>` 中的 commons、keyvalue 条目
- **THEN** commons 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:3.5.13-nes.patch.1-SNAPSHOT`
- **AND** keyvalue 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue:3.5.13-nes.patch.1-SNAPSHOT`

#### Scenario: 未 fork 模块保持官方坐标

- **WHEN** 检查其余 14 个模块（cassandra / couchbase / elasticsearch / jdbc / r2dbc / relational / jpa / envers / mongodb / neo4j / redis / rest-webmvc / rest-core / rest-hal-explorer / ldap）条目
- **THEN** 其 groupId 仍为 `org.springframework.data`、artifactId 仍为官方 `spring-data-*`
- **AND** BOM 不引用任何尚不存在的 fork 制品

#### Scenario: 无失效 exclusions 需清理

- **WHEN** 检查 commons / keyvalue 两条 managed 依赖
- **THEN** 二者为裸依赖、原本即无 `<exclusions>`（区别于 bom-2.7）
- **AND** 本变更不涉及 exclusions 的增删

### Requirement: pom 版本一致性

三个 pom 的版本引用 MUST 相互一致且可解析：工作分支基线 MUST 抬到官方正式版 `2025.0.13`；根 parent version MUST 保持官方正式版 `2025.0.13`（公开 Maven 仓库可解析，不加 nes 后缀）；BOM 本体 version MUST 为 `2025.0.13-nes.patch.1-SNAPSHOT`；bom-client 的 `<parent>` 引用 MUST 与 BOM 本体的实际坐标与版本对齐。

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

- **WHEN** 检查 `bom-client/pom.xml` 的 commons / keyvalue 两条 `<dependency>`
- **THEN** 其坐标为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons` 与 `-keyvalue`（不写 version，由 BOM 托管）
- **AND** 官方坐标 `org.springframework.data:spring-data-commons/keyvalue` 不再出现，避免 "missing version" 校验失败
- **AND** 其余 14 个模块 bom-client 声明保持官方坐标
