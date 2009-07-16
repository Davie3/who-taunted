local WhoTaunted = WhoTaunted;
local L = LibStub("AceLocale-3.0"):GetLocale("WhoTaunted");

WhoTaunted.options = {
	name = L["Who Taunted?"],
	type = 'group',
	args = {
		Disabled = {
				type = "toggle",
				name = L["Disable Who Taunted?"],
				desc = L["Disables Who Taunted?."],
				width = "full",
				get = function(info) return WhoTaunted.db.profile.Disabled; end,
				set = function(info, v) WhoTaunted.db.profile.Disabled = v; end,
				order = 10
			},
			AnounceFails = {
				type = "toggle",
				name = L["Anounce Fails"],
				desc = L["Anounce taunts that fail."],
				width = "full",
				get = function(info) return WhoTaunted.db.profile.AnounceFails; end,
				set = function(info, v) WhoTaunted.db.profile.AnounceFails = v; end,
				order = 20
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
				order = 30
			},
	}
}
		

