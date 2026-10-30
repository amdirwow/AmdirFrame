local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUF
--[[
	This is a stripped and modified oUF Auras to fit my needs.
	-- freebaser
]]--

local createAuraIcon = function(debuffs)
	local button = CreateFrame("Button", nil, debuffs)
	button:EnableMouse(false)
	
	button:SetSize(debuffs.size, debuffs.size)

	local cd = CreateFrame("Cooldown", nil, button)
	cd:SetAllPoints(button)
	cd:SetReverse()

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetAllPoints(button)
	icon:SetTexCoord(.07, .93, .07, .93)
	
	local count = button:CreateFontString(nil, "OVERLAY")
	count:SetFontObject(NumberFontNormal)
	count:SetPoint("LEFT", button, "BOTTOM", 3, 2)

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetTexture("Interface\\AddOns\\" .. ADDON_NAME .. "\\media\\border")
	overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
	overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
	overlay:SetTexCoord(0, 1, 0.02, 1)
	button.overlay = overlay
	
	button:SetPoint("BOTTOMLEFT", debuffs, "BOTTOMLEFT")
	
	button.parent = debuffs
	button.icon = icon
	button.count = count
	button.cd = cd
	button:Hide()
	
	debuffs.button = button
end

local updateDebuff = function(icon, texture, count, dtype, duration, timeLeft)
	local cd = icon.cd
	if(duration and duration > 0) then
		cd:SetCooldown(timeLeft - duration, duration)
		cd:Show()
	else
		cd:Hide()
	end

	local color = DebuffTypeColor[dtype] or DebuffTypeColor.none

	icon.overlay:SetVertexColor(color.r, color.g, color.b)
	icon.overlay:Show()

	icon.icon:SetTexture(texture)
	icon.count:SetText((count > 1 and count))
end

local updateIcon = function(unit, debuffs)
	local icon = debuffs.button
	local best, selected = 0
	icon:Hide()
	for _, filter in ipairs(debuffs.dispelOnly and {"HARMFUL"} or {"HARMFUL", "HELPFUL"}) do
		local index = 1
		while true do
			local name, rank, texture, count, dtype, duration, expires, caster, stealable, consolidate, spellID = UnitAura(unit, index, filter)
			if not name then break end
			local show = debuffs.CustomFilter(debuffs, unit, icon, name, rank, texture, count, dtype, duration, expires, caster, stealable, consolidate, spellID)
			if show and (filter == "HARMFUL" or icon.buff)
				and (debuffs.dispelOnly or not icon.dispel) and icon.priority > best then
				best = icon.priority
				selected = {texture, count or 0, dtype, duration, expires}
			end
			index = index + 1
		end
	end
	if selected then
		updateDebuff(icon, selected[1], selected[2], selected[3], selected[4], selected[5])
		icon:Show()
	end
end

local Update = function(self, event, unit)
	if(self.unit ~= unit) then return end

	local debuffs = self.amdirDebuffs
	if(debuffs) then
		updateIcon(unit, debuffs)	
	end
	if self.amdirDispels then updateIcon(unit, self.amdirDispels) end
end

local Enable = function(self)
	if(self.amdirDebuffs) then
		createAuraIcon(self.amdirDebuffs)
		if self.amdirDispels then createAuraIcon(self.amdirDispels) end
		self:RegisterEvent("UNIT_AURA", Update)

		return true
	end
end

local Disable = function(self)
	if(self.amdirDebuffs) then
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement('amdirDebuffs', Update, Enable, Disable)
