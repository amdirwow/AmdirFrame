local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

oUF.Tags['amdirframe:name'] = function(u, r)
	local name = UnitName(r or u) or "невідомо"
	return name
end
oUF.TagEvents['amdirframe:name'] = 'UNIT_NAME_UPDATE'

oUF.Tags['amdirframe:ddg'] = function(u)
	local x
	if UnitIsDead(u) then
		x = "Мертвий"
	elseif UnitIsGhost(u) then
		x = "Дух"
	elseif not UnitIsConnected(u) then
		x = "Офлайн"
	else
		x = " "
	end
	return "|cffCFCFCF"..x.."|r"
end
oUF.TagEvents['amdirframe:ddg'] = 'UNIT_HEALTH'

local L = {
  ["Prayer of Mending"] = GetSpellInfo(33076),
  ["Gift of the Naaru"] = GetSpellInfo(59542),
  ["Renew"] = GetSpellInfo(139),
  ["Power Word: Shield"] = GetSpellInfo(17),
  ["Weakened Soul"] = GetSpellInfo(6788),
  ["Prayer of Shadow Protection"] = GetSpellInfo(27683),
  ["Shadow Protection"] = GetSpellInfo(976),
  ["Prayer of Fortitude"] = GetSpellInfo(21562),
  ["Power Word: Fortitude"] = GetSpellInfo(1243),
  ["Divine Spirit"] = GetSpellInfo(48073),
  ["Prayer of Spirit"] = GetSpellInfo(48074),
  ["Fear Ward"] = GetSpellInfo(6346),
  ["Lifebloom"] = GetSpellInfo(33763),
  ["Rejuvenation"] = GetSpellInfo(774),
  ["Regrowth"] = GetSpellInfo(8936),
  ["Wild Growth"] = GetSpellInfo(48438),
  ["Tree of Life"] = GetSpellInfo(33891),
  ["Gift of the Wild"] = GetSpellInfo(48470),
  ["Mark of the Wild"] = GetSpellInfo(48469),
  ["Horn of Winter"] = GetSpellInfo(57623),
  ["Battle Shout"] = GetSpellInfo(47436),
  ["Commanding Shout"] = GetSpellInfo(47440),
  ["Vigilance"] = GetSpellInfo(50720),
  ["Magic Concentration"] = GetSpellInfo(54646),
  ["Beacon of Light"] = GetSpellInfo(53563),
  ["Sacred Shield"] = GetSpellInfo(53601),
  ['Earth Shield'] = GetSpellInfo(49284),
  ['Riptide'] = GetSpellInfo(61301),
  ['Flash of Light'] = GetSpellInfo(66922),
  ['Shield Wall'] = GetSpellInfo(871),
}
local x = "M"

local getTime = function(expirationTime)
	local expire = -1*(GetTime()-expirationTime)
	local timeleft = format("%.0f", expire)
	if expire > 0.5 then
		local spellTimer = "|cffffff00"..timeleft.."|r"
		return spellTimer
	end
end

oUF.Tags['amdirframe:aggro'] = function(u) 
	local s = UnitThreatSituation(u) if s == 2 or s == 3 then return "|cffFF0000"..x.."|r" end end
oUF.TagEvents['amdirframe:aggro'] = "UNIT_THREAT_SITUATION_UPDATE"

--priest
oUF.pomCount = {"i","h","g","f","Z","Y"}
oUF.Tags['amdirframe:pom'] = function(u) local c = select(4, UnitAura(u, L["Prayer of Mending"])) if c then return "|cffFFCF7F"..oUF.pomCount[c].."|r" end end
oUF.TagEvents['amdirframe:pom'] = "UNIT_AURA"
oUF.Tags['amdirframe:gotn'] = function(u) if UnitAura(u, L["Gift of the Naaru"]) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents['amdirframe:gotn'] = "UNIT_AURA"
oUF.Tags['amdirframe:rnw'] = function(u)
  local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L["Renew"], nil, "HELPFUL|PLAYER")
  if not (fromwho == "player") then return end
  if UnitAura(u, L["Renew"]) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents['amdirframe:rnw'] = "UNIT_AURA"
