if not AmdirFrame then return end

-- These are just the defaults that are created as a base.
AmdirFrameDefaults = {
	locked = true,
	
	scale = 1.0,
	width = 42,
	height = 42,
    
	powerbar = false,
	powerbarsize = 0.08,
    
	reversecolors = false,
	
	iconsize = 12,
	debuffsize = 18,
	fontsize = 14,
	
	inRange = 1,
	outsideRange = 0.4,
	
	texture = "gradient",
	font = "calibri",
	
	solo = false,
	player = true,
	partyOn = true,
	
	pets = false,
    
	MT = true,
	OT = true,
	
	symbolsize = 11,
	indicatorsize = 6,
	
	numCol = 8,
	numUnits = 5,
	spacing = 5,
	snapdistance = 12,
    
	orientation = "VERTICAL",
	point = "TOP",
	growth = "RIGHT",
	
	
	healcommtext = true,
	healcommbar = false,
	healcommoverflow = true,
	healothersonly = false,
	healalpha = 0.4, 
    
	rescomm =  true,
	rescommalpha = 0.6,
	
	showname = false,
	
	
	lfdicon = true,
	
	frequent = false,
	multi = false,
}

AmdirFrame.orientation = {
	["VERTICAL"] = "VERTICAL",
	["HORIZONTAL"] = "HORIZONTAL",
}
AmdirFrame.orientationLabels = {VERTICAL = "Вертикальна", HORIZONTAL = "Горизонтальна"}

AmdirFrame.point = {
	["TOP"] = "TOP",
	["RIGHT"] = "RIGHT",
	["BOTTOM"] = "BOTTOM",
	["LEFT"] = "LEFT",
}
AmdirFrame.pointLabels = {TOP = "Згори", RIGHT = "Праворуч", BOTTOM = "Знизу", LEFT = "Ліворуч"}

AmdirFrame.growth = {
	["UP"] = "UP",
	["RIGHT"] = "RIGHT",
	["DOWN"] = "DOWN",
	["LEFT"] = "LEFT",
}
AmdirFrame.growthLabels = {UP = "Вгору", RIGHT = "Праворуч", DOWN = "Вниз", LEFT = "Ліворуч"}

function AmdirFrame:SetTex(v)
	if v then self.db.texture = v end
end

function AmdirFrame:SetFont(v)
	if v then self.db.font = v end
end

function AmdirFrame:SetOrientation(v)
	if v then self.db.orientation = v end
end

function AmdirFrame:SetPoint(v)
	if v then self.db.point = v end
end

function AmdirFrame:SetGrowth(v)
	if v then self.db.growth = v end
end

----------------------
--      Locals      --
----------------------

local tekcheck = LibStub("tekKonfig-Checkbox")
local tekbutton = LibStub("tekKonfig-Button")
local tekslider = LibStub("tekKonfig-Slider")
local tekdropdown = LibStub("tekKonfig-Dropdown")
local GAP = 7

local function texfunc(frame)
	local texturedropdown, texturedropdowntext, texturedropdowncontainer = tekdropdown.new(frame, "Текстура", "TOPRIGHT", frame, 0, 0)
	texturedropdowntext:SetText(AmdirFrame.db.texture or AmdirFrameDefaults.texture)
	texturedropdown.tiptext = "Змінює текстуру фреймів."

	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(texturedropdown, self.value)
		texturedropdowntext:SetText(self.value)
		AmdirFrame:SetTex(self.value)
	end
	UIDropDownMenu_Initialize(texturedropdown, function()
		local selected, info = UIDropDownMenu_GetSelectedValue(texturedropdown) or AmdirFrame.db.texture, UIDropDownMenu_CreateInfo()

		for name in pairs(AmdirFrame.textures) do
			info.text = name
			info.value = name
			info.func = OnClick
			info.checked = name == selected
			UIDropDownMenu_AddButton(info)
		end
	end)
end

