# Changelog

## [3.1.2](https://github.com/voxpupuli/beaker-docker/tree/3.1.2) (2026-02-27)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/3.1.1...3.1.2)

**Fixed bugs:**

- fix: complete the support for docker-ce \>= v29 network configuration [\#183](https://github.com/voxpupuli/beaker-docker/pull/183) ([mxey](https://github.com/mxey))
- Handle empty IPAddress when setting host vm\_ip [\#182](https://github.com/voxpupuli/beaker-docker/pull/182) ([uvNikita](https://github.com/uvNikita))

## [3.1.1](https://github.com/voxpupuli/beaker-docker/tree/3.1.1) (2026-01-31)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/3.1.0...3.1.1)

**Fixed bugs:**

- Handle both podman and docker to get SUT container IP address [\#180](https://github.com/voxpupuli/beaker-docker/pull/180) ([alelindq](https://github.com/alelindq))

## [3.1.0](https://github.com/voxpupuli/beaker-docker/tree/3.1.0) (2025-12-27)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/3.0.1...3.1.0)

**Implemented enhancements:**

- Add Ruby 4.0 support [\#177](https://github.com/voxpupuli/beaker-docker/pull/177) ([bastelfreak](https://github.com/bastelfreak))

## [3.0.1](https://github.com/voxpupuli/beaker-docker/tree/3.0.1) (2025-10-01)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/3.0.0...3.0.1)

**Fixed bugs:**

-  fix: deep merge dockeropts [\#167](https://github.com/voxpupuli/beaker-docker/pull/167) ([mpldr](https://github.com/mpldr))

## [3.0.0](https://github.com/voxpupuli/beaker-docker/tree/3.0.0) (2025-08-11)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/2.6.0...3.0.0)

**Breaking changes:**

- Require Ruby 3.2 or newer [\#163](https://github.com/voxpupuli/beaker-docker/pull/163) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- beaker: Allow 7.x [\#162](https://github.com/voxpupuli/beaker-docker/pull/162) ([bastelfreak](https://github.com/bastelfreak))

## [2.6.0](https://github.com/voxpupuli/beaker-docker/tree/2.6.0) (2025-05-28)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/2.5.2...2.6.0)

**Implemented enhancements:**

- CI: Run tests with podman and docker [\#160](https://github.com/voxpupuli/beaker-docker/pull/160) ([bastelfreak](https://github.com/bastelfreak))
- CI: Generate matrix automatically & drop unused coverage reporting [\#158](https://github.com/voxpupuli/beaker-docker/pull/158) ([bastelfreak](https://github.com/bastelfreak))
- voxpupuli-rubocop: 3.0.0-\>3.1.0 [\#157](https://github.com/voxpupuli/beaker-docker/pull/157) ([bastelfreak](https://github.com/bastelfreak))
- fakefs: Allow 3.x [\#155](https://github.com/voxpupuli/beaker-docker/pull/155) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- excon: exclude 1.2.6 [\#156](https://github.com/voxpupuli/beaker-docker/pull/156) ([bastelfreak](https://github.com/bastelfreak))

## [2.5.2](https://github.com/voxpupuli/beaker-docker/tree/2.5.2) (2024-11-20)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/2.5.1...2.5.2)

**Fixed bugs:**

- fix: ignore /etc/ssh/sshd\_config.d/\* if files are not present [\#152](https://github.com/voxpupuli/beaker-docker/pull/152) ([vchepkov](https://github.com/vchepkov))

## [2.5.1](https://github.com/voxpupuli/beaker-docker/tree/2.5.1) (2024-11-20)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/2.5.0...2.5.1)

**Fixed bugs:**

- Update sshd configuration \(UsePAM no, sshd\_config.d\) [\#148](https://github.com/voxpupuli/beaker-docker/pull/148) ([jay7x](https://github.com/jay7x))

## [2.5.0](https://github.com/voxpupuli/beaker-docker/tree/2.5.0) (2024-09-20)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/2.4.0...2.5.0)

**Implemented enhancements:**

- add ContainerDocker and ContainerSwarm [\#145](https://github.com/voxpupuli/beaker-docker/pull/145) ([evgeni](https://github.com/evgeni))
- Add ContainerPodman class [\#130](https://github.com/voxpupuli/beaker-docker/pull/130) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- fix tests after Beaker::Platform refactoring [\#146](https://github.com/voxpupuli/beaker-docker/pull/146) ([evgeni](https://github.com/evgeni))

## [2.4.0](https://github.com/voxpupuli/beaker-docker/tree/2.4.0) (2024-08-13)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/2.3.1...2.4.0)

**Implemented enhancements:**

- Arch Linux: remove redundant system updates [\#142](https://github.com/voxpupuli/beaker-docker/pull/142) ([bastelfreak](https://github.com/bastelfreak))

## [2.3.1](https://github.com/voxpupuli/beaker-docker/tree/2.3.1) (2024-07-08)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/2.3.0...2.3.1)

**Fixed bugs:**

- CI: Switch from EL7/8-\>Debian12/EL9 [\#140](https://github.com/voxpupuli/beaker-docker/pull/140) ([bastelfreak](https://github.com/bastelfreak))
- docker-api: depend on 2.3 or newer [\#139](https://github.com/voxpupuli/beaker-docker/pull/139) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- voxpupuli-rubocop: Update to 2.8.0 [\#138](https://github.com/voxpupuli/beaker-docker/pull/138) ([bastelfreak](https://github.com/bastelfreak))

## [2.3.0](https://github.com/voxpupuli/beaker-docker/tree/2.3.0) (2024-05-28)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/2.2.1...2.3.0)

**Implemented enhancements:**

- beaker: Allow 6.x [\#135](https://github.com/voxpupuli/beaker-docker/pull/135) ([bastelfreak](https://github.com/bastelfreak))
- Add Ruby 3.3 to CI matrix [\#134](https://github.com/voxpupuli/beaker-docker/pull/134) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- voxpupuli-rubocop: Use 2.7.0 [\#136](https://github.com/voxpupuli/beaker-docker/pull/136) ([bastelfreak](https://github.com/bastelfreak))

## [2.2.1](https://github.com/voxpupuli/beaker-docker/tree/2.2.1) (2024-03-27)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/2.2.0...2.2.1)

**Fixed bugs:**

- Fix privileged remote docker port forward resolution  [\#126](https://github.com/voxpupuli/beaker-docker/pull/126) ([h0tw1r3](https://github.com/h0tw1r3))

## [2.2.0](https://github.com/voxpupuli/beaker-docker/tree/2.2.0) (2024-03-17)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/2.1.0...2.2.0)

**Implemented enhancements:**

- Implement writing out a containerfile for a host [\#125](https://github.com/voxpupuli/beaker-docker/pull/125) ([ekohl](https://github.com/ekohl))
- Support Amazon Linux 2023 [\#123](https://github.com/voxpupuli/beaker-docker/pull/123) ([treydock](https://github.com/treydock))

**Merged pull requests:**

- Rakefile: Use rubocop tasks from voxpupuli-rubocop [\#131](https://github.com/voxpupuli/beaker-docker/pull/131) ([bastelfreak](https://github.com/bastelfreak))
- voxpupuli-rubocop: Update 1.2-\>2.6 [\#129](https://github.com/voxpupuli/beaker-docker/pull/129) ([bastelfreak](https://github.com/bastelfreak))
- README.md: Document CLI; Add ToC [\#127](https://github.com/voxpupuli/beaker-docker/pull/127) ([bastelfreak](https://github.com/bastelfreak))

## [2.1.0](https://github.com/voxpupuli/beaker-docker/tree/2.1.0) (2023-05-05)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/2.0.0...2.1.0)

**Implemented enhancements:**

- switch to voxpupuli-rubocop & restore beaker 4 support [\#120](https://github.com/voxpupuli/beaker-docker/pull/120) ([bastelfreak](https://github.com/bastelfreak))

**Closed issues:**

- Enable SSH Agent forwarding on MacOS [\#117](https://github.com/voxpupuli/beaker-docker/issues/117)

**Merged pull requests:**

- GCG: Add faraday-retry dep [\#119](https://github.com/voxpupuli/beaker-docker/pull/119) ([bastelfreak](https://github.com/bastelfreak))
- CI: Build gems with strictness and verbosity [\#118](https://github.com/voxpupuli/beaker-docker/pull/118) ([bastelfreak](https://github.com/bastelfreak))
- rubocop: Fix RSpec/AnyInstance [\#116](https://github.com/voxpupuli/beaker-docker/pull/116) ([jay7x](https://github.com/jay7x))
- rubocop: Fix RSpec/VerifiedDoubles [\#115](https://github.com/voxpupuli/beaker-docker/pull/115) ([jay7x](https://github.com/jay7x))

## [2.0.0](https://github.com/voxpupuli/beaker-docker/tree/2.0.0) (2023-03-28)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/1.5.0...2.0.0)

**Breaking changes:**

- Drop Ruby 2.4/2.5/2.6 support [\#109](https://github.com/voxpupuli/beaker-docker/pull/109) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Drop `beaker-rspec` dependency [\#107](https://github.com/voxpupuli/beaker-docker/pull/107) ([jay7x](https://github.com/jay7x))

**Merged pull requests:**

- Rubocop: fix more violations [\#113](https://github.com/voxpupuli/beaker-docker/pull/113) ([bastelfreak](https://github.com/bastelfreak))
- rubocop: Use shared config from beaker [\#112](https://github.com/voxpupuli/beaker-docker/pull/112) ([bastelfreak](https://github.com/bastelfreak))
- Fix even more rubocop issues [\#111](https://github.com/voxpupuli/beaker-docker/pull/111) ([jay7x](https://github.com/jay7x))
- More rubocop fixes [\#110](https://github.com/voxpupuli/beaker-docker/pull/110) ([jay7x](https://github.com/jay7x))
- Fix more rubocop warnings [\#108](https://github.com/voxpupuli/beaker-docker/pull/108) ([jay7x](https://github.com/jay7x))
- Fix multiple Rubocop warnings [\#106](https://github.com/voxpupuli/beaker-docker/pull/106) ([bastelfreak](https://github.com/bastelfreak))

## [1.5.0](https://github.com/voxpupuli/beaker-docker/tree/1.5.0) (2023-03-24)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/1.4.0...1.5.0)

**Implemented enhancements:**

- Ruby 3.2 compatibility [\#100](https://github.com/voxpupuli/beaker-docker/pull/100) ([ekohl](https://github.com/ekohl))
- Set required Ruby version to 2.4+ [\#99](https://github.com/voxpupuli/beaker-docker/pull/99) ([ekohl](https://github.com/ekohl))
- Simplify port detection code [\#95](https://github.com/voxpupuli/beaker-docker/pull/95) ([ekohl](https://github.com/ekohl))
- Add Ruby 3.1 to CI matrix [\#87](https://github.com/voxpupuli/beaker-docker/pull/87) ([bastelfreak](https://github.com/bastelfreak))
- Use ssh-keygen -A on Red Hat-based distros & SuSE/SLES [\#73](https://github.com/voxpupuli/beaker-docker/pull/73) ([ekohl](https://github.com/ekohl))

**Fixed bugs:**

- Deal with docker\_cmd being an array and remove use of =~ [\#93](https://github.com/voxpupuli/beaker-docker/pull/93) ([ekohl](https://github.com/ekohl))

**Merged pull requests:**

- Remove Gemfile.local from git [\#104](https://github.com/voxpupuli/beaker-docker/pull/104) ([ekohl](https://github.com/ekohl))
- Fix rubocop Naming/FileName [\#103](https://github.com/voxpupuli/beaker-docker/pull/103) ([jay7x](https://github.com/jay7x))
- cleanup GitHub actions [\#102](https://github.com/voxpupuli/beaker-docker/pull/102) ([bastelfreak](https://github.com/bastelfreak))
- Remove unused rspec-its dependency [\#98](https://github.com/voxpupuli/beaker-docker/pull/98) ([ekohl](https://github.com/ekohl))
- Allow fakefs 2.x [\#97](https://github.com/voxpupuli/beaker-docker/pull/97) ([ekohl](https://github.com/ekohl))
- Remove yard rake tasks [\#96](https://github.com/voxpupuli/beaker-docker/pull/96) ([ekohl](https://github.com/ekohl))
- rubocop: fix dependency ordering [\#94](https://github.com/voxpupuli/beaker-docker/pull/94) ([bastelfreak](https://github.com/bastelfreak))
- GHA: Use builtin podman [\#86](https://github.com/voxpupuli/beaker-docker/pull/86) ([bastelfreak](https://github.com/bastelfreak))
- GHA: Use builtin docker [\#85](https://github.com/voxpupuli/beaker-docker/pull/85) ([bastelfreak](https://github.com/bastelfreak))
- Fix rubocop-related issues \(part 1\) [\#75](https://github.com/voxpupuli/beaker-docker/pull/75) ([jay7x](https://github.com/jay7x))

## [1.4.0](https://github.com/voxpupuli/beaker-docker/tree/1.4.0) (2023-03-10)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/1.3.0...1.4.0)

**Implemented enhancements:**

- Enable Rubocop [\#72](https://github.com/voxpupuli/beaker-docker/pull/72) ([jay7x](https://github.com/jay7x))
- Refactor built-in Dockerfile and fix\_ssh\(\) [\#71](https://github.com/voxpupuli/beaker-docker/pull/71) ([jay7x](https://github.com/jay7x))

**Fixed bugs:**

- set flag for container to container communication [\#84](https://github.com/voxpupuli/beaker-docker/pull/84) ([rwaffen](https://github.com/rwaffen))

**Merged pull requests:**

- dependabot: check for github actions as well [\#89](https://github.com/voxpupuli/beaker-docker/pull/89) ([bastelfreak](https://github.com/bastelfreak))

## [1.3.0](https://github.com/voxpupuli/beaker-docker/tree/1.3.0) (2022-12-18)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/1.2.0...1.3.0)

**Implemented enhancements:**

- Generate a ssh port from 1025..9999 range [\#68](https://github.com/voxpupuli/beaker-docker/pull/68) ([jay7x](https://github.com/jay7x))

## [1.2.0](https://github.com/voxpupuli/beaker-docker/tree/1.2.0) (2022-08-11)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/1.1.1...1.2.0)

**Implemented enhancements:**

- Use ssh-keygen -A on modern Enterprise Linux [\#66](https://github.com/voxpupuli/beaker-docker/pull/66) ([ekohl](https://github.com/ekohl))
- Add Docker hostfile parameter docker\_image\_first\_commands [\#65](https://github.com/voxpupuli/beaker-docker/pull/65) ([Rathios](https://github.com/Rathios))

## [1.1.1](https://github.com/voxpupuli/beaker-docker/tree/1.1.1) (2022-02-17)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/1.1.0...1.1.1)

**Fixed bugs:**

- Arch Linux: do not install openssh twice [\#58](https://github.com/voxpupuli/beaker-docker/pull/58) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Remove beaker from Gemfile [\#62](https://github.com/voxpupuli/beaker-docker/pull/62) ([bastelfreak](https://github.com/bastelfreak))
- CI: Switch centos:8 to centos:stream8 image [\#61](https://github.com/voxpupuli/beaker-docker/pull/61) ([bastelfreak](https://github.com/bastelfreak))

## [1.1.0](https://github.com/voxpupuli/beaker-docker/tree/1.1.0) (2022-01-27)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/1.0.1...1.1.0)

**Implemented enhancements:**

- Use host\_packages helper to reuse logic from beaker [\#59](https://github.com/voxpupuli/beaker-docker/pull/59) ([ekohl](https://github.com/ekohl))

## [1.0.1](https://github.com/voxpupuli/beaker-docker/tree/1.0.1) (2021-09-13)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/1.0.0...1.0.1)

**Implemented enhancements:**

- Initial EL9 support [\#55](https://github.com/voxpupuli/beaker-docker/pull/55) ([ekohl](https://github.com/ekohl))
- Add support for additional Docker port bindings [\#54](https://github.com/voxpupuli/beaker-docker/pull/54) ([treydock](https://github.com/treydock))

**Fixed bugs:**

- Fix IP detection in WSL2 environments [\#56](https://github.com/voxpupuli/beaker-docker/pull/56) ([trevor-vaughan](https://github.com/trevor-vaughan))
- Fix SSH port binding [\#53](https://github.com/voxpupuli/beaker-docker/pull/53) ([treydock](https://github.com/treydock))
- Added ENV DOCKER\_IN\_DOCKER to fix SSH conn info [\#51](https://github.com/voxpupuli/beaker-docker/pull/51) ([QueerCodingGirl](https://github.com/QueerCodingGirl))

**Closed issues:**

- Regression with 1.0.0 WRT SSH port usage [\#52](https://github.com/voxpupuli/beaker-docker/issues/52)

## [1.0.0](https://github.com/voxpupuli/beaker-docker/tree/1.0.0) (2021-08-06)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.8.4...1.0.0)

**Implemented enhancements:**

- Implement codecov reporting [\#49](https://github.com/voxpupuli/beaker-docker/pull/49) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- Treat Fedora 22+ and EL8 the same [\#48](https://github.com/voxpupuli/beaker-docker/pull/48) ([ekohl](https://github.com/ekohl))
- Be more aggressive about picking a connection [\#47](https://github.com/voxpupuli/beaker-docker/pull/47) ([trevor-vaughan](https://github.com/trevor-vaughan))

## [0.8.4](https://github.com/voxpupuli/beaker-docker/tree/0.8.4) (2021-03-15)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.8.3...0.8.4)

**Fixed bugs:**

- Force Container Removal [\#45](https://github.com/voxpupuli/beaker-docker/pull/45) ([trevor-vaughan](https://github.com/trevor-vaughan))

**Closed issues:**

- Wrong SSH port getting used [\#43](https://github.com/voxpupuli/beaker-docker/issues/43)
- Beaker complains about host unreachable - Ubuntu 18 and 20 [\#39](https://github.com/voxpupuli/beaker-docker/issues/39)

**Merged pull requests:**

- Fix docker usage to use correct port and IP address on local docker [\#44](https://github.com/voxpupuli/beaker-docker/pull/44) ([treydock](https://github.com/treydock))
- Update to Check Rootless [\#41](https://github.com/voxpupuli/beaker-docker/pull/41) ([trevor-vaughan](https://github.com/trevor-vaughan))
- Change from my personal fork to docker-api 2.1+ [\#40](https://github.com/voxpupuli/beaker-docker/pull/40) ([trevor-vaughan](https://github.com/trevor-vaughan))

## [0.8.3](https://github.com/voxpupuli/beaker-docker/tree/0.8.3) (2021-02-28)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.8.2...0.8.3)

**Merged pull requests:**

- Cleanup docs and gemspec [\#37](https://github.com/voxpupuli/beaker-docker/pull/37) ([genebean](https://github.com/genebean))

## [0.8.2](https://github.com/voxpupuli/beaker-docker/tree/0.8.2) (2021-02-28)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.8.1...0.8.2)

**Merged pull requests:**

- Deconflict Privileged and CAPs [\#34](https://github.com/voxpupuli/beaker-docker/pull/34) ([trevor-vaughan](https://github.com/trevor-vaughan))

## [0.8.1](https://github.com/voxpupuli/beaker-docker/tree/0.8.1) (2021-02-28)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.8.0...0.8.1)

**Merged pull requests:**

- Fix docker support and update github actions [\#32](https://github.com/voxpupuli/beaker-docker/pull/32) ([trevor-vaughan](https://github.com/trevor-vaughan))
- Add GH Action for releases [\#31](https://github.com/voxpupuli/beaker-docker/pull/31) ([genebean](https://github.com/genebean))

## [0.8.0](https://github.com/voxpupuli/beaker-docker/tree/0.8.0) (2021-02-26)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.7.1...0.8.0)

**Merged pull requests:**

- Move testing to GH Actions [\#30](https://github.com/voxpupuli/beaker-docker/pull/30) ([genebean](https://github.com/genebean))
- Add Podman Support [\#29](https://github.com/voxpupuli/beaker-docker/pull/29) ([trevor-vaughan](https://github.com/trevor-vaughan))

## [0.7.1](https://github.com/voxpupuli/beaker-docker/tree/0.7.1) (2020-09-11)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.7.0...0.7.1)

**Merged pull requests:**

- Fix: docker-api gem dependency [\#26](https://github.com/voxpupuli/beaker-docker/pull/26) ([msalway](https://github.com/msalway))
- Add Dependabot to keep thins up to date [\#23](https://github.com/voxpupuli/beaker-docker/pull/23) ([genebean](https://github.com/genebean))

## [0.7.0](https://github.com/voxpupuli/beaker-docker/tree/0.7.0) (2020-01-23)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.6.0...0.7.0)

**Merged pull requests:**

- Fix: Too many authentication failures [\#21](https://github.com/voxpupuli/beaker-docker/pull/21) ([b4ldr](https://github.com/b4ldr))
- \(MAINT\) add release section to README [\#20](https://github.com/voxpupuli/beaker-docker/pull/20) ([kevpl](https://github.com/kevpl))

## [0.6.0](https://github.com/voxpupuli/beaker-docker/tree/0.6.0) (2019-11-12)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.5.4...0.6.0)

**Merged pull requests:**

- \(BKR-1613\) add CentOS8 support [\#19](https://github.com/voxpupuli/beaker-docker/pull/19) ([ciprianbadescu](https://github.com/ciprianbadescu))

## [0.5.4](https://github.com/voxpupuli/beaker-docker/tree/0.5.4) (2019-07-15)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.5.3...0.5.4)

**Merged pull requests:**

- \(maint\) A number of fixes for rerunning tests on docker containers [\#18](https://github.com/voxpupuli/beaker-docker/pull/18) ([underscorgan](https://github.com/underscorgan))

## [0.5.3](https://github.com/voxpupuli/beaker-docker/tree/0.5.3) (2019-05-06)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.5.2...0.5.3)

**Merged pull requests:**

- BKR-1586 - allow an 'as-is' container to be used rather than rebuilding every time [\#17](https://github.com/voxpupuli/beaker-docker/pull/17) ([oldNoakes](https://github.com/oldNoakes))

## [0.5.2](https://github.com/voxpupuli/beaker-docker/tree/0.5.2) (2019-02-11)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.5.1...0.5.2)

**Merged pull requests:**

- Allow users with large keyrings to run test [\#16](https://github.com/voxpupuli/beaker-docker/pull/16) ([trevor-vaughan](https://github.com/trevor-vaughan))

## [0.5.1](https://github.com/voxpupuli/beaker-docker/tree/0.5.1) (2018-11-29)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.5.0...0.5.1)

**Merged pull requests:**

- \(SERVER-2380\) add image tagging ability [\#14](https://github.com/voxpupuli/beaker-docker/pull/14) ([tvpartytonight](https://github.com/tvpartytonight))

## [0.5.0](https://github.com/voxpupuli/beaker-docker/tree/0.5.0) (2018-11-19)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.4.0...0.5.0)

**Merged pull requests:**

- \(BKR-1551\) Updates for Beaker 4 [\#13](https://github.com/voxpupuli/beaker-docker/pull/13) ([caseywilliams](https://github.com/caseywilliams))

## [0.4.0](https://github.com/voxpupuli/beaker-docker/tree/0.4.0) (2018-10-26)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.3.3...0.4.0)

**Merged pull requests:**

- \(PUP-9212\) Allow for building containers with context [\#12](https://github.com/voxpupuli/beaker-docker/pull/12) ([tvpartytonight](https://github.com/tvpartytonight))
- \(PUP-9212\) Allow for image entry point CMDs [\#11](https://github.com/voxpupuli/beaker-docker/pull/11) ([tvpartytonight](https://github.com/tvpartytonight))
- \(BKR-1509\) Hypervisor usage instructions for Beaker 4..0 [\#9](https://github.com/voxpupuli/beaker-docker/pull/9) ([Dakta](https://github.com/Dakta))

## [0.3.3](https://github.com/voxpupuli/beaker-docker/tree/0.3.3) (2018-04-16)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.3.2...0.3.3)

**Merged pull requests:**

- \(BKR-305\) Support custom docker options [\#8](https://github.com/voxpupuli/beaker-docker/pull/8) ([double16](https://github.com/double16))

## [0.3.2](https://github.com/voxpupuli/beaker-docker/tree/0.3.2) (2018-04-09)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.3.1...0.3.2)

**Merged pull requests:**

- \(MAINT\) fix paths when using DOCKER\_TOOLBOX on windows [\#7](https://github.com/voxpupuli/beaker-docker/pull/7) ([tabakhase](https://github.com/tabakhase))

## [0.3.1](https://github.com/voxpupuli/beaker-docker/tree/0.3.1) (2018-02-22)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.3.0...0.3.1)

**Merged pull requests:**

- Fix Archlinux support [\#6](https://github.com/voxpupuli/beaker-docker/pull/6) ([bastelfreak](https://github.com/bastelfreak))

## [0.3.0](https://github.com/voxpupuli/beaker-docker/tree/0.3.0) (2018-01-29)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.2.0...0.3.0)

**Merged pull requests:**

- \[BKR-1021\] Archlinux support [\#5](https://github.com/voxpupuli/beaker-docker/pull/5) ([jantman](https://github.com/jantman))
- Don't set container name to node hostname [\#4](https://github.com/voxpupuli/beaker-docker/pull/4) ([jovrum](https://github.com/jovrum))

## [0.2.0](https://github.com/voxpupuli/beaker-docker/tree/0.2.0) (2017-08-11)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/0.1.0...0.2.0)

**Merged pull requests:**

- \(BKR-1189\) Fix port mapping [\#3](https://github.com/voxpupuli/beaker-docker/pull/3) ([rishijavia](https://github.com/rishijavia))
- Make beaker-docker work in a docker container [\#2](https://github.com/voxpupuli/beaker-docker/pull/2) ([hedinasr](https://github.com/hedinasr))

## [0.1.0](https://github.com/voxpupuli/beaker-docker/tree/0.1.0) (2017-08-01)

[Full Changelog](https://github.com/voxpupuli/beaker-docker/compare/7f6a78541f30385016478e810ecb0c14f3936e20...0.1.0)

**Merged pull requests:**

- \(MAINT\) Add docker-api dependency as its removed from beaker [\#1](https://github.com/voxpupuli/beaker-docker/pull/1) ([rishijavia](https://github.com/rishijavia))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
