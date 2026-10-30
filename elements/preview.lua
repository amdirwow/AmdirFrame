-- Decorative previews only: never assign units or change secure headers.
local preview = CreateFrame("Frame", nil, UIParent)
preview:Hide()
preview:RegisterEvent("PLAYER_REGEN_DISABLED")
preview:SetScript("OnEvent", function(self) self:Hide() end)
local buttons = {}
local classes = {"WARRIOR", "PALADIN", "PRIEST", "DRUID", "MAGE"}

local function showBlock(anchor, count, label, raid)
	local db = AmdirFrame.db
	local horizontal = db.point == "LEFT" or db.point == "RIGHT"
	local corner = (db.point == "BOTTOM" or db.growth == "UP") and "BOTTOM" or "TOP"
	corner = corner .. ((db.point == "RIGHT" or db.growth == "LEFT") and "RIGHT" or "LEFT")
	local sx = corner:find("RIGHT") and -1 or 1
	local sy = corner:find("BOTTOM") and 1 or -1
	for i = 1, count do
		local key = label .. i
		local bar = buttons[key]
		if not bar then
			bar = CreateFrame("StatusBar", nil, preview)
			bar:SetFrameStrata("DIALOG")
			bar:SetMinMaxValues(0, 100)
			bar.bg = bar:CreateTexture(nil, "BACKGROUND")
			bar.bg:SetAllPoints(bar)
			bar.bg:SetTexture(0.08, 0.08, 0.08, .9)
			bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			bar.text:SetPoint("CENTER")
			bar.aura = bar:CreateTexture(nil, "OVERLAY")
			bar.aura:SetPoint("BOTTOMRIGHT")
			buttons[key] = bar
		end
		local row = raid and (i - 1) % db.numUnits or i - 1
		local col = raid and math.floor((i - 1) / db.numUnits) or 0
		local x, y = col, row
		if horizontal then x, y = row, col end
		bar:SetSize(db.width, db.height)
		bar:SetScale(db.scale)
		bar:ClearAllPoints()
		bar:SetPoint(corner, anchor, corner, sx * x * (db.width + db.spacing), sy * y * (db.height + db.spacing))
		bar:SetStatusBarTexture(AmdirFrame.textures[db.texture])
		bar:SetOrientation(db.orientation)
		local color = RAID_CLASS_COLORS[classes[(i - 1) % #classes + 1]]
		bar:SetStatusBarColor(color.r, color.g, color.b)
		bar:SetValue(35 + (i * 13) % 66)
		bar.text:SetText(label .. i)
		bar.aura:SetSize(db.debuffsize, db.debuffsize)
		bar.aura:SetTexture(select(3, GetSpellInfo(70541)))
		if i % 4 == 0 then bar.aura:Show() else bar.aura:Hide() end
		bar:Show()
	end
end

AMDIRFRAMETEST = function()
	if InCombatLockdown() then return print("AmdirFrame: тест недоступний у бою.") end
	if preview:IsShown() then preview:Hide(); return end
	for _, bar in pairs(buttons) do bar:Hide() end
	showBlock(AmdirFrameRaidFrame, 25, "Тест", true)
	showBlock(AmdirFramePetFrame, 5, "Пет", false)
	showBlock(AmdirFrameMTFrame, 1, "МТ", false)
	showBlock(AmdirFrameOTFrame, 1, "ОТ", false)
	preview:Show()
	if AmdirFrame.db.locked then AMDIRFRAMEMOVABLE() end
	print("AmdirFrame: тестові фрейми увімкнено. /amdirframe test — закрити.")
end

local panel = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
panel.name, panel.parent = "Інструменти розміщення", "AmdirFrame"
panel:Hide()
panel:SetScript("OnShow", function(self)
	LibStub("tekKonfig-Heading").new(self, "Інструменти розміщення", "Тест і прилипання застосовуються одразу. Решта змін потребує /reload.")
	local slider, label = LibStub("tekKonfig-Slider").new(self, "Відстань прилипання", 0, 30, "TOPLEFT", self, "TOPLEFT", 20, -90)
	slider:SetValueStep(1)
	slider:SetValue(AmdirFrame.db.snapdistance)
	label:SetText("Відстань прилипання: " .. AmdirFrame.db.snapdistance)
	slider:SetScript("OnValueChanged", function(s)
		local value = math.floor(s:GetValue() + .5)
		AmdirFrame.db.snapdistance = value
		label:SetText("Відстань прилипання: " .. value)
	end)
	local function button(text, y, action)
		local b = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
		b:SetSize(230, 24)
		b:SetPoint("TOPLEFT", 20, y)
		b:SetText(text)
		b:SetScript("OnClick", action)
	end
	button("Тест: 25 / пети / МТ / ОТ", -150, AMDIRFRAMETEST)
	button("Скинути всі позиції", -185, AMDIRFRAMERESET)
	button("Розблокувати / заблокувати", -220, AMDIRFRAMEMOVABLE)
	self:SetScript("OnShow", nil)
end)
InterfaceOptions_AddCategory(panel)
