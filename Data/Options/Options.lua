local WhoTaunted = LibStub('AceAddon-3.0'):GetAddon("WhoTaunted");
local L = LibStub("AceLocale-3.0"):GetLocale("WhoTaunted");
local version, build, date, tocVersion, localizedVersion, buildType = GetBuildInfo();
local Env = {
	RighteousDefense = 31789,
}

WhoTaunted.OutputTypes = {
    Self = L["Self"],
    Party = CHAT_MSG_PARTY,
    Raid = CHAT_MSG_RAID,
    RaidWarning = CHAT_MSG_RAID_WARNING,
    Officer = CHAT_MSG_OFFICER,
};

WhoTaunted.options = {
    name = "Who Taunted? "..GetAddOnMetadata("WhoTaunted", "Version"),
    type = 'group',
    args = {
        Intro = {
            order = 10,
            type = "description",
            name = GetAddOnMetadata("WhoTaunted", "Notes")
        },
        Disabled = {
            type = "toggle",
            name = L["Disable Who Taunted?"],
            desc = L["Disables Who Taunted?."],
            width = "full",
            get = function(info)
                WhoTaunted:CheckOptions();
                return WhoTaunted.db.profile.Disabled;
            end,
            set = function(info, v)
                WhoTaunted.db.profile.Disabled = v;
                WhoTaunted:CheckOptions();
            end,
            order = 20
        },
        General = {
            name = L["General"],
            type = "group",
            guiInline = false,
            disabled = false,
            order = 30,
            args = {
                PvpHeader = {
                    order = 10,
                    type = "header",
                    name = PVP,
                },
                DisableInBG = {
                    type = "toggle",
                    name = L["Disable Who Taunted? in Battlegrounds"],
                    desc = L["Disables Who Taunted? while you are in a battleground."],
                    width = "full",
                    get = function(info)
                        return WhoTaunted.db.profile.DisableInBG;
                    end,
                    set = function(info, v)
                        WhoTaunted.db.profile.DisableInBG = v;
                        WhoTaunted:EnteringWorldOnEvent();
                    end,
                    order = 20
                },
                DisableInPvPZone = {
                    type = "toggle",
                    name = L["Disable Who Taunted? in PvP Zones"],
                    desc = L["Disables Who Taunted? while you are in PvP Zones such as Ashran."],
                    width = "full",
                    get = function(info)
                        return WhoTaunted.db.profile.DisableInPvPZone;
                    end,
                    set = function(info, v)
                        WhoTaunted.db.profile.DisableInPvPZone = v;
                        WhoTaunted:ZoneChangedOnEvent();
                    end,
                    order = 30
                },
                SelfHeader = {
                    order = 40,
                    type = "header",
                    name = L["Self"],
                },
                HideOwnTaunts = {
                    type = "toggle",
                    name = L["Hide Own Taunts"],
                    desc = L["Don't show your own taunts."],
                    width = "full",
                    get = function(info)
                        return WhoTaunted.db.profile.HideOwnTaunts;
                    end,
                    set = function(info, v)
                        WhoTaunted.db.profile.HideOwnTaunts = v;
                    end,
                    order = 50
                },
                HideOwnFailedTaunts = {
                    type = "toggle",
                    name = L["Hide Own Failed Taunts"],
                    desc = L["Don't show your own failed taunts."],
                    width = "full",
                    get = function(info)
                        return WhoTaunted.db.profile.HideOwnFailedTaunts;
                    end,
                    set = function(info, v)
                        WhoTaunted.db.profile.HideOwnFailedTaunts = v;
                    end,
                    order = 60
                },
                AbilityHeader = {
                    order = 70,
                    type = "header",
                    name = COMBATLOG_HIGHLIGHT_ABILITY,
                },
                DisplayAbility = {
                    type = "toggle",
                    name = L["Display Ability"],
                    desc = L["Display the ability that was used to taunt."],
                    width = "full",
                    get = function(info)
                        return WhoTaunted.db.profile.DisplayAbility;
                    end,
                    set = function(info, v)
                        WhoTaunted.db.profile.DisplayAbility = v;
                    end,
                    order = 80
                },
                RighteousDefenseTarget = {
					type = "toggle",
                    hidden = false,
					name = L["Show"].." "..WhoTaunted:GetSpellName(Env.RighteousDefense).." "..L["Target"],
					desc = L["Show"].." "..LOCALIZED_CLASS_NAMES_MALE["PALADIN"].."'s".." "..WhoTaunted:GetSpellName(Env.RighteousDefense).." "..string.lower(L["Target"])..".",
					width = "full",
					get = function(info) return WhoTaunted.db.profile.RighteousDefenseTarget; end,
					set = function(info, v) WhoTaunted.db.profile.RighteousDefenseTarget = v; end,
					order = 90
				}
            }
        },
        Announcements = {
            name = L["Announcements"],
            type = "group",
            guiInline = false,
            disabled = false,
            order = 40,
            args = {
                ChatWindow = {
                    type = "select",
                    values = WhoTaunted:GetChatWindows(),
                    disabled = false,
                    name = L["Chat Window"],
                    desc = L["The chat window taunts will be announced in when the output is set to"].." "..WhoTaunted.OutputTypes.Self..".",
                    width = "100",
                    get = function(info)
                        WhoTaunted:UpdateChatWindows();
                        return WhoTaunted.db.profile.ChatWindow;
                    end,
                    set = function(info, v)
                        WhoTaunted:UpdateChatWindows();
                        WhoTaunted.db.profile.ChatWindow = v;
                    end,
                    order = 10
                },
                Prefix = {
					type = "toggle",
                    disabled = false,
					name = L["Include Prefix"],
					desc = L["Include the"].." '"..L["<WhoTaunted>"].."' "..L["prefix when a message's output is"].." "..WhoTaunted.OutputTypes.Party..", "..WhoTaunted.OutputTypes.Raid..", "..L["etc"]..".",
					width = "full",
					get = function(info)
                        return WhoTaunted.db.profile.Prefix;
                    end,
					set = function(info, v)
                        WhoTaunted.db.profile.Prefix = v;
                    end,
					order = 20
				},
                DefaultToSelf = {
                    type = "toggle",
                    name = L["Default to Self"],
                    desc = L["Default the output to Self if any of the below outputs are unavailable. For example, if you are not in a party or raid."],
                    width = "full",
                    get = function(info)
                        return WhoTaunted.db.profile.DefaultToSelf;
                    end,
                    set = function(info, v)
                        WhoTaunted.db.profile.DefaultToSelf = v;
                    end,
                    order = 30
                },
                AnnouncementsHeader = {
                    order = 40,
                    type = "header",
                    name = L["Announcements"],
                },
                AnounceTaunts = {
                    type = "toggle",
                    name = L["Anounce Taunts"],
                    desc = L["Anounce taunts."],
                    width = "full",
                    get = function(info)
                        WhoTaunted:CheckOptions();
                        return WhoTaunted.db.profile.AnounceTaunts;
                    end,
                    set = function(info, v)
                        WhoTaunted.db.profile.AnounceTaunts = v;
                        WhoTaunted:CheckOptions();
                    end,
                    order = 50
                },
                AnounceTauntsOutput = {
					type = "select",
					values = WhoTaunted.OutputTypes,
                    disabled = false,
					name = L["Anounce Taunts Output:"],
					desc = L["Where taunts will be announced."],
					width = "100",
					get = function(info)
                        WhoTaunted:CheckOptions();
                        return WhoTaunted.db.profile.AnounceTauntsOutput;
                    end,
					set = function(info, v)
                        WhoTaunted.db.profile.AnounceTauntsOutput = v;
                        WhoTaunted:CheckOptions();
                    end,
					order = 60
				},
                AnounceAOETaunts = {
                    type = "toggle",
                    name = L["Anounce AOE Taunts"],
                    desc = L["Anounce AOE Taunts."],
                    width = "full",
                    get = function(info)
                        WhoTaunted:CheckOptions();
                        return WhoTaunted.db.profile.AnounceAOETaunts;
                    end,
                    set = function(info, v)
                        WhoTaunted.db.profile.AnounceAOETaunts = v;
                        WhoTaunted:CheckOptions();
                    end,
                    order = 70
                },
                AnounceAOETauntsOutput = {
					type = "select",
					values = WhoTaunted.OutputTypes,
                    disabled = false,
					name = L["Anounce AOE Taunts Output:"],
					desc = L["Where AOE Taunts will be announced."],
					width = "100",
					get = function(info)
                        WhoTaunted:CheckOptions();
                        return WhoTaunted.db.profile.AnounceAOETauntsOutput;
                    end,
					set = function(info, v)
                        WhoTaunted.db.profile.AnounceAOETauntsOutput = v;
                        WhoTaunted:CheckOptions();
                    end,
					order = 80
				},
                AnounceFails = {
                    type = "toggle",
                    name = L["Anounce Fails"],
                    desc = L["Anounce taunts that fail."],
                    width = "full",
                    get = function(info)
                        WhoTaunted:CheckOptions();
                        return WhoTaunted.db.profile.AnounceFails;
                    end,
                    set = function(info, v)
                        WhoTaunted.db.profile.AnounceFails = v;
                        WhoTaunted:CheckOptions();
                    end,
                    order = 90
                },
                AnounceFailsOutput = {
					type = "select",
					values = WhoTaunted.OutputTypes,
                    disabled = false,
					name = L["Anounce Fails Output:"],
					desc = L["Where the taunt fails will be announced."],
					width = "100",
					get = function(info)
                        WhoTaunted:CheckOptions();
                        return WhoTaunted.db.profile.AnounceFailsOutput;
                    end,
					set = function(info, v)
                        WhoTaunted.db.profile.AnounceFailsOutput = v;
                        WhoTaunted:CheckOptions();
                    end,
					order = 100
				}
            }
        },
        Profiles = {},
        FAQ = {
            name = L["FAQ"],
            desc = L["Frequently Asked Questions"],
            type = "group",
            order = -1,
            args = {
                line1 = {
                    type = "description",
                    name = "|cffffd200"..L["Where can I report issues?"].."|r",
                    order = 10,
                },
                line2 = {
                    type = "description",
                    name = L["Issues can be reported on the Who Taunted? GitHub page"].." - |cffffff78https://github.com/Davie3/who-taunted/issues|r",
                    order = 20,
                },
                line3 = {
                    type = "description",
                    name = "\n".."|cffffd200"..L["How can I help with Localization?"].."|r",
                    order = 30,
                },
                line4 = {
                    type = "description",
                    name = L["Help localize on Curseforge!"].." - |cffffff78https://www.curseforge.com/wow/addons/who-taunted/localization|r",
                    order = 40,
                },
                line5 = {
                    type = "description",
                    name = "\n".."|cffffd200"..L["Who wrote this Addon?"].."|r",
                    order = 50,
                },
                line6 = {
                    type = "description",
                    name = L["This Addon was written and is still maintained by Davie3. Follow me on Twitch!"].." - |cffffff78https://www.twitch.tv/davie3|r",
                    order = 60,
                },
            },
        }
    }
}

