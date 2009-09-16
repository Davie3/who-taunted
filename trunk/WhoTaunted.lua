WhoTaunted = LibStub("AceAddon-3.0"):NewAddon("WhoTaunted", "AceEvent-3.0", "AceConsole-3.0")
local AceConfig = LibStub("AceConfigDialog-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("WhoTaunted");
local BabbleClass = LibStub("LibBabble-Class-3.0"):GetLookupTable();

local KDOEN = false;

local BgDisable = false;
local inCombat = false;
local TauntData = {};
local TauntsList = {
	SingleTarget = {
		--Warrior
		355, --Taunt
		694, --Mocking Blow
		
		--Death Knight
		49576, --Death Grip
		56222, --Dark Command
		
		--Paladin
		62124, --Hand of Reckoning
		
		--Druid
		6795, --Growl
		
		--Hunter
		20736, --Distracting Shot
	},
	AOE = {
		--Warrior
		1161, --Challenging Shout
		
		--Paladin
		31789, --Righteous Defense
		
		--Druid
		5209, --Challenging Roar
		
		--Warlock
		59671, --Challenging Howl
	},
};

function WhoTaunted:OnInitialize()
	WhoTaunted:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CombatLog")
	WhoTaunted:RegisterEvent("PLAYER_REGEN_ENABLED", "CombatEnd")
	WhoTaunted:RegisterEvent("PLAYER_REGEN_DISABLED", "CombatBegin")
	
	WhoTaunted:RegisterChatCommand("whotaunted", "ChatCommand")
	WhoTaunted:RegisterChatCommand("wtaunted", "ChatCommand")
	WhoTaunted:RegisterChatCommand("wtaunt", "ChatCommand")
	
	WhoTaunted.db = LibStub("AceDB-3.0"):New("WhoTauntedDB", WhoTaunted.defaults, "profile");
	LibStub("AceConfig-3.0"):RegisterOptionsTable("WhoTaunted", WhoTaunted.options)
	AceConfig:AddToBlizOptions("WhoTaunted", L["Who Taunted?"].." v"..GetAddOnMetadata("WhoTaunted", "Version"));
end

function WhoTaunted:ChatCommand()
	InterfaceOptionsFrame_OpenToCategory(L["Who Taunted?"].." v"..GetAddOnMetadata("WhoTaunted", "Version"));
end

function WhoTaunted:CombatLog(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = select(1, ...);
	if (UnitInParty("player")) or (UnitInRaid("player")) and (WhoTaunted.db.profile.Disabled == false) and (BgDisable == false) then
		if (arg1 == "SPELL_AURA_APPLIED") then
			local IsTaunt, TauntType, SpellID = WhoTaunted:IsTaunt(arg9);
			if (IsTaunt == true) and (UnitIsPlayer(arg3)) and (TauntType == "SingleTarget") then
				local hour, minute, seconds = tonumber(date("%H")), tonumber(date("%M")), tonumber(date("%S"));
				local time;
				if (minute < 10) then
					time = hour..":0"..minute;
				else
					time = hour..":"..minute;
				end
				if (seconds < 10) then
					time = time..":0"..seconds;
				else
					time = time..":"..seconds;
				end
				table.insert(TauntData,{
										Taunttype = TauntType,
										Arg1 = arg1,
										Arg2 = arg2,
										Arg3 = arg3,
										Arg4 = arg4,
										Arg5 = arg5,
										Arg6 = arg6,
										Arg7 = arg7,
										Arg8 = arg8,
										Arg9 = arg9,
										Arg10 = arg10,
										Arg11 = arg11,
										Time = time,
									})
			end
			if (IsTaunt == true) and (TauntType == "SingleTarget") and (UnitIsPlayer(arg3)) then
				if (WhoTaunted:CheckIfRecentlyTaunted(arg3, time) == false) then
					local link = GetSpellLink(SpellID);
					if (WhoTaunted.db.profile.AnounceTaunts == true) then
						if (WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceTauntsOutput) == "print") then
							if (link) then
								WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."|r "..L["taunts"].." "..arg6.." "..L["using"].." "..link..".", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceTauntsOutput));
							else
								WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."|r "..L["taunts"].." "..arg6.." "..L["using"].." "..arg9..".", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceTauntsOutput));
							end
						else
							if (link) then
								WhoTaunted:OutPut("<WhoTaunted> "..arg3.." "..L["taunts"].." "..arg6.." "..L["using"].." "..link..".", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceTauntsOutput));
							else
								WhoTaunted:OutPut("<WhoTaunted> "..arg3.." "..L["taunts"].." "..arg6.." "..L["using"].." "..arg9..".", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceTauntsOutput));
							end
						end
					end
				end			
			end
		elseif (arg1 == "SPELL_CAST_SUCCESS") then
			local IsTaunt, TauntType, SpellID = WhoTaunted:IsTaunt(arg9);
			if (IsTaunt == true) and (TauntType == "AOE") and (UnitIsPlayer(arg3)) then
					local hour, minute, seconds = tonumber(date("%H")), tonumber(date("%M")), tonumber(date("%S"));
					local time;
					if (minute < 10) then
						time = hour..":0"..minute;
					else
						time = hour..":"..minute;
					end
					if (seconds < 10) then
						time = time..":0"..seconds;
					else
						time = time..":"..seconds;
					end
					table.insert(TauntData,{
											Taunttype = TauntType,
											Arg1 = arg1,
											Arg2 = arg2,
											Arg3 = arg3,
											Arg4 = arg4,
											Arg5 = arg5,
											Arg6 = arg6,
											Arg7 = arg7,
											Arg8 = arg8,
											Arg9 = arg9,
											Arg10 = arg10,
											Arg11 = arg11,
											Time = time,
										})
				local link = GetSpellLink(SpellID);
				if (WhoTaunted.db.profile.AnounceAOETaunts == true) then
					if (WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceAOETauntsOutput) == "print") then
						if (link) then
							WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."|r "..L["AOE taunted using"].." "..link..".", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceAOETauntsOutput));
						else
							WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."|r "..L["AOE taunted using"].." "..arg9..".", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceAOETauntsOutput));
						end
					else
						if (link) then
							WhoTaunted:OutPut("<WhoTaunted> "..arg3.." "..L["AOE taunted using"].." "..link..".", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceAOETauntsOutput));
						else
							WhoTaunted:OutPut("<WhoTaunted> "..arg3.." "..L["AOE taunted using"].." "..arg9..".", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceAOETauntsOutput));
						end
					end
				end
			end
		elseif (arg1 == "SPELL_MISSED") and (WhoTaunted.db.profile.AnounceFails == true) then		
			local IsTaunt, TauntType, SpellID = WhoTaunted:IsTaunt(arg9);			
			--Death Grip is different in that it kind of has 2 effects. It taunts then attempts pull the mob to you.
			--This causes 2 different events and with most mobs immuned to Death Grip's pull effect but not its taunt 
			--WhoTaunted starts to get spammy with successful Death Grip taunts then immuned ones. So I hacky hackyed!
			if not (SpellID == 49576 and arg11 == string.upper(L["Immune"])) and (IsTaunt == true) and (TauntType == "SingleTarget") then
				if (IsTaunt == true) and (UnitIsPlayer(arg3)) and (TauntType == "SingleTarget") then
						local hour, minute, seconds = tonumber(date("%H")), tonumber(date("%M")), tonumber(date("%S"));
						local time;
						if (minute < 10) then
							time = hour..":0"..minute;
						else
							time = hour..":"..minute;
						end
						if (seconds < 10) then
							time = time..":0"..seconds;
						else
							time = time..":"..seconds;
						end
						table.insert(TauntData,{
												Taunttype = TauntType,
												Arg1 = arg1,
												Arg2 = arg2,
												Arg3 = arg3,
												Arg4 = arg4,
												Arg5 = arg5,
												Arg6 = arg6,
												Arg7 = arg7,
												Arg8 = arg8,
												Arg9 = arg9,
												Arg10 = arg10,
												Arg11 = arg11,
												Time = time,
											})
				end
				if (IsTaunt == true) and (TauntType == "SingleTarget") and (UnitIsPlayer(arg3)) then
					if (WhoTaunted:CheckIfRecentlyTaunted(arg3, time) == false) then
						local link = GetSpellLink(SpellID);
						if (WhoTaunted.db.profile.AnounceFails == true) then
							if (WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput) == "print") then
								if (link) then
									WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."'s|r "..L["taunt"].." "..link.." "..L["against"].." "..arg6.." |c00FF0000"..string.upper(L["Failed:"]).." "..arg11.."|r!", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput));
								else
									WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."'s|r "..L["taunt"].." "..arg9.." "..L["against"].." "..arg6.." |c00FF0000"..string.upper(L["Failed:"]).." "..arg11.."|r!", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput));
								end
							else
								if (link) then
									WhoTaunted:OutPut("<WhoTaunted> "..arg3.."'s "..L["taunt"].." "..link.." "..L["against"].." "..arg6.." "..string.upper(L["Failed:"]).." "..arg11.."!", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput));
								else
									WhoTaunted:OutPut("<WhoTaunted> "..arg3.."'s "..L["taunt"].." "..arg9.." "..L["against"].." "..arg6.." "..string.upper(L["Failed:"]).." "..arg11.."!", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput));
								end
							end
						end
					end
				end
			end
		--elseif (arg1 == "UNIT_DIED") then
			--WhoTaunted:Print(arg6..": "..UnitClassification(arg6));
			--WhoTaunted:Print(arg1);
			--WhoTaunted:Print(arg2);
			--WhoTaunted:Print(arg3);
			--WhoTaunted:Print(arg4);
			--WhoTaunted:Print(arg5);
			--WhoTaunted:Print(arg6);
			--WhoTaunted:Print(arg7);
			--WhoTaunted:Print(arg8);
			--WhoTaunted:Print(arg9);
			--WhoTaunted:Print(arg10);
			--WhoTaunted:Print(arg11);			
			--if (UnitClassification(arg6) == "worldboss") then
				--if (KDOEN == false) then
					--WhoTaunted:Print(arg6.." died and I detected it correctly :O!");
					--KDOEN = true;
				--end
				--WhoTaunted:ClearTauntData();
			--end
		end
	end
