local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end
local mediaPath = "Interface\\AddOns\\" .. ADDON_NAME .. "\\media\\"

local raid

-- Number formatting
local numberize = function(val)
	if (val >= 1e6) then
		return ("%.1fm"):format(val / 1e6)
	elseif (val >= 1e3) then
		return ("%.1fk"):format(val / 1e3)
	else
		return ("%d"):format(val)
	end
end

local colors = setmetatable({
	power = setmetatable({
		['MANA'] = {.31,.45,.63},
		['RAGE'] = {.69,.31,.31},
		['FOCUS'] = {.71,.43,.27},
		['ENERGY'] = {.65,.63,.35},
		['RUNIC_POWER'] = {0,.8,.9},
	}, {__index = oUF.colors.power}),
}, {__index = oUF.colors})

-- Unit Menu
local menu = function(self)
	-- Raid/header units do not own one of Blizzard's Target/Party dropdowns.
	-- Reusing TargetFrameDropDown here taints protected entries such as Set Focus.
	local dropdown = FriendsDropDown
	dropdown.unit = self.unit
	dropdown.name = UnitName(self.unit)
	dropdown.id = self.id
	dropdown.initialize = RaidFrameDropDown_Initialize
	ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
end

local backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	insets = {top = 0, left = 0, bottom = 0, right = 0},
}

local border = {
	bgFile = mediaPath .. "white.tga",
	insets = {top = -1, left = -1, bottom = -1, right = -1},
}

local glowBorder = {
	edgeFile = mediaPath .. "glowTex.tga", edgeSize = 5,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
}

-- Show Target Border
local ChangedTarget = function(self)
	if UnitIsUnit('target', self.unit) then
		self.TargetBorder:SetBackdropColor(.8, .8, .8, 1)
		self.TargetBorder:Show()
	else
		self.TargetBorder:Hide()
	end
end

-- Show Focus Border
local FocusTarget = function(self)
	if UnitIsUnit('focus', self.unit) then
		self.FocusHighlight:SetBackdropColor(.6, .8, 0, 1)
		self.FocusHighlight:Show()
	else
		self.FocusHighlight:Hide()
	end
end

local updateThreat = function(self, event, unit)
	if(unit ~= self.unit) then return end
	local threat = self.Threat

	unit = unit or self.unit
	local status = UnitThreatSituation(unit)

	if(status and status > 1) then
		local r, g, b = GetThreatStatusColor(status)
		threat:SetBackdropBorderColor(r, g, b, 1)
	else
		threat:SetBackdropBorderColor(0, 0, 0, 1)
	end
	threat:Show()
end

local function utf8sub(str, start, numChars) 
	local currentIndex = start 
	while numChars > 0 and currentIndex <= #str do 
	    local char = string.byte(str, currentIndex) 
	    if char >= 240 then 
	      currentIndex = currentIndex + 4 
	    elseif char >= 225 then 
	      currentIndex = currentIndex + 3 
	    elseif char >= 192 then 
	      currentIndex = currentIndex + 2 
	    else 
	      currentIndex = currentIndex + 1 
	    end 
		numChars = numChars - 1 
	end 
	return str:sub(start, currentIndex - 1) 
end 
local nameCache = {}

