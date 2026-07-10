## MODIFIED Requirements

### Requirement: managed 依赖反映下游 fork

BOM 的 `<dependencyManagement>` 中，已完成下游 fork 的模块坐标 MUST 反映其真实 fork 坐标；尚未 fork 的模块 MUST 保持官方坐标。当前已 fork 范围为 commons、keyvalue、redis、elasticsearch 四个模块。

#### Scenario: commons / keyvalue 切 fork 坐标

- **WHEN** 检查 `<dependencyManagement>` 中的 commons、keyvalue 条目
- **THEN** commons 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:2.7.18-nes.patch.1-SNAPSHOT`
- **AND** keyvalue 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue:2.7.18-nes.patch.1-SNAPSHOT`

#### Scenario: redis / elasticsearch 切 fork 坐标

- **WHEN** 检查 `<dependencyManagement>` 中的 redis、elasticsearch 条目
- **THEN** redis 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis:2.7.18-nes.patch.1-SNAPSHOT`
- **AND** elasticsearch 为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:4.4.18-nes.patch.1-SNAPSHOT`

#### Scenario: 未 fork 模块保持官方坐标

- **WHEN** 检查其余 11 个模块（cassandra / couchbase / geode / jdbc / relational / jpa / mongodb / neo4j / r2dbc / rest / envers / ldap）条目
- **THEN** 其 groupId 仍为 `org.springframework.data`、artifactId 仍为官方 `spring-data-*`
- **AND** BOM 不引用任何尚不存在的 fork 制品

#### Scenario: 清理失效 exclusions

- **WHEN** commons / keyvalue / redis / elasticsearch 坐标已切为 fork
- **THEN** 这些 managed 依赖上排除官方 `org.springframework:spring-*` 的 `<exclusions>` 被删除
- **AND** 不残留无法匹配任何依赖的死配置
