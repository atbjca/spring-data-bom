# Design — nes-bom-patch-2025

## 1. 背景与定位

`spring-data-bom` 是 Spring Data 全家桶的版本清单（纯 pom、零字节码），下游以 `import` 作用域统一托管 16 个模块版本。下游已 fork commons / keyvalue 两个模块（3.5 线，基线正式版 `3.5.13`），但本 BOM 仍指向官方坐标，导致 fork 在 BOM 这层断链。本变更让 BOM 反映已完成的下游 fork，BOM 本体去特征化，并接入内网 Nexus 私服发布。

本项目结构上有三个 pom，**彼此无 Maven 继承关系**（bom-client 通过 `<parent>` 引用 BOM 本体，是唯一的引用关系），需分别理解：

| pom | 角色 | 是否发布 | 版本决策 |
|-----|------|---------|---------|
| `pom.xml` | reactor 聚合根 | 否（install/deploy skip） | `2025.0.13-nes.patch.1-SNAPSHOT` |
| `bom/pom.xml` | 唯一发布制品 | 是 | `2025.0.13-nes.patch.1-SNAPSHOT`（GAV 全切 fork） |
| `bom-client/pom.xml` | 冒烟校验，仅 `with-bom-client` profile | 否 | `<parent>` 对齐 BOM 本体 |

## 2. 关键决策

### 2.0 前置：工作分支基线迁移到 2025.0.13

**决策**：先把 `2025.0.x-bjca-patch` 从 `1c627ee`（`2025.0.10-SNAPSHOT` 时代）抬到官方正式版 `2025.0.13`（commit `ca0af42`），再在其上做 fork 改造。

**理由**：commons / keyvalue 的 fork 基线是 `3.5.13`，BOM 若停在旧基线，版本号与下游 fork 对不上。经拓扑核实，`2025.0.x-bjca-patch` 是 `origin/2025.0.x` 的**严格祖先且无任何自有提交**（`origin/2025.0.x..2025.0.x-bjca-patch` 为空），迁移是零冲突 fast-forward，无 rebase 冲突风险。落点选发布点 `ca0af42`（三 pom 均为干净 `2025.0.13`、无 SNAPSHOT），而非 `2025.0.14-SNAPSHOT`，以对齐已发布正式版基线。

### 2.1 改造范围：只切 commons + keyvalue 两条 managed 依赖

**决策**：`<dependencyManagement>` 中仅将 commons、keyvalue 改为 fork 坐标，其余 14 个模块保持官方坐标。

**理由**：BOM 是版本清单，条目应如实反映各模块的真实发布坐标。只有 commons / keyvalue 完成了 fork，其余模块下游未 fork，官方坐标即为其真实坐标。BOM 不应超前引用尚不存在的 fork 制品。

### 2.2 BOM 本体也去特征化（GAV 全切 fork）

**决策**：BOM 制品自身 groupId → `cn.bjca.footstone.bpring.data`、artifactId → `bjca-footstone-bpring-data-bom`、version `2025.0.13` → `2025.0.13-nes.patch.1-SNAPSHOT`。

**理由**：BOM 是纯 pom，SCA 的两条命中路径（GAV 匹配 / 字节码指纹）对它都不适用，去特征化**无直接 SCA 收益**。但基于三点仍切 fork：
- **全家桶坐标一致性**：commons / keyvalue 已在 `cn.bjca.footstone.bpring.data` 命名空间，BOM 作为清单留在官方命名空间会割裂。
- **下游 import 前缀统一**：下游可用同一 groupId 前缀声明 BOM 与各模块。
- **私服制品干净**：内网 Nexus 上不再混入 `org.springframework.data` 官方坐标的自产物。

version 从 `2025.0.13` 补 `-nes.patch.1-SNAPSHOT` 后缀，与 commons / keyvalue 的 `3.5.13-nes.patch.1-SNAPSHOT` 命名规约一致（同为 patch.1 的首个补丁快照）。

### 2.3 无失效 exclusions 需清理（区别于 bom-2.7）

**决策**：不含「清理 commons / keyvalue 上官方 exclusions」步骤。

**理由**：与 bom-2.7 不同，3.5 线 BOM 的 commons / keyvalue 条目**原本就是裸依赖、无 `<exclusions>`**（经 `ca0af42:bom/pom.xml` 第 83、176 行核实）。故 2.7 中的第 2.3/2.4 步在此不适用。其余模块（elasticsearch / jdbc / relational 等）若带 exclusions，因坐标未改 fork，其 exclusions 仍匹配官方传递依赖，保持不动。