-- Upate Health, Name, and coloring
local updateHealth = function(health, unit)
	local def = oUF.Tags['missinghp'](unit)
	local per = oUF.Tags['perhp'](unit)
	local name = oUF.Tags['amdirframe:name'](unit)
	local self = health:GetParent()
    local val = 1
    if AmdirFrame.db.powerbar then
        val = 8
    end

	if per > 90 or per == 0 or AmdirFrame.db.showname then
		if nameCache[name] then 
			self.Info:SetText(nameCache[name]) 
		else 
			local substring 
			for length=#name, 1, -1 do 
				substring = utf8sub(name, 1, length) 
				self.Info:SetText(substring) 
				if self.Info:GetStringWidth() <= AmdirFrame.db.width - val then break end 
			end
			nameCache[name] = substring
		end
	else
		self.Info:SetText('-'..numberize(def))
	end

	local r, g, b, t
	if(UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = oUF.colors.class[class]
	else		
		r, g, b = .2, .9, .1
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end
	
	self.Info:SetTextColor(r, g, b)
	
	if(b) then
		local bg = health.bg
		if AmdirFrame.db.reversecolors then
			bg:SetVertexColor(r*.2, g*.2, b*.2)
			health:SetStatusBarColor(r, g, b)
		else
			bg:SetVertexColor(r, g, b)
			health:SetStatusBarColor(0, 0, 0, .8)
		end
	end
end

local updatePower = function(power, unit)
	local _, ptype = UnitPowerType(unit)
	local self = power:GetParent()
	
	local r, g, b, t
	t = colors.power[ptype]
	r, g, b = 1, 1, 1
	if(t) then
		r, g, b = t[1], t[2], t[3]
	end
	
	if(b) then
		power.bg:SetVertexColor(r*.18, g*.18, b*.18)
		power:SetStatusBarColor(r, g, b)
	end
	
	local perc = oUF.Tags['perpp'](unit)
	-- This kinda conflicts with the threat module, but I don't really care
	if (perc < 10 and UnitIsConnected(unit) and ptype == 'MANA' and not UnitIsDeadOrGhost(unit)) then
		self.Threat:SetBackdropBorderColor(0, 0, 1, 1)
	else
		-- pass the coloring back to the threat func
		return updateThreat(self, nil, unit)
	end
end

local fixStatusbar = function(bar)
	bar:GetStatusBarTexture():SetHorizTile(false)
	bar:GetStatusBarTexture():SetVertTile(false)
end

local powerbar = function(self)
	local size = math.max(1, AmdirFrame.db.height * AmdirFrame.db.powerbarsize)
	local pp = CreateFrame"StatusBar"
	pp:SetStatusBarTexture(AmdirFrame.textures[AmdirFrame.db.texture])
	fixStatusbar(pp)
	pp:SetOrientation("HORIZONTAL")
	pp.frequentUpdates = true

	pp:SetParent(self)
	pp:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
	pp:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	pp:SetHeight(size)

	-- Reserve the lower part of every unit frame for the resource bar.
	self.Health:ClearAllPoints()
	self.Health:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, size)
    
	local ppbg = pp:CreateTexture(nil, "BORDER")
	ppbg:SetAllPoints(pp)
	ppbg:SetTexture(AmdirFrame.textures[AmdirFrame.db.texture])
	pp.bg = ppbg
	pp.PostUpdate = updatePower

    self.Power = pp
end

-- Add healcomm stuff
local addHealcomm = function(self)
	local heal = self.Health:CreateFontString(nil, "OVERLAY")
	heal:SetPoint("BOTTOM")
	heal:SetJustifyH("CENTER")
	heal:SetFont(AmdirFrame.fonts[AmdirFrame.db.font], AmdirFrame.db.fontsize-2)
	heal:SetShadowOffset(1.25, -1.25)
	heal:SetTextColor(0,1,0,1)

	self.HealCommText = AmdirFrame.db.healcommtext and heal or nil
	self.HealCommTextFormat = numberize

	local healbar = CreateFrame('StatusBar', nil, self.Health)
	healbar:SetStatusBarTexture(AmdirFrame.textures[AmdirFrame.db.texture])
	fixStatusbar(healbar)
	healbar:SetStatusBarColor(0, 1, 0, AmdirFrame.db.healalpha)
	if AmdirFrame.db.orientation == "VERTICAL" then
		healbar:SetPoint('BOTTOM', self.Health, 'BOTTOM')
	else
		healbar:SetPoint('LEFT', self.Health, 'LEFT')
	end

	self.HealCommBar = AmdirFrame.db.healcommbar and healbar or nil
	self.allowHealCommOverflow = AmdirFrame.db.healcommoverflow
	self.HealCommOthersOnly = AmdirFrame.db.healothersonly
end

local _, class = UnitClass("player")
local dispellClass = {
	PRIEST = { Magic = true, Disease = true, },
	SHAMAN = { Poison = true, Disease = true, Curse = true, },
	PALADIN = { Magic = true, Poison = true, Disease = true, },
	MAGE = { Curse = true, },
	DRUID = { Curse = true, Poison = true, },
}
local dispellist = dispellClass[class] or {}
local dispellPriority = {
	Magic = 4,
	Poison = 3,
	Curse = 2,
	Disease = 1,
}

