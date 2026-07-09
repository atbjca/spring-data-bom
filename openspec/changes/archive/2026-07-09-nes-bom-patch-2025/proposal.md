## Why

`spring-data-bom` 通过 `<dependencyManagement>` 统一托管 16 个 Spring Data 模块的版本，供下游以 `import` 作用域消费。下游已完成两个模块的 NES fork（3.5 线基线 `3.5.13`）：

- `spring-data-commons` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:3.5.13-nes.patch.1-SNAPSHOT`
- `spring-data-keyvalue` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue:3.5.13-nes.patch.1-SNAPSHOT`

但本 BOM 现有的 commons / keyvalue 条目仍指向**官方坐标**（`org.springframework.data:spring-data-*`），且当前工作分支 `2025.0.x-bjca-patch` 停留在旧基线（`2025.0.10-SNAPSHOT` 时代）。结果：下游 `import` 本 BOM 后拿到的仍是官方制品，fork 在 BOM 这一层断链。

本变更把工作分支基线抬到官方最新正式版 `2025.0.13`，让 BOM 反映下游已完成的 fork，BOM 本体去特征化，并接入内网 Nexus 私服发布，使私服制品坐标干净、下游 `import` 前缀与全家桶一致。

## What Changes

- **基线迁移（git，前置）**：`2025.0.x-bjca-patch` 从 `2025.0.10-SNAPSHOT` 时代的 `1c627ee` 抬到官方正式版 `2025.0.13`（commit `ca0af42`）。该分支是 `origin/2025.0.x` 的严格祖先、无自有改动，迁移为零冲突 fast-forward。
- **BOM 本体去特征化**（`bom/pom.xml`）：
  - groupId `org.springframework.data` → `cn.bjca.footstone.bpring.data`
  - artifactId `spring-data-bom` → `bjca-footstone-bpring-data-bom`
  - version `2025.0.13` → `2025.0.13-nes.patch.1-SNAPSHOT`
- **commons / keyvalue 两条 managed 依赖切 fork 坐标**（`bom/pom.xml` 的 `<dependencyManagement>`）：
  - `org.springframework.data:spring-data-commons:3.5.13` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:3.5.13-nes.patch.1-SNAPSHOT`
  - `org.springframework.data:spring-data-keyvalue:3.5.13` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue:3.5.13-nes.patch.1-SNAPSHOT`
- **根 parent 保持官方正式版**（`pom.xml`）：version 保持 `2025.0.13`（官方已发布、公开 Maven 仓库可解析，**不加** nes 后缀）；groupId/artifactId 保持官方不变（reactor 聚合根，install/deploy 均 skip，不发布）。
- **bom-client parent 引用与依赖对齐**（`bom-client/pom.xml`）：`<parent>` 随 BOM 本体同步为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2025.0.13-nes.patch.1-SNAPSHOT`；commons / keyvalue 两条 `<dependency>` 同步切 fork 坐标（否则 BOM 已改 fork、bom-client 声明官方坐标将因 "missing version" 校验失败）。
- **接入内网 Nexus 发布**（`bom/pom.xml`）：新增 `<distributionManagement>`，`releases`（`${nexusReleaseUrl}`）与 `snapshots`（`${nexusSnapshotUrl}`），URL 由环境 `~/.m2/settings.xml` 的 `bjca` profile 提供，settings 不改。
- **构建快捷命令**（`Makefile`）：新增 `Makefile` 封装 `clean/build/validate/install/deploy/verify-client`，与 commons-3.5 / keyvalue-3.5 交付一致；核心为 `make deploy`（发布 BOM 到私服）。

## Capabilities

### Added Capabilities

- `gav-renaming`：本项目首个 spec，确立「BOM 制品 GAV 去特征化」「managed 依赖反映下游 fork」「三 pom 版本一致性」三项能力。
- `nexus-config`：确立「Nexus 私服发布配置」能力，复用环境已激活的 `bjca` profile。
- `build-documentation`：确立「构建快捷命令（Makefile）」能力，与全家桶其余 fork 仓库交付形态一致。

## Impact

- **构建配置**：`bom/pom.xml`（GAV + 2 条 managed 依赖坐标 + distributionManagement）、`pom.xml`（根 parent version）、`bom-client/pom.xml`（`<parent>` 坐标与版本）。
- **依赖解析前提**：内网 Nexus 必须可解析 `bjca-footstone-bpring-data-commons` 与 `bjca-footstone-bpring-data-keyvalue` 的 `3.5.13-nes.patch.1-SNAPSHOT`（下游 fork 已发布）。
- **下游影响**：`import` 本 BOM 的坐标由 `org.springframework.data:spring-data-bom` 变为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom`——下游需同步 `import` 坐标。commons / keyvalue 的消费坐标随之切到 fork。Java 包名 `org.springframework.data.*` 不变。
- **未 fork 的 14 个模块**（cassandra / couchbase / elasticsearch / jdbc / r2dbc / relational / jpa / envers / mongodb / neo4j / redis / rest-webmvc / rest-core / rest-hal-explorer / ldap）保持官方坐标，本变更不动。
- **与 bom-2.7 的差异**：3.5 线的 commons / keyvalue 条目**原本就无 `<exclusions>`**，故本变更不含「清理失效 exclusions」步骤（bom-2.7 有）。
- **风险点**：
  - BOM 为纯 pom、零字节码，去特征化对 SCA 无直接技术收益；本变更的价值在坐标一致性与私服制品整洁，非漏洞修复。
  - 下游若同时 `import` 本 BOM 又单独声明官方 commons/keyvalue 坐标，会出现官方与 fork 并存——需在下游对齐（本变更范围外）。
