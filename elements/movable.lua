local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUF
--[[
	This is a stripped and modified oUF MovableFrames to fit my needs.
	-- freebaser
]]--
local _DB

local round = function(n)
	return math.floor(n * 1e5 + .5) / 1e5
end

local getPoint = function(obj)
	local UIx, UIy = UIParent:GetCenter()
	local Ox, Oy = obj:GetCenter()

	-- Frame doesn't really have a positon yet.
	if(not Ox) then return end

	local UIS = UIParent:GetEffectiveScale()
	local OS = obj:GetEffectiveScale()

	local UIWidth, UIHeight = UIParent:GetRight(), UIParent:GetTop()

	local LEFT = UIWidth / 3
	local RIGHT = UIWidth * 2 / 3

	local point, x, y
	if(Ox >= RIGHT) then
		point = 'RIGHT'
		x = obj:GetRight() - UIWidth
	elseif(Ox <= LEFT) then
		point = 'LEFT'
		x = obj:GetLeft()
	else
		x = Ox - UIx
	end

	local BOTTOM = UIHeight / 3
	local TOP = UIHeight * 2 / 3

	if(Oy >= TOP) then
		point = 'TOP' .. (point or '')
		y = obj:GetTop() - UIHeight
	elseif(Oy <= BOTTOM) then
		point = 'BOTTOM' .. (point or '')
		y = obj:GetBottom()
	else
		if(not point) then point = 'CENTER' end
		y = Oy - UIy
	end

	return string.format(
		'%s\031%s\031%d\031%d',
		point, 'UIParent', round(x * UIS / OS),  round(y * UIS / OS)
	)
end

local saveDefaultPosition = function(anchor)
	local style, identifier = "AmdirFrame", anchor:GetName()
	if(not _DB.__INITIAL) then
		_DB.__INITIAL = {}
	end

	if(not _DB.__INITIAL[style]) then
		_DB.__INITIAL[style] = {}
	end

	if(not _DB.__INITIAL[style][identifier]) then	
		_DB.__INITIAL[style][identifier] = getPoint(anchor)
	end
end

local savePosition = function(anchor)
	local style, identifier  = "AmdirFrame", anchor:GetName()
	if(not _DB[style]) then _DB[style] = {} end
	
	_DB[style][identifier] = getPoint(anchor)
end

local function snapDistance()
	return AmdirFrame.db.snapdistance or 12
end

local function moverWidth()
	return AmdirFrame.db.width * AmdirFrame.db.scale
end

local function moverHeight()
	return AmdirFrame.db.height * AmdirFrame.db.scale
end

local function moverGap()
	return AmdirFrame.db.spacing * AmdirFrame.db.scale
end

local setAbsolutePosition = function(frame, left, bottom)
	if(not left or not bottom) then return end
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
end

local getMoverBounds = function(frame)
	if(not frame or not frame:IsVisible()) then return end
	local left, right, top, bottom = frame:GetLeft(), frame:GetRight(), frame:GetTop(), frame:GetBottom()
	if(not left or not right or not top or not bottom) then return end

	return {left = left, right = right, top = top, bottom = bottom}
end

local addSnapCandidates = function(candidates, moving, target)
	if(not moving or not target) then return end

	local gap = moverGap()
	local verticalAlignment = math.abs(moving.bottom - target.bottom)
	local horizontalAlignment = math.abs(moving.left - target.left)
	local function add(edgeDistance, alignmentDistance, x, y)
		if(edgeDistance <= snapDistance() and alignmentDistance <= snapDistance()) then
			table.insert(candidates, {math.max(edgeDistance, alignmentDistance), x, y})
		end
	end

	-- Left/right neighbours align their bottom edges; top/bottom neighbours
	-- align their left edges.  Both axes must be close, preventing overlaps.
	add(math.abs(moving.left - (target.right + gap)), verticalAlignment,
		target.right + gap - moving.left, target.bottom - moving.bottom)
	add(math.abs(moving.right - (target.left - gap)), verticalAlignment,
		target.left - gap - moving.right, target.bottom - moving.bottom)
	add(math.abs(moving.bottom - (target.top + gap)), horizontalAlignment,
		target.left - moving.left, target.top + gap - moving.bottom)
	add(math.abs(moving.top - (target.bottom - gap)), horizontalAlignment,
		target.left - moving.left, target.bottom - gap - moving.top)
end

