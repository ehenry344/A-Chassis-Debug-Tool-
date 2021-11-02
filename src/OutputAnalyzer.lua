--[[
@author gilaga4815

Last Update : 6 / 8 / 2021

A - Chassis Vehicle Output Analyzer
]]

local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")

local Analyzer = {}
Analyzer.__index = Analyzer

local sMatch = string.match

function Analyzer.New(attachTo)
	local self = {		
		PluginData = {},
		BrokenPlugins = {},		
		VehicleErrors = {},
		
		VehicleModel = attachTo
	}
	
	self.PluginData.LocalPlugins = {}
	self.PluginData.ServerPlugins = {}
	
	return setmetatable(self, Analyzer)
end

function Analyzer:PopulatePluginData()
	local pluginsFolder = self.VehicleModel:FindFirstChild("A-Chassis Tune") and self.VehicleModel["A-Chassis Tune"]:FindFirstChild("Plugins")
	if not pluginsFolder then return end
	
	for i, v in pairs(pluginsFolder:GetDescendants()) do
		if v:IsA("LocalScript") then
			self.PluginData.LocalPlugins[#self.PluginData.LocalPlugins + 1] = v
		elseif v:IsA("Script") and v.Parent:IsA("RemoteEvent") or v.Parent:IsA("RemoteFunction") then			
			self.PluginData.ServerPlugins[#self.PluginData.ServerPlugins + 1] = v
		end
	end
end

function Analyzer:ScanOutputLog(lastLogTime) -- lastLogTime just allows me to better keep track of where the last logging period started.
	local currentLog = LogService:GetLogHistory()
	local startIndex = 1
	
	if lastLogTime ~= nil then
		for cStamp = 1, #currentLog do
			if currentLog[cStamp].timestamp > lastLogTime then
				startIndex = cStamp
				break
			end
		end
	end
	
	for i = startIndex, #currentLog do
		local logMessage = currentLog[i].message
		
		if (sMatch(logMessage, self.VehicleModel.Name) or sMatch(logMessage, "A-Chassis")) and not table.find(self.VehicleErrors, logMessage) then
			self.VehicleErrors[#self.VehicleErrors + 1] = logMessage -- add the log messages into the thing. 
		end
	end
end

function Analyzer:GetFromPath(path)
	for _, pluginSub in pairs(self.PluginData) do
		for i, v in pairs(pluginSub) do
			if v:IsA("LocalScript") and v.Name == path then
				return v
			elseif v:IsA("Script") and (v.Parent.Name .. "." .. v.Name) == path then
				return v
			end
		end
	end
end

function Analyzer:InterpretErrorData()
	for i = 1, #self.VehicleErrors do		
		local scriptSource = string.sub(self.VehicleErrors[i], 1, 6) == "Script" 
		local cleanedPath = scriptSource and string.gsub(sMatch(self.VehicleErrors[i], "%b\'\'"), "'", "") 
		
		if cleanedPath then
			cleanedPath = string.split(cleanedPath, ".")
			local formattedPath = ""
			
			if cleanedPath[1] == "Workspace" then -- this is how you know it's a localscript
				formattedPath = cleanedPath[#cleanedPath - 1] .. "." 
			end
			formattedPath = formattedPath .. cleanedPath[#cleanedPath]
			
			-- now to get the script source  
			
			local scriptInstance = self:GetFromPath(formattedPath)
			if scriptInstance then
				self.BrokenPlugins[#self.BrokenPlugins + 1] = scriptInstance
			end
		end	
	end
end

function Analyzer:PerformScan(lastLogTime)
	self:PopulatePluginData() -- get all the plugin scripts from the vehicle.
	self:ScanOutputLog(lastLogTime) -- check the output log for the errors that may pertain to these scripts
	self:InterpretErrorData()
	
	if #self.BrokenPlugins > 0 then
		return self.BrokenPlugins 
	end
end


function Analyzer:Destroy()
	for _, currentVal in pairs(self) do
		currentVal = nil
	end
	
	self = nil
end

return Analyzer 
