# Changelog for Cldr v1.0.0-rc.2

This is the changelog for Cldr v1.0.0-rc.2 released on November 22nd, 2017.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

This version signals API stability and the first release candidate.

## Bug Fixes (including for 1.0.0-rc.1)

* Fixed a bug in `Cldr.Map.underscore_keys/1` that wasn't correctly accounting for repeated "-"'s

* Fixed currency definition in `Cldr.Config.territory_info/1` so that a list is returned instead of a map so that the record of the same currency being used at different times is preserved.  The canonical example if Palestine (territory code :PS) which has used the Jordanian Dinar twice during its history.

* Restored the correct api for `Cldr.Map.deep_map/2` and added `Cldr.Map.deep_map/3`

* Fixed a bug in `Cldr.Consolidate` that crept in during the replacement of `Flow` with `Task.async_stream`

## Enhancements

* Removed obsolete guides since they are now merged into the readme files of each dependent package
