WhoTaunted = LibStub("AceAddon-3.0"):NewAddon("WhoTaunted", "AceEvent-3.0", "AceConsole-3.0")
local AceConfig = LibStub("AceConfigDialog-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("WhoTaunted");
local BabbleClass = LibStub("LibBabble-Class-3.0"):GetLookupTable();

local KDOEN = false;

local BgDisable = false;
local inCombat = false;
WhoTaunted_TauntData = {};
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
	},
	AOE = {
		--Warrior
		1161, --Challenging Shout
		
		--Paladin
		31789, --Righteous Defense
		
		--Druid
		5209, --Challenging Roar
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
				hour, minute, seconds = tonumber(date("%H")), tonumber(date("%M")), tonumber(date("%S"));
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
				table.insert(WhoTaunted_TauntData,{
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
					hour, minute, seconds = tonumber(date("%H")), tonumber(date("%M")), tonumber(date("%S"));
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
					table.insert(WhoTaunted_TauntData,{
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
						hour, minute, seconds = tonumber(date("%H")), tonumber(date("%M")), tonumber(date("%S"));
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
						table.insert(WhoTaunted_TauntData,{
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
									WhoTaunted:OutPut("<WhoTaunted> "..arg3.."'s "..L["taunt"].." "..link.." "..L["against"].." "..arg6..string.upper(L["Failed:"]).." "..arg11.."!", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput));
								else
									WhoTaunted:OutPut("<WhoTaunted> "..arg3.."'s "..L["taunt"].." "..arg9.." "..L["against"].." "..arg6..string.upper(L["Failed:"]).." "..arg11.."!", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput));
								end
							end
						end
					end
				end
			end
		elseif (arg1 == "UNIT_DIED") then
			if (UnitClassification(arg6) == "worldboss") then
				if (KDOEN == false) then
					WhoTaunted:Print(arg6.." died and I detected it correctly :O!");
					KDOEN = true;
				end
				WhoTaunted:ClearTauntData();
			end
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
	--WhoTaunted_TauntData = table.wipe(WhoTaunted_TauntData);
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
	for k, v in pairs(WhoTaunted_TauntData) do
		if (WhoTaunted_TauntData[k].Arg3 == Name) and (WhoTaunted_TauntData[k].Time == Time) then
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
		if (localizedclass) then
			if (string.lower(localizedclass) == string.lower(BabbleClass["DEATHKNIGHT"])) then
				ClassColor = "00C41F3B";
			elseif (string.lower(localizedclass) == string.lower(BabbleClass["DRUID"])) then
				ClassColor = "00FF7D0A";
			elseif (string.lower(localizedclass) == string.lower(BabbleClass["HUNTER"])) then
				ClassColor = "00ABD473";
			elseif (string.lower(localizedclass) == string.lower(BabbleClass["MAGE"])) then
				ClassColor = "0069CCF0";
			elseif (string.lower(localizedclass) == string.lower(BabbleClass["PALADIN"])) then
				ClassColor = "00F58CBA";
			elseif (string.lower(localizedclass) == string.lower(BabbleClass["PRIEST"])) then
				ClassColor = "00FFFFFF";
			elseif (string.lower(localizedclass) == string.lower(BabbleClass["ROGUE"])) then
				ClassColor = "00FFF569";
			elseif (string.lower(localizedclass) == string.lower(BabbleClass["SHAMAN"])) then
				ClassColor = "002459FF";
			elseif (string.lower(localizedclass) == string.lower(BabbleClass["WARLOCK"])) then
				ClassColor = "009482CA";
			elseif (string.lower(localizedclass) == string.lower(BabbleClass["WARRIOR"])) then
				ClassColor = "00C79C6E";
			end
		end
	end
	
	if (ClassColor == nil) then		
		ClassColor = "00FFFFFF";
	end
	
	return ClassColor;
end

function WhoTaunted:OutPut(msg, output)
	if (string.lower(output) == "raid") then
		if (UnitInRaid("player")) then
			SendChatMessage(msg, "RAID");
		end
	elseif (string.lower(output) == "raidwarning") then
		if (UnitInRaid("player")) then
			if (IsRaidLeader()) or (IsRaidOfficer()) then	
				SendChatMessage(msg, "RAID_WARNING");
			else
				SendChatMessage(msg, "RAID");
			end
		end
	elseif (string.lower(output) == "party") then
		if (UnitInParty("player")) then
			SendChatMessage(msg, "PARTY");
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