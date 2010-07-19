﻿WhoTaunted = LibStub("AceAddon-3.0"):NewAddon("WhoTaunted", "AceEvent-3.0", "AceConsole-3.0")
local AceConfig = LibStub("AceConfigDialog-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("WhoTaunted");

local PlayerName, PlayerRealm = UnitName("player");
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
local TauntTypes = {
	Normal = "Normal",
	AOE = "AOE",
	Failed = "Failed",
};

function WhoTaunted:OnInitialize()
	WhoTaunted:RegisterEvent("PLAYER_ENTERING_WORLD", "EnteringWorldOnEvent")
	WhoTaunted:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CombatLog")
	--WhoTaunted:RegisterEvent("PLAYER_REGEN_ENABLED", "ClearTauntData")
	--WhoTaunted:RegisterEvent("PLAYER_REGEN_DISABLED", "ClearTauntData")
	WhoTaunted:RegisterEvent("UPDATE_CHAT_WINDOWS", "UpdateChatWindowsOnEvent")

	WhoTaunted:RegisterChatCommand("whotaunted", "ChatCommand")
	WhoTaunted:RegisterChatCommand("wtaunted", "ChatCommand")
	WhoTaunted:RegisterChatCommand("wtaunt", "ChatCommand")

	WhoTaunted.db = LibStub("AceDB-3.0"):New("WhoTauntedDB", WhoTaunted.defaults, "profile");
	LibStub("AceConfig-3.0"):RegisterOptionsTable("WhoTaunted", WhoTaunted.options)
	AceConfig:AddToBlizOptions("WhoTaunted", L["Who Taunted?"].." v"..GetAddOnMetadata("WhoTaunted", "Version"));
end

function WhoTaunted:OnEnable()
	if (type(tonumber(WhoTaunted.db.profile.AnounceTauntsOutput)) == "number") or (type(tonumber(WhoTaunted.db.profile.AnounceAOETauntsOutput)) == "number") or (type(tonumber(WhoTaunted.db.profile.AnounceFailsOutput)) == "number") then
		WhoTaunted.db.profile.AnounceTauntsOutput = WhoTaunted.OutputTypes.Self;
		WhoTaunted.db.profile.AnounceAOETauntsOutput = WhoTaunted.OutputTypes.Self;
		WhoTaunted.db.profile.AnounceFailsOutput = WhoTaunted.OutputTypes.Self;
	end
end

function WhoTaunted:OnDisable()
	WhoTaunted:UnregisterAllEvents();
end

function WhoTaunted:UpdateChatWindowsOnEvent()
	WhoTaunted:UpdateChatWindows();
end

function WhoTaunted:ChatCommand()
	InterfaceOptionsFrame_OpenToCategory(L["Who Taunted?"].." v"..GetAddOnMetadata("WhoTaunted", "Version"));
end

function WhoTaunted:CombatLog(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = select(1, ...);
	WhoTaunted:DisplayTaunt(arg1, arg3, arg8, arg6, arg11);
end

function WhoTaunted:DisplayTaunt(Event, Name, ID, Target, FailType)
	if (Event) and (Name) and (ID) and (Target) then
		--if (WhoTaunted.db.profile.Disabled == false) and (BgDisable == false) then
		if (WhoTaunted.db.profile.Disabled == false) and (BgDisable == false) and (UnitIsPlayer(Name)) and ((UnitInParty("player")) or (UnitInRaid("player"))) and ((UnitInParty(Name)) or (UnitInRaid(Name))) then
			local OutputMessage = nil;
			local IsTaunt, TauntType;
			if (Event == "SPELL_AURA_APPLIED") then				
				IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);				
				if (not IsTaunt) or (TauntType ~= TauntTypes.Normal) or (WhoTaunted.db.profile.AnounceTaunts == false) or ((WhoTaunted.db.profile.HideOwnTaunts == true) and (Name == PlayerName)) then
					return;
				end
				--if (TauntType == TauntTypes.Normal) and (UnitIsPlayer(Name)) then
					--if (WhoTaunted.db.profile.AnounceTaunts == true) then
					--if (WhoTaunted.db.profile.AnounceTaunts == true) and (WhoTaunted:CheckIfRecentlyTaunted(ID, Name, WhoTaunted:GetCurrentTime()) == false) then
						--WhoTaunted:AddToTauntData(ID, Name)
						local Spell = GetSpellLink(ID);
						if (not Spell) then
							Spell = GetSpellInfo(ID);
						end
						--if (WhoTaunted.db.profile.AnounceTauntsOutput == WhoTaunted.OutputTypes.Self) then
							OutputMessage = "|c"..WhoTaunted:GetClassColor(Name)..Name.."|r "..L["taunted"].." "..Target;
						--else
							--OutputMessage = Name.." "..L["taunted"].." "..Target;
						--end
						if (WhoTaunted.db.profile.DisplayAbility == true) then
							OutputMessage = OutputMessage.." "..L["using"].." "..Spell..".";
						else
							OutputMessage = OutputMessage..".";
						end
					--end
				--end
			elseif (Event == "SPELL_CAST_SUCCESS") then				
				IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);
				if (not IsTaunt) or (TauntType ~= TauntTypes.AOE) or (WhoTaunted.db.profile.AnounceAOETaunts == false) or ((WhoTaunted.db.profile.HideOwnTaunts == true) and (Name == PlayerName)) then
					return;
				end
				--if (TauntType == TauntTypes.AOE) and (UnitIsPlayer(Name)) then
					--if (WhoTaunted.db.profile.AnounceAOETaunts == true) then
					--if (WhoTaunted.db.profile.AnounceAOETaunts == true) and (WhoTaunted:CheckIfRecentlyTaunted(ID, Name, WhoTaunted:GetCurrentTime()) == false) then
						--WhoTaunted:AddToTauntData(ID, Name);
						local Spell = GetSpellLink(ID);
						if (not Spell) then
							Spell = GetSpellInfo(ID);
						end
						--if (WhoTaunted.db.profile.AnounceAOETauntsOutput == WhoTaunted.OutputTypes.Self) then
							OutputMessage = "|c"..WhoTaunted:GetClassColor(Name)..Name.."|r "..L["AOE"].." "..L["taunted"];
						--else
							--OutputMessage = Name.." "..L["AOE"].." "..L["taunted"];
						--end
						if (GetSpellInfo(ID) == GetSpellInfo(31789)) and (WhoTaunted.db.profile.RighteousDefenseTarget == true) then
							OutputMessage = OutputMessage.." "..L["off of"].." |c"..WhoTaunted:GetClassColor(Target)..Target.."|r";
						end
						if (WhoTaunted.db.profile.DisplayAbility == true) then
							OutputMessage = OutputMessage.." "..L["using"].." "..Spell..".";
						else
							OutputMessage = OutputMessage..".";
						end
					--end
				--end
			elseif (Event == "SPELL_MISSED") then
				IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);
				--Death Grip is different in that it kind of has 2 effects. It taunts then attempts pull the mob to you.
				--This causes 2 different events and with most mobs immuned to Death Grip's pull effect but not its taunt
				--WhoTaunted starts to get spammy with successful Death Grip taunts then immuned ones.
				if (not FailType) or (not IsTaunt) or (TauntType ~= TauntTypes.Normal) or (WhoTaunted.db.profile.AnounceFails == false) or ((GetSpellInfo(ID) == GetSpellInfo(49576)) and (string.lower(tostring(FailType)) == string.lower(ACTION_SPELL_MISSED_IMMUNE))) or ((WhoTaunted.db.profile.HideOwnFailedTaunts == true) and (Name == PlayerName)) then
					return;
				end
				--if (TauntType == TauntTypes.Normal) and (UnitIsPlayer(Name)) then
					--if (WhoTaunted.db.profile.AnounceFails == true) then
						local Spell = GetSpellLink(ID);
						if (not Spell) then
							Spell = GetSpellInfo(ID);
						end
						--if (WhoTaunted.db.profile.AnounceFailsOutput == WhoTaunted.OutputTypes.Self) then
							OutputMessage = "|c"..WhoTaunted:GetClassColor(Name)..Name..L["'s"].."|r "..L["taunt"];
							if (WhoTaunted.db.profile.DisplayAbility == true) then
								OutputMessage = OutputMessage.." "..Spell;
							end
							OutputMessage = OutputMessage.." "..L["against"].." "..Target.." |c00FF0000"..string.upper(L["Failed:"].." "..FailType.."|r!");

							--if (WhoTaunted.db.profile.DisplayAbility == true) then
								--OutputMessage = "|c"..WhoTaunted:GetClassColor(Name)..Name.."'s|r "..L["taunt"].." "..Spell.." "..L["against"].." "..Target.." |c00FF0000"..string.upper(L["Failed:"].." "..FailType.."|r!");
							--else
								--OutputMessage = "|c"..WhoTaunted:GetClassColor(Name)..Name.."'s|r "..L["taunt"].." "..L["against"].." "..Target.." |c00FF0000"..string.upper(L["Failed:"].." "..FailType.."|r!");
							--end
						--else
							--OutputMessage = Name.."'s "..L["taunt"];
							--if (WhoTaunted.db.profile.DisplayAbility == true) then
								--OutputMessage = OutputMessage..": "..Spell;
							--end
							--OutputMessage = OutputMessage.." "..L["against"].." "..Target.." "..string.upper(L["Failed:"].." "..FailType.."!");

							----if (WhoTaunted.db.profile.DisplayAbility == true) then
								----OutputMessage = Name.."'s "..L["taunt"].." "..Spell.." "..L["against"].." "..Target.." "..string.upper(L["Failed:"].." "..FailType.."!");
							----else
								----OutputMessage = Name.."'s "..L["taunt"].." "..L["against"].." "..Target.." "..string.upper(L["Failed:"].." "..FailType.."!");
							----end
						--end
						TauntType = TauntTypes.Failed;
					--end
				--end
			else
				return;
			end
			if (OutputMessage) and (TauntType) then
				local OutputType = WhoTaunted:GetOutputType(TauntType);
				if (WhoTaunted.db.profile.AnounceTauntsOutput ~= WhoTaunted.OutputTypes.Self) then
					if (WhoTaunted.db.profile.Prefix == true) then
						OutputMessage = L["<WhoTaunted>"].." "..OutputMessage;
					end
					--Remove color codes, but don't mess up item links.
					OutputMessage = OutputMessage:gsub("(|c00%x%x%x%x%x%x)", ""):gsub("(|h|r)", "|h|.r"):gsub("(|r)", ""):gsub("(|h|.r)", "|h|r");
				end
				WhoTaunted:OutPut(OutputMessage:trim(), OutputType);
				
				--if (TauntType == TauntTypes.Normal) then
					--if (WhoTaunted.db.profile.AnounceTauntsOutput ~= WhoTaunted.OutputTypes.Self) and (WhoTaunted.db.profile.Prefix == true) then
						--OutputMessage = "<WhoTaunted> "..OutputMessage;
					--end
					--WhoTaunted:OutPut(OutputMessage, WhoTaunted.db.profile.AnounceTauntsOutput);
				--elseif (TauntType == TauntTypes.AOE) then
					--if (WhoTaunted.db.profile.AnounceAOETauntsOutput ~= WhoTaunted.OutputTypes.Self) and (WhoTaunted.db.profile.Prefix == true) then
						--OutputMessage = "<WhoTaunted> "..OutputMessage;
					--end
					--WhoTaunted:OutPut(OutputMessage, WhoTaunted.db.profile.AnounceAOETauntsOutput);
				--elseif (TauntType == TauntTypes.Failed) then
					--if (WhoTaunted.db.profile.AnounceFailsOutput ~= WhoTaunted.OutputTypes.Self) and (WhoTaunted.db.profile.Prefix == true) then
						--OutputMessage = "<WhoTaunted> "..OutputMessage;
					--end
					--WhoTaunted:OutPut(OutputMessage, WhoTaunted.db.profile.AnounceFailsOutput);
				--end
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

