--[[
@author gilaga4815

Last Update : 6 / 8 / 2021

Plugin GUI Utility 
]]

local UIUtility = {}
local UI_Enums = require(script:WaitForChild("UI_Enums"))

function UIUtility.ClearFrame(frame, exceptions)	
	for _, v in pairs(frame:GetChildren()) do
		if not v:IsA("UIListLayout") and not table.find(exceptions, v) then
			v:Destroy() 
		end
	end
end 

function UIUtility.CreateButtonImage()
	local newImage = Instance.new("ImageLabel")

	newImage.Size = UDim2.new(0, 17, 1)
	newImage.BackgroundTransparency = 1

	return newImage
end

function UIUtility.CreateClassButton(addLastClick, imageIndex)
	local newButton = Instance.new("TextButton")
	
	newButton.Size = UDim2.new(1, 0, 0, 20)
	newButton.BackgroundColor3 = UI_Enums.StudioColorValues.Main
	newButton.BorderSizePixel = 0
	
	newButton.TextColor3 = UI_Enums.StudioColorValues.BrightText
	newButton.Font = Enum.Font.Arial
	newButton.TextSize = 15
	newButton.TextXAlignment = Enum.TextXAlignment.Left
	
	if imageIndex and UI_Enums.RelClassImages[imageIndex] then
		local newButtonImage = UIUtility.CreateButtonImage()
		
		newButtonImage.Parent = newButton
		newButtonImage.Image = UI_Enums.RelClassImages[imageIndex]
	end
	
	if addLastClick then
		newButton:SetAttribute("LastClick", os.clock())
	end
	
	return newButton
end

function UIUtility.SetupButton(button, parent, clickCallback, extras)
	if not button or not parent or not clickCallback then return end
	button.Parent = parent	
		
	if extras and extras.MouseEnterLeave then -- checks if they want to add a mouseenter connection
		button.MouseEnter:Connect(function()
			local controlColor = UI_Enums.StudioColorValues.ButtonSelected 
			
			if not controlColor or button.BackgroundColor3 ~= controlColor then
				button.BackgroundColor3 = UI_Enums.StudioColorValues.ButtonPressed
			end
		end)
		
		button.MouseLeave:Connect(function()
			if button.BackgroundColor3 == UI_Enums.StudioColorValues.ButtonPressed then
				button.BackgroundColor3 = UI_Enums.StudioColorValues.Main
			end
		end)
	end
	
	button.MouseButton1Down:Connect(function()
		local buttonState = false 
		
		if extras and extras.Toggleable then
			local selColor = UI_Enums.StudioColorValues.ButtonSelected
					
			button.BackgroundColor3 = button.BackgroundColor3 == selColor and UI_Enums.StudioColorValues.Main or selColor
			buttonState = button.BackgroundColor3 ~= UI_Enums.StudioColorValues.Main
		elseif extras and extras.DoubleClick then -- can't have doubleclick and toggleable, makes no sense			
			local lastClicked = button:GetAttribute("LastClick")
			
			buttonState = os.clock() - lastClicked < 0.5 		
			button:SetAttribute("LastClick", os.clock())
		end
		
		clickCallback(buttonState)
	end)
end 



return UIUtility
