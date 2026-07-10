## Why

上一轮 `nes-bom-patch-2025` 已把 BOM 本体去特征化、并将 commons / keyvalue 两条 managed 依赖切到 NES fork 坐标。此后下游又新增完成了两个模块的 fork：

- `spring-data-elasticsearch` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:5.5.13-nes.patch.1-SNAPSHOT`
- `spring-data-redis` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis:3.5.13-nes.patch.1-SNAPSHOT`

但本 BOM 的 elasticsearch / redis 条目（以及 `bom-client` 的对应声明）仍指向**官方坐标**（`org.springframework.data:spring-data-*`）。结果：下游 `import` 本 BOM 后，es / redis 拿到的仍是官方制品，这两个模块的 fork 在 BOM 这一层断链。

本变更把 BOM 纳管的 fork 覆盖面从 2 个模块（commons / keyvalue）扩到 4 个（+ elasticsearch / redis），让 BOM 反映下游已完成的全部 fork。这是上一轮 `gav-renaming` 能力「managed 依赖反映下游 fork」的**直接延续**——同一能力扩大覆盖面，不新增能力。

## What Changes

- **elasticsearch / redis 两条 managed 依赖切 fork 坐标**（`bom/pom.xml` 的 `<dependencyManagement>`）：
  - `org.springframework.data:spring-data-elasticsearch:5.5.13` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:5.5.13-nes.patch.1-SNAPSHOT`
  - `org.springframework.data:spring-data-redis:3.5.13` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis:3.5.13-nes.patch.1-SNAPSHOT`
  - ⚠️ **elasticsearch 属独立版本线 `5.5.x`**（非 data 主线 `3.5.x`），fork 版本号为 `5.5.13-nes.patch.1-SNAPSHOT`，不得写成 `3.5.13`。
- **bom-client 两条 `<dependency>` 同步切 fork 坐标**（`bom-client/pom.xml`）：
  - es / redis 由 `org.springframework.data:spring-data-elasticsearch/redis` 切为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch/redis`（**不写 version**，由 BOM 托管）。
  - 否则 BOM 已改 fork、bom-client 仍声明官方坐标，将因 "missing version" 校验失败（与上一轮 commons / keyvalue 同构）。
- **不做**：不新增 / 不改任何文档基建（无 `VULNERABILITY_REPORT.md`、无 `doc/CVE/`）。
- **不动**：commons / keyvalue（上一轮已切）、其余 12 个官方模块、BOM 本体 GAV 与 version、根 parent、`<distributionManagement>`、`Makefile`、`settings.xml`。

## Capabilities

### Modified Capabilities

- `gav-renaming`：「managed 依赖反映下游 fork」requirement 的 fork 覆盖面由 commons / keyvalue 两模块扩至 + elasticsearch / redis 共四模块；「未 fork 模块保持官方坐标」的清单由 14 个收敛为 12 个；bom-client 依赖同步 fork 的清单加入 es / redis 两条。

## Impact

- **构建配置**：`bom/pom.xml`（2 条 managed 依赖坐标 + 版本）、`bom-client/pom.xml`（2 条 `<dependency>` 坐标）。共 **2 个文件、4 处**。
- **依赖解析前提**：内网 Nexus 必须可解析 `bjca-footstone-bpring-data-elasticsearch:5.5.13-nes.patch.1-SNAPSHOT` 与 `bjca-footstone-bpring-data-redis:3.5.13-nes.patch.1-SNAPSHOT`（下游 fork 已发布）。
- **下游影响**：`import` 本 BOM 的下游，其 es / redis 的消费坐标随之切到 fork。Java 包名 `org.springframework.data.*` 不变。
- **仍保持官方的 12 个模块**（cassandra / couchbase / jdbc / r2dbc / relational / jpa / envers / mongodb / neo4j / rest-webmvc / rest-core / rest-hal-explorer / ldap）保持官方坐标，本变更不动。
- **验证门槛**：以 `validate` 为准。`./mvnw -Pwith-bom-client verify`（全量拉取 16 模块 jar）会因内网 Nexus 无法代理外网官方 jar 而失败，**与本变更无关**；本变更涉及的两个 fork 制品单独用 `dependency:get` 证实可解析即可。
- **风险点**：
  - es 版本线 `5.5.x` 与 redis / commons / keyvalue 的 `3.5.x` 不同，是本变更唯一易错点——effective-pom 校验须显式确认 es 那条为 `5.5.13-nes.patch.1-SNAPSHOT`。
  - BOM 为纯 pom、零字节码，本变更价值在坐标一致性与私服制品整洁，非漏洞修复。
