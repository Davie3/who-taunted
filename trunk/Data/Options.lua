local WhoTaunted = WhoTaunted;
local L = LibStub("AceLocale-3.0"):GetLocale("WhoTaunted");

WhoTaunted.OutputTypes = {
	Self = L["Self"],
	Party = L["Party"],
	Raid = L["Raid"],
	RaidWarning = L["Raid Warning"],
	Say = L["Say"],
	Yell = L["Yell"],
};

WhoTaunted.options = {
	name = L["Who Taunted?"],
	type = 'group',
	args = {
		Intro = {
			order = 10,
			type = "description",
			name = GetAddOnMetadata("WhoTaunted", "Notes"),
		},
		Disabled = {
			type = "toggle",
			name = L["Disable Who Taunted?"],
			desc = L["Disables Who Taunted?."],
			width = "full",
			get = function(info) return WhoTaunted.db.profile.Disabled; end,
			set = function(info, v) WhoTaunted.db.profile.Disabled = v; end,
			order = 20
		},
		General = {
			name = L["General"],
			type = "group",
			--guiInline = true,
			disabled = false,
			order = 30,
			args = {
				DisableInBG = {
					type = "toggle",
					name = L["Disable Who Taunted? in Battlegrounds"],
					desc = L["Disables Who Taunted? while you are in a battleground."],
					width = "full",
					get = function(info) return WhoTaunted.db.profile.DisableInBG; end,
					set = function(info, v)
						WhoTaunted.db.profile.DisableInBG = v;
						WhoTaunted:EnteringWorldOnEvent();
					end,
					order = 10
				},
				ChatWindow = {
					type = "select",
					values = WhoTaunted:GetChatWindows(),
					name = L["Chat Window"],
					desc = L["The chat window taunts will be announced in when the output is set to"].." "..WhoTaunted.OutputTypes.Self..".",
					width = "100",
					get = function(info) return WhoTaunted.db.profile.ChatWindow; end,
					set = function(info, v) WhoTaunted.db.profile.ChatWindow = v; end,
					order = 20
				},
				RighteousDefenseTarget = {
					type = "toggle",
					name = L["Show"].." "..GetSpellInfo(31789).." "..L["Target"],
					desc = L["Show"].." "..LOCALIZED_CLASS_NAMES_MALE["PALADIN"].."'s".." "..GetSpellInfo(31789).." "..string.lower(L["Target"])..".",
					width = "full",
					get = function(info) return WhoTaunted.db.profile.RighteousDefenseTarget; end,
					set = function(info, v) WhoTaunted.db.profile.RighteousDefenseTarget = v; end,
					order = 30
				},
				HideOwnTaunts = {
					type = "toggle",
					name = L["Hide Own Taunts"],
					desc = L["Don't show your own taunts."],
					width = "full",
					get = function(info) return WhoTaunted.db.profile.HideOwnTaunts; end,
					set = function(info, v) WhoTaunted.db.profile.HideOwnTaunts = v; end,
					order = 40
				},
				HideOwnFailedTaunts = {
					type = "toggle",
					name = L["Hide Own Failed Taunts"],
					desc = L["Don't show your own failed taunts."],
					width = "full",
					get = function(info) return WhoTaunted.db.profile.HideOwnFailedTaunts; end,
					set = function(info, v) WhoTaunted.db.profile.HideOwnFailedTaunts = v; end,
					order = 50
				},
				Prefix = {
					type = "toggle",
					name = L["Include Prefix"],
					desc = L["Include the"].." '"..L["<WhoTaunted>"].."' "..L["prefix when a message's output is"].." "..WhoTaunted.OutputTypes.Party..", "..WhoTaunted.OutputTypes.Raid..", "..L["etc"]..".",
					width = "full",
					get = function(info) return WhoTaunted.db.profile.Prefix; end,
					set = function(info, v) WhoTaunted.db.profile.Prefix = v; end,
					order = 60
				},
				DisplayAbility = {
					type = "toggle",
					name = L["Display Ability"],
					desc = L["Display the ability that was used to taunt."],
					width = "full",
					get = function(info) return WhoTaunted.db.profile.DisplayAbility; end,
					set = function(info, v) WhoTaunted.db.profile.DisplayAbility = v; end,
					order = 70
				},
			},
		},
		Announcements = {
			name = L["Announcements"],
			type = "group",
			--guiInline = true,
			disabled = false,
			order = 40,
			args = {
				AnounceTaunts = {
					type = "toggle",
					name = L["Anounce Taunts"],
					desc = L["Anounce taunts."],
					width = "full",
					get = function(info) return WhoTaunted.db.profile.AnounceTaunts; end,
					set = function(info, v) WhoTaunted.db.profile.AnounceTaunts = v; end,
					order = 10
				},
				AnounceTauntsOutput = {
					type = "select",
					--values = {
						--[1] = L["Self"],
						--[2] = L["Party"],
						--[3] = L["Raid"],
						--[4] = L["Raid Warning"],
						--[5] = L["Say"],
						--[6] = L["Yell"],
					--},
					values = WhoTaunted.OutputTypes,
					name = L["Anounce Taunts Output:"],
					desc = L["Where taunts will be announced."],
					width = "100",
					get = function(info) return WhoTaunted.db.profile.AnounceTauntsOutput; end,
					set = function(info, v) WhoTaunted.db.profile.AnounceTauntsOutput = v; end,
					order = 20
				},
				AnounceAOETaunts = {
					type = "toggle",
					name = L["Anounce AOE Taunts"],
					desc = L["Anounce AOE Taunts."],
					width = "full",
					get = function(info) return WhoTaunted.db.profile.AnounceAOETaunts; end,
					set = function(info, v) WhoTaunted.db.profile.AnounceAOETaunts = v; end,
					order = 30
				},
				AnounceAOETauntsOutput = {
					type = "select",
					--values = {
						--[1] = L["Self"],
						--[2] = L["Party"],
						--[3] = L["Raid"],
						--[4] = L["Raid Warning"],
						--[5] = L["Say"],
						--[6] = L["Yell"],
					--},
					values = WhoTaunted.OutputTypes,
					name = L["Anounce AOE Taunts Output:"],
					desc = L["Where AOE Taunts will be announced."],
					width = "100",
					get = function(info) return WhoTaunted.db.profile.AnounceAOETauntsOutput; end,
					set = function(info, v) WhoTaunted.db.profile.AnounceAOETauntsOutput = v; end,
					order = 40
				},
				AnounceFails = {
					type = "toggle",
					name = L["Anounce Fails"],
					desc = L["Anounce taunts that fail."],
					width = "full",
					get = function(info) return WhoTaunted.db.profile.AnounceFails; end,
					set = function(info, v) WhoTaunted.db.profile.AnounceFails = v; end,
					order = 50
				},
				AnounceFailsOutput = {
					type = "select",
					--values = {
						--[1] = L["Self"],
						--[2] = L["Party"],
						--[3] = L["Raid"],
						--[4] = L["Raid Warning"],
						--[5] = L["Say"],
						--[6] = L["Yell"],
					--},
					values = WhoTaunted.OutputTypes,
					name = L["Anounce Fails Output:"],
					desc = L["Where the taunt fails will be announced."],
					width = "100",
					get = function(info) return WhoTaunted.db.profile.AnounceFailsOutput; end,
					set = function(info, v) WhoTaunted.db.profile.AnounceFailsOutput = v; end,
					order = 60
				},
			},
		},
	}
}