local instDebuffs = {}
local instances = AmdirFrameDebuffs.instances
local getzone = function()
	local zone = GetInstanceInfo()
	if instances[zone] then
		instDebuffs = instances[zone]
	else
		instDebuffs = {}
	end
end

local zoneEvents = CreateFrame("Frame")
zoneEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
zoneEvents:RegisterEvent("ZONE_CHANGED_NEW_AREA")
zoneEvents:SetScript("OnEvent", getzone)

local debuffs = AmdirFrameDebuffs.debuffs
local buffs = AmdirFrameDebuffs.buffs
local CustomFilter = function(icons, ...)
	local _, icon, name, _, _, _, dtype = ...
	local spellID = select(13, ...)
	icon.buff = false
	icon.dispel = false
	icon.priority = 0
	if icons.dispelOnly then
		icon.priority = dispellist[dtype] and dispellPriority[dtype] or 0
		return icon.priority > 0
	end

	if instDebuffs[name] then
		icon.priority = instDebuffs[name]
		return true
	elseif AmdirFrameDebuffs.spellIDs[spellID] or debuffs[name] then
		icon.priority = AmdirFrameDebuffs.spellIDs[spellID] or debuffs[name]
		return true
	elseif buffs[name] then
		icon.priority = buffs[name]
		icon.buff = true
		return true
	elseif dispellist[dtype] then
		icon.priority = dispellPriority[dtype]
		icon.dispel = true
		return true
	else
		icon.priority = 0
	end
end

-- Show Mouseover highlight
local OnEnter = function(self)
	UnitFrame_OnEnter(self)
	self.Highlight:Show()	
end

local OnLeave = function(self)
	UnitFrame_OnLeave(self)
	self.Highlight:Hide()	
end

