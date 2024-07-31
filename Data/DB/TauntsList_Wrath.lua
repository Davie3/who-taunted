local WhoTaunted = LibStub('AceAddon-3.0'):GetAddon("WhoTaunted");

WhoTaunted.TauntsList = {
	SingleTarget = {
		--Warrior
		355, --Taunt
		694, --Mocking Blow

		--Death Knight
		51399, --Death Grip for Blood (49576 is now just the pull effect)
		56222, --Dark Command

		--Paladin
		62124, --Hand of Reckoning

		--Druid
		6795, --Growl

		--Hunter
		20736, --Distracting Shot

		--Shaman
		5730, --Stoneclaw Totem
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