-- rnwtime
oUF.Tags['amdirframe:rnwTime'] = function(u)
  local name, _,_,_,_,_, expirationTime, fromwho,_ = UnitAura(u, L["Renew"], nil, "HELPFUL|PLAYER")
  if (fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents['amdirframe:rnwTime'] = "UNIT_AURA"
oUF.Tags['amdirframe:pws'] = function(u) if UnitAura(u, L["Power Word: Shield"]) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents['amdirframe:pws'] = "UNIT_AURA"
oUF.Tags['amdirframe:ws'] = function(u) if UnitDebuff(u, L["Weakened Soul"]) then return "|cffFF9900"..x.."|r" end end
oUF.TagEvents['amdirframe:ws'] = "UNIT_AURA"
oUF.Tags['amdirframe:fw'] = function(u) if UnitAura(u, L["Fear Ward"]) then return "|cff8B4513"..x.."|r" end end
oUF.TagEvents['amdirframe:fw'] = "UNIT_AURA"
oUF.Tags['amdirframe:sp'] = function(u) local c = UnitAura(u, L["Prayer of Shadow Protection"]) or UnitAura(u, L["Shadow Protection"]) if not c then return "|cff9900FF"..x.."|r" end end
oUF.TagEvents['amdirframe:sp'] = "UNIT_AURA"
oUF.Tags['amdirframe:fort'] = function(u) local c = UnitAura(u, L["Prayer of Fortitude"]) or UnitAura(u, L["Power Word: Fortitude"]) if not c then return "|cff00A1DE"..x.."|r" end end
oUF.TagEvents['amdirframe:fort'] = "UNIT_AURA"
oUF.Tags['amdirframe:ds'] = function(u) local c = UnitAura(u, L["Prayer of Spirit"]) or UnitAura(u, L["Divine Spirit"]) if not c then return "|cffffff00"..x.."|r" end end
oUF.TagEvents['amdirframe:ds'] = "UNIT_AURA"
oUF.Tags['amdirframe:wsTime'] = function(u)
  local name, _,_,_,_,_, expirationTime = UnitDebuff(u, L["Weakened Soul"])
  if UnitDebuff(u, L["Weakened Soul"]) then return getTime(expirationTime) end
end
oUF.TagEvents['amdirframe:wsTime'] = "UNIT_AURA"

--druid
oUF.lbCount = { 4, 2, 3 }
oUF.Tags['amdirframe:lb'] = function(u) 
	local name, _,_, c,_,_, expirationTime, fromwho,_ = UnitAura(u, L["Lifebloom"], nil, "HELPFUL|PLAYER")
	if not (fromwho == "player") then return end
	local spellTimer = GetTime()-expirationTime
	if spellTimer > -2 then
		return "|cffFF0000"..oUF.lbCount[c].."|r"
	elseif spellTimer > -4 then
		return "|cffFF9900"..oUF.lbCount[c].."|r"
	else
		return "|cffA7FD0A"..oUF.lbCount[c].."|r"
	end
end
oUF.TagEvents['amdirframe:lb'] = "UNIT_AURA"
oUF.Tags['amdirframe:rejuv'] = function(u) 
  local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L["Rejuvenation"], nil, "HELPFUL|PLAYER")
  if not (fromwho == "player") then return end
  if UnitAura(u, L["Rejuvenation"]) then return "|cff00FEBF"..x.."|r" end end