local style = function(self)
	self.menu = menu
	self.colors = colors

	-- Backdrop
	self.BG = CreateFrame("Frame", nil, self)
	self.BG:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.BG:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	self.BG:SetFrameLevel(3)
	self.BG:SetBackdrop(backdrop)
	self.BG:SetBackdropColor(0, 0, 0)

	-- Mouseover script
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self:RegisterForClicks"anyup"
	-- FocusUnit called from a custom dropdown is protected during combat in
	-- WoW 3.3.5.  Secure click attributes remain usable in combat.
	self:SetAttribute("shift-type1", "focus")
	self:SetAttribute("type3", "focus")
	self:SetAttribute("*type2", "menu")

	-- Health bar
	local hp = CreateFrame"StatusBar"
	hp:SetStatusBarTexture(AmdirFrame.textures[AmdirFrame.db.texture])
	fixStatusbar(hp)
	hp:SetOrientation(AmdirFrame.db.orientation)
	hp:SetParent(self)
	hp:SetPoint"TOP"
	hp:SetPoint"LEFT"
	if AmdirFrame.db.orientation == "VERTICAL" then
		hp:SetPoint"BOTTOM"
	else
		hp:SetPoint"RIGHT"
	end
	hp.frequentUpdates = true
	
	-- HP background
	local hpbg = hp:CreateTexture(nil, "BORDER")
	hpbg:SetTexture(AmdirFrame.textures[AmdirFrame.db.texture])
	hpbg:SetAllPoints(hp)

	hp.bg = hpbg
	hp.PostUpdate = updateHealth
	self.Health = hp
    
	if AmdirFrame.db.powerbar then
		powerbar(self)
	end

	-- Threat
	local threat = CreateFrame("Frame", nil, self)
	threat:SetPoint("TOPLEFT", self, "TOPLEFT", -4, 4)
	threat:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -4)
	threat:SetFrameStrata("LOW")
	threat:SetBackdrop(glowBorder)
	threat:SetBackdropColor(0, 0, 0, 0)
	threat:SetBackdropBorderColor(0, 0, 0, 1)
	threat.Update = updateThreat
	self.Threat = threat

	-- Name/Hp
	local info = hp:CreateFontString(nil, "OVERLAY")
	info:SetPoint("CENTER")
	info:SetJustifyH("CENTER")
	info:SetFont(AmdirFrame.fonts[AmdirFrame.db.font], AmdirFrame.db.fontsize)
	info:SetShadowOffset(1.25, -1.25)
	self.Info = info

	-- Dead/DC/Ghost text
	local DDG = hp:CreateFontString(nil, "OVERLAY")
	DDG:SetPoint("BOTTOM")
	DDG:SetJustifyH("CENTER")
	DDG:SetFont(AmdirFrame.fonts[AmdirFrame.db.font], AmdirFrame.db.fontsize-2)
	DDG:SetShadowOffset(1.25, -1.25)
	self:Tag(DDG, '[amdirframe:ddg]')

	-- Highliget tex
	local hl = hp:CreateTexture(nil, "OVERLAY")
	hl:SetAllPoints(self)
	hl:SetTexture(mediaPath .. "white.tga")
	hl:SetVertexColor(1,1,1,.1)
	hl:SetBlendMode("ADD")
	hl:Hide()
	self.Highlight = hl

	-- Target tex
	local tBorder = CreateFrame("Frame", nil, self)
	tBorder:SetPoint("TOPLEFT", self, "TOPLEFT")
	tBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	tBorder:SetBackdrop(border)
	tBorder:SetFrameLevel(2)
	tBorder:Hide()
	self.TargetBorder = tBorder
	
	-- Focus tex
	local fBorder = CreateFrame("Frame", nil, self)
	fBorder:SetPoint("TOPLEFT", self, "TOPLEFT")
	fBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	fBorder:SetBackdrop(border)
	fBorder:SetFrameLevel(2)
	fBorder:Hide()
	self.FocusHighlight = fBorder

	-- Raid Icons
	local ricon = hp:CreateTexture(nil, 'OVERLAY')
	ricon:SetPoint("TOP", self, 0, 5)
	ricon:SetSize(AmdirFrame.db.iconsize, AmdirFrame.db.iconsize)
	self.RaidIcon = ricon

	-- Leader Icon
	self.Leader = hp:CreateTexture(nil, "OVERLAY")
	self.Leader:SetPoint("TOPLEFT", self, 0, 8)
	self.Leader:SetSize(AmdirFrame.db.iconsize, AmdirFrame.db.iconsize)
	
	-- Assistant Icon
	self.Assistant = hp:CreateTexture(nil, "OVERLAY")
	self.Assistant:SetPoint("TOPLEFT", self, 0, 8)
	self.Assistant:SetSize(AmdirFrame.db.iconsize, AmdirFrame.db.iconsize)
	
	local masterlooter = hp:CreateTexture(nil, 'OVERLAY')
	masterlooter:SetSize(AmdirFrame.db.iconsize, AmdirFrame.db.iconsize)
	masterlooter:SetPoint('LEFT', self.Leader, 'RIGHT')
	self.MasterLooter = masterlooter
	
	-- LFD Icon
	if AmdirFrame.db.lfdicon then
		self.LFDRole = hp:CreateTexture(nil, 'OVERLAY')
		self.LFDRole:SetSize(AmdirFrame.db.iconsize, AmdirFrame.db.iconsize)
		self.LFDRole:SetPoint('RIGHT', self, 'LEFT', AmdirFrame.db.iconsize/2, AmdirFrame.db.iconsize/2)
	end
    
    -- ResComm
	if AmdirFrame.db.rescomm then
		local rescomm = hp:CreateTexture(nil, "OVERLAY")
		rescomm:SetTexture([=[Interface\Icons\Spell_Holy_Resurrection]=])
			rescomm:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			rescomm:SetAllPoints(hp)
			rescomm:SetAlpha(AmdirFrame.db.rescommalpha)
			rescomm:Hide()
			self.ResComm = rescomm
		end
	
	if (self:GetAttribute('unitsuffix') == 'target') then
	else
		-- Enable Indicators
		self.Indicators = true
        
		-- Range
		self.Range = {
			insideAlpha = AmdirFrame.db.inRange,
			outsideAlpha = AmdirFrame.db.outsideRange,
		}
        
		-- Healcomm
		addHealcomm(self)
		
			-- ReadyCheck
			self.ReadyCheck = hp:CreateTexture(nil, "OVERLAY")
			self.ReadyCheck:SetPoint("TOP", self)
			self.ReadyCheck:SetSize(AmdirFrame.db.iconsize, AmdirFrame.db.iconsize)
			self.ReadyCheck:Hide()
			self.ReadyCheck.delayTime = 8
			self.ReadyCheck.fadeTime = 1
		
		-- Debuffs
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetSize(AmdirFrame.db.debuffsize, AmdirFrame.db.debuffsize)
		debuffs:SetPoint("CENTER", hp)
		debuffs.size = AmdirFrame.db.debuffsize
		
		debuffs.CustomFilter = CustomFilter
		self.amdirDebuffs = debuffs
		local dispels = CreateFrame("Frame", nil, self)
		dispels.size = math.max(10, math.floor(AmdirFrame.db.debuffsize * .7))
		dispels:SetSize(dispels.size, dispels.size)
		dispels:SetPoint("BOTTOMLEFT", hp, "BOTTOMLEFT", 1, 1)
		dispels.dispelOnly = true
		dispels.CustomFilter = CustomFilter
		self.amdirDispels = dispels
	end
	
	-- Add events
	self:RegisterEvent('PLAYER_FOCUS_CHANGED', FocusTarget)
	self:RegisterEvent('RAID_ROSTER_UPDATE', FocusTarget)
	self:RegisterEvent('PLAYER_TARGET_CHANGED', ChangedTarget)
	self:RegisterEvent('RAID_ROSTER_UPDATE', ChangedTarget)
		
	-- Unit sizes
	self:SetAttribute('initial-height', AmdirFrame.db.height)
	self:SetAttribute('initial-width', AmdirFrame.db.width)
