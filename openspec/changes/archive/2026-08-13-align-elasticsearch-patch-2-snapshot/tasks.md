## 1. Version Alignment

- [x] 1.1 Set the BOM artifact version to `2021.2.18-nes.patch.2-SNAPSHOT` while keeping the root aggregator at `2021.2.18`
- [x] 1.2 Set the managed NES Spring Data Elasticsearch version to `4.4.18-nes.patch.2-SNAPSHOT`
- [x] 1.3 Align the `bom-client` parent to `2021.2.18-nes.patch.2-SNAPSHOT`

## 2. Development Documentation

- [x] 2.1 Document the current BOM SNAPSHOT, managed Elasticsearch SNAPSHOT, resolution prerequisite, and previous stable RELEASE in `README.adoc`
- [x] 2.2 Document that the SNAPSHOT line must not be deployed to Nexus RELEASE or tagged and that formal release requires a separate change

## 3. Structural Validation

- [x] 3.1 Run root reactor validation and generate the BOM effective POM
- [x] 3.2 Verify effective POM selects BOM `patch.2-SNAPSHOT` and Elasticsearch `patch.2-SNAPSHOT`, with root version and unrelated managed modules unchanged
- [x] 3.3 Run `with-bom-client` validation and report separately if the sibling Elasticsearch SNAPSHOT is not yet resolvable
- [x] 3.4 Run local package and verify the tracked flattened POM contains the BOM and Elasticsearch `patch.2-SNAPSHOT` versions

## 4. Consumer And Final Gates

- [x] 4.1 Record the independent consumer check as a downstream gate: Nexus does not yet contain `4.4.18-nes.patch.2-SNAPSHOT`, so conflict validation remains required by `snapshot-alignment` when the sibling closure becomes available
- [x] 4.2 Run strict OpenSpec validation and inspect the final Git diff for scope, whitespace errors, secrets, and accidental release actions
- [x] 4.3 Confirm no remote deploy, RELEASE publication, release tag, or sibling-repository write occurred
