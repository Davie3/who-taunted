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
- [ ] Update CHANGELOG.md with version compatibility

## GitHub Workflow

- [ ] Update `.github/workflows/toc-updater.yml`:
  - [ ] Update `MAINLINE_NAME` environment variable (currently: "The War Within")
  - [ ] Update `CLASSIC_NAME` environment variable (currently: "Mists of Pandaria")
  - [ ] Update `RETAIL_TOC` to point to new mainline TOC file (currently: "WhoTaunted.toc")
  - [ ] Update `CLASSIC_TOC` to point to new classic TOC file (currently: "WhoTaunted_MoP.toc")
  - [ ] Verify workflow triggers and schedule (currently runs hourly)
  - [ ] Check API endpoints are current:
    - [ ] Blizztrack mainline API: <https://blizztrack.com/api/manifest/wow/versions>
    - [ ] Blizztrack classic API: <https://blizztrack.com/api/manifest/wow_classic/versions>

## Testing & Validation

- [ ] Verify all taunt spell IDs are correct for the version
- [ ] Test PvP zone detection works properly
- [ ] Confirm TOC loads without errors
- [ ] Validate database files load correctly

## Release Process

- [ ] Create version tag/release
- [ ] Verify packages deploy to CurseForge/WoWInterface/Wago
- [ ] Test in-game functionality
