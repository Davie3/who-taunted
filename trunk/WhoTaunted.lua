WhoTaunted = LibStub("AceAddon-3.0"):NewAddon("WhoTaunted", "AceEvent-3.0", "AceConsole-3.0")
local AceConfig = LibStub("AceConfigDialog-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("WhoTaunted");

local BgDisable = false;
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
	--WhoTaunted:RegisterEvent("PLAYER_REGEN_ENABLED", "CombatEnd")
	--WhoTaunted:RegisterEvent("PLAYER_REGEN_DISABLED", "CombatBegin")
	WhoTaunted:RegisterEvent("PLAYER_REGEN_ENABLED", "ClearTauntData")
	WhoTaunted:RegisterEvent("PLAYER_REGEN_DISABLED", "ClearTauntData")
	
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
	WhoTaunted:DisplayTaunt(arg1, arg3, arg8, arg6, arg11);	
end

function WhoTaunted:DisplayTaunt(Event, Name, ID, Target, FailType)
	if (UnitInParty("player")) or (UnitInRaid("player")) and (UnitInParty(Name)) or (UnitInRaid(Name)) and (WhoTaunted.db.profile.Disabled == false) and (BgDisable == false) then
		local OutputMessage = nil;
		if (Event == "SPELL_AURA_APPLIED") then
			local IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);			
			if (IsTaunt == true) and (TauntType == "SingleTarget") and (UnitIsPlayer(Name)) then
				if (WhoTaunted:CheckIfRecentlyTaunted(ID, Name, WhoTaunted:GetCurrentTime()) == false) then
					WhoTaunted:AddToTauntData(ID, Name);
					local link = GetSpellLink(ID);
					if (WhoTaunted.db.profile.AnounceTaunts == true) then
						if (WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceTauntsOutput) == "print") then
							if (link) then
								OutputMessage = "|c"..WhoTaunted:GetClassColor(Name)..Name.."|r "..L["taunts"].." "..Target.." "..L["using"].." "..link..".";
							else
								OutputMessage = "|c"..WhoTaunted:GetClassColor(Name)..Name.."|r "..L["taunts"].." "..Target.." "..L["using"].." "..GetSpellInfo(ID)..".";
							end
						else
							if (link) then
								OutputMessage = Name.." "..L["taunts"].." "..Target.." "..L["using"].." "..link..".";
							else
								OutputMessage = Name.." "..L["taunts"].." "..Target.." "..L["using"].." "..GetSpellInfo(ID)..".";
							end
						end
					end
				end			
			end
		elseif (Event == "SPELL_CAST_SUCCESS") then
			local IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);
			if (IsTaunt == true) and (TauntType == "AOE") and (UnitIsPlayer(Name)) then
				if (WhoTaunted:CheckIfRecentlyTaunted(ID, Name, WhoTaunted:GetCurrentTime()) == false) then
					WhoTaunted:AddToTauntData(ID, Name);
					local link = GetSpellLink(ID);
					if (WhoTaunted.db.profile.AnounceAOETaunts == true) then
						if (WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceAOETauntsOutput) == "print") then
							if (link) then
								OutputMessage = "|c"..WhoTaunted:GetClassColor(Name)..Name.."|r "..L["AOE taunted using"].." "..link..".";
							else
								OutputMessage = "|c"..WhoTaunted:GetClassColor(Name)..Name.."|r "..L["AOE taunted using"].." "..GetSpellInfo(ID)..".";
							end
						else
							if (link) then
								OutputMessage = Name.." "..L["AOE taunted using"].." "..link..".";
							else
								OutputMessage = Name.." "..L["AOE taunted using"].." "..GetSpellInfo(ID)..".";
							end
						end
					end
				end
			end
		elseif (Event == "SPELL_MISSED") and (WhoTaunted.db.profile.AnounceFails == true) then		
			local IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);			
			--Death Grip is different in that it kind of has 2 effects. It taunts then attempts pull the mob to you.
			--This causes 2 different events and with most mobs immuned to Death Grip's pull effect but not its taunt 
			--WhoTaunted starts to get spammy with successful Death Grip taunts then immuned ones.
			if not ((ID == 49576) and (string.upper(FailType) == string.upper(ACTION_SPELL_MISSED_IMMUNE))) and (IsTaunt == true) and (TauntType == "SingleTarget") then
				if (IsTaunt == true) and (TauntType == "SingleTarget") and (UnitIsPlayer(Name)) then
					local link = GetSpellLink(ID);
					if (WhoTaunted.db.profile.AnounceFails == true) then
						if (WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput) == "print") then
							if (link) then
								OutputMessage = "|c"..WhoTaunted:GetClassColor(Name)..Name.."'s|r "..L["taunt"].." "..link.." "..L["against"].." "..Target.." |c00FF0000"..string.upper(L["Failed:"]).." "..FailType.."|r!";
							else
								OutputMessage = "|c"..WhoTaunted:GetClassColor(Name)..Name.."'s|r "..L["taunt"].." "..GetSpellInfo(ID).." "..L["against"].." "..Target.." |c00FF0000"..string.upper(L["Failed:"]).." "..FailType.."|r!";
							end
						else
							if (link) then
								OutputMessage = Name.."'s "..L["taunt"].." "..link.." "..L["against"].." "..Target.." "..string.upper(L["Failed:"]).." "..FailType.."!";
							else
								OutputMessage = Name.."'s "..L["taunt"].." "..GetSpellInfo(ID).." "..L["against"].." "..Target.." "..string.upper(L["Failed:"]).." "..FailType.."!";
							end
						end
					end
				end
			end
		end
		if (OutputMessage ~= nil) then
			if (WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput) == "print") then
				WhoTaunted:OutPut(OutputMessage, WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput));
			else
				OutputMessage = "<WhoTaunted> "..OutputMessage;
				WhoTaunted:OutPut(OutputMessage, WhoTaunted:GetOutPutType(WhoTaunted.db.profile.AnounceFailsOutput));
			end
		end
	end