oUF.TagEvents['amdirframe:rejuv'] = "UNIT_AURA"
-- rejuvtime
oUF.Tags['amdirframe:rejuvTime'] = function(u)
  local name, _,_,_,_,_, expirationTime, fromwho,_ = UnitAura(u, L["Rejuvenation"], nil, "HELPFUL|PLAYER")
  if (fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents['amdirframe:rejuvTime'] = "UNIT_AURA"
oUF.Tags['amdirframe:regrow'] = function(u) if UnitAura(u, L["Regrowth"]) then return "|cff00FF10"..x.."|r" end end
oUF.TagEvents['amdirframe:regrow'] = "UNIT_AURA"
oUF.Tags['amdirframe:wg'] = function(u) if UnitAura(u, L["Wild Growth"]) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents['amdirframe:wg'] = "UNIT_AURA"
oUF.Tags['amdirframe:tree'] = function(u) if UnitAura(u, L["Tree of Life"]) then return "|cff33FF33"..x.."|r" end end
oUF.TagEvents['amdirframe:tree'] = "UNIT_AURA"
oUF.Tags['amdirframe:gotw'] = function(u) local c = UnitAura(u, L["Gift of the Wild"]) or UnitAura(u, L["Mark of the Wild"]) if not c then return "|cffFF00FF"..x.."|r" end end
oUF.TagEvents['amdirframe:gotw'] = "UNIT_AURA"

--warrior
oUF.Tags['amdirframe:Bsh'] = function(u) if UnitAura(u, L["Battle Shout"]) then return "|cffff0000"..x.."|r" end end
oUF.TagEvents['amdirframe:Bsh'] = "UNIT_AURA"
oUF.Tags['amdirframe:Csh'] = function(u) if UnitAura(u, L["Commanding Shout"]) then return "|cffffff00"..x.."|r" end end
oUF.TagEvents['amdirframe:Csh'] = "UNIT_AURA"
oUF.Tags['amdirframe:vigil'] = function(u)
  local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L["Vigilance"], nil, "HELPFUL|PLAYER")
  if not (fromwho == "player") then return end
  if UnitAura(u, L["Vigilance"]) then return "|cffDEB887"..x.."|r" end end
oUF.TagEvents['amdirframe:vigil'] = "UNIT_AURA"
oUF.Tags['amdirframe:SW'] = function(u) if UnitAura(u, L['Shield Wall']) then return "|cff9900FF"..x.."|r" end end
oUF.TagEvents['amdirframe:SW'] = "UNIT_AURA"

--deathknight
oUF.Tags['amdirframe:how'] = function(u) if UnitAura(u, L["Horn of Winter"]) then return "|cffffff10"..x.."|r" end end
oUF.TagEvents['amdirframe:how'] = "UNIT_AURA"

--mage
oUF.Tags['amdirframe:mc'] = function(u) if UnitAura(u, L["Magic Concentration"]) then return "|cffffff00"..x.."|r" end end
oUF.TagEvents['amdirframe:mc'] = "UNIT_AURA"

--paladin
oUF.Tags['amdirframe:sacred'] = function(u) if UnitAura(u, L["Sacred Shield"]) then return "|cffffff10"..x.."|r" end end
oUF.TagEvents['amdirframe:sacred'] = "UNIT_AURA"
oUF.Tags['amdirframe:beacon'] = function(u) if UnitAura(u, L["Beacon of Light"]) then return "|cffffff10"..x.."|r" end end
oUF.TagEvents['amdirframe:beacon'] = "UNIT_AURA"
oUF.Tags['amdirframe:selfsacred'] = function(u)
  local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L["Sacred Shield"], nil, "HELPFUL|PLAYER")
  if not (fromwho == "player") then return end
  if UnitAura(u, L["Sacred Shield"]) then return "|cffff33ff"..x.."|r" end end
oUF.TagEvents['amdirframe:selfsacred'] = "UNIT_AURA"
oUF.Tags['amdirframe:selfbeacon'] = function(u)
  local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L["Beacon of Light"], nil, "HELPFUL|PLAYER")
  if not (fromwho == "player") then return end
  if UnitAura(u, L["Beacon of Light"]) then return "|cffff33ff"..x.."|r" end end