### 2.4 根 parent 保持官方正式版 2025.0.13，不去特征化

**决策**：根 `pom.xml` version 保持基线的官方正式版 `2025.0.13`（**不加** `-nes.patch.1-SNAPSHOT` 后缀）；groupId/artifactId 保持官方。

**理由**：根 parent 是 reactor 聚合根，install/deploy 均 skip、不发布，无任何模块 `<parent>` 继承它，版本纯装饰。`2025.0.13` 是官方已发布正式版、在公开 Maven 仓库可解析，保持它即引用一个真实可访问的坐标；若补 `-nes.patch.1-SNAPSHOT`，反而凭空造出一个私服上并不存在的自产 SNAPSHOT 坐标。与 bom-2.7 做法（根 parent 定官方正式版、不带后缀）对齐。迁移到 `ca0af42` 后该 pom 本就是 `2025.0.13`，故本步实为**确认不改**。

### 2.5 bom-client parent 引用与依赖坐标对齐

**决策**：`bom-client/pom.xml` 的 `<parent>` 改为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2025.0.13-nes.patch.1-SNAPSHOT`；同时其 `<dependencies>` 中 commons / keyvalue 两条 `<dependency>` 同步切 fork 坐标（`bjca-footstone-bpring-data-commons` / `-keyvalue`）。

**理由**：`with-bom-client` profile 激活时，bom-client 通过 `<parent>` 引用 BOM 本体。BOM 本体 GAV/version 一变，此引用必须同步，否则 profile 激活即解析失败。此外，bom-client 的依赖声明不写 version、靠 parent（BOM）的 `<dependencyManagement>` 托管；BOM 已把 commons / keyvalue 改为 fork 坐标后，官方坐标 `org.springframework.data:spring-data-commons` 在 managed 中已不存在，bom-client 若仍声明官方坐标将因 "missing version" 在模型校验阶段即失败。故 bom-client 的这两条依赖必须与 BOM 同步切 fork 坐标（与 bom-2.7 一致）。其余 14 个模块 bom-client 声明保持官方坐标不变。

### 2.6 接入内网 Nexus 发布

**决策**：`bom/pom.xml` 新增 `<distributionManagement>`，`releases`→`${nexusReleaseUrl}`、`snapshots`→`${nexusSnapshotUrl}`；不改 `settings.xml`。

**理由**：与 commons-3.5 的 nexus-config 保持一致。环境 `~/.m2/settings.xml` 已激活 `bjca` profile，提供 `nexusReleaseUrl`/`nexusSnapshotUrl`（`http://192.168.131.36:8088/repository/{releases,snapshots}/`）及 server 凭证 `releases`/`snapshots`，BOM 侧只需声明目标仓库、用属性占位以隔离环境。根 pom 与 bom-client 不发布，无需各自的 distributionManagement。

## 3. 验证

- **解析验证**：`./mvnw -N validate` 校验根 reactor；`./mvnw help:effective-pom -pl bom` 确认 BOM 本体 GAV、commons/keyvalue fork 坐标、版本均生效，无残留官方 data 自产坐标。
- **profile 验证**：`./mvnw -Pwith-bom-client validate` 确认 bom-client `<parent>` 可解析。
- **发布验证（可选）**：`./mvnw -pl bom -DskipTests deploy` 将 `2025.0.13-nes.patch.1-SNAPSHOT` 发布到 snapshots 仓库。
- **前提**：内网 Nexus 已发布 commons / keyvalue 的 `3.5.13-nes.patch.1-SNAPSHOT`（下游 fork 产物）。

## 4. 非目标

- 不 fork 其余 14 个模块，不超前引用不存在的 fork 制品。
- 不改根 parent / bom-client 的 groupId/artifactId 之外的结构（`<modules>`、profile 机制、flatten 配置、既有 artifactory/central/release profile 均不动）。
- 不修改任何 Java 源码或对外 API（本项目无字节码）。
- 不改 `settings.xml`（复用环境已激活的 `bjca` profile）。
- 不处理下游「官方与 fork 并存」的对齐（属下游范围）。
- 不含 CVE 文档 / Makefile / 用户手册（BOM 为纯 pom，SCA 无命中路径，参照 bom-2.7 范围）。