end

local function SAP()
	if not AmdirFrame then return end
	
	local pos, posRel, spacingX, spacingY, colX, colY, growth, point
	local db = AmdirFrame.db
	-- SetPoint of MOTHERFUCKING DOOM!
	if db.point == "TOP" and db.growth == "LEFT" then
		pos = "TOPRIGHT"
		posRel = "TOPLEFT"
		growth = "RIGHT"
		spacingX = 0
		spacingY = -(db.spacing)
		colX = -(db.spacing)
		colY = 0
		point = "TOPRIGHT"
	elseif db.point == "TOP" and db.growth == "RIGHT" then
		pos = "TOPLEFT"
		posRel = "TOPRIGHT"
		growth = "LEFT"
		spacingX = 0
		spacingY = -(db.spacing)
		colX = db.spacing
		colY = 0
		point = "TOPLEFT"
	elseif db.point == "LEFT" and db.growth == "UP" then
		pos = "BOTTOMLEFT"
		posRel = "TOPLEFT"
		growth = "BOTTOM"
		spacingX = db.spacing
		spacingY = 0
		colX = 0
		colY = db.spacing
		point = "BOTTOMLEFT"
	elseif db.point == "LEFT" and db.growth == "DOWN" then
		pos = "TOPLEFT"
		posRel = "BOTTOMLEFT"
		growth = "TOP"
		spacingX = db.spacing
		spacingY = 0
		colX = 0
		colY = -(db.spacing)
		point = "TOPLEFT"
	elseif db.point == "RIGHT" and db.growth == "UP" then
		pos = "BOTTOMRIGHT"
		posRel = "TOPRIGHT"
		growth = "BOTTOM"
		spacingX = -(db.spacing)
		spacingY = 0
		colX = 0
		colY = db.spacing
		point = "BOTTOMRIGHT"
	elseif db.point == "RIGHT" and db.growth == "DOWN" then
		pos = "TOPRIGHT"
		posRel = "BOTTOMRIGHT"
		growth = "TOP"
		spacingX = -(db.spacing)
		spacingY = 0
		colX = 0
		colY = -(db.spacing)
		point = "TOPRIGHT"
	elseif db.point == "BOTTOM" and db.growth == "LEFT" then
		pos = "BOTTOMRIGHT"
		posRel = "BOTTOMLEFT"
		growth = "RIGHT"
		spacingX = 0
		spacingY = (db.spacing)
		colX = -(db.spacing)
		colY = 0
		point = "BOTTOMRIGHT"
	elseif db.point == "BOTTOM" and db.growth == "RIGHT" then
		pos = "BOTTOMLEFT"
		posRel = "BOTTOMRIGHT"
		growth = "LEFT"
		spacingX = 0
		spacingY = (db.spacing)
		colX = (db.spacing)
		colY = 0
		point = "BOTTOMLEFT"
	else -- You failed to equal any of the above. So I give this...
		pos = "TOPLEFT"
		posRel = "TOPRIGHT"
		growth = "LEFT"
		spacingX = 0
		spacingY = -(db.spacing)
		colX = db.spacing
		colY = 0
		point = "TOPLEFT"
	end
	
	return pos, posRel, spacingX, spacingY, colX, colY, growth, point