end

function WhoTaunted:CombatBegin()
	inCombat = true;
	WhoTaunted:ClearTauntData();
end

function WhoTaunted:CombatEnd()
	inCombat = false;
	WhoTaunted:ClearTauntData();
end

function WhoTaunted:EnteringWorldOnEvent()
	local inInstance, instanceType = IsInInstance()
	if (inInstance == 1) and (instanceType == "pvp") and (WhoTaunted.db.profile.DisableInBG == true) then
		BgDisable = true;
	else
		BgDisable = false;
	end
end

function WhoTaunted:ClearTauntData()
	TauntData = table.wipe(TauntData);
end

function WhoTaunted:IsTaunt(SpellName)
	local IsTaunt, TauntType, SpellID;
	for k, v in pairs(TauntsList.SingleTarget) do
		if (GetSpellInfo(v) == SpellName) then
			IsTaunt, TauntType, SpellID = true, "SingleTarget", v;
			break;
		end
	end
	for k, v in pairs(TauntsList.AOE) do
		if (GetSpellInfo(v) == SpellName) then
			IsTaunt, TauntType, SpellID = true, "AOE", v;
			break;
		end
	end
	return IsTaunt, TauntType, SpellID;
end

function WhoTaunted:CheckIfRecentlyTaunted(Name, Time)
	local RecentlyTaunted = false;
	for k, v in pairs(TauntData) do
		if (TauntData[k].Arg3 == Name) and (TauntData[k].Time == Time) then
			RecentlyTaunted = true;
			break;
		end
	end
	return RecentlyTaunted;
