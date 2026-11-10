# Who Taunted? Update Checklist

## Database Files

- [ ] Create/update `TauntsList_[Version].lua` with version-specific taunt abilities
- [ ] Create/update `PvPZoneIDs_[Version].lua` with version-specific PvP zones
- [ ] Create `load-db-[version].xml` to load the database files

## TOC File

- [ ] Create `WhoTaunted_[Version].toc` with correct interface number
- [ ] Update interface version (format: XXYYZZ for X.Y.Z)
- [ ] Reference correct database loader (`Data\load-db-[version].xml`)
- [ ] **Note**: Check if any TOC files need to remain on specific interface versions (e.g., Cata on `40402`)

## Documentation

- [ ] Update README.md supported taunts table
- [ ] Update README-CF.md supported taunts table
- [ ] Move previous current version to Legacy table if needed
- [ ] Update version references in documentation
- [ ] Update CHANGELOG.md with version compatibility (replace it with this version's entry only, and add the same entry to the top of `CHANGELOG-HISTORY.md`)
- [ ] Check TOC format reference: <https://warcraft.wiki.gg/wiki/TOC_format>

## GitHub Workflow

- [ ] Update `.github/toc-updater/supported_expansions.json`:
  - [ ] Add/rename the expansion entry (the TOC filename suffix decides which game version it gets)
  - [ ] Point `toc` to the new TOC file
  - [ ] Update `blizztrack` product for the PR review links
  - [ ] Review `static_interfaces` (interfaces always kept in a TOC)
- [ ] Verify workflow triggers and schedule in `.github/workflows/toc-updater.yml` (currently runs hourly)
- [ ] Check TOC format reference: <https://warcraft.wiki.gg/wiki/TOC_format>

## Testing & Validation

- [ ] Verify all taunt spell IDs are correct for the version
- [ ] Test PvP zone detection works properly
- [ ] Confirm TOC loads without errors
- [ ] Validate database files load correctly

## Release Process

- [ ] Create version tag/release
- [ ] Verify packages deploy to CurseForge/WoWInterface/Wago
- [ ] Test in-game functionality