end

oUF:RegisterStyle("AmdirFrame", style)
	
oUF:Factory(function(self)
	self:SetActiveStyle"AmdirFrame"

    AMDIRFRAMEENABLE()
	
	local visible
	if AmdirFrame.db.solo and AmdirFrame.db.partyOn then
		visible = 'raid,party,solo'
	elseif AmdirFrame.db.solo and not AmdirFrame.db.partyOn then
		visible = 'raid,solo'
	elseif AmdirFrame.db.partyOn and not AmdirFrame.db.solo then
		visible = 'raid,party'
	else
		visible = 'raid'
	end
	
	local pos, posRel, spacingX, spacingY, colX, colY, growth, point = SAP()
	
	if AmdirFrame.db.multi then
		raid = {}
		for i = 1, AmdirFrame.db.numCol do 
			local group = self:SpawnHeader('Raid_AmdirFrame'..i, nil, visible,
				'showPlayer', AmdirFrame.db.player,
				'showSolo', true,
				'showParty', AmdirFrame.db.partyOn,
				'showRaid', true,
				'xoffset', spacingX, 
				'yOffset', spacingY,
				'point', AmdirFrame.db.point,
				'groupFilter', tostring(i),
				'groupingOrder', '1,2,3,4,5,6,7,8',
				'groupBy', 'GROUP',
				'maxColumns', AmdirFrame.db.numCol,
				'unitsPerColumn', AmdirFrame.db.numUnits,
				'columnSpacing', AmdirFrame.db.spacing,
				'columnAnchorPoint', growth
			)
			if i == 1 then
				group:SetPoint(point, "AmdirFrameRaidFrame", point)
			else
				group:SetPoint(pos, raid[i-1], posRel, colX, colY)
			end
			group:SetScale(AmdirFrame.db.scale)
			raid[i] = group
		end
	else
		raid = self:SpawnHeader('Raid_AmdirFrame', nil, visible,
			'showPlayer', AmdirFrame.db.player,
			'showSolo', true,
			'showParty', AmdirFrame.db.partyOn,
			'showRaid', true,
			'xoffset', spacingX, 
			'yOffset', spacingY,
			'point', AmdirFrame.db.point,
			'groupFilter', '1,2,3,4,5,6,7,8',
			'groupingOrder', '1,2,3,4,5,6,7,8',
			'groupBy', 'GROUP',
			'maxColumns', AmdirFrame.db.numCol,
			'unitsPerColumn', AmdirFrame.db.numUnits,
			'columnSpacing', AmdirFrame.db.spacing,
			'columnAnchorPoint', growth
		)
		raid:SetPoint(point, "AmdirFrameRaidFrame", point)
		raid:SetScale(AmdirFrame.db.scale)
	end
	
	if AmdirFrame.db.pets then
		local pets = self:SpawnHeader('Pet_AmdirFrame', 'SecureGroupPetHeaderTemplate', visible,
			'showSolo', true,
			'showParty', AmdirFrame.db.partyOn,
			'showRaid', true,
			'xoffset', spacingX,
			'yOffset', spacingY,
			'point', AmdirFrame.db.point,
			'maxColumns', AmdirFrame.db.numCol,
			'unitsPerColumn', AmdirFrame.db.numUnits,
			'columnSpacing', AmdirFrame.db.spacing,
			'columnAnchorPoint', growth
		)
		pets:SetPoint(point, "AmdirFramePetFrame", point)
		pets:SetScale(AmdirFrame.db.scale)
	end
	
	if AmdirFrame.db.MT then
		local tank = self:SpawnHeader('MT_AmdirFrame', nil, visible,
			"showRaid", true,
			"yOffset", -AmdirFrame.db.spacing
		)
		tank:SetPoint(point, "AmdirFrameMTFrame", point)
	
		if oRA3 then
			local tankhandler = CreateFrame("Frame")
			local function updateTanks()
				if InCombatLockdown() then
					tankhandler:RegisterEvent("PLAYER_REGEN_ENABLED")
					return
				end
				tankhandler:UnregisterEvent("PLAYER_REGEN_ENABLED")
				local assistants, names = {}, {}
				if AmdirFrame.db.OT then
					for i = 1, GetNumRaidMembers() do
						local name, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i)
						if name and role == "MAINASSIST" then assistants[name] = true end
					end
				end
				for _, name in ipairs(oRA3:GetSortedTanks() or {}) do
					if not assistants[name] then names[#names + 1] = name end
				end
				-- oRA3 can briefly return an empty list while changing zones.  In
				-- that case fall back to Blizzard's MAINTANK role instead of hiding
				-- the whole header.
				if #names > 0 then
					tank:SetAttribute("groupFilter", nil)
					tank:SetAttribute("nameList", table.concat(names, ","))
				else
					tank:SetAttribute("nameList", nil)
					tank:SetAttribute("groupFilter", "MAINTANK")
				end
			end
			local function scheduleUpdate()
				tankhandler.updateAt = GetTime() + 1
				tankhandler:SetScript("OnUpdate", function(self)
					if GetTime() < self.updateAt then return end
					self:SetScript("OnUpdate", nil)
					self.updateAt = nil
					updateTanks()
				end)
			end
			tankhandler.OnTanksUpdated = updateTanks
			tankhandler:RegisterEvent("RAID_ROSTER_UPDATE")
			tankhandler:RegisterEvent("PLAYER_ENTERING_WORLD")
			tankhandler:RegisterEvent("ZONE_CHANGED_NEW_AREA")
			tankhandler:SetScript("OnEvent", function(self, event)
				if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
					scheduleUpdate()
				else
					updateTanks()
				end
			end)
			oRA3.RegisterCallback(tankhandler, "OnTanksUpdated")
			updateTanks()
		
		else
			tank:SetAttribute('groupFilter', 'MAINTANK')
		end
		tank:SetScale(AmdirFrame.db.scale)
	end

	if AmdirFrame.db.OT then
		local offtank = self:SpawnHeader('OT_AmdirFrame', nil, visible,
			"showRaid", true,
			"yOffset", -AmdirFrame.db.spacing,
			"groupFilter", "MAINASSIST"
		)
		offtank:SetPoint(point, "AmdirFrameOTFrame", point)
		offtank:SetScale(AmdirFrame.db.scale)
	end
end)

