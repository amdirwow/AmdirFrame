local ADDON_NAME, ns = ...
local oUF =  ns.oUF or oUF
if not oUF then return end
local _, class = UnitClass("player")
local mediapath = "Interface\\AddOns\\" .. ADDON_NAME .. "\\media\\"
local indicator = mediapath.."squares.ttf"
local symbols = mediapath.."PIZZADUDEBULLETS.ttf"

local Enable = function(self)
	if(self.Indicators) then
		self.AuraStatusTL = self.Health:CreateFontString(nil, "OVERLAY")
		self.AuraStatusTL:ClearAllPoints()
		self.AuraStatusTL:SetPoint("TOPLEFT", 0, 0)
		self.AuraStatusTL:SetFont(indicator, AmdirFrame.db.indicatorsize, "THINOUTLINE")
		self:Tag(self.AuraStatusTL, oUF.classIndicators[class]["TL"])
		
		self.AuraStatusTR = self.Health:CreateFontString(nil, "OVERLAY")
		self.AuraStatusTR:ClearAllPoints()
		self.AuraStatusTR:SetPoint("TOPRIGHT", 2, 0)
		self.AuraStatusTR:SetFont(indicator, AmdirFrame.db.indicatorsize, "THINOUTLINE")
		self:Tag(self.AuraStatusTR, oUF.classIndicators[class]["TR"])

		self.AuraStatusBL = self.Health:CreateFontString(nil, "OVERLAY")
		self.AuraStatusBL:ClearAllPoints()
		self.AuraStatusBL:SetPoint("BOTTOMLEFT", 0, 0)
		self.AuraStatusBL:SetFont(indicator, AmdirFrame.db.indicatorsize, "THINOUTLINE")
		self:Tag(self.AuraStatusBL, oUF.classIndicators[class]["BL"])	

		self.AuraStatusBR = self.Health:CreateFontString(nil, "OVERLAY")
		self.AuraStatusBR:ClearAllPoints()
		self.AuraStatusBR:SetPoint("BOTTOMRIGHT", 6, -2)
		self.AuraStatusBR:SetFont(symbols, AmdirFrame.db.symbolsize, "THINOUTLINE")
		self.AuraStatusBR.frequentUpdates = AmdirFrame.db.frequent or class == "DRUID"
		self:Tag(self.AuraStatusBR, oUF.classIndicators[class]["BR"])

		self.AuraStatusCen = self.Health:CreateFontString(nil, "OVERLAY")
		self.AuraStatusCen:ClearAllPoints()
		self.AuraStatusCen:SetPoint("TOP")
		self.AuraStatusCen:SetJustifyH("CENTER")
		self.AuraStatusCen:SetFont(AmdirFrame.fonts[AmdirFrame.db.font], AmdirFrame.db.fontsize-2)
		self.AuraStatusCen:SetShadowOffset(1.25, -1.25)
		self.AuraStatusCen.frequentUpdates = true
		self:Tag(self.AuraStatusCen, oUF.classIndicators[class]["Cen"])

		return true
	end
end

oUF:AddElement('Indicators', nil, Enable, nil)
