local WhoTaunted = LibStub('AceAddon-3.0'):GetAddon("WhoTaunted");

WhoTaunted.TauntsList = {
	SingleTarget = {
		--Warrior
		355, --Taunt

		--Death Knight
		49576, --Death Grip
		56222, --Dark Command

		--Paladin
		62124, --Hand of Reckoning

		--Druid
		6795, --Growl

		--Hunter
		20736, --Distracting Shot

		--Shaman
		73684, --Unleash Earth

		--Monk
		115546, --Provoke
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

		--Monk
		--61146, --Black Ox Statue (handled in main file due to only triggering AOE Taunt when the Statue is Provoked)
	},
};