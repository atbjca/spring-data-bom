## Why

`spring-data-bom` 通过 `<dependencyManagement>` 统一托管 15 个 Spring Data 模块的版本，供下游以 `import` 作用域消费。下游已完成两个模块的 NES fork：

- `spring-data-commons` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:2.7.18-nes.patch.1-SNAPSHOT`
- `spring-data-keyvalue` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue:2.7.18-nes.patch.1-SNAPSHOT`

但 BOM 现有的 commons / keyvalue 条目仍指向**官方坐标**（`org.springframework.data:spring-data-*:2.7.18`）。结果：下游 `import` 本 BOM 后拿到的仍是官方制品，fork 完全没有被 BOM 反映——去特征化在 BOM 这一层断链。

此外 BOM 本体处于「半 fork」状态（version 已带 `-nes.patch.1`，但 groupId/artifactId 仍官方），且三个 pom 的版本互不一致（根 parent `2021.2.19-SNAPSHOT`、BOM 本体 `2021.2.18-nes.patch.1-SNAPSHOT`、bom-client 的 `<parent>` 引用 `2021.2.19-SNAPSHOT`，`with-bom-client` profile 激活即解析失败）。

本变更让 BOM 反映下游 fork，并统一全家桶坐标前缀与版本，使私服制品坐标干净、下游 `import` 前缀一致。

## What Changes

- **BOM 本体去特征化**（`bom/pom.xml`）：
  - groupId `org.springframework.data` → `cn.bjca.footstone.bpring.data`
  - artifactId `spring-data-bom` → `bjca-footstone-bpring-data-bom`
  - version 保持 `2021.2.18-nes.patch.1-SNAPSHOT`（已 fork，不变）
- **commons / keyvalue 两条 managed 依赖切 fork 坐标**（`bom/pom.xml` 的 `<dependencyManagement>`）：
  - `org.springframework.data:spring-data-commons:2.7.18` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:2.7.18-nes.patch.1-SNAPSHOT`
  - `org.springframework.data:spring-data-keyvalue:2.7.18` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue:2.7.18-nes.patch.1-SNAPSHOT`
- **清理失效 exclusions**：commons / keyvalue 条目上排除官方 `org.springframework:spring-core/beans/context/tx/...` 的 `<exclusions>` 在坐标改 fork 后不再匹配（fork 模块传递的已是 `cn.bjca.*` 坐标），删除这两组死配置。
- **根 parent 定版**（`pom.xml`）：version `2021.2.19-SNAPSHOT` → `2021.2.18`；groupId/artifactId 保持官方不变（reactor 聚合根，install/deploy 均 skip，不发布，版本纯装饰）。
- **bom-client parent 引用对齐**（`bom-client/pom.xml`）：`<parent>` 随 BOM 本体同步为
  `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2021.2.18-nes.patch.1-SNAPSHOT`。

## Capabilities

### Added Capabilities

- `gav-renaming`：本项目首个 spec，确立「BOM 制品 GAV 去特征化」与「managed 依赖反映下游 fork」两项能力。

## Impact

- **构建配置**：`bom/pom.xml`（GAV + 2 条 managed 依赖坐标 + 清理 2 组 exclusions）、`pom.xml`（根 parent version）、`bom-client/pom.xml`（`<parent>` 坐标与版本）。
- **依赖解析前提**：内网 Nexus 必须可解析 `bjca-footstone-bpring-data-commons` 与 `bjca-footstone-bpring-data-keyvalue` 的 `2.7.18-nes.patch.1-SNAPSHOT`（下游 fork 已发布）。
- **下游影响**：`import` 本 BOM 的坐标由 `org.springframework.data:spring-data-bom` 变为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom`——下游需同步 `import` 坐标。commons / keyvalue 的消费坐标随之切到 fork。Java 包名 `org.springframework.data.*` 不变。
- **未 fork 的 13 个模块**（cassandra / couchbase / elasticsearch / geode / jdbc / relational / jpa / mongodb / neo4j / r2dbc / redis / rest / envers / ldap）保持官方坐标，本变更不动。
- **风险点**：
  - BOM 为纯 pom、零字节码，去特征化对 SCA 无直接技术收益；本变更的价值在坐标一致性与私服制品整洁，非漏洞修复。
  - 下游若同时 `import` 本 BOM 又单独声明官方 commons/keyvalue 坐标，会出现官方与 fork 并存——需在下游对齐（本变更范围外）。
