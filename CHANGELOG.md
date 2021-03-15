# Change Log

All notable changes to this project will be documented in this file.

The format is based on
[Keep a Changelog](http://keepachangelog.com)
& makes a strong effort to adhere to
[Semantic Versioning](http://semver.org).

Tracking in this Changelog began for this project in version 0.8.4.
If you're looking for changes from before this, refer to the project's
git logs & PR history.

The headers used in [Keep a Changelog](http://keepachangelog.com) are:

- Added - for new features.
- Changed - for changes in existing functionality.
- Deprecated - for soon-to-be removed features.
- Removed - for now removed features.
- Fixed - for any bug fixes.
- Security - in case of vulnerabilities.

# [0.8.4](https://github.com/voxpupuli/beaker/compare/0.8.3...0.8.4) - 03-15-2021

### Fixed

- Use the `docker-api` function `::Docker.rootless?` to see if the container
  ecosystem is running in `rootless` mode. This reduces false positive
  failures across the board.
- Ensure that the correct port and IP is used for local docker connections
- Added the `force` option to ensure container removal on error
