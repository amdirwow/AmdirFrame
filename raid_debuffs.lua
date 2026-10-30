
AmdirFrameDebuffs = {
	debuffs = {
		-- Any Zone
		-- The Lich King: Infest (10/25 player, normal/heroic).
		-- All ranks have the same localized name; listing every ID also keeps
		-- this working on 3.3.5 servers whose spell data differs slightly.
		[70541] = 20,
		[73779] = 20,
		[73780] = 20,
		[73781] = 20,

		[3034] = 12, -- Viper Sting

		[57978] = 9, -- Wound Poison
		[47486] = 8, -- Mortal Strike
		[46911] = 8, -- Furious Attacks
		[49050] = 8, -- Aimed Shot

		[2139] = 10, -- Counterspell

		[2094] = 10, -- Blind
		[33786] = 10, -- Cyclone

		[12826] = 7, -- Polymorph

		[53308] = 7, -- Entangling Roots
		[14311] = 7, -- Freezing Trap

		[3775] = 6, -- Crippling Poison
		[1715] = 5, -- Hamstring
		[2974] = 5, -- Wing Clip

		[6215] = 3, -- Fear
		[10890] = 3, -- Psychic Scream
		[17928] = 3, -- Howl of Terror
	},
	buffs = {
		--[871] = 15, -- Shield Wall
	},
	instances = {
		--[[
		["Zone"] = {
			[Name or GetSpellInfo(#)] = PRIORITY,
		},
		]]--
		
	},
}

-- Resolve names safely once; localized names also match difficulty variants.
AmdirFrameDebuffs.spellIDs = AmdirFrameDebuffs.debuffs
local icc = {
	[70337] = 24, [70338] = 24, -- Necrotic Plague
	[69674] = 22, -- Mutated Infection
	[70911] = 24, -- Unbound Plague
	[72451] = 18, -- Mutated Plague
	[70447] = 22, -- Volatile Ooze Adhesive
	[70126] = 23, -- Frost Beacon
	[69762] = 19, -- Unchained Magic
	[70128] = 18, -- Mystic Buffet
	[71340] = 23, -- Pact of the Darkfallen
	[71264] = 22, -- Swarming Shadows
	[72293] = 21, -- Mark of the Fallen Champion
}
for id, priority in pairs(icc) do AmdirFrameDebuffs.spellIDs[id] = priority end
local names = {}
for id, priority in pairs(AmdirFrameDebuffs.spellIDs) do
	local name = GetSpellInfo(id)
	if name then names[name] = math.max(names[name] or 0, priority) end
end
AmdirFrameDebuffs.debuffs = names
