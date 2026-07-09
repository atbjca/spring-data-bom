# Tasks — nes-bom-gav-align

> 图例：`[ ]` 未开始 `[~]` 进行中 `[x]` 完成

## 阶段 0：前置确认

- [ ] 0.1 确认内网 Nexus 可解析 `bjca-footstone-bpring-data-commons:2.7.18-nes.patch.1-SNAPSHOT`
- [ ] 0.2 确认内网 Nexus 可解析 `bjca-footstone-bpring-data-keyvalue:2.7.18-nes.patch.1-SNAPSHOT`

> 备注：阶段 0 需在内网环境执行。本次实现在外网环境完成，`validate` 阶段不下载依赖，故未实际拉取 fork SNAPSHOT；下游 fork 已发布为前提。真正 `install`/冒烟 resolve 时须在内网复验。

## 阶段 1：BOM 本体去特征化（bom/pom.xml）

- [x] 1.1 groupId `org.springframework.data` → `cn.bjca.footstone.bpring.data`
- [x] 1.2 artifactId `spring-data-bom` → `bjca-footstone-bpring-data-bom`
- [x] 1.3 version 保持 `2021.2.18-nes.patch.1-SNAPSHOT`（确认不改）

## 阶段 2：managed 依赖反映 fork（bom/pom.xml 的 dependencyManagement）

- [x] 2.1 commons：`org.springframework.data:spring-data-commons:2.7.18` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-commons:2.7.18-nes.patch.1-SNAPSHOT`
- [x] 2.2 keyvalue：`org.springframework.data:spring-data-keyvalue:2.7.18` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-keyvalue:2.7.18-nes.patch.1-SNAPSHOT`
- [x] 2.3 删除 commons 条目上排除官方 `org.springframework:spring-*` 的失效 `<exclusions>`
- [x] 2.4 删除 keyvalue 条目上排除官方 `org.springframework:spring-*` 的失效 `<exclusions>`
- [x] 2.5 确认其余 13 个模块条目保持官方坐标不变（effective-pom 确认 cassandra 等仍 `org.springframework.data`）

## 阶段 3：根 parent 与 bom-client 对齐

- [x] 3.1 根 `pom.xml` version `2021.2.19-SNAPSHOT` → `2021.2.18`
- [x] 3.2 `bom-client/pom.xml` 的 `<parent>` → `cn.bjca.footstone.bpring.data:bjca-footstone-bpring-data-bom:2021.2.18-nes.patch.1-SNAPSHOT`
- [x] 3.3 （实现中发现）`bom-client/pom.xml` 内部 commons/keyvalue 两条 `<dependency>` 的 GA 同步切 fork —— 否则父 BOM managed 坐标已改，官方 GA 找不到 managed 版本会解析失败

## 阶段 4：解析验证

- [x] 4.1 `mvn -N validate` 校验根 reactor 无误（`spring-data-bom-parent 2021.2.18`，BUILD SUCCESS）
- [x] 4.2 `mvn help:effective-pom -pl bom` 确认 BOM GAV 与 commons/keyvalue fork 坐标生效、无残留官方 data 自产坐标（BUILD SUCCESS）
- [x] 4.3 `mvn -Pwith-bom-client validate` 确认 bom-client `<parent>` 可解析（三模块 reactor BUILD SUCCESS）

## 阶段 5：收尾

- [x] 5.1 `openspec validate nes-bom-gav-align` 通过
- [x] 5.2 归档 change 到 `openspec/changes/archive/`