-- Raid, Pet, MT and OT are equal magnetic blocks.  Every block can be dragged to
-- every other block, and all positions remain absolute so pulling a block
-- away immediately detaches it without creating anchor chains or cycles.
local snapFrame = function(frame)
	local name = frame:GetName()
	if(name ~= "AmdirFrameRaidFrame"
	and name ~= "AmdirFramePetFrame"
	and name ~= "AmdirFrameMTFrame"
	and name ~= "AmdirFrameOTFrame") then return end

	local moving = getMoverBounds(frame)
	local candidates = {}
	local targets = {
		_G.AmdirFrameRaidFrame,
		_G.AmdirFramePetFrame,
		_G.AmdirFrameMTFrame,
		_G.AmdirFrameOTFrame,
	}
	for _, targetFrame in ipairs(targets) do
		if(targetFrame ~= frame) then
			addSnapCandidates(candidates, moving, getMoverBounds(targetFrame))
		end
	end

	local best
	for _, candidate in ipairs(candidates) do
		if(candidate[1] <= snapDistance() and (not best or candidate[1] < best[1])) then
			best = candidate
		end
	end
	if(best) then
		setAbsolutePosition(frame, frame:GetLeft() + best[2], frame:GetBottom() + best[3])
	end
end

local setframe
do
	local OnDragStart = function(self)
		if InCombatLockdown() then return end
		saveDefaultPosition(self)
		local left, bottom = self:GetLeft(), self:GetBottom()
		setAbsolutePosition(self, left, bottom)
		self:StartMoving()
	end

	local OnDragStop = function(self)
		self:StopMovingOrSizing()
		if InCombatLockdown() then return end
		snapFrame(self)
		savePosition(self)
	end
	
	setframe = function(frame)
		-- Secure headers scale their unit buttons, while mover frames do not.
		-- Match the mover to the final on-screen size used by snapping.
		frame:SetHeight(moverHeight())
		frame:SetWidth(moverWidth())
		frame:SetFrameStrata"TOOLTIP"
		frame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background";})
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:SetClampedToScreen(true)
		frame:RegisterForDrag"LeftButton"
		frame:SetBackdropBorderColor(0, .9, 0)
		frame:SetBackdropColor(0, .9, 0)
		frame:Hide()

		frame:SetScript("OnDragStart", OnDragStart)
		frame:SetScript("OnDragStop", OnDragStop)
		
		frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		frame.name:SetPoint"CENTER"
		frame.name:SetJustifyH"CENTER"
		frame.name:SetFont(GameFontNormal:GetFont(), 12)
		frame.name:SetTextColor(1, 1, 1)
		
		return frame
	end
end

local anchorpool = {}
local anchors = function()
	local raidframe = CreateFrame("Frame", "AmdirFrameRaidFrame", UIParent)
	setframe(raidframe)
	raidframe.ident = "Raid"
	raidframe.displayName = "Рейд"
	raidframe.name:SetText(raidframe.displayName)
	raidframe:SetPoint("LEFT", UIParent, "LEFT", 8, 0)
	anchorpool["AmdirFrameRaidFrame"] = raidframe
	
	local petframe = CreateFrame("Frame", "AmdirFramePetFrame", UIParent)
	setframe(petframe)
	petframe.ident = "Pet"
	petframe.displayName = "Пети"
	petframe.name:SetText(petframe.displayName)
	petframe:SetPoint("LEFT", UIParent, "LEFT", 250, 0)
	anchorpool["AmdirFramePetFrame"] = petframe
	
	local mtframe = CreateFrame("Frame", "AmdirFrameMTFrame", UIParent)
	setframe(mtframe)
	mtframe.ident = "MT"
	mtframe.displayName = "МТ"
	mtframe.name:SetText(mtframe.displayName)
	mtframe:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 8, -25)
	anchorpool["AmdirFrameMTFrame"] = mtframe

	local otframe = CreateFrame("Frame", "AmdirFrameOTFrame", UIParent)
	setframe(otframe)
	otframe.ident = "OT"
	otframe.displayName = "ОТ"
	otframe.name:SetText(otframe.displayName)
	otframe:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16 + moverWidth(), -25)
	anchorpool["AmdirFrameOTFrame"] = otframe
end

local restoreDefaultPosition = function(style, identifier)
	-- We've not saved any default position for this style.
	if(not _DB.__INITIAL or not _DB.__INITIAL[style] or not _DB.__INITIAL[style][identifier]) then return end

	local anchor
	for _, frame in next, anchorpool do
		if frame:GetName() == identifier then
			anchor = frame
		end
	end
	if not anchor then return end
	
    local scale = anchor:GetScale()
    local SetPoint = getmetatable(anchor).__index.SetPoint;

    (anchor):ClearAllPoints();

    local point, parentName, x, y = string.split('\031', _DB.__INITIAL[style][identifier])
    SetPoint(anchor, point, parentName, point, x / scale, y / scale)

    -- We don't need this anymore
    _DB.__INITIAL[style][identifier] = nil
    if(not next(_DB.__INITIAL[style])) then
        _DB.__INITIAL[style] = nil
    end