local function fontfunc(frame)
	local fontdropdown, fontdropdowntext, fontdropdowncontainer = tekdropdown.new(frame, "Шрифт", "TOPRIGHT", frame, 0, -50)
	fontdropdowntext:SetText(AmdirFrame.db.font or AmdirFrameDefaults.font)
	fontdropdown.tiptext = "Змінює шрифт фреймів."

	local function FontOnClick(self)
		UIDropDownMenu_SetSelectedValue(fontdropdown, self.value)
		fontdropdowntext:SetText(self.value)
		AmdirFrame:SetFont(self.value)
	end
	UIDropDownMenu_Initialize(fontdropdown, function()
		local selected, info = UIDropDownMenu_GetSelectedValue(fontdropdown) or AmdirFrame.db.font, UIDropDownMenu_CreateInfo()

		for name in pairs(AmdirFrame.fonts) do
			info.text = name
			info.value = name
			info.func = FontOnClick
			info.checked = name == selected
			UIDropDownMenu_AddButton(info)
		end
	end)
end

local function orientationfunc(frame)
	local orientationdropdown, orientationdropdowntext, orientationdropdowncontainer = tekdropdown.new(frame, "Орієнтація смуг", "TOPRIGHT", frame, 0, -100)
	orientationdropdowntext:SetText(AmdirFrame.orientationLabels[AmdirFrame.db.orientation or AmdirFrameDefaults.orientation])
	orientationdropdown.tiptext = "Змінює орієнтацію смуг."

	local function OrientationOnClick(self)
		UIDropDownMenu_SetSelectedValue(orientationdropdown, self.value)
		orientationdropdowntext:SetText(AmdirFrame.orientationLabels[self.value])
		AmdirFrame:SetOrientation(self.value)
	end

	UIDropDownMenu_Initialize(orientationdropdown, function()
		local selected, info = UIDropDownMenu_GetSelectedValue(orientationdropdown) or AmdirFrame.db.orientation, UIDropDownMenu_CreateInfo()

		for name in pairs(AmdirFrame.orientation) do
			info.text = AmdirFrame.orientationLabels[name]
			info.value = name
			info.func = OrientationOnClick
			info.checked = name == selected
			UIDropDownMenu_AddButton(info)
		end
	end)
end

local function pointfunc(frame)
	local pointdropdown, pointdropdowntext, pointdropdowncontainer = tekdropdown.new(frame, "Точка росту", "TOPRIGHT", frame, 0, -150)
	pointdropdowntext:SetText(AmdirFrame.pointLabels[AmdirFrame.db.point or AmdirFrameDefaults.point])
	pointdropdown.tiptext = "Вибирає точку додавання нових фреймів."

	local function PointClick(self)
		UIDropDownMenu_SetSelectedValue(pointdropdown, self.value)
		pointdropdowntext:SetText(AmdirFrame.pointLabels[self.value])
		AmdirFrame:SetPoint(self.value)
	end

	UIDropDownMenu_Initialize(pointdropdown, function()
		local selected, info = UIDropDownMenu_GetSelectedValue(pointdropdown) or AmdirFrame.db.point, UIDropDownMenu_CreateInfo()

		for name in pairs(AmdirFrame.point) do
			info.text = AmdirFrame.pointLabels[name]
			info.value = name
			info.func = PointClick
			info.checked = name == selected
			UIDropDownMenu_AddButton(info)
		end
	end)
end

local function growthfunc(frame)
	local growthdropdown, growthdropdowntext, growthdropdowncontainer = tekdropdown.new(frame, "Напрямок росту", "TOPRIGHT", frame, 0, -200)
	growthdropdowntext:SetText(AmdirFrame.growthLabels[AmdirFrame.db.growth or AmdirFrameDefaults.growth])
	growthdropdown.tiptext = "Вибирає напрямок росту груп."

	local function GrowthOnClick(self)
		UIDropDownMenu_SetSelectedValue(growthdropdown, self.value)
		growthdropdowntext:SetText(AmdirFrame.growthLabels[self.value])
		AmdirFrame:SetGrowth(self.value)
	end

	UIDropDownMenu_Initialize(growthdropdown, function()
		local selected, info = UIDropDownMenu_GetSelectedValue(growthdropdown) or AmdirFrame.db.growth, UIDropDownMenu_CreateInfo()

		for name in pairs(AmdirFrame.growth) do
			info.text = AmdirFrame.growthLabels[name]
			info.value = name
			info.func = GrowthOnClick
			info.checked = name == selected
			UIDropDownMenu_AddButton(info)
		end
	end)
