# Tasks — nes-bom-redis-es-align

> 图例：`[ ]` 未开始 `[~]` 进行中 `[x]` 完成
> 本变更范围极窄：只改 `bom/pom.xml` 的 redis / elasticsearch 两条 managed 依赖（+ bom-client 连带）。机制同构于已归档 change `2026-07-09-nes-bom-gav-align`。

## 阶段 0：前置确认

- [~] 0.1 内网 Nexus 可解析 `bjca-footstone-bpring-data-redis:2.7.18-nes.patch.1-SNAPSHOT`——**本机 `~/.m2` 已确认**；内网私服须复验（本机验不了）
- [~] 0.2 内网 Nexus 可解析 `bjca-footstone-bpring-data-elasticsearch:4.4.18-nes.patch.1-SNAPSHOT`——**本机 `~/.m2` 已确认**；内网私服须复验（本机验不了）

> 备注：阶段 0 需在内网环境执行。本次实现在外网环境完成，`validate` 阶段不下载依赖；真正 `install`/冒烟 resolve 时须在内网复验。

## 阶段 1：managed 依赖切 fork（bom/pom.xml 的 dependencyManagement）

- [x] 1.1 elasticsearch：groupId `org.springframework.data` → `cn.bjca.footstone.bpring.data`
- [x] 1.2 elasticsearch：artifactId `spring-data-elasticsearch` → `bjca-footstone-bpring-data-elasticsearch`
- [x] 1.3 elasticsearch：version `4.4.18` → `4.4.18-nes.patch.1-SNAPSHOT`
- [x] 1.4 elasticsearch：删除排除官方 `org.springframework:spring-context/tx` 的失效 `<exclusions>`（2 条）
- [x] 1.5 redis：groupId `org.springframework.data` → `cn.bjca.footstone.bpring.data`
- [x] 1.6 redis：artifactId `spring-data-redis` → `bjca-footstone-bpring-data-redis`
- [x] 1.7 redis：version `2.7.18` → `2.7.18-nes.patch.1-SNAPSHOT`
- [x] 1.8 redis：删除排除官方 `org.springframework:spring-context/tx/oxm/aop/context-support` 的失效 `<exclusions>`（5 条）

## 阶段 2：bom-client 核实（同上次 change 阶段 3.3 的坑）

- [x] 2.1 核实 `bom-client/pom.xml`：**确显式声明了 redis（行 141）/ elasticsearch（行 94）**——坑命中，同上次 commons/keyvalue
- [x] 2.2 已将 bom-client 的 redis / elasticsearch 两条 `<dependency>` 的 GA 同步切 fork 坐标（无 version，靠父 BOM managed 托管；不切则官方 GA 找不到 managed 版本、`with-bom-client` profile 解析失败）

## 阶段 3：解析验证

- [x] 3.1 `mvn -N validate` 校验根 reactor：**BUILD SUCCESS**
- [x] 3.2 `mvn help:effective-pom -pl bom`：redis / elasticsearch fork 坐标生效、**官方 redis/es/commons/keyvalue 自产坐标零残留**；其余 11 模块仍官方
- [x] 3.3 `mvn -Pwith-bom-client validate`：三模块 reactor **BUILD SUCCESS**，实证 bom-client 连带切 fork 后 redis/es 可解析

## 阶段 4：收尾

- [ ] 4.1 `openspec validate nes-bom-redis-es-align --strict` 通过
- [ ] 4.2 归档 change 到 `openspec/changes/archive/`
