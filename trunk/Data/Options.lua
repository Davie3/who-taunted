local WhoTaunted = WhoTaunted;
local L = LibStub("AceLocale-3.0"):GetLocale("WhoTaunted");

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
			order = 30
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
					values = {
						[1] = L["Self"],
						[2] = L["Party"],
						[3] = L["Raid"],
						[4] = L["Raid Warning"],
						[5] = L["Say"],
						[6] = L["Yell"],
					},
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
					values = {
						[1] = L["Self"],
						[2] = L["Party"],
						[3] = L["Raid"],
						[4] = L["Raid Warning"],
						[5] = L["Say"],
						[6] = L["Yell"],
					},
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
					values = {
						[1] = L["Self"],
						[2] = L["Party"],
						[3] = L["Raid"],
						[4] = L["Raid Warning"],
						[5] = L["Say"],
						[6] = L["Yell"],
					},
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
		

