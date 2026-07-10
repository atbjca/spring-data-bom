# Design — nes-bom-redis-es-align

## 1. 背景与定位

`spring-data-bom` 是 Spring Data 全家桶的版本清单（纯 pom、零字节码），下游以 `import` 作用域统一托管 15 个模块版本。已归档 change `2026-07-09-nes-bom-gav-align` 完成了 BOM 本体去特征化 + commons / keyvalue 两条 managed 依赖切 fork。此后 redis / elasticsearch 也完成下游 fork 并 deploy，BOM 再次落后于现实。本变更把这两条 managed 依赖切 fork，是上次 change 的自然延续、机制完全同构。

**范围极窄**：只改 `bom/pom.xml` 一个文件的两条 `<dependencyManagement>` 条目。BOM 本体 GAV、根 parent、bom-client 已在上次 change 定型，本次不动。

## 2. 关键决策

### 2.1 只切 redis + elasticsearch 两条 managed 依赖

**决策**：`<dependencyManagement>` 中将 redis、elasticsearch 改为 fork 坐标，其余 11 个未 fork 模块保持官方坐标。

**理由**：BOM 是版本清单，条目应如实反映各模块真实发布坐标。commons / keyvalue（上次）+ redis / elasticsearch（本次）已完成 fork，官方坐标不再是其真实坐标；其余 11 模块下游未 fork，官方坐标即为真实坐标，BOM 不应超前引用不存在的 fork 制品。

### 2.2 清理 redis / elasticsearch 上的官方 exclusions

**决策**：删除这两条 managed 依赖上排除 `org.springframework:spring-*` 的 `<exclusions>`——redis 5 条（context/tx/oxm/aop/context-support）、elasticsearch 2 条（context/tx）。

**理由**：原 exclusions 用于拦截官方模块传递出来的官方 Spring 依赖。坐标改 fork 后，redis / elasticsearch 传递出来的已是 `cn.bjca.footstone.bpring:bjca-footstone-bpring-*` fork 坐标，排除 `org.springframework:spring-*` 的规则再也匹配不到任何东西——变成死配置，删除以免误导后人。此坑与上次 commons / keyvalue change 完全同构、已有先例（见归档 change 决策 2.3）。若确需拦截 fork 传递依赖，应另立规则，不在本变更范围。

### 2.3 BOM 本体 / 根 parent / bom-client 不动

**决策**：本变更不触碰 BOM 本体 GAV、根 `pom.xml`、`bom-client/pom.xml`。

**理由**：这些已在上次 change 全部定型到位（BOM 本体已是 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2021.2.18-nes.patch.1-SNAPSHOT`，根 parent 已定版 `2021.2.18`，bom-client `<parent>` 已对齐）。本次纯粹是 managed 依赖清单的增量对齐，无需重复处理。

**注**：上次 change 阶段 3.3 曾发现 `bom-client/pom.xml` 内部显式声明了 commons/keyvalue 两条 `<dependency>` 需同步切 fork。本次须核实 bom-client 是否同样显式声明了 redis/elasticsearch——若有，须同步切 fork（否则父 BOM managed 坐标已改、官方 GA 找不到 managed 版本会解析失败）；若无，则无需处理。此项在 tasks 中作为核实点列出。

## 3. 验证

- **解析验证**：`mvn -N validate` 校验根 reactor；`mvn help:effective-pom -pl bom` 确认 redis / elasticsearch fork 坐标生效、无残留官方坐标、其余 11 模块仍官方。
- **profile 验证**：`mvn -Pwith-bom-client validate` 确认 bom-client 仍可解析（若 bom-client 显式引用了 redis/elasticsearch，须一并切 fork 后再验）。
- **前提**：内网 Nexus 已发布 redis / elasticsearch 的 `*-nes.patch.1-SNAPSHOT`（下游 fork 已 deploy）。本机 `~/.m2` 已确认可解析；`validate` 阶段不下载依赖，真正 `install`/冒烟 resolve 时须在内网复验。

## 4. 非目标

- 不 fork 其余 11 个模块，不超前引用不存在的 fork 制品。
- 不改 BOM 本体 GAV、根 parent、bom-client 结构（除非核实发现 bom-client 显式引用 redis/elasticsearch 需同步）。
- 不修改任何 Java 源码或对外 API（本项目无字节码）。
- 不处理下游「官方与 fork 并存」的对齐（属下游范围）。