function WhoTaunted:CheckOptions()
	--Disable Righteous Defense options if the client is Classic Era or Mists
	if (tocVersion) and ((tocVersion >= 50000) or (tocVersion < 20000)) then
		WhoTaunted.db.profile.RighteousDefenseTarget = false;
		WhoTaunted.options.args.General.args.RighteousDefenseTarget.hidden = true;
	end

	if (WhoTaunted.OutputTypes[WhoTaunted.db.profile.AnounceTauntsOutput] ~= WhoTaunted.OutputTypes.Self) or (WhoTaunted.OutputTypes[WhoTaunted.db.profile.AnounceAOETauntsOutput] ~= WhoTaunted.OutputTypes.Self) or (WhoTaunted.OutputTypes[WhoTaunted.db.profile.AnounceFailsOutput] ~= WhoTaunted.OutputTypes.Self) then
		WhoTaunted.options.args.Announcements.args.Prefix.disabled = false;
	else
		WhoTaunted.options.args.Announcements.args.Prefix.disabled = true;
	end

	if (WhoTaunted.OutputTypes[WhoTaunted.db.profile.AnounceTauntsOutput] == WhoTaunted.OutputTypes.Self) or (WhoTaunted.OutputTypes[WhoTaunted.db.profile.AnounceAOETauntsOutput] == WhoTaunted.OutputTypes.Self) or (WhoTaunted.OutputTypes[WhoTaunted.db.profile.AnounceFailsOutput] == WhoTaunted.OutputTypes.Self) then
		WhoTaunted.options.args.Announcements.args.ChatWindow.disabled = false;
	else
		WhoTaunted.options.args.Announcements.args.ChatWindow.disabled = true;
	end

	if (WhoTaunted.db.profile.AnounceTaunts == true) then
		WhoTaunted.options.args.Announcements.args.AnounceTauntsOutput.disabled = false;
	else
		WhoTaunted.options.args.Announcements.args.AnounceTauntsOutput.disabled = true;
	end

	if (WhoTaunted.db.profile.AnounceAOETaunts == true) then
		WhoTaunted.options.args.Announcements.args.AnounceAOETauntsOutput.disabled = false;
	else
		WhoTaunted.options.args.Announcements.args.AnounceAOETauntsOutput.disabled = true;
	end

	if (WhoTaunted.db.profile.AnounceFails == true) then
		WhoTaunted.options.args.Announcements.args.AnounceFailsOutput.disabled = false;
	else
		WhoTaunted.options.args.Announcements.args.AnounceFailsOutput.disabled = true;
	end

    if (WhoTaunted:CheckOutputTypeOptions(WhoTaunted.db.profile.AnounceTauntsOutput) == false) then
        WhoTaunted.db.profile.AnounceTauntsOutput = WhoTaunted.OutputTypes.Self;
    end

    if (WhoTaunted:CheckOutputTypeOptions(WhoTaunted.db.profile.AnounceAOETauntsOutput) == false) then
        WhoTaunted.db.profile.AnounceAOETauntsOutput = WhoTaunted.OutputTypes.Self;
    end

    if (WhoTaunted:CheckOutputTypeOptions(WhoTaunted.db.profile.AnounceFailsOutput) == false) then
        WhoTaunted.db.profile.AnounceFailsOutput = WhoTaunted.OutputTypes.Self;
    end

	if (WhoTaunted.db.profile.Disabled == true) then
		WhoTaunted.options.args.General.disabled = true;
		WhoTaunted.options.args.Announcements.disabled = true;
		WhoTaunted.options.args.Profiles.disabled = true;
		WhoTaunted.options.args.FAQ.disabled = true;
		WhoTaunted.options.args.Announcements.args.ChatWindow.disabled = true;
		WhoTaunted.options.args.Announcements.args.Prefix.disabled = true;
		WhoTaunted.options.args.Announcements.args.AnounceTauntsOutput.disabled = true;
		WhoTaunted.options.args.Announcements.args.AnounceAOETauntsOutput.disabled = true;
		WhoTaunted.options.args.Announcements.args.AnounceFailsOutput.disabled = true;
	else
		WhoTaunted.options.args.General.disabled = false;
		WhoTaunted.options.args.Announcements.disabled = false;
		WhoTaunted.options.args.Profiles.disabled = false;
		WhoTaunted.options.args.FAQ.disabled = false;
	end
end

function WhoTaunted:CheckOutputTypeOptions(output)
    local found = false;

    for k, v in pairs(WhoTaunted.OutputTypes) do
        if (WhoTaunted:FormatString(output) == WhoTaunted:FormatString(k)) then
            found = true;
            break;
        end
        if (WhoTaunted:FormatString(output) == WhoTaunted:FormatString(v)) then
            found = true;
            break;
        end
	end

    return found;
end