end

--function WhoTaunted:CombatBegin()
	--WhoTaunted:ClearTauntData();
--end
--
--function WhoTaunted:CombatEnd()
	--WhoTaunted:ClearTauntData();
--end

function WhoTaunted:EnteringWorldOnEvent()
	local inInstance, instanceType = IsInInstance();
	if (inInstance == 1) and (instanceType == "pvp") and (WhoTaunted.db.profile.DisableInBG == true) then
		BgDisable = true;
	else
		BgDisable = false;
	end
end

function WhoTaunted:AddToTauntData(ID, Name)
	local IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);
	--if (IsTaunt == true) and (UnitIsPlayer(Name)) then
	if (IsTaunt == true) and (UnitIsPlayer(Name)) and (TauntType == "SingleTarget") then
		table.insert(TauntData,{
								Name = Name,
								ID = ID,
								Time = WhoTaunted:GetCurrentTime(),
							})
	end
end

function WhoTaunted:ClearTauntData()
	TauntData = table.wipe(TauntData);
end

function WhoTaunted:CheckIfRecentlyTaunted(ID, Name, Time)
	local RecentlyTaunted = false;
	for k, v in pairs(TauntData) do
		if (TauntData[k].ID == ID) and (TauntData[k].Name == Name) and (TauntData[k].Time == Time) then
			RecentlyTaunted = true;
			break;
		end
	end
	return RecentlyTaunted;
end

function WhoTaunted:IsTaunt(Spell)
	local IsTaunt, TauntType;
	for k, v in pairs(TauntsList.SingleTarget) do
		if (GetSpellInfo(v) == GetSpellInfo(Spell)) then
		--if (v == Spell) then
			IsTaunt, TauntType = true, "SingleTarget";
			break;
		end
	end
	for k, v in pairs(TauntsList.AOE) do
		if (GetSpellInfo(v) == GetSpellInfo(Spell)) then
		--if (v == Spell) then
			IsTaunt, TauntType = true, "AOE";
			break;
		end
	end
	return IsTaunt, TauntType;
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

function WhoTaunted:GetCurrentTime()
	local time;
	local hour, minute, seconds = tonumber(date("%H")), tonumber(date("%M")), tonumber(date("%S"));	
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
	return time;
end

function WhoTaunted:OutPut(msg, output, dest)
	if (msg) and (output) then
		if (string.lower(output) == "raid") then
			local isInRaid = UnitInRaid("player");
			if (isInRaid) then
				if (isInRaid >= 1) then
					ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "RAID");
				end
			end
		elseif (string.lower(output) == "raidwarning") or (string.lower(output) == "rw") then
			local isInRaid = UnitInRaid("player");
			if (isInRaid) then
				if (isInRaid >= 1) and ((IsRaidLeader()) or (IsRaidOfficer())) then	
					ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "RAID_WARNING");
				else
					ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "RAID");
				end
			end
		elseif (string.lower(output) == "party") then
			local isInParty = UnitInParty("player");
			if (isInParty) then
				if (isInParty >= 1) then
					ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "PARTY");
				end
			end
		elseif (string.lower(output) == "say") then
			ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "SAY");
		elseif (string.lower(output) == "whisper") and (dest) then
			ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "WHISPER", nil, dest);	
		elseif (string.lower(output) == "guild") then
			ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "GUILD");
		elseif (string.lower(output) == "officer") then
			ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "OFFICER");
		elseif (string.lower(output) == "channel") and (dest) and (WhoTaunted:IsChatChannel(dest) == true) then
			ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "CHANNEL", nil, dest);
		elseif (string.lower(output) == "print") then
			WhoTaunted:Print(tostring(msg));
		end
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

function WhoTaunted:IsChatChannel(ChannelName)
	local IsChatChannel = false;
	for i = 1, NUM_CHAT_WINDOWS, 1 do
		for k, v in pairs({ GetChatWindowChannels(i) }) do
			if (string.lower(tostring(v)) == string.lower(tostring(ChannelName))) then
				IsChatChannel = true;
				break;
			end
		end
		if (IsChatChannel == true) then
			break;
		end
	end
	return IsChatChannel;
end
