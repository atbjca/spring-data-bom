# Tasks — nes-bom-patch-2025

> 图例：`[ ]` 未开始 `[~]` 进行中 `[x]` 完成

## 阶段 0：前置确认与基线迁移

- [x] 0.1 确认内网 Nexus 可解析 `bjca-footstone-bpring-data-commons:3.5.13-nes.patch.1-SNAPSHOT`
- [x] 0.2 确认内网 Nexus 可解析 `bjca-footstone-bpring-data-keyvalue:3.5.13-nes.patch.1-SNAPSHOT`
- [x] 0.3 将 `2025.0.x-bjca-patch` 基线抬到官方正式版 `2025.0.13`（commit `ca0af42`）——零冲突 fast-forward
- [x] 0.4 迁移后确认三 pom 版本均为干净 `2025.0.13`、工作树无残留改动

## 阶段 1：BOM 本体去特征化（bom/pom.xml）

- [x] 1.1 groupId `org.springframework.data` → `cn.bjca.footstone.bpring.data`
- [x] 1.2 artifactId `spring-data-bom` → `bjca-footstone-bpring-data-bom`
- [x] 1.3 version `2025.0.13` → `2025.0.13-nes.patch.1-SNAPSHOT`

## 阶段 2：managed 依赖反映 fork（bom/pom.xml 的 dependencyManagement）

- [x] 2.1 commons：`org.springframework.data:spring-data-commons:3.5.13` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:3.5.13-nes.patch.1-SNAPSHOT`
- [x] 2.2 keyvalue：`org.springframework.data:spring-data-keyvalue:3.5.13` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue:3.5.13-nes.patch.1-SNAPSHOT`
- [x] 2.3 确认其余 14 个模块条目保持官方坐标不变（含各自既有 exclusions，不动）

## 阶段 3：根 parent 与 bom-client 对齐

- [x] 3.1 根 `pom.xml` version 保持官方正式版 `2025.0.13`（公开 Maven 仓库可解析，**不加** nes 后缀；迁移后本就是 `2025.0.13`，实为确认不改）
- [x] 3.2 `bom-client/pom.xml` 的 `<parent>` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2025.0.13-nes.patch.1-SNAPSHOT`
- [x] 3.3 `bom-client/pom.xml` 的 commons / keyvalue 两条 `<dependency>` 同步切 fork 坐标（`bjca-footstone-bpring-data-commons` / `-keyvalue`），否则 BOM 已改 fork、bom-client 声明官方坐标将因 "missing version" 校验失败

## 阶段 4：接入 Nexus 发布（bom/pom.xml）

- [x] 4.1 新增 `<distributionManagement>`：`releases`（`${nexusReleaseUrl}`）+ `snapshots`（`${nexusSnapshotUrl}`）
- [x] 4.2 确认 `settings.xml` 无需改动（复用环境已激活的 `bjca` profile 与 server 凭证 `releases`/`snapshots`）

## 阶段 4b：构建快捷命令（Makefile）

- [x] 4b.1 新增 `Makefile`，目标 `clean/build/validate/install/deploy/verify-client`（针对纯 pom 定制，不含 `test`）
- [x] 4b.2 `make help` / `make build` 验证可用，flatten 生成扁平化发布 POM 坐标正确

## 阶段 5：解析与发布验证

- [x] 5.1 `./mvnw -N validate` 校验根 reactor 无误 — BUILD SUCCESS
- [x] 5.2 `./mvnw help:effective-pom -pl bom` 确认 BOM GAV、commons/keyvalue fork 坐标与版本生效、无残留官方 data 自产坐标 — 已确认（BOM=2025.0.13-nes.patch.1-SNAPSHOT，commons/keyvalue=3.5.13-nes.patch.1-SNAPSHOT，无官方 commons/keyvalue 残留，其余 14 模块保持官方）
- [x] 5.3 `./mvnw -Pwith-bom-client validate` 确认 bom-client `<parent>` 可解析、依赖版本被 BOM 正确托管 — 三模块全部 BUILD SUCCESS
- [x] 5.3a 单独解析两个 fork jar（`dependency:get ... :jar`）确认私服制品可用 — commons/keyvalue 均 BUILD SUCCESS
- [x] 5.4 `make deploy`（= `./mvnw -pl bom clean deploy`）将 `2025.0.13-nes.patch.1-SNAPSHOT` 发布到私服 snapshots 仓库 — BUILD SUCCESS，制品(纯 pom)已 Uploaded 至 `192.168.131.36:8088/repository/snapshots/`

> **注**：`./mvnw -Pwith-bom-client verify`（触发 dependency:resolve 全量拉取 16 模块 jar）会失败，根因是内网 Nexus 无法代理外网官方 jar（未 fork 的 `spring-data-couchbase:5.5.13`、`hibernate-core/envers` 等返回 500），**与本变更无关**——本变更涉及的两个 fork 制品已单独证实可解析（5.3a）。验证门槛以 `validate` 为准（与 design 一致）。

## 阶段 6：收尾

- [x] 6.1 `openspec validate nes-bom-patch-2025` 通过
- [ ] 6.2 归档 change 到 `openspec/changes/archive/`