end

-----------------------
--      Panel 1      --
-----------------------

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "AmdirFrame"
frame:Hide()
frame:SetScript("OnShow", function(frame)
	local AmdirFrame = AmdirFrame
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "AmdirFrame", "Зміни вигляду потребують /reload. Інструменти: /amdirframe test, /amdirframe reset.")

	local lockpos = tekcheck.new(frame, nil, "Розблокувати", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, 0)
	lockpos.tiptext = "Дозволяє переміщувати блоки."
	local checksound = lockpos:GetScript("OnClick")
	lockpos:SetScript("OnClick", function() AMDIRFRAMEMOVABLE() end)
	lockpos:SetChecked(not AmdirFrame.db.locked)
	

	local scaleslider, scaleslidertext, scalecontainer = tekslider.new(frame, string.format("Масштаб: %.2f", AmdirFrame.db.scale or AmdirFrameDefaults.scale), 0.5, 2, "TOPLEFT", lockpos, "BOTTOMLEFT", 0, -GAP)
	scaleslider.tiptext = "Встановлює масштаб фреймів."
	scaleslider:SetValue(AmdirFrame.db.scale or AmdirFrameDefaults.scale)
	scaleslider:SetValueStep(.05)
	scaleslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.scale = self:GetValue()
		scaleslidertext:SetText(string.format("Масштаб: %.2f", AmdirFrame.db.scale or AmdirFrameDefaults.scale))
	end)
	
	local widthslider, widthslidertext, widthcontainer = tekslider.new(frame, string.format("Ширина: %d", AmdirFrame.db.width or AmdirFrameDefaults.width), 20, 100, "TOPLEFT", scaleslider, "BOTTOMLEFT", 0, -GAP)
	widthslider.tiptext = "Встановлює ширину фреймів."
	widthslider:SetValue(AmdirFrame.db.width or AmdirFrameDefaults.width)
	widthslider:SetValueStep(1)
	widthslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.width = self:GetValue()
		widthslidertext:SetText(string.format("Ширина: %d", AmdirFrame.db.width or AmdirFrameDefaults.width))
	end)
	
	local heightslider, heightslidertext, heightcontainer = tekslider.new(frame, string.format("Висота: %d", AmdirFrame.db.height or AmdirFrameDefaults.height), 20, 100, "TOPLEFT", widthslider, "BOTTOMLEFT", 0, -GAP)
	heightslider.tiptext = "Встановлює висоту фреймів."
	heightslider:SetValue(AmdirFrame.db.height or AmdirFrameDefaults.height)
	heightslider:SetValueStep(1)
	heightslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.height = self:GetValue()
		heightslidertext:SetText(string.format("Висота: %d", AmdirFrame.db.height or AmdirFrameDefaults.height))
	end)
	
	local fontslider, fontslidertext, fontcontainer = tekslider.new(frame, string.format("Розмір шрифту: %d", AmdirFrame.db.fontsize or AmdirFrameDefaults.fontsize), 10, 30, "TOPLEFT", heightslider, "BOTTOMLEFT", 0, -GAP)
	fontslider.tiptext = "Встановлює розмір шрифту."
	fontslider:SetValue(AmdirFrame.db.fontsize or AmdirFrameDefaults.fontsize)
	fontslider:SetValueStep(1)
	fontslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.fontsize = self:GetValue()
		fontslidertext:SetText(string.format("Розмір шрифту: %d", AmdirFrame.db.fontsize or AmdirFrameDefaults.fontsize))
	end)
	
	local inRangeslider, inRangeslidertext, inRangecontainer = tekslider.new(frame, string.format("Прозорість у радіусі: %.2f", AmdirFrame.db.inRange or AmdirFrameDefaults.inRange), 0, 1, "TOPLEFT", fontslider, "BOTTOMLEFT", 0, -GAP)
	inRangeslider.tiptext = "Прозорість гравців у радіусі."
	inRangeslider:SetValue(AmdirFrame.db.inRange or AmdirFrameDefaults.inRange)
	inRangeslider:SetValueStep(.05)
	inRangeslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.inRange = self:GetValue()
		inRangeslidertext:SetText(string.format("Прозорість у радіусі: %.2f", AmdirFrame.db.inRange or AmdirFrameDefaults.inRange))
	end)
	
	local ooRangeslider, ooRangeslidertext, ooRangecontainer = tekslider.new(frame, string.format("Прозорість поза радіусом: %.2f", AmdirFrame.db.outsideRange or AmdirFrameDefaults.outsideRange), 0, 1, "TOPLEFT", inRangeslider, "BOTTOMLEFT", 0, -GAP)
	ooRangeslider.tiptext = "Прозорість гравців поза радіусом."
	ooRangeslider:SetValue(AmdirFrame.db.outsideRange or AmdirFrameDefaults.outsideRange)
	ooRangeslider:SetValueStep(.05)
	ooRangeslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.outsideRange = self:GetValue()
		ooRangeslidertext:SetText(string.format("Прозорість поза радіусом: %.2f", AmdirFrame.db.outsideRange or AmdirFrameDefaults.outsideRange))
	end)
	
	local iconsizeslider, iconsizeslidertext, iconsizecontainer = tekslider.new(frame, string.format("Розмір іконок: %d", AmdirFrame.db.iconsize or AmdirFrameDefaults.iconsize), 8, 20, "TOPLEFT", ooRangeslider, "BOTTOMLEFT", 0, -GAP)
	iconsizeslider.tiptext = "Розмір рейдових та службових іконок."
	iconsizeslider:SetValue(AmdirFrame.db.iconsize or AmdirFrameDefaults.iconsize)
	iconsizeslider:SetValueStep(1)
	iconsizeslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.iconsize = self:GetValue()
		iconsizeslidertext:SetText(string.format("Розмір іконок: %d", AmdirFrame.db.iconsize or AmdirFrameDefaults.iconsize))
	end)
	
	local debuffsizeslider, debuffsizeslidertext, debuffsizecontainer = tekslider.new(frame, string.format("Розмір дебафа: %d", AmdirFrame.db.debuffsize or AmdirFrameDefaults.debuffsize), 8, 30, "TOPLEFT", iconsizeslider, "BOTTOMLEFT", 0, -GAP)
	debuffsizeslider.tiptext = "Розмір іконки дебафа."
	debuffsizeslider:SetValue(AmdirFrame.db.debuffsize or AmdirFrameDefaults.debuffsize)
	debuffsizeslider:SetValueStep(1)
	debuffsizeslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.debuffsize = self:GetValue()
		debuffsizeslidertext:SetText(string.format("Розмір дебафа: %d", AmdirFrame.db.debuffsize or AmdirFrameDefaults.debuffsize))
	end)
    
	local spacingslider, spacingslidertext, spacingcontainer = tekslider.new(frame, string.format("Відступ: %d", AmdirFrame.db.spacing or AmdirFrameDefaults.spacing), 0, 30, "TOPRIGHT", frame, -40, -265)
	spacingslider.tiptext = "Відстань між фреймами."
	spacingslider:SetValue(AmdirFrame.db.spacing or AmdirFrameDefaults.spacing)
	spacingslider:SetValueStep(1)
	spacingslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.spacing = self:GetValue()
		spacingslidertext:SetText(string.format("Відступ: %d", AmdirFrame.db.spacing or AmdirFrameDefaults.spacing))
	end)
	
	local numColslider, numColslidertext, numColcontainer = tekslider.new(frame, string.format("Кількість груп: %d", AmdirFrame.db.numCol or AmdirFrameDefaults.numCol), 1, 8, "TOPLEFT", spacingslider, "BOTTOMLEFT", 0, -GAP)
	numColslider.tiptext = "Кількість рейдових груп."
	numColslider:SetValue(AmdirFrame.db.numCol or AmdirFrameDefaults.numCol)
	numColslider:SetValueStep(1)
	numColslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.numCol = self:GetValue()
		numColslidertext:SetText(string.format("Кількість груп: %d", AmdirFrame.db.numCol or AmdirFrameDefaults.numCol))
	end)
    
	local numUnitsslider, numUnitsslidertext, numUnitscontainer = tekslider.new(frame, string.format("Гравців у групі: %d", AmdirFrame.db.numUnits or AmdirFrameDefaults.numUnits), 1, 40, "TOPLEFT", numColslider, "BOTTOMLEFT", 0, -GAP)
	numUnitsslider.tiptext = "Кількість гравців у групі."
	numUnitsslider:SetValue(AmdirFrame.db.numUnits or AmdirFrameDefaults.numUnits)
	numUnitsslider:SetValueStep(1)
	numUnitsslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.numUnits = self:GetValue()
		numUnitsslidertext:SetText(string.format("Гравців у групі: %d", AmdirFrame.db.numUnits or AmdirFrameDefaults.numUnits))
	end)
    
	texfunc(frame)
	fontfunc(frame)
	orientationfunc(frame)
	pointfunc(frame)
	growthfunc(frame)
    
	local reload = tekbutton.new_small(frame)
	reload:SetPoint("BOTTOMRIGHT", -16, 16)
	reload:SetText("Перезавантажити")
	reload.tiptext = "Перезавантажити інтерфейс для застосування змін"
	reload:SetScript("OnClick", function() ReloadUI() end)

	frame:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(frame)

