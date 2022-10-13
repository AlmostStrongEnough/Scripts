local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService =  game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Utils = require(ServerScriptService.Utils.Utils)


local dataStore = DataStoreService:GetDataStore("egfgytgfhg resfort") -- Always to "Official" when publishing

local toolConfig = require(ReplicatedStorage:FindFirstChild("Config"):FindFirstChild("ToolConfig"))
local rankConfig = require(ReplicatedStorage:FindFirstChild("Config"):FindFirstChild("RankConfig"))
local upgradeConfig = require(ReplicatedStorage:FindFirstChild("Config"):FindFirstChild("UpgradeConfig"))

local DEFAULTHEALTH = 100
local DEFAULTWALKSPEED = 16


--[[local function givePlayerCurrency(player: player)
	while true do
		task.wait(1)
		player.leaderstats.Coins.Value += 1
		player.leaderstats.Robux.Value += 1
	end
end]]

local function waitForRequestBudget(requestType)
	local currentBudget = DataStoreService:GetRequestBudgetForRequestType(requestType)
	while currentBudget < 1 do
		currentBudget = DataStoreService:GetRequestBudgetForRequestType(requestType)
		task.wait(5)
	end
end

local function giveItems(player: Player)
	local tool = player.inventory.EquippedTool.Value
	repeat task.wait() until player.Character
	local toolClone = ServerStorage:FindFirstChild("Tools"):FindFirstChild(tool):Clone()
	toolClone.Parent = player:FindFirstChild("Backpack")
	
	Utils.equipRank(player)
end

local function setupPlayerData(player: player)
	local userID = player.UserId
	local key = "Player_"..userID
	
	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"
	
	local coins = Instance.new("IntValue", leaderstats)
	coins.Name = "Coins"
	coins.Value = 200000
	
	local robux = Instance.new("IntValue", leaderstats)
	robux.Name = "Robux"
	robux.Value = 2500000
	
	local inventoryFolder = Instance.new("Folder", player)
	inventoryFolder.Name = "inventory"
	
	local equippedTool = Instance.new("StringValue", inventoryFolder)
	equippedTool.Name = "EquippedTool"
	equippedTool.Value = "CoinTool1"
	
	local ownedToolsFolder = Instance.new("Folder", inventoryFolder)
	ownedToolsFolder.Name = "OwnedTools"
	
	for _, toolTable in ipairs(toolConfig) do
		local toolBoolean = Instance.new("BoolValue", ownedToolsFolder)
		toolBoolean.Name = toolTable.ID
		
		if toolTable.ID == "CoinTool1" then
			toolBoolean.Value = true
		else
			toolBoolean.Value = false
		end
	end
	
	local equippedRank = Instance.new("StringValue", inventoryFolder)
	equippedRank.Name = "EquippedRank"
	equippedRank.Value = "Noob"
	
	local ownedRanksFolder = Instance.new("Folder", inventoryFolder)
	ownedRanksFolder.Name = "OwnedRanks"

	for _, rankTable in ipairs(rankConfig) do
		local rankBoolean = Instance.new("BoolValue", ownedRanksFolder)
		rankBoolean.Name = rankTable.ID

		if rankTable.ID == "Noob" then
			rankBoolean.Value = true
		else
			rankBoolean.Value = false
		end
	end
	
	local equippedUpgrade = Instance.new("StringValue", inventoryFolder)
	equippedUpgrade.Name = "EquippedUpgrade"
	equippedUpgrade.Value = "Upgrade1"

	local ownedUpgradesFolder = Instance.new("Folder", inventoryFolder)
	ownedUpgradesFolder.Name = "OwnedUpgrades"

	for _, upgradeTable in ipairs(upgradeConfig) do
		local upgradeBoolean = Instance.new("BoolValue", ownedUpgradesFolder)
		upgradeBoolean.Name = upgradeTable.ID

		if upgradeTable.ID == "Upgrade1" then
			upgradeBoolean.Value = true
		else
			upgradeBoolean.Value = false
		end
	end
	
	local sucess, returnValue
	repeat
		waitForRequestBudget(Enum.DataStoreRequestType.GetAsync)
		sucess, returnValue = pcall(dataStore.GetAsync, dataStore, key)
	until sucess or not Players:FindFirstChild(player.Name)
	
	if sucess then
		print(returnValue)
		if returnValue ~= nil then
			player.leaderstats.Coins.Value = if returnValue.Coins ~= nil then returnValue.Coins else 0
			player.leaderstats.Robux.Value = if returnValue.Robux ~= nil then returnValue.Robux else 0
			player.inventory.EquippedTool.Value = if returnValue.Inventory.EquippedTool ~= nil then returnValue.Inventory.EquippedTool else "CoinTool1"
		
			for _, tool in ipairs(player.inventory.OwnedTools:GetChildren()) do
				tool.Value = if returnValue.Inventory.OwnedTools[tool.Name] ~= nil then returnValue.Inventory.OwnedTools[tool.Name] else false
			end
		
			player.inventory.EquippedRank.Value = if returnValue.Inventory.EquippedRank ~= nil then returnValue.Inventory.EquippedRank else "Noob"
		
			if returnValue.Inventory.OwnedRanks then
				for _, rank in ipairs(player.inventory.OwnedRanks:GetChildren()) do
					rank.Value = if returnValue.Inventory.OwnedRanks[rank.Name] ~= nil then returnValue.Inventory.OwnedRanks[rank.Name] else false
				end
			end
			
			player.inventory.EquippedUpgrade.Value = if returnValue.Inventory.EquippedUpgrade ~= nil then returnValue.Inventory.EquippedUpgrade else "Upgrade1"

			if returnValue.Inventory.OwnedUpgrades then
				for _, upgrade in ipairs(player.inventory.OwnedUpgrades:GetChildren()) do
					upgrade.Value = if returnValue.Inventory.OwnedUpgrades[upgrade.Name] ~= nil then returnValue.Inventory.OwnedUpgrades[upgrade.Name] else false
				end
			end 
			
		end
		
	else
		player:Kick("There was an error loading Data! Robox's DataStore is probably down, try again later, or contact us through our Group!")
		print(player.Name.. "Data loading ERROR!!")
	end
	giveItems(player)
	-- givePlayerCurrency(player)