end

function WhoTaunted:GetClassColor(Unit)
	local localizedclass = nil;
	local ClassColor = nil;
	if (Unit) then
		localizedclass = UnitClass(Unit);
		if (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["DEATHKNIGHT"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["DEATHKNIGHT"])) then
			ClassColor = "00C41F3B";
		elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["DRUID"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["DRUID"])) then
			ClassColor = "00FF7D0A";
		elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["HUNTER"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["HUNTER"])) then
			ClassColor = "00ABD473";
		elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["MAGE"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["MAGE"])) then
			ClassColor = "0069CCF0";
		elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["PALADIN"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["PALADIN"])) then
			ClassColor = "00F58CBA";
		elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["PRIEST"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["PRIEST"])) then
			ClassColor = "00FFFFFF";
		elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["ROGUE"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["ROGUE"])) then
			ClassColor = "00FFF569";
		elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["SHAMAN"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["SHAMAN"])) then
			ClassColor = "002459FF";
		elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["WARLOCK"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["WARLOCK"])) then
			ClassColor = "009482CA";
		elseif (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_MALE["WARRIOR"])) or (string.lower(localizedclass) == string.lower(LOCALIZED_CLASS_NAMES_FEMALE["WARRIOR"])) then
			ClassColor = "00C79C6E";
		end
	end
	
	if (ClassColor == nil) then		
		ClassColor = "00FFFFFF";
	end
	
	return ClassColor;
end

function WhoTaunted:OutPut(msg, output)
	if (string.lower(output) == "raid") then
		local isInRaid = UnitInRaid("player");
		if (isInRaid) then
			if (isInRaid >= 1) then
				SendChatMessage(msg, "RAID");
			end
		end
	elseif (string.lower(output) == "raidwarning") or (string.lower(output) == "rw") then
		local isInRaid = UnitInRaid("player");
		if (isInRaid) then
			if (isInRaid >= 1) and ((IsRaidLeader()) or (IsRaidOfficer())) then	
				SendChatMessage(msg, "RAID_WARNING");
			else
				SendChatMessage(msg, "RAID");
			end
		end
	elseif (string.lower(output) == "party") then
		local isInParty = UnitInParty("player");
		if (isInParty) then
			if (isInParty >= 1) then
				SendChatMessage(msg, "PARTY");
			end
		end
	elseif (string.lower(output) == "say") then
		SendChatMessage(msg, "SAY");
	elseif (string.lower(output) == "yell") then
		SendChatMessage(msg, "YELL");
	elseif (string.lower(output) == "print") then
		WhoTaunted:Print(msg);
	end
end

function WhoTaunted:GetOutPutType(OptionsValue)
	local Output;
	if (OptionsValue == 1) then
		Output = "print";
	elseif (OptionsValue == 2) then
		Output = "party";
	elseif (OptionsValue == 3) then
		Output = "raid";
	elseif (OptionsValue == 4) then
		Output = "raidwarning";
	elseif (OptionsValue == 5) then
		Output = "say";
	elseif (OptionsValue == 6) then
		Output = "yell";
	end
	return Output;
end