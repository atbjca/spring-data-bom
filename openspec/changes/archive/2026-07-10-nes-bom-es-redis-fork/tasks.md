# Tasks — nes-bom-es-redis-fork

> 图例：`[ ]` 未开始 `[~]` 进行中 `[x]` 完成

## 阶段 0：前置确认

- [x] 0.1 确认内网 Nexus 可解析 `bjca-footstone-bpring-data-elasticsearch:5.5.13-nes.patch.1-SNAPSHOT`（注意 `5.5.x` 版本线）— `dependency:get` BUILD SUCCESS
- [x] 0.2 确认内网 Nexus 可解析 `bjca-footstone-bpring-data-redis:3.5.13-nes.patch.1-SNAPSHOT` — `dependency:get` BUILD SUCCESS

## 阶段 1：managed 依赖切 fork（bom/pom.xml 的 dependencyManagement）

- [x] 1.1 elasticsearch：`org.springframework.data:spring-data-elasticsearch:5.5.13` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch:5.5.13-nes.patch.1-SNAPSHOT`（版本号 `5.5.13`，**勿写 3.5.13**）
- [x] 1.2 redis：`org.springframework.data:spring-data-redis:3.5.13` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis:3.5.13-nes.patch.1-SNAPSHOT`
- [x] 1.3 确认其余 12 个官方模块条目、commons / keyvalue 两条 fork 条目、BOM 本体 GAV 与 version 均不变

## 阶段 2：bom-client 依赖坐标同步（bom-client/pom.xml）

- [x] 2.1 elasticsearch `<dependency>`：`org.springframework.data:spring-data-elasticsearch` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-elasticsearch`（不写 version，由 BOM 托管）
- [x] 2.2 redis `<dependency>`：`org.springframework.data:spring-data-redis` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-redis`（不写 version）
- [x] 2.3 确认 `<parent>` 与其余 12 个官方模块 `<dependency>` 声明不变

## 阶段 3：解析与发布验证

- [x] 3.1 `./mvnw -N validate` 校验根 reactor 无误 — BUILD SUCCESS
- [x] 3.2 `make validate`（`help:effective-pom -pl bom`）确认 es 为 `5.5.13-nes.patch.1-SNAPSHOT`、redis 为 `3.5.13-nes.patch.1-SNAPSHOT`，无官方 es/redis 残留，其余 12 模块保持官方 — 已确认（effective-pom：es=5.5.13-nes.patch.1-SNAPSHOT、redis=3.5.13-nes.patch.1-SNAPSHOT，无官方残留）
- [x] 3.3 `./mvnw -Pwith-bom-client validate` 确认 bom-client 依赖版本被 BOM 正确托管（es / redis 无 "missing version"）— 三模块 BUILD SUCCESS
- [x] 3.4 单独解析两个 fork jar（`dependency:get ... :jar`）确认私服制品可用 — es / redis 均 BUILD SUCCESS
- [x] 3.5 `make deploy` 将 `2025.0.13-nes.patch.1-SNAPSHOT` 重新发布到私服 snapshots 仓库（BOM version 不变，内容含 es/redis fork 坐标）— BUILD SUCCESS

## 阶段 4：收尾

- [x] 4.1 `openspec validate nes-bom-es-redis-fork` 通过
- [x] 4.2 归档 change 到 `openspec/changes/archive/` — 已归档为 `2026-07-10-nes-bom-es-redis-fork`

> **注**：与 `nes-bom-patch-2025` 一致，`./mvnw -Pwith-bom-client verify`（全量拉取 16 模块 jar）会因内网 Nexus 无法代理外网官方 jar 而失败，**与本变更无关**——本变更涉及的两个 fork 制品已单独证实可解析（3.4）。验证门槛以 `validate` 为准。
