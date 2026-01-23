# Who Taunted? Expansion Archive Checklist

This checklist documents the process for archiving expansion-specific data when a new expansion releases.

## When to Archive

Archive the current expansion's data when:
- A new WoW expansion is about to launch
- The current expansion becomes legacy/unsupported
- Major taunt ability changes warrant preserving the old data structure

## Archive Process

### Database Files

- [ ] Create `TauntsList_[Expansion].lua` by copying current `TauntsList.lua`
- [ ] Create `PvPZoneIDs_[Expansion].lua` by copying current `PvPZoneIDs.lua`
- [ ] Verify archived files contain the correct expansion-specific data
- [ ] Leave main `TauntsList.lua` and `PvPZoneIDs.lua` unchanged if no new version will be created

**Naming Convention**: Use expansion abbreviations (e.g., `_TWW`, `_Dragonflight`, `_Shadowlands`)

### Commands for Archiving

```bash
# Archive TauntsList
cp "Data/DB/TauntsList.lua" "Data/DB/TauntsList_[Expansion].lua"

# Archive PvPZoneIDs
cp "Data/DB/PvPZoneIDs.lua" "Data/DB/PvPZoneIDs_[Expansion].lua"
```

### Documentation Updates

- [ ] Update README.md if expansion moves to legacy/archive status
- [ ] Update README-CF.md if expansion moves to legacy/archive status
- [ ] Update supported versions tables to reflect archive status

## Verification

- [ ] Verify archived files exist in `Data/DB/` directory
- [ ] Confirm file sizes are non-zero
- [ ] Check git status shows new files staged
- [ ] Review diff to ensure correct content was copied

```bash
# Verify files were created
ls -la Data/DB/*_[Expansion].lua

# Check git status
git status
```