AmdirFrame = AmdirFrame or {}
local AmdirFrame, f = AmdirFrame, CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)
	if addon ~= ADDON_NAME then return end
	
	if not AmdirFrameDB and type(FreebgridDB) == "table" then AmdirFrameDB = FreebgridDB end
	AmdirFrameDB = AmdirFrameDB or {}
	AmdirFrame.db = AmdirFrameDB
	
	for k, v in pairs(AmdirFrameDefaults) do
		if(type(AmdirFrameDB[k]) == 'nil') then
			AmdirFrameDB[k] = v
		end
	end
	
	LibStub("tekKonfig-AboutPanel").new("AmdirFrame", ADDON_NAME)
	
	self:UnregisterEvent("ADDON_LOADED")
end)

SLASH_AMDIRFRAMEOMF1 = '/amdirframe'
SLASH_AMDIRFRAMEOMF2 = '/freeb'
SlashCmdList['AMDIRFRAMEOMF'] = function(inp)
	if inp:match("^%s*test%s*$") then
		AMDIRFRAMETEST()
	elseif inp:match("^%s*reset%s*$") then
		AMDIRFRAMERESET()
	elseif(inp:match("%S+")) then
		InterfaceOptionsFrame_OpenToCategory'AmdirFrame'
	else
		AMDIRFRAMEMOVABLE()
	end
end
