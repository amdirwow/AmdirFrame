local ADDON_NAME = ...
if not AmdirFrame then return end

local mediapath = "Interface\\AddOns\\" .. ADDON_NAME .. "\\media\\"

AmdirFrame.textures = {
	["gradient"] = mediapath.."gradient",
	["Minimalist"] = mediapath.."Minimalist",
	["Smooth"] = mediapath.."Smoothv2",
	["Blizzard"] = "Interface\\TargetingFrame\\UI-StatusBar",
}

AmdirFrame.fonts = {
	["calibri"] = mediapath.."calibri.ttf",
	["ABF"] = mediapath.."ABF.ttf",
	["Accidental Presidency"] = mediapath.."Accidental Presidency.ttf",
	["Tw_Cen_MT_Bold"] = mediapath.."Tw_Cen_MT_Bold.ttf",
	["FRIZQT__"] = "Fonts\\FRIZQT__.ttf",
}