end

local function save(player)
	local userID = player.UserId
	local key = "Player_"..userID
	
	local coins = player.leaderstats.Coins.Value
	local robux = player.leaderstats.Robux.Value
	local equippedTool = player.inventory.EquippedTool.Value
	
	local ownedToolsTable = {}
	for _, tool in ipairs(player.inventory.OwnedTools:GetChildren()) do
		ownedToolsTable[tool.Name] = tool.Value
	end
	
	local equippedRank = player.inventory.EquippedRank.Value

	local ownedRanksTable = {}
	for _, rank in ipairs(player.inventory.OwnedRanks:GetChildren()) do
		ownedRanksTable[rank.Name] = rank.Value
	end
	
	local equippedUpgrade = player.inventory.EquippedUpgrade.Value

	local ownedUpgradesTable = {}
	for _, upgrade in ipairs(player.inventory.OwnedUpgrades:GetChildren()) do
		ownedUpgradesTable[upgrade.Name] = upgrade.Value
	end
	
	local dataTable = {
		Coins = coins,
		Robux = robux,
		Inventory = {
			EquippedTool = equippedTool,
			OwnedTools = ownedToolsTable,
			EquippedRank = equippedRank,
			OwnedRanks = ownedRanksTable,
			EquippedUpgrade = equippedUpgrade,
			OwnedUpgrades = ownedUpgradesTable,
		}
	}
	local sucess, returnValue
	repeat
		waitForRequestBudget(Enum.DataStoreRequestType.UpdateAsync)
		sucess, returnValue = pcall(dataStore.UpdateAsync, dataStore, key, function()
			return dataTable
		end)
	until sucess

	if sucess then
		print("Data Saved!")
		print(dataTable)
	else
		print("Data Saving ERROR!!")
	end
end

local function onShutdown()
	if RunService:IsStudio() then
		task.wait(2)
	else
		local finished = Instance.new("BindableEvent")
		local allPlayers = Players:GetPlayers()
		local leftPlayers = #allPlayers
		
		for _, player in ipairs(allPlayers) do
			coroutine.wrap(function()
				save(player)
				leftPlayers -=1
				if leftPlayers == 0 then
					finished:Fire()
				end
			end)()
		end
		finished.Event:Wait()
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	coroutine.wrap(setupPlayerData)(player)
end

Players.PlayerAdded:Connect(setupPlayerData)
Players.PlayerRemoving:Connect(save)
game:BindToClose(onShutdown)

while true do
	task.wait(600)
	for _, player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(save)(player)
	end
end
