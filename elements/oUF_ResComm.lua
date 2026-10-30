--[[
	Elements handled: .ResComm
	
	Optional:
	 - .OthersOnly: (boolean) Defines whether the player's resurrection triggers the element or not.
	   (Default: nil)
	
	Functions that can be overridden from within a layout:
	 - :CustomOnUpdate(elapsed)
]]

local _, ns = ...
local oUF = ns.oUF or oUF

local libResComm = LibStub("LibResComm-1.0")
local playerName = UnitName("player")

local GetUnitName = function(unit)
	local unitName, unitRealm = UnitName(unit)
	if unitName and unitRealm and unitRealm ~= "" then
		return unitName .. "-" .. unitRealm
	end
	return unitName
end

local Hide = function(resComm)
	if resComm:IsObjectType("Statusbar") then
		resComm.duration = 0
		resComm.endTime = 0
		resComm:SetScript("OnUpdate", nil)
	end

	resComm:Hide()
end

local onUpdate
do
	local duration
	onUpdate = function(self, elapsed)
		duration = self.duration + elapsed
		
		if duration >= self.endTime then
			self:Hide()
		end
		
		self.duration = duration
		self:SetValue(duration)
	end
end

local Update = function(self, event, destUnit, endTime)
	local resComm = self.ResComm
	
	if resComm then
		if destUnit and destUnit ~= self.unit then
			return
		end

		destUnit = destUnit or self.unit
		if not destUnit or not UnitExists(destUnit) or not UnitIsDeadOrGhost(destUnit) then
			return Hide(resComm)
		end

		local unitName = GetUnitName(destUnit)
		if not unitName then
			unitName = destUnit
		end
		
		local beingRessed, resserName = libResComm:IsUnitBeingRessed(unitName)
		if beingRessed and not (resComm.OthersOnly and resserName == playerName) then
			if resComm:IsObjectType("Statusbar") and endTime and (not resComm:GetScript("OnUpdate")) then
				if endTime then
					local maxValue = endTime - GetTime()
					
					resComm.duration = 0
					resComm.endTime = maxValue
					resComm:SetMinMaxValues(0, maxValue)
					resComm:SetValue(0)
					
					if resComm.CustomOnUpdate then
						resComm:SetScript("OnUpdate", resComm.CustomOnUpdate)
					else
						resComm:SetScript("OnUpdate", onUpdate)
					end
				end
			end
			
			resComm:Show()
		else
			Hide(resComm)
		end
	end
end

local Enable = function(self)
	local resComm = self.ResComm
	if resComm then
		if resComm:IsObjectType("Texture") and not resComm:GetTexture() then
			resComm:SetTexture([=[Interface\Icons\Spell_Holy_Resurrection]=])
		elseif resComm:IsObjectType("Statusbar") and not resComm:GetStatusBarTexture():GetTexture() then
			resComm:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

			self:RegisterEvent("UNIT_HEALTH", Update)
			self:RegisterEvent("UNIT_MAXHEALTH", Update)
			self:RegisterEvent("UNIT_NAME_UPDATE", Update)
			self:RegisterEvent("RAID_ROSTER_UPDATE", Update)
			self:RegisterEvent("PARTY_MEMBERS_CHANGED", Update)

			Hide(resComm)
			
			return true
		end
	end

local Disable = function(self)
	if self.ResComm then
		self:UnregisterEvent("UNIT_HEALTH", Update)
		self:UnregisterEvent("UNIT_MAXHEALTH", Update)
		self:UnregisterEvent("UNIT_NAME_UPDATE", Update)
		self:UnregisterEvent("RAID_ROSTER_UPDATE", Update)
		self:UnregisterEvent("PARTY_MEMBERS_CHANGED", Update)
		Hide(self.ResComm)
	end
end

oUF:AddElement("ResComm", Update, Enable, Disable)

local ResComm_Update = function(event, ...)
	local endTime = type(select(2, ...)) == "number" and select(2, ...) or nil
	
	local destUnit
	for _, frame in ipairs(oUF.objects) do
		if frame.unit and frame.ResComm then
			destUnit = frame.unit
			Update(frame, event, destUnit, endTime)
		end
	end
end

libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResStart", ResComm_Update)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResEnd", ResComm_Update)

local ResComm_Clear = function(event, name)
	for _, frame in ipairs(oUF.objects) do
		if frame.unit and frame.ResComm and GetUnitName(frame.unit) == name then
			Hide(frame.ResComm)
		end
	end
end

libResComm.RegisterCallback("oUF_ResComm", "ResComm_Ressed", ResComm_Clear)
libResComm.RegisterCallback("oUF_ResComm", "ResComm_ResExpired", ResComm_Clear)