end

local function restorePosition(anchor)
	local style, identifier = "AmdirFrame", anchor:GetName()
	-- We've not saved any custom position for this style.
	if(not _DB[style] or not _DB[style][identifier]) then return end

	local scale = anchor:GetScale()
	local SetPoint = getmetatable(anchor).__index.SetPoint;

	-- Hah, a spot you have to use semi-colon!
	-- Guess I've never experienced that as these are usually wrapped in do end
	-- statements.
	-- Restore once at login; leave the widget's positioning API intact.
	(anchor):ClearAllPoints();

	-- damn it Blizzard, _how_ did you manage to get the input of this function
	-- reversed. Any sane person would implement this as: split(str, dlm, lim);
	local point, parentName, x, y = string.split('\031', _DB[style][identifier])
	SetPoint(anchor, point, parentName, point, x / scale, y / scale)
end

do
	local frame = CreateFrame"Frame"
	frame:RegisterEvent"ADDON_LOADED"
	frame:SetScript("OnEvent", function(self, event, addon)
        if addon ~= ADDON_NAME then return end
		
		if not AmdirFramePositions and type(Freebgridomf2) == "table" then AmdirFramePositions = Freebgridomf2 end
		_DB = AmdirFramePositions or {}
		AmdirFramePositions = _DB
		local oldStyle = _DB.Freebgrid
		if oldStyle and not _DB.AmdirFrame then
			_DB.AmdirFrame = {}
			local rename = {
				oUF_FreebgridRaidFrame = "AmdirFrameRaidFrame",
				oUF_FreebgridPetFrame = "AmdirFramePetFrame",
				oUF_FreebgridMTFrame = "AmdirFrameMTFrame",
				oUF_FreebgridOTFrame = "AmdirFrameOTFrame",
			}
			for key, position in pairs(oldStyle) do _DB.AmdirFrame[rename[key] or key] = position end
		end
		local oldInitial = _DB.__INITIAL and _DB.__INITIAL.Freebgrid
		if oldInitial and not _DB.__INITIAL.AmdirFrame then
			_DB.__INITIAL.AmdirFrame = {}
			local rename = {
				oUF_FreebgridRaidFrame = "AmdirFrameRaidFrame",
				oUF_FreebgridPetFrame = "AmdirFramePetFrame",
				oUF_FreebgridMTFrame = "AmdirFrameMTFrame",
				oUF_FreebgridOTFrame = "AmdirFrameOTFrame",
			}
			for key, position in pairs(oldInitial) do _DB.__INITIAL.AmdirFrame[rename[key] or key] = position end
		end
		
		self:UnregisterEvent"ADDON_LOADED"
	end)
end

