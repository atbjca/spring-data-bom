## ADDED Requirements

### Requirement: BOM 制品 GAV 去特征化

发布制品 `spring-data-bom`（`bom/pom.xml`）的坐标 MUST 从官方 `org.springframework.data:spring-data-bom` 重命名为 NES fork 坐标 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom`，version 保持 `2021.2.18-nes.patch.1-SNAPSHOT`，使 BOM 制品与全家桶 fork 命名空间一致、私服制品坐标不残留官方自产坐标。

#### Scenario: BOM 坐标重命名

- **WHEN** 检查 `bom/pom.xml` 的 `<groupId>` / `<artifactId>` / `<version>`
- **THEN** groupId 为 `cn.bjca.footstone.bpring.data`、artifactId 为 `bjca-footstone-bpring-data-bom`、version 为 `2021.2.18-nes.patch.1-SNAPSHOT`

#### Scenario: 下游 import 坐标切换

- **WHEN** 下游以 `import` 作用域引用本 BOM
- **THEN** 使用 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom` 坐标即可托管全家桶版本
- **AND** Java 包名 `org.springframework.data.*` 无需修改

### Requirement: managed 依赖反映下游 fork

BOM 的 `<dependencyManagement>` 中，已完成下游 fork 的模块坐标 MUST 反映其真实 fork 坐标；尚未 fork 的模块 MUST 保持官方坐标。当前范围为 commons 与 keyvalue 两个模块。

#### Scenario: commons / keyvalue 切 fork 坐标

- **WHEN** 检查 `<dependencyManagement>` 中的 commons、keyvalue 条目
- **THEN** commons 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:2.7.18-nes.patch.1-SNAPSHOT`
- **AND** keyvalue 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue:2.7.18-nes.patch.1-SNAPSHOT`

#### Scenario: 未 fork 模块保持官方坐标

- **WHEN** 检查其余 13 个模块（cassandra / couchbase / elasticsearch / geode / jdbc / relational / jpa / mongodb / neo4j / r2dbc / redis / rest / envers / ldap）条目
- **THEN** 其 groupId 仍为 `org.springframework.data`、artifactId 仍为官方 `spring-data-*`
- **AND** BOM 不引用任何尚不存在的 fork 制品

#### Scenario: 清理失效 exclusions

- **WHEN** commons / keyvalue 坐标已切为 fork
- **THEN** 这两条 managed 依赖上排除官方 `org.springframework:spring-*` 的 `<exclusions>` 被删除
- **AND** 不残留无法匹配任何依赖的死配置

### Requirement: pom 版本一致性

三个 pom 的版本引用 MUST 相互一致且可解析：根 parent 定版 `2021.2.18`，bom-client 的 `<parent>` 引用 MUST 与 BOM 本体的实际坐标与版本对齐。

#### Scenario: 根 parent 定版

- **WHEN** 检查根 `pom.xml`
- **THEN** version 为 `2021.2.18`
- **AND** groupId/artifactId 保持官方（reactor 聚合根，不发布）

#### Scenario: bom-client parent 引用对齐

- **WHEN** 激活 `with-bom-client` profile 并检查 `bom-client/pom.xml` 的 `<parent>`
- **THEN** `<parent>` 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2021.2.18-nes.patch.1-SNAPSHOT`
- **AND** `mvn -Pwith-bom-client validate` 能成功解析 parent