--function WhoTaunted:AddToTauntData(ID, Name)
	--local IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);
	----if (IsTaunt == true) and (UnitIsPlayer(Name)) then
	--if (IsTaunt == true) and (UnitIsPlayer(Name)) and (TauntType == TauntTypes.Normal) then
		--table.insert(TauntData,{
			--Name = Name,
			--ID = ID,
			--Time = WhoTaunted:GetCurrentTime(),
		--});
	--end
--end
--
--function WhoTaunted:ClearTauntData()
	--TauntData = table.wipe(TauntData);
--end
--
--function WhoTaunted:CheckIfRecentlyTaunted(ID, Name, Time)
	--local RecentlyTaunted = false;
	--for k, v in pairs(TauntData) do
		--if (TauntData[k].ID == ID) and (TauntData[k].Name == Name) and (TauntData[k].Time == Time) then
			--RecentlyTaunted = true;
			--break;
		--end
	--end
	--return RecentlyTaunted;
--end

function WhoTaunted:IsTaunt(Spell)
	local IsTaunt, TauntType = false, "";
	for k, v in pairs(TauntsList.SingleTarget) do
		if (GetSpellInfo(v) == GetSpellInfo(Spell)) then
		--if (v == Spell) then
			IsTaunt, TauntType = true, TauntTypes.Normal;
			break;
		end
	end
	for k, v in pairs(TauntsList.AOE) do
		if (GetSpellInfo(v) == GetSpellInfo(Spell)) then
		--if (v == Spell) then
			IsTaunt, TauntType = true, TauntTypes.AOE;
			break;
		end
	end
	return IsTaunt, TauntType;
