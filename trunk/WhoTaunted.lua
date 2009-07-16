WhoTaunted = LibStub("AceAddon-3.0"):NewAddon("WhoTaunted", "AceEvent-3.0", "AceConsole-3.0")
local AceConfig = LibStub("AceConfigDialog-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("WhoTaunted");
local BabbleClass = LibStub("LibBabble-Class-3.0"):GetLookupTable();

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
	AceConfig:AddToBlizOptions("WhoTaunted", "Who Taunted?");
end

function WhoTaunted:ChatCommand()
	InterfaceOptionsFrame_OpenToCategory("Who Taunted?");
end

function WhoTaunted:CombatLog(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = select(1, ...);
	if (UnitInParty("player")) or (UnitInRaid("player")) and (WhoTaunted.db.profile.Disabled == false) then
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
				if (WhoTaunted:CheckIfRecentlyTaunted(arg3, hour, seconds, minute) == false) then
					local link = GetSpellLink(SpellID);
					if (link) then
						WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."|r"..L[" taunts "]..arg6..L[" using "]..link..".", "print");
					else
						WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."|r"..L[" taunts "]..arg6..L[" using "]..arg9..".", "print");
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
				if (WhoTaunted:CheckIfRecentlyTaunted(arg3, hour, seconds, minute) == false) then
					local link = GetSpellLink(SpellID);
					if (link) then
						WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."|r"..L[" AOE taunted using "]..link..".", "print");
					else
						WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."|r"..L[" AOE taunted using "]..arg9..".", "print");
					end
				end
			end
		elseif (arg1 == "SPELL_MISSED") and (WhoTaunted.db.profile.AnounceFails == true) then		
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
				if (WhoTaunted:CheckIfRecentlyTaunted(arg3, hour, seconds, minute) == false) then
					local link = GetSpellLink(SpellID);
					if (WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput) == "print") then
						if (link) then
							WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."'s".."|r"..L[" taunt "]..link..L[" against "]..arg6.." |c00FF0000"..L["FAILED: "]..arg11.."|r!", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput));
						else
							WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."'s".."|r"..L[" taunt "]..arg9..L[" against "]..arg6.." |c00FF0000"..L["FAILED: "]..arg11.."|r!", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput));
						end
					else
						if (link) then
							WhoTaunted:OutPut(arg3.."'s"..L[" taunt "]..link..L[" against "]..arg6..L["FAILED: "]..arg11.."!", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput));
						else
							WhoTaunted:OutPut(arg3.."'s"..L[" taunt "]..arg9..L[" against "]..arg6..L["FAILED: "]..arg11.."!", WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput));
						end
					end
				end
			--elseif (IsTaunt == true) and (TauntType == "AOE") and (UnitIsPlayer(arg3)) then
				--if (WhoTaunted:CheckIfRecentlyTaunted(arg3, hour, seconds, minute) == false) then
					--local link = GetSpellLink(SpellID);
					--if (link) then
						--WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."'s|r AOE taunt "..link.." |c00FF0000FAILED: "..arg11.."|r!", "print");
					--else
						--WhoTaunted:OutPut("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."'s|r AOE taunt "..arg9.." |c00FF0000FAILED: "..arg11.."|r!", "print");
					--end
				--end
			end
		elseif (arg1 == "UNIT_DIED") then
			WhoTaunted:ClearTauntData();
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

function WhoTaunted:ClearTauntData()
	WhoTaunted_TauntData = table.wipe(WhoTaunted_TauntData);
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

function WhoTaunted:CheckIfRecentlyTaunted(Name, Hour, Minute, Seconds)
	local RecentlyTaunted = false;
	for k, v in pairs(WhoTaunted_TauntData) do
		if (WhoTaunted_TauntData[k].Arg3 == Name) and (WhoTaunted_TauntData[k].Hour == Hour) and (WhoTaunted_TauntData[k].Seconds == Seconds) and (WhoTaunted_TauntData[k].Minute == minute) then
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