do
	local opt = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
	opt:Hide()

    opt.parent = "AmdirFrame"
	opt.name = "Збережені позиції"
	opt:SetScript("OnShow", function(self)
		local title = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		title:SetPoint('TOPLEFT', 16, -16)
		title:SetText'Збережені позиції AmdirFrame'

		local subtitle = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		subtitle:SetHeight(40)
		subtitle:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -8)
		subtitle:SetPoint('RIGHT', self, -32, 0)
		subtitle:SetNonSpaceWrap(true)
		subtitle:SetWordWrap(true)
		subtitle:SetJustifyH'LEFT'
		subtitle:SetText('Видаліть позицію, щоб повернути блок на початкове місце. У бою змінювати позиції не можна.')

		local scroll = CreateFrame("ScrollFrame", nil, self)
		scroll:SetPoint('TOPLEFT', subtitle, 'BOTTOMLEFT', 0, -8)
		scroll:SetPoint("BOTTOMRIGHT", 0, 4)

		local scrollchild = CreateFrame("Frame", nil, self)
		scrollchild:SetPoint"LEFT"
		scrollchild:SetHeight(scroll:GetHeight())
		scrollchild:SetWidth(scroll:GetWidth())

		scroll:SetScrollChild(scrollchild)
		scroll:UpdateScrollChildRect()
		scroll:EnableMouseWheel(true)

		local slider = CreateFrame("Slider", nil, scroll)

		local backdrop = {
			bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
			edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		}

		local createOrUpdateMadnessOfGodIhateGUIs
		local OnClick = function(self)
			if InCombatLockdown() then return end
			scroll.value = slider:GetValue()
			_DB[self.style][self.ident] = nil

			if(not next(_DB[self.style])) then
				_DB[self.style] = nil
			end

			restoreDefaultPosition(self.style, self.ident)

			return createOrUpdateMadnessOfGodIhateGUIs()
		end

		local OnEnter = function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetText(DELETE)
		end

		function createOrUpdateMadnessOfGodIhateGUIs()
			local data = self.data or {}

			local slideHeight = 0
			local numStyles = 1
			for style, styleData in next, _DB do
				if(style ~= '__INITIAL') then
					if(not data[numStyles]) then
						local box = CreateFrame('Frame', nil, scrollchild)
						box:SetBackdrop(backdrop)
						box:SetBackdropColor(.1, .1, .1, .5)
						box:SetBackdropBorderColor(.3, .3, .3, 1)

						if(numStyles == 1) then
							box:SetPoint('TOP', 0, -12)
						else
							box:SetPoint('TOP', data[numStyles - 1], 'BOTTOM', 0, -16)
						end
						box:SetPoint'LEFT'
						box:SetPoint('RIGHT', -30, 0)

						local title = box:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
						title:SetPoint('BOTTOMLEFT', box, 'TOPLEFT', 8, 0)
						box.title = title

						data[numStyles] = box
					end

					-- Fetch the box and update it
					local box = data[numStyles]
					box.title:SetText(style)

					local rows = box.rows or {}
					local numFrames = 1
					for unit, points in next, styleData do
						if(not rows[numFrames]) then
							local row = CreateFrame('Button', nil, box)

							row:SetBackdrop(backdrop)
							row:SetBackdropBorderColor(.3, .3, .3)
							row:SetBackdropColor(.1, .1, .1, .5)

							if(numFrames == 1) then
								row:SetPoint('TOP', 0, -8)
							else
								row:SetPoint('TOP', rows[numFrames-1], 'BOTTOM')
							end

							row:SetPoint('LEFT', 6, 0)
							row:SetPoint('RIGHT', -25, 0)
							row:SetHeight(24)

							local anchor = row:CreateFontString(nil, nil, 'GameFontHighlight')
							anchor:SetPoint('RIGHT', -10, 0)
							anchor:SetPoint('TOP', 0, -4)
							anchor:SetPoint'BOTTOM'
							anchor:SetJustifyH'RIGHT'
							row.anchor = anchor

							local label = row:CreateFontString(nil, nil, 'GameFontHighlight')
							label:SetPoint('LEFT', 10, 0)
							label:SetPoint('RIGHT', anchor)
							label:SetPoint('TOP', 0, -4)
							label:SetPoint'BOTTOM'
							label:SetJustifyH'LEFT'
							row.label = label

							local delete = CreateFrame("Button", nil, row)
							delete:SetWidth(16)
							delete:SetHeight(16)
							delete:SetPoint('LEFT', row, 'RIGHT')

							delete:SetNormalTexture[[Interface\Buttons\UI-Panel-MinimizeButton-Up]]
							delete:SetPushedTexture[[Interface\Buttons\UI-Panel-MinimizeButton-Down]]
							delete:SetHighlightTexture[[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]]

							delete:SetScript("OnClick", OnClick)
							delete:SetScript("OnEnter", OnEnter)
							delete:SetScript("OnLeave", GameTooltip_Hide)
							row.delete = delete

							rows[numFrames] = row
						end

						-- Fetch row and update it:
						local row = rows[numFrames]
						local point, _, x, y = string.split('\031', points)
						row.anchor:SetFormattedText('%11s %4s %4s', point, x, y)
						row.label:SetText(anchorpool[unit] and anchorpool[unit].displayName or unit)

						row.delete.style = style
						row.delete.ident = unit
						row:Show()

						numFrames = numFrames + 1
					end

					box.rows = rows

					local height = (numFrames * 24) - 8
					slideHeight = slideHeight + height + 16
					box:SetHeight(height)
					box:Show()

					-- Hide left over rows we aren't using:
					while(rows[numFrames]) do
						rows[numFrames]:Hide()
						numFrames = numFrames + 1
					end

					numStyles = numStyles + 1
				end
			end

			-- Hide left over boxes we aren't using:
			while(data[numStyles]) do
				data[numStyles]:Hide()
				numStyles = numStyles + 1
			end

			self.data = data
			local height = slideHeight - scroll:GetHeight()
			if(height > 0) then
				slider:SetMinMaxValues(0, height)
			else
				slider:SetMinMaxValues(0, 0)
			end

			slider:SetValue(scroll.value or 0)
		end

		slider:SetWidth(16)

		slider:SetPoint("TOPRIGHT", -8, -24)
		slider:SetPoint("BOTTOMRIGHT", -8, 24)

		local up = CreateFrame("Button", nil, slider)
		up:SetPoint("BOTTOM", slider, "TOP")
		up:SetWidth(16)
		up:SetHeight(16)
		up:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
		up:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down")
		up:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Disabled")
		up:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight")

		up:GetNormalTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		up:GetPushedTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		up:GetDisabledTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		up:GetHighlightTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		up:GetHighlightTexture():SetBlendMode("ADD")

		up:SetScript("OnClick", function(self)
			local box = self:GetParent()
			box:SetValue(box:GetValue() - box:GetHeight()/2)
		end)

		local down = CreateFrame("Button", nil, slider)
		down:SetPoint("TOP", slider, "BOTTOM")
		down:SetWidth(16)
		down:SetHeight(16)
		down:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
		down:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down")
		down:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled")
		down:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight")

		down:GetNormalTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		down:GetPushedTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		down:GetDisabledTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		down:GetHighlightTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
		down:GetHighlightTexture():SetBlendMode("ADD")

		down:SetScript("OnClick", function(self)
			local box = self:GetParent()
			box:SetValue(box:GetValue() + box:GetHeight()/2)
		end)

		slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
		local thumb = slider:GetThumbTexture()
		thumb:SetWidth(16)
		thumb:SetHeight(24)
		thumb:SetTexCoord(1/4, 3/4, 1/8, 7/8)

		slider:SetScript("OnValueChanged", function(self, val, ...)
			local min, max = self:GetMinMaxValues()
			if(val == min) then up:Disable() else up:Enable() end
			if(val == max) then down:Disable() else down:Enable() end

			scroll.value = val
			scroll:SetVerticalScroll(val)
			scrollchild:SetPoint('TOP', 0, val)
		end)

		opt:SetScript("OnShow", function()
			return createOrUpdateMadnessOfGodIhateGUIs()
		end)

		return createOrUpdateMadnessOfGodIhateGUIs()
	end)

	InterfaceOptions_AddCategory(opt)
