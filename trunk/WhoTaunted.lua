WhoTaunted = LibStub("AceAddon-3.0"):NewAddon("WhoTaunted", "AceEvent-3.0", "AceConsole-3.0")
local AceConfig = LibStub("AceConfigDialog-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("WhoTaunted");
local BabbleClass = LibStub("LibBabble-Class-3.0"):GetLookupTable();

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
	if (arg1 == "SPELL_CAST_SUCCESS") then
		local IsTaunt, TauntType, SpellID = WhoTaunted:IsTaunt(arg9);
		if (IsTaunt == true) and (TauntType == "SingleTarget") and (UnitIsPlayer(arg3)) then
			local link = GetSpellLink(SpellID);
			WhoTaunted:Print("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."|r taunts "..arg6.." using "..link..".");
		end
	elseif (arg1 == "SPELL_MISSED") then
		local IsTaunt, TauntType, SpellID = WhoTaunted:IsTaunt(arg9);
		if (IsTaunt == true) and (TauntType == "SingleTarget") and (UnitIsPlayer(arg3)) then
			local link = GetSpellLink(SpellID);
			WhoTaunted:Print("|c"..WhoTaunted:GetClassColor(arg3)..arg3.."'s|r taunt against "..arg6.." using "..link.." failed: "..arg11.."!");
		end
	end
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