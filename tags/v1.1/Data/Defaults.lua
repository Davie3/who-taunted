local WhoTaunted = WhoTaunted;

WhoTaunted.defaults = {
	profile = {
		Disabled = false,
		DisableInBG = true,
		ChatWindow = "",
		RighteousDefenseTarget = true,
		HideOwnTaunts = false,
		HideOwnFailedTaunts = false,
		Prefix = true,
		DisplayAbility = true,
		AnounceTaunts = true,
		AnounceTauntsOutput = WhoTaunted.OutputTypes.Self,
		AnounceAOETaunts = true,
		AnounceAOETauntsOutput = WhoTaunted.OutputTypes.Self,
		AnounceFails = true,
		AnounceFailsOutput = WhoTaunted.OutputTypes.Self,
	},
}