end

function WhoTaunted:OutPut(msg, output, dest)
	if (not output) or (output == "") then
		output = "print";
	end
	if (msg) then
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
		elseif (string.lower(output) == "print") or (string.lower(output) == "self") then
			if (WhoTaunted:IsChatWindow(WhoTaunted.db.profile.ChatWindow) == true) then
				WhoTaunted:PrintToChatWindow(tostring(msg), WhoTaunted.db.profile.ChatWindow)
			else
				WhoTaunted.db.profile.ChatWindow = "";
				WhoTaunted:Print(tostring(msg));
			end
		end
	end
end

function WhoTaunted:GetOutputType(TauntType)
	local OutputType = "print";
	if (TauntType == TauntTypes.Normal) then
		OutputType = WhoTaunted.db.profile.AnounceTauntsOutput;
	elseif (TauntType == TauntTypes.AOE) then		
		OutputType = WhoTaunted.db.profile.AnounceAOETauntsOutput;
	elseif (TauntType == TauntTypes.Failed) then
		OutputType = WhoTaunted.db.profile.AnounceFailsOutput;
	end
	return OutputType;
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

function WhoTaunted:UpdateChatWindows()
	WhoTaunted.options.args.General.args.ChatWindow.values = WhoTaunted:GetChatWindows();
