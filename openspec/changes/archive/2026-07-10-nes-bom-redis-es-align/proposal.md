## Why

`spring-data-bom`（`bom/pom.xml`）通过 `<dependencyManagement>` 统一托管 15 个 Spring Data 模块版本，供下游以 `import` 作用域消费。已归档 change `2026-07-09-nes-bom-gav-align` 让 BOM 反映了当时已完成的 commons / keyvalue fork，但**当时 redis / elasticsearch 尚未 fork**，故这两条仍保留官方坐标。

此后下游又完成了两个模块的 NES fork 并 deploy：

- `spring-data-redis` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis:2.7.18-nes.patch.1-SNAPSHOT`
- `spring-data-elasticsearch` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:4.4.18-nes.patch.1-SNAPSHOT`

结果：BOM 再次**落后于现实**——redis / elasticsearch 已 fork，但 BOM 仍指向官方坐标（`org.springframework.data:spring-data-redis:2.7.18` / `spring-data-elasticsearch:4.4.18`），下游 `import` 本 BOM 拿到的仍是官方制品，这两个模块的去特征化在 BOM 层断链。

本变更是上次 change 的**自然延续、完全同构**：把 redis / elasticsearch 两条 managed 依赖切到 fork 坐标，使 BOM 反映全部四个已 fork 模块。

## What Changes

- **redis / elasticsearch 两条 managed 依赖切 fork 坐标**（`bom/pom.xml` 的 `<dependencyManagement>`）：
  - `org.springframework.data:spring-data-redis:2.7.18` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis:2.7.18-nes.patch.1-SNAPSHOT`
  - `org.springframework.data:spring-data-elasticsearch:4.4.18` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:4.4.18-nes.patch.1-SNAPSHOT`
- **清理失效 exclusions**：
  - redis 条目上排除官方 `org.springframework:spring-context/tx/oxm/aop/context-support` 的 `<exclusions>`（5 条）——坐标改 fork 后不再匹配，删除。
  - elasticsearch 条目上排除官方 `org.springframework:spring-context/tx` 的 `<exclusions>`（2 条）——同上，删除。
- **BOM 本体 / 根 parent / bom-client 不动**：本变更只改这两条 managed 依赖，其余结构（BOM 本体 GAV、根 parent、bom-client、profile 机制）已在上次 change 定型，不重复处理。

## Capabilities

### Modified Capabilities

- `gav-renaming`：扩展现有 requirement「managed 依赖反映下游 fork」的范围——已 fork 模块从 commons / keyvalue 两个扩展为 commons / keyvalue / redis / elasticsearch 四个；未 fork 模块从 13 个缩减为 11 个。

## Impact

- **构建配置**：`bom/pom.xml`（2 条 managed 依赖坐标 + 清理 7 条 exclusions）。仅此一个文件。
- **依赖解析前提**：内网 Nexus 必须可解析 `bjca-footstone-bpring-data-redis:2.7.18-nes.patch.1-SNAPSHOT` 与 `bjca-footstone-bpring-data-elasticsearch:4.4.18-nes.patch.1-SNAPSHOT`（下游 fork 已 deploy）。本机 `~/.m2` 已确认可解析；内网私服须在 `install`/冒烟 resolve 时复验。
- **下游影响**：`import` 本 BOM 后，redis / elasticsearch 的消费坐标随之切到 fork。Java 包名 `org.springframework.data.redis.*` / `org.springframework.data.elasticsearch.*` 与 JPMS 模块名不变，下游 `import`/`requires` 无需改动，仅 Maven GAV 声明处（若显式声明官方坐标）需对齐。
- **仍未 fork 的 11 个模块**（cassandra / couchbase / geode / jdbc / relational / jpa / mongodb / neo4j / r2dbc / rest / envers / ldap）保持官方坐标，本变更不动。
- **风险点**：
  - BOM 为纯 pom、零字节码，去特征化对 SCA 无直接技术收益；本变更价值在坐标一致性与私服制品整洁，非漏洞修复。
  - 下游若同时 `import` 本 BOM 又单独声明官方 redis/elasticsearch 坐标，会出现官方与 fork 并存——需在下游对齐（本变更范围外）。
