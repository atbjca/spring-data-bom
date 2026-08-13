## Context

当前 `2021.2.18-nes.patch.1` BOM 已发布并由标签固定，托管 `bjca-footstone-bpring-data-elasticsearch:4.4.18-nes.patch.1`。Elasticsearch 兄弟仓库正在实施 `migrate-to-nes-elasticsearch-client-stack`，其开发制品为 `4.4.18-nes.patch.2-SNAPSHOT`，并通过传递 POM 切换到 NES Elasticsearch 7.17.29 客户端、Barsson 和 NES Spring JCL。

BOM 是纯 POM 版本清单，不包含 Java 字节码。它只需托管 Spring Data Elasticsearch 顶层制品，不应重复管理由 Elasticsearch 项目拥有的底层客户端闭包。当前需要的是跨仓 SNAPSHOT 联调能力，而不是提前发布一个包含可变依赖的 RELEASE。

## Goals / Non-Goals

**Goals:**

- 建立 `2021.2.18-nes.patch.2-SNAPSHOT` BOM 开发线并消费 Elasticsearch `4.4.18-nes.patch.2-SNAPSHOT`。
- 保持已发布 BOM `patch.1` 不可变，并保留根聚合版本 `2021.2.18`。
- 用 `bom-client`、effective POM 和独立消费者验证顶层坐标选择与传递闭包。
- 在任何内部 SNAPSHOT 存在时阻断 BOM RELEASE 发布和标签。

**Non-Goals:**

- 不等待或执行 Elasticsearch `patch.2` RELEASE 发布。
- 不在 BOM 中新增 HLRC、REST Client、Java Client、Barsson 或 JCL 的直接 dependency management。
- 不修改 Elasticsearch 兄弟仓库，不执行 Nexus deploy，不创建 release tag。
- 不将本次开发态版本描述为已发布版本。

## Decisions

### 1. BOM 自身递增到 patch.2-SNAPSHOT

将发布模块版本设为 `2021.2.18-nes.patch.2-SNAPSHOT`，`bom-client` parent 同步。不能继续使用 `patch.1`，因为 BOM 内容变化且该 RELEASE 已存在；也不直接使用 `patch.2`，因为 managed Elasticsearch 当前仍为 SNAPSHOT。

根聚合 `pom.xml` 保持 `2021.2.18`。它仅组织 reactor，install/deploy 均跳过，不是需要随 NES 补丁递增的发布制品。

### 2. 只更新 Spring Data Elasticsearch 顶层 managed 版本

BOM 将 `bjca-footstone-bpring-data-elasticsearch` 更新到 `4.4.18-nes.patch.2-SNAPSHOT`。底层 NES Elasticsearch 客户端、Barsson 和 JCL 继续由该制品生成的 POM 管理。

替代方案是在 BOM 中同时托管底层闭包。该方案会把 Elasticsearch 项目的依赖所有权复制到 BOM，并可能掩盖其生成 POM 错误，因此拒绝。

### 3. 开发验证允许 SNAPSHOT，RELEASE 流程禁止 SNAPSHOT

本地 `validate`、effective POM、install 和消费者 smoke test 可以解析 SNAPSHOT，以便两个仓库并行演进。任何 Nexus RELEASE deploy、非 SNAPSHOT BOM 版本或 release tag 都必须等待 Elasticsearch `patch.2` 和全部内部依赖形成已批准 RELEASE，并通过独立 release change 执行。

### 4. 消费者验证覆盖顶层选择和冲突风险

`bom-client` 继续只声明 NES Spring Data Elasticsearch GA，不写 version，以证明由 BOM 选择 `patch.2-SNAPSHOT`。若环境能解析完整闭包，独立消费者还应检查依赖树中不存在官方/NES Elasticsearch 客户端和 Parsson/Barsson 的重复入口。

由于这些底层依赖来自正在变更的兄弟制品，若其 SNAPSHOT 尚未安装或部署，解析失败应作为外部前置条件报告，不能回退到 `patch.1` 或官方坐标。

## Risks / Trade-offs

- [Elasticsearch SNAPSHOT 尚不可解析] -> 先完成结构和 effective POM 校验，明确标记消费者验证受兄弟制品就绪状态阻断。
- [SNAPSHOT 内容可变] -> 仅用于开发联调；正式发布时重新生成依赖树和消费者证据，并替换为 RELEASE。
- [官方与 NES 同包名 JAR 并存] -> 在完整消费者验证中检查 GAV、关键类和 JSON-P provider 来源。
- [BOM 重复管理底层版本造成所有权漂移] -> BOM 只托管 Spring Data 顶层制品，让 Elasticsearch 发布 POM拥有其客户端闭包。
- [文档混淆开发态与已发布状态] -> README 同时明确当前 SNAPSHOT 和上一稳定 RELEASE，禁止声明 `patch.2` 已发布。

## Migration Plan

1. 创建并严格验证本 OpenSpec change。
2. 将 BOM 和 `bom-client` parent 更新到 `2021.2.18-nes.patch.2-SNAPSHOT`，将 managed Elasticsearch 更新到 `4.4.18-nes.patch.2-SNAPSHOT`，并通过本地 package 重新生成已跟踪的 flattened POM。
3. 更新 README 开发态说明，保留 `patch.1` 为上一稳定 RELEASE。
4. 运行 reactor、effective POM 和可用范围内的消费者验证；不执行 deploy。
5. Elasticsearch `4.4.18-nes.patch.2` 完成 Nexus 验证后，另开 BOM release change，将 BOM 和内部依赖收敛为 RELEASE，再发布新的 BOM patch。

回滚只需恢复本变更涉及的 BOM 版本、Elasticsearch managed version、`bom-client` parent 和 README；已发布的 `patch.1` 不受影响。

## Open Questions

- 当前 Elasticsearch `patch.2-SNAPSHOT` 的完整 NES 客户端与 Barsson 闭包尚在实施中，因此完整消费者门禁何时可通过取决于兄弟仓库进度。
- 下一次 BOM RELEASE 的最终 patch 编号默认采用 `2021.2.18-nes.patch.2`，仍需在独立 release change 中核对 Nexus 目标不存在并获得发布授权。
