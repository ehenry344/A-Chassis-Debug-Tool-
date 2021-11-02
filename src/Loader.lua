--[[
@author gilaga4815

Last Update : 6 / 8 / 2021

A-Chassis Vehicle Output Interpreter Bootstrapper
]]
-- Services

local SelectionService = game:GetService("Selection")
local StudioService = game:GetService("StudioService")
local LogService = game:GetService("LogService")

local OutputAnalyzer = require(script.Parent:WaitForChild("OutputAnalyzer"))
local UI_Util = require(script.Parent:WaitForChild("UI_Utility"))
local UI_Enums = require(script.Parent:WaitForChild("UI_Utility"):WaitForChild("UI_Enums"))
local lastLogTime = plugin:GetSetting("LastLogTime")

-- Enums for the plugin display here

local debugWidgetData = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float,false,false,100,200,50, 100)

local ancestryConnections = {}

-- Plugin Setup 

local backButton = nil

local function searchUntilPlugin(currentAsset)
	if currentAsset.Parent.Name ~= "Plugins" and currentAsset.Parent ~= game.Workspace then
		return searchUntilPlugin(currentAsset.Parent)
	else
		return currentAsset
	end
end

-- GUI Handling 

local function scriptSelector(parentTo, scriptAsset) -- scriptAsset is the broken script that the plugins is looking for. 	
	local scriptButton = UI_Util.CreateClassButton(false, scriptAsset:IsA("LocalScript") and "LocalScript" or "Script")
	scriptButton.Name = scriptAsset.Name
	scriptButton.Text = "      " .. scriptAsset.Name

	UI_Util.SetupButton(
		scriptButton,
		parentTo,
		function(returnValue)
			local selectAsset = searchUntilPlugin(scriptAsset) -- this will get the correct plugin path of the azsset 

			if returnValue then
				SelectionService:Add({selectAsset})
			else
				SelectionService:Remove({selectAsset})
			end
		end,
		{
			MouseEnterLeave = true,
			Toggleable = true,
		}
	)

	-- Script Connections

	ancestryConnections[#ancestryConnections + 1] = scriptAsset.AncestryChanged:Connect(function()
		if not scriptAsset:IsDescendantOf(game) then
			scriptButton:Destroy()
		end
	end)
end

local function createCarSelector(parentTo, carModel)	
	local newButton = UI_Util.CreateClassButton(true, "Model")
	newButton.Name = carModel.Name
	newButton.Text = "     " .. newButton.Name
	
	UI_Util.SetupButton(
		newButton,
		parentTo,
		function(returnValue)
			if not returnValue then return end

			for i = 1, #ancestryConnections do
				ancestryConnections[i]:Disconnect()		
			end
			
			UI_Util.ClearFrame(parentTo, {backButton})			
			backButton.Visible = true
			backButton.Parent = parentTo 
			
			-- Handle the actual output stuff now 

			local newAnalyses = OutputAnalyzer.New(carModel)
			local scanResults = newAnalyses:PerformScan(lastLogTime)

			if scanResults then
				for i = 1, #scanResults do
					scriptSelector(parentTo, scanResults[i])
				end
			else
				local newDisclaimer = Instance.new("TextLabel", parentTo)

				newDisclaimer.Size = UDim2.new(1, 0, 0, 200)
				newDisclaimer.BorderSizePixel = 0 
				newDisclaimer.BackgroundColor3 = UI_Enums.StudioColorValues.Main
				newDisclaimer.TextColor3 = Color3.fromRGB(255, 255, 0)
				newDisclaimer.TextXAlignment = Enum.TextXAlignment.Center
				newDisclaimer.TextScaled = true
				newDisclaimer.Font = Enum.Font.TitilliumWeb
				newDisclaimer.Text = "After scanning the vehicle no errors were found. However this may be because you never tested this vehicle.\nIf this is the case please test the vehicle for as long as you would like, in order to gather error data from the vehicle\nin order for this plugin to work. Please hit [BACK]\n or start a new session."
			end
				
			newAnalyses:Destroy()
		end,
		{
			MouseEnterLeave = true,
			DoubleClick = true,
		}
	)
end

-- Element Setup

-- Plugin Specific Stuff

local debugToolbar = plugin:CreateToolbar("Chassis Debug Tool")
local showDebugFrame = debugToolbar:CreateButton("Tool Output", "Toggle Tool Output", "rbxassetid://6903761098")

local debugWidget = plugin:CreateDockWidgetPluginGui("AC_DebugOutput", debugWidgetData)
debugWidget.Title = "AC Broken Plugins"

-- Regular UI Stuff 

local outputFrame = Instance.new("ScrollingFrame", debugWidget)
local outputLayout = Instance.new("UIListLayout", outputFrame)

outputFrame.Size = UDim2.new(1, 0, 1, 0)
outputFrame.BackgroundColor3 = UI_Enums.StudioColorValues.Main
outputFrame.BorderSizePixel = 0
outputFrame.ScrollBarThickness = 10
outputFrame.ScrollBarImageColor3 = UI_Enums.StudioColorValues.ScrollBar
outputFrame.CanvasSize = UDim2.new(0, 0, 0, outputLayout.AbsoluteContentSize.Y)

outputLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Create a single use back button so it doesn't need to be created later

backButton = UI_Util.CreateClassButton()
backButton.Name = "Back"
backButton.Text = "BACK"
backButton.Visible = false
backButton.LayoutOrder = 2

UI_Util.SetupButton(
	backButton,
	outputFrame,
	function()					
		backButton.Visible = false
		
		UI_Util.ClearFrame(outputFrame, {backButton})

		for _, v in pairs(game.Workspace:GetDescendants()) do
			if v:FindFirstChild("DriveSeat") then
				createCarSelector(outputFrame, v)
			end
		end
	end
)

-- Connections and calls here 

outputLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	outputFrame.CanvasSize = UDim2.new(0, 0, 0, outputLayout.AbsoluteContentSize.Y)
end)

showDebugFrame.Click:Connect(function()
	debugWidget.Enabled = not debugWidget.Enabled
end)

plugin.Unloading:Connect(function()
	local lastLog = (LogService:GetLogHistory() ~= nil) and LogService:GetLogHistory()[#LogService:GetLogHistory()].timestamp
	print(lastLog)
	plugin:SetSetting("LastLogTime", lastLog or nil) 
end)

for _, car in pairs(game.Workspace:GetChildren()) do
	if car:FindFirstChild("DriveSeat") then
		createCarSelector(outputFrame, car)
	end
end