end

function WhoTaunted:GetChatWindows()
	local ChatWindows = {};
	for i = 1, NUM_CHAT_WINDOWS, 1 do
		local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
		if (name) and (tostring(name) ~= COMBAT_LOG) and (name:trim() ~= "") then
			--table.insert(ChatWindows, name);
			ChatWindows[tostring(name)] = tostring(name);
		end
	end
	return ChatWindows;
end

function WhoTaunted:IsChatWindow(ChatWindow)
	local IsChatWindow = false;
	for i = 1, NUM_CHAT_WINDOWS, 1 do
		local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
		if (name) and (name:trim() ~= "") and (tostring(name) == tostring(ChatWindow)) then
		--if (name) and (string.lower(tostring(name)) == string.lower(tostring(ChatWindow))) then
			IsChatWindow = true;
			break;
		end
	end
	return IsChatWindow;
end

function WhoTaunted:PrintToChatWindow(message, ChatWindow)
	for i = 1, NUM_CHAT_WINDOWS, 1 do
		local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
		if (name) and (name:trim() ~= "") and (tostring(name) == tostring(ChatWindow)) then
		--if (name) and (string.lower(tostring(name)) == string.lower(tostring(ChatWindow))) then
			WhoTaunted:Print(_G["ChatFrame"..i], tostring(message));
		end
	end
end

function WhoTaunted:GetClassColor(Unit)
	local localizedclass = nil;
	local ClassColor = nil;
	if (Unit) then
		localizedclass = UnitClass(Unit);
		if (localizedclass) then
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
	end

	if (ClassColor == nil) then
		ClassColor = "00FFFFFF";
	end

	return ClassColor;
end

--function WhoTaunted:GetCurrentTime()
	--local time;
	--local hour, minute, seconds = tonumber(date("%H")), tonumber(date("%M")), tonumber(date("%S"));
	--if (minute < 10) then
		--time = hour..":0"..minute;
	--else
		--time = hour..":"..minute;
	--end
	--if (seconds < 10) then
		--time = time..":0"..seconds;
	--else
		--time = time..":"..seconds;
	--end
	--return time;
--end

function WhoTaunted:DebugPrint(message)
	for i = 1, NUM_CHAT_WINDOWS, 1 do
		local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
		if (name) and (string.lower(tostring(name)) == "zalruh debug") then
			WhoTaunted:Print(_G["ChatFrame"..i], tostring(message));
		end
	end
end