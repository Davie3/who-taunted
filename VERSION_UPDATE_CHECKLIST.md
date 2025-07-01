# WoW Addon Version Update Checklist

## Database Files

- [ ] Create/update `TauntsList_[Version].lua` with version-specific taunt abilities
- [ ] Create/update `PvPZoneIDs_[Version].lua` with version-specific PvP zones
- [ ] Create `load-db-[version].xml` to load the database files

## TOC File

- [ ] Create `WhoTaunted_[Version].toc` with correct interface number
- [ ] Update interface version (format: XXYYZZ for X.Y.Z)
- [ ] Reference correct database loader (`Data\load-db-[version].xml`)

## Documentation

- [ ] Update README.md supported taunts table
- [ ] Move previous current version to Legacy table if needed
- [ ] Update version references in documentation

## GitHub Workflow

- [ ] Update `.github/workflows/toc-updater.yml`:
- [ ] Update `CLASSIC_NAME` environment variable
- [ ] Update `CLASSIC_TOC` to point to new TOC file

## Testing & Validation

- [ ] Verify all taunt spell IDs are correct for the version
- [ ] Test PvP zone detection works properly
- [ ] Confirm TOC loads without errors
- [ ] Validate database files load correctly

## Release Process

- [ ] Update CHANGELOG.md with version compatibility
- [ ] Create version tag/release
- [ ] Verify packages deploy to CurseForge/WoWInterface/Wago
- [ ] Test in-game functionality