----------------------
--      Panel 2     --
----------------------

local f = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
f.name = "Додаткові налаштування"
f.parent = "AmdirFrame"
f:Hide()
f:SetScript("OnShow", function(f)
	local AmdirFrame = AmdirFrame

	local solo = tekcheck.new(f, nil, "Показувати гравця наодинці.", "BOTTOMLEFT", f, "TOPLEFT", 10, -40)
	local checksound = solo:GetScript("OnClick")
	solo:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.solo = not AmdirFrame.db.solo; end)
	solo:SetChecked(AmdirFrame.db.solo)
	
	local party = tekcheck.new(f, nil, "Показувати у групі.", "TOPLEFT", solo, "BOTTOMLEFT", 0, -GAP)
	party:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.partyOn = not AmdirFrame.db.partyOn; end)
	party:SetChecked(AmdirFrame.db.partyOn)
	
	local player = tekcheck.new(f, nil, "Показувати власний фрейм.", "TOPLEFT", party, "BOTTOMLEFT", 0, -GAP)
	player:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.player = not AmdirFrame.db.player; end)
	player:SetChecked(AmdirFrame.db.player)
	
	local lfdicon = tekcheck.new(f, nil, "Показувати іконку ролі.", "TOPLEFT", player, "BOTTOMLEFT", 0, -GAP)
	lfdicon:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.lfdicon = not AmdirFrame.db.lfdicon; end)
	lfdicon:SetChecked(AmdirFrame.db.lfdicon)
	
	local frequent = tekcheck.new(f, nil, "Часто оновлювати індикатори.", "TOPLEFT", lfdicon, "BOTTOMLEFT", 0, -GAP)
	frequent:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.frequent = not AmdirFrame.db.frequent; end)
	frequent:SetChecked(AmdirFrame.db.frequent)
    
	local reversecolors = tekcheck.new(f, nil, "Поміняти кольори здоров’я і фону.", "TOPLEFT", frequent, "BOTTOMLEFT", 0, -GAP)
	reversecolors:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.reversecolors = not AmdirFrame.db.reversecolors; end)
	reversecolors:SetChecked(AmdirFrame.db.reversecolors)
	
	local pets = tekcheck.new(f, nil, "Увімкнути петів групи/рейду. (/reload)", "TOPLEFT", reversecolors, "BOTTOMLEFT", 0, -GAP)
	pets:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.pets = not AmdirFrame.db.pets; end)
	pets:SetChecked(AmdirFrame.db.pets)
    
	local MT = tekcheck.new(f, nil, "Увімкнути мейн-танків. (/reload)", "TOPLEFT", pets, "BOTTOMLEFT", 0, -GAP)
	MT:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.MT = not AmdirFrame.db.MT; end)
	MT:SetChecked(AmdirFrame.db.MT)

	local OT = tekcheck.new(f, nil, "Увімкнути офтанків. (/reload)", "TOPLEFT", MT, "BOTTOMLEFT", 0, -GAP)
	OT:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.OT = not AmdirFrame.db.OT; end)
	OT:SetChecked(AmdirFrame.db.OT)
    
	
	local showname = tekcheck.new(f, nil, "Завжди показувати імена.", "TOPLEFT", OT, "BOTTOMLEFT", 0, -GAP)
	showname:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.showname = not AmdirFrame.db.showname; end)
	showname:SetChecked(AmdirFrame.db.showname)
	
	local multi = tekcheck.new(f, nil, "Окремі групи для кращого сортування.", "TOPLEFT", showname, "BOTTOMLEFT", 0, -GAP)
	multi:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.multi = not AmdirFrame.db.multi; end)
	multi:SetChecked(AmdirFrame.db.multi)
    
	local healgroup = LibStub("tekKonfig-Group").new(f, "Вхідне лікування")
	healgroup:SetHeight(190)
	healgroup:SetWidth(180)
	healgroup:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -15)
    
	local healcommtext = tekcheck.new(f, nil, "Показувати текст лікування.", "TOPLEFT", healgroup, "TOPLEFT", 15, -GAP)
	healcommtext:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.healcommtext = not AmdirFrame.db.healcommtext; end)
	healcommtext:SetChecked(AmdirFrame.db.healcommtext)
    
	local healcommbar = tekcheck.new(f, nil, "Показувати смугу лікування.", "TOPLEFT", healcommtext, "BOTTOMLEFT", 0, -GAP)
	healcommbar:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.healcommbar = not AmdirFrame.db.healcommbar; end)
	healcommbar:SetChecked(AmdirFrame.db.healcommbar)

	local healcommoverflow = tekcheck.new(f, nil, "Дозволити смузі виходити за максимум.", "TOPLEFT", healcommbar, "BOTTOMLEFT", 0, -GAP)
	healcommoverflow:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.healcommoverflow = not AmdirFrame.db.healcommoverflow; end)
	healcommoverflow:SetChecked(AmdirFrame.db.healcommoverflow)
    
	local healothersonly = tekcheck.new(f, nil, "Показувати лише чуже лікування.", "TOPLEFT", healcommoverflow, "BOTTOMLEFT", 0, -GAP)
	healothersonly:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.healothersonly = not AmdirFrame.db.healothersonly; end)
	healothersonly:SetChecked(AmdirFrame.db.healothersonly)
    
	local healalphaslider, healalphaslidertext, healalphacontainer = tekslider.new(f, string.format("Прозорість смуги лікування: %.2f", AmdirFrame.db.healalpha or AmdirFrameDefaults.healalpha), 0, 1, "TOPLEFT", healothersonly, "BOTTOMLEFT", 0, -GAP)
	healalphaslider.tiptext = "Прозорість смуги вхідного лікування."
	healalphaslider:SetValue(AmdirFrame.db.healalpha or AmdirFrameDefaults.healalpha)
	healalphaslider:SetValueStep(.05)
	healalphaslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.healalpha = self:GetValue()
		healalphaslidertext:SetText(string.format("Прозорість смуги лікування: %.2f", AmdirFrame.db.healalpha or AmdirFrameDefaults.healalpha))
	end)
    
	local resgroup = LibStub("tekKonfig-Group").new(f, "Воскресіння")
	resgroup:SetHeight(85)
	resgroup:SetWidth(180)
	resgroup:SetPoint("TOPRIGHT", healgroup, "BOTTOMRIGHT", 0, -GAP-2)
    
	local rescomm = tekcheck.new(f, nil, "Показувати воскресіння.", "TOPLEFT", resgroup, "TOPLEFT", 15, -GAP)
	rescomm:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.rescomm = not AmdirFrame.db.rescomm; end)
	rescomm:SetChecked(AmdirFrame.db.rescomm)
    
	local rescommalphaslider, rescommalphaslidertext, rescommalphacontainer = tekslider.new(f, string.format("Прозорість воскресіння: %.2f", AmdirFrame.db.rescommalpha or AmdirFrameDefaults.rescommalpha), 0, 1, "TOPLEFT", rescomm, "BOTTOMLEFT", 0, -GAP)
	rescommalphaslider.tiptext = "Прозорість індикатора воскресіння."
	rescommalphaslider:SetValue(AmdirFrame.db.rescommalpha or AmdirFrameDefaults.rescommalpha)
	rescommalphaslider:SetValueStep(.05)
	rescommalphaslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.rescommalpha = self:GetValue()
		rescommalphaslidertext:SetText(string.format("Прозорість воскресіння: %.2f", AmdirFrame.db.rescommalpha or AmdirFrameDefaults.rescommalpha))
	end)
    
	local powerbar = tekcheck.new(f, nil, "Показувати ману / енергію", "TOPLEFT", resgroup, "BOTTOMLEFT", 15, -GAP)
	powerbar:SetScript("OnClick", function(self) checksound(self); AmdirFrame.db.powerbar = not AmdirFrame.db.powerbar; end)
	powerbar:SetChecked(AmdirFrame.db.powerbar)
    
	local powerbarsizeslider, powerbarsizeslidertext, powerbarsizecontainer = tekslider.new(f, string.format("Товщина смуги ресурсу: %.2f", AmdirFrame.db.powerbarsize or AmdirFrameDefaults.powerbarsize), .02, .30, "TOPLEFT", powerbar, "BOTTOMLEFT", 0, -GAP)
	powerbarsizeslider.tiptext = "Частка висоти фрейму, яку займає нижня смуга ресурсу."
	powerbarsizeslider:SetValue(AmdirFrame.db.powerbarsize or AmdirFrameDefaults.powerbarsize)
	powerbarsizeslider:SetValueStep(.02)
	powerbarsizeslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.powerbarsize = self:GetValue()
		powerbarsizeslidertext:SetText(string.format("Товщина смуги ресурсу: %.2f", AmdirFrame.db.powerbarsize or AmdirFrameDefaults.powerbarsize))
	end)
    
	local symbolsizeslider, symbolsizeslidertext, symbolsizecontainer = tekslider.new(f, string.format("Розмір символів: %d", AmdirFrame.db.symbolsize or AmdirFrameDefaults.symbolsize), 8, 20, "BOTTOMLEFT", f, "BOTTOMLEFT", 15, GAP)
	symbolsizeslider.tiptext = "Розмір індикатора внизу праворуч."
	symbolsizeslider:SetValue(AmdirFrame.db.symbolsize or AmdirFrameDefaults.symbolsize)
	symbolsizeslider:SetValueStep(1)
	symbolsizeslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.symbolsize = self:GetValue()
		symbolsizeslidertext:SetText(string.format("Розмір символів: %d", AmdirFrame.db.symbolsize or AmdirFrameDefaults.symbolsize))
	end)
    
	local indicatorsizeslider, indicatorsizeslidertext, indicatorsizecontainer = tekslider.new(f, string.format("Розмір індикаторів: %d", AmdirFrame.db.indicatorsize or AmdirFrameDefaults.indicatorsize), 4, 20, "BOTTOMLEFT", symbolsizeslider, "TOPLEFT", 0, GAP)
	indicatorsizeslider.tiptext = "Розмір кутових індикаторів."
	indicatorsizeslider:SetValue(AmdirFrame.db.indicatorsize or AmdirFrameDefaults.indicatorsize)
	indicatorsizeslider:SetValueStep(1)
	indicatorsizeslider:SetScript("OnValueChanged", function(self)
		AmdirFrame.db.indicatorsize = self:GetValue()
		indicatorsizeslidertext:SetText(string.format("Розмір індикаторів: %d", AmdirFrame.db.indicatorsize or AmdirFrameDefaults.indicatorsize))
	end)
    
	local reload = tekbutton.new_small(f)
	reload:SetPoint("BOTTOMRIGHT", -16, 16)
	reload:SetText("Перезавантажити")
	reload.tiptext = "Перезавантажити інтерфейс для застосування змін"
	reload:SetScript("OnClick", function() ReloadUI() end)

	f:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(f)
