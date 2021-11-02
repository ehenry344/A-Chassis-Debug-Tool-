local StudioTheme = settings().Studio.Theme

local PluginUIEnums = {}

PluginUIEnums.StudioColorValues = {
	["Main"] = StudioTheme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
	["BrightText"] = StudioTheme:GetColor(Enum.StudioStyleGuideColor.BrightText),
	["ScrollBar"] = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScrollBar),
	["ButtonSelected"] = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Selected),
	["ButtonPressed"] = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Pressed),
}

PluginUIEnums.RelClassImages = {
	["Script"] = "rbxassetid://6904490133",
	["LocalScript"] = "rbxassetid://6904492202",
	["Model"] = "rbxassetid://6905077694",

}

return PluginUIEnums