end

AMDIRFRAMEENABLE = function()
    anchors()

	for _, frame in next, anchorpool do
		saveDefaultPosition(frame)
		restorePosition(frame)
	end

	-- The saved option and the actual mover visibility must start in sync.
	-- Without this, locked=false survived /reload while all movers stayed hidden.
	if AmdirFrame.db.locked == false then
		AMDIRFRAMEMOVABLE()
	end
end

local _LOCK
AMDIRFRAMERESET = function()
	if InCombatLockdown() then return print("AmdirFrame: у бою не можна скидати позиції.") end
	for _, frame in pairs(anchorpool) do
		local x, y, point = 8, 0, "LEFT"
		if frame.ident == "Pet" then x = 250 end
		if frame.ident == "MT" or frame.ident == "OT" then
			point, y = "TOPLEFT", -25
			if frame.ident == "OT" then x = 16 + moverWidth() end
		end
		frame:ClearAllPoints()
		frame:SetPoint(point, UIParent, point, x, y)
	end
	_DB.AmdirFrame = nil
	if _DB.__INITIAL then _DB.__INITIAL.AmdirFrame = nil end
	for _, frame in pairs(anchorpool) do saveDefaultPosition(frame) end
end

local combatLock = CreateFrame("Frame")
combatLock:RegisterEvent("PLAYER_REGEN_DISABLED")
combatLock:SetScript("OnEvent", function()
	for _, frame in pairs(anchorpool) do
		frame:StopMovingOrSizing()
		frame:Hide()
	end
	_LOCK = nil
	AmdirFrame.db.locked = true
end)

AMDIRFRAMEMOVABLE = function()
    if(InCombatLockdown()) then
		return print"AmdirFrame: у бою не можна переміщувати фрейми."
	end
    
	if(not _LOCK) then
		for k, frame in next, anchorpool do
			local enabled = frame.ident == "Raid" or (frame.ident == "Pet" and AmdirFrame.db.pets)
				or (frame.ident == "MT" and AmdirFrame.db.MT) or (frame.ident == "OT" and AmdirFrame.db.OT)
			frame:SetBackdropColor(enabled and 0 or .3, enabled and .9 or .3, enabled and 0 or .3)
			frame.name:SetText(frame.displayName .. (enabled and "" or " (вимк.)"))
			frame:Show()
		end
		_LOCK = true
		AmdirFrame.db.locked = false
	else
		for k, frame in next, anchorpool do
			frame:Hide()
		end
		_LOCK = nil
		AmdirFrame.db.locked = true
	end
end