oUF.TagEvents['amdirframe:selfbeacon'] = "UNIT_AURA"
oUF.Tags['amdirframe:beaconTime'] = function(u)
  local name, _,_,_,_,_, expirationTime, fromwho,_ = UnitAura(u, L["Beacon of Light"], nil, "HELPFUL|PLAYER")
  if (fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents['amdirframe:beaconTime'] = "UNIT_AURA"
oUF.Tags['amdirframe:FoLTime'] = function(u)
  local name, _,_,_,_,_, expirationTime, fromwho,_ = UnitAura(u, L['Flash of Light'], nil, "HELPFUL|PLAYER")
  if (fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents['amdirframe:FoLTime'] = "UNIT_AURA"

--shaman
oUF.Tags['amdirframe:rip'] = function(u) 
	local name, _,_,_,_,_,_, fromwho,_ = UnitAura(u, L['Riptide'], nil, "HELPFUL|PLAYER")
	if not (fromwho == 'player') then return end
	if UnitAura(u, L['Riptide']) then return '|cff00FEBF'..x..'|r' end end
oUF.TagEvents['amdirframe:rip'] = 'UNIT_AURA'

oUF.Tags['amdirframe:ripTime'] = function(u)
	local name, _,_,_,_,_, expirationTime, fromwho,_ = UnitAura(u, L['Riptide'], nil, "HELPFUL|PLAYER")
	if (fromwho == "player") then return getTime(expirationTime) end 
end
oUF.TagEvents['amdirframe:ripTime'] = 'UNIT_AURA'

oUF.earthCount = {'i','h','g','f','p','q','Z','Y'}
oUF.Tags['amdirframe:earth'] = function(u) local c = select(4, UnitAura(u, L['Earth Shield'])) if c then return '|cffFFCF7F'..oUF.earthCount[c]..'|r' end end
oUF.TagEvents['amdirframe:earth'] = 'UNIT_AURA'

oUF.classIndicators={
		["DRUID"] = {
				["TL"] = "[amdirframe:tree]",
				["TR"] = "[amdirframe:gotw]",
				["BL"] = "[amdirframe:regrow][amdirframe:wg]",
				["BR"] = "[amdirframe:lb]",
				["Cen"] = "[amdirframe:rejuvTime]",
		},
		["PRIEST"] = {
				["TL"] = "[amdirframe:pws][amdirframe:ws]",
				["TR"] = "[amdirframe:ds][amdirframe:sp][amdirframe:fort][amdirframe:fw]",
				["BL"] = "[amdirframe:gotn]",
				["BR"] = "[amdirframe:pom]",
				["Cen"] = "[amdirframe:rnwTime]",
		},
		["PALADIN"] = {
				["TL"] = "[amdirframe:selfsacred][amdirframe:sacred]",
				["TR"] = "[amdirframe:selfbeacon][amdirframe:beacon]",
				["BL"] = "",
				["BR"] = "",
				["Cen"] = "[amdirframe:beaconTime]",
				
		},
		["WARLOCK"] = {
				["TL"] = "",
				["TR"] = "",
				["BL"] = "",
				["BR"] = "",
				["Cen"] = "",
		},
		["WARRIOR"] = {
				["TL"] = "[amdirframe:vigil]",
				["TR"] = "",
				["BL"] = "",
				["BR"] = "",
				["Cen"] = "",
		},
		["DEATHKNIGHT"] = {
				["TL"] = "",
				["TR"] = "[amdirframe:how]",
				["BL"] = "",
				["BR"] = "",
				["Cen"] = "",
		},
		["SHAMAN"] = {
				["TL"] = "[amdirframe:rip]",
				["TR"] = "",
				["BL"] = "",
				["BR"] = "[amdirframe:earth]",
				["Cen"] = "[amdirframe:ripTime]",
		},
		["HUNTER"] = {
				["TL"] = "",
				["TR"] = "",
				["BL"] = "",
				["BR"] = "",
				["Cen"] = "",
		},
		["ROGUE"] = {
				["TL"] = "",
				["TR"] = "",
				["BL"] = "",
				["BR"] = "",
				["Cen"] = "",
		},
		["MAGE"] = {
				["TL"] = "",
				["TR"] = "[amdirframe:mc]",
				["BL"] = "",
				["BR"] = "",
				["Cen"] = "",
		}
}
