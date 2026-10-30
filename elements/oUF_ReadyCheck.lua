--[[

	Elements handled:
	 .ReadyCheck [texture]

	Options:
	 - delayTime [value] default: 10
	 - fadeTime [value] default: 1.5

	Add-on originally made by Starlon
--]]
local _, ns = ...
local oUF = ns.oUF or oUF

local GetReadyCheckStatus = GetReadyCheckStatus

local statusTexture = {
	notready = [=[Interface\RAIDFRAME\ReadyCheck-NotReady]=],
	ready = [=[Interface\RAIDFRAME\ReadyCheck-Ready]=],
	waiting = [=[Interface\RAIDFRAME\ReadyCheck-Waiting]=],
}

local function onUpdate(self, elapsed)
	if(self.finish) then
		self.finish = self.finish - elapsed
		if(self.finish <= 0) then
			self.finish = nil
		end
	elseif(self.fade) then
		self.fade = self.fade - elapsed
		if(self.fade <= 0) then
			self.fade = nil
			self:SetScript('OnUpdate', nil)

			self:GetParent().ReadyCheck:Hide()
		else
			self:GetParent().ReadyCheck:SetAlpha(self.fade / self.offset)
		end
	end
end

local function update(self, event)
	if event == "READY_CHECK" and self.ReadyCheck.dummy then
		local dummy = self.ReadyCheck.dummy
		dummy.finish, dummy.fade = nil, nil
		dummy:SetScript("OnUpdate", nil)
	end
	if(not self.unit or not UnitExists(self.unit)) then
		return self.ReadyCheck:Hide()
	end

	local status = GetReadyCheckStatus(self.unit)
	if(status) then
		self.ReadyCheck:SetTexture(statusTexture[status])
		self.ReadyCheck:SetAlpha(1)
		self.ReadyCheck:Show()
	else
		self.ReadyCheck:Hide()
	end
end

local function prepare(self)
	local readycheck = self.ReadyCheck
	if(not readycheck) then return end

	local dummy = readycheck.dummy

	dummy.unit = self.unit
	dummy.finish = readycheck.delayTime or 10
	dummy.fade = readycheck.fadeTime or 1.5
	dummy.offset = readycheck.fadeTime or 1.5

	dummy:SetScript('OnUpdate', onUpdate)
end

local function enable(self)
	local readycheck = self.ReadyCheck
		if(readycheck) then
			self:RegisterEvent('READY_CHECK', update)
			self:RegisterEvent('READY_CHECK_CONFIRM', update)
			self:RegisterEvent('READY_CHECK_FINISHED', prepare)

			readycheck.dummy = CreateFrame('Frame', nil, self)
			readycheck:Hide()

			return true
		end
	end

local function disable(self)
	if(self.ReadyCheck) then
		self:UnregisterEvent('READY_CHECK', update)
		self:UnregisterEvent('READY_CHECK_CONFIRM', update)
		self:UnregisterEvent('READY_CHECK_FINISHED', prepare)
		self.ReadyCheck:Hide()
	end
end

oUF:AddElement('ReadyCheck', update, enable, disable)
