# Design — nes-bom-gav-align

## 1. 背景与定位

`spring-data-bom` 是 Spring Data 全家桶的版本清单（纯 pom、零字节码），下游以 `import` 作用域统一托管 15 个模块版本。下游已 fork commons / keyvalue 两个模块，但 BOM 仍指向官方坐标，导致 fork 在 BOM 这层断链。本变更让 BOM 反映已完成的下游 fork，并顺带修正三个 pom 的版本不一致与 BOM 本体「半 fork」状态。

本项目结构上有三个 pom，**彼此无 Maven 继承关系**，需分别理解：

| pom | 角色 | 是否发布 | 版本决策 |
|-----|------|---------|---------|
| `pom.xml` | reactor 聚合根 | 否（install/deploy skip） | `2021.2.18`（用户定版） |
| `bom/pom.xml` | 唯一发布制品 | 是 | `2021.2.18-nes.patch.1-SNAPSHOT`（已 fork，不变） |
| `bom-client/pom.xml` | 冒烟校验，仅 `with-bom-client` profile | 否 | `<parent>` 对齐 BOM 本体 |

## 2. 关键决策

### 2.1 改造范围：只切 commons + keyvalue 两条 managed 依赖

**决策**：`<dependencyManagement>` 中仅将 commons、keyvalue 改为 fork 坐标，其余 13 个模块保持官方坐标。

**理由**：BOM 是版本清单，条目应如实反映各模块的真实发布坐标。只有 commons / keyvalue 完成了 fork，其余模块下游未 fork，官方坐标即为其真实坐标。BOM 不应超前引用尚不存在的 fork 制品。

### 2.2 BOM 本体也去特征化（GAV 全切 fork）

**决策**：BOM 制品自身 groupId → `cn.bjca.footstone.bpring.data`、artifactId → `bjca-footstone-bpring-data-bom`；version 保持 `2021.2.18-nes.patch.1-SNAPSHOT`。

**理由**：BOM 是纯 pom，SCA 的两条命中路径（GAV 匹配 / 字节码指纹）对它都不适用，去特征化**无直接 SCA 收益**。但基于三点仍切 fork：
- **全家桶坐标一致性**：commons / keyvalue 已在 `cn.bjca.footstone.bpring.data` 命名空间，BOM 作为清单留在官方命名空间会割裂。
- **下游 import 前缀统一**：下游可用同一 groupId 前缀声明 BOM 与各模块。
- **私服制品干净**：内网 Nexus 上不再混入 `org.springframework.data` 官方坐标的自产物。

version 之所以不动，是因为它早已带 `-nes.patch.1`（本体处于「半 fork」），本变更只补齐 groupId/artifactId。

### 2.3 清理 commons / keyvalue 上的官方 exclusions

**决策**：删除这两条 managed 依赖上排除 `org.springframework:spring-core/beans/context/tx/...` 的 `<exclusions>`。

**理由**：原 exclusions 用于拦截官方模块传递出来的官方 Spring 依赖。坐标改 fork 后，commons / keyvalue 传递出来的已是 `cn.bjca.footstone.bpring:bjca-footstone-bpring-context/tx` 等 fork 坐标，排除 `org.springframework:spring-*` 的规则再也匹配不到任何东西——变成死配置，删除以免误导后人。若确需拦截 fork 传递依赖，应另立规则，不在本变更范围。

### 2.4 根 parent 定版 2021.2.18，不去特征化

**决策**：根 `pom.xml` version `2021.2.19-SNAPSHOT` → `2021.2.18`；groupId/artifactId 保持官方。

**理由**：根 parent 是 reactor 聚合根，install/deploy 均 skip、不发布，无任何模块 `<parent>` 继承它，版本纯装饰。用户明确定为 `2021.2.18`。因不发布、不进私服，无去特征化必要。

### 2.5 bom-client parent 引用对齐

**决策**：`bom-client/pom.xml` 的 `<parent>` 改为 `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2021.2.18-nes.patch.1-SNAPSHOT`。

**理由**：现引用 `org.springframework.data:spring-data-bom:2021.2.19-SNAPSHOT` 与 BOM 本体实际坐标/版本都对不上，`with-bom-client` profile 激活即解析失败。随 BOM 本体去特征化后必须同步 groupId/artifactId/version，否则冒烟校验无法运行。

## 3. 验证

- **解析验证**：`mvn -N validate` 校验根 reactor；`mvn help:effective-pom -pl bom` 确认 BOM 本体 GAV 与 commons/keyvalue fork 坐标生效、无残留官方坐标。
- **profile 验证**：`mvn -Pwith-bom-client validate` 确认 bom-client `<parent>` 可解析。
- **前提**：内网 Nexus 已发布 commons / keyvalue 的 `2.7.18-nes.patch.1-SNAPSHOT`（下游 fork 产物）。

## 4. 非目标

- 不 fork 其余 13 个模块，不超前引用不存在的 fork 制品。
- 不改根 parent / bom-client 的 groupId/artifactId 之外的结构（`<modules>`、profile 机制、flatten 配置、distributionManagement 变量均不动）。
- 不修改任何 Java 源码或对外 API（本项目无字节码）。
- 不处理下游「官方与 fork 并存」的对齐（属下游范围）。
