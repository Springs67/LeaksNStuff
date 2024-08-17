repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer.Character

local PlayerService = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lplr = PlayerService.LocalPlayer

local LiquidBounceLoaded = false

if getgenv == nil then
	getgenv = function() return {} end
end

local GuiScale = 0.9

local makefolder = getgenv().makefolder or function() warn("MAKEFOLDER NOT SUPPORTED!") end
local writefile = getgenv().writefile or function() warn("WRITEFILE NOT SUPPORTED!") end
local isfile = getgenv().isfile or function() warn("ISFILE NOT SUPPORTED!") end
local readfile = getgenv().readfile or function() warn("READFILE NOT SUPPORTED!") end
local delfile = getgenv().delfile or function() warn("DELFILE NOT SUPPORTED!") end
local loadfile = getgenv().loadfile or function() warn("LOADFILE NOT SUPPORTED!") end
local debugTest = debug.getupvalue ~= nil and debug.getupvalue or function() warn("DEBUG.GETUPVALUE NOT SUPPORTED!") end
local require = getgenv().require or function() warn("REQUIRE NOT SUPPORTED!") end

local hasDebugUpValue = function()
	return debug.getupvalue
end

local config = { -- LiquidConfig V1
	Buttons = {},
	Toggles = {},
	Dropdowns = {},
	Keybinds = {}
}

if not isfile("Liquidbounce") then
	makefolder("Liquidbounce")
end

if not isfile("Liquidbounce/Configs") then
	makefolder("Liquidbounce/Configs")
end

local isConfigAvailable = function()
	return isfile("Liquidbounce/Configs/"..game.PlaceId..".json")
end

local saveConfig = function()
	if isConfigAvailable() then
		delfile("Liquidbounce/Configs/"..game.PlaceId..".json")
	end

	writefile("Liquidbounce/Configs/"..game.PlaceId..".json",HttpService:JSONEncode(config))
end

local loadConfig = function()
	local data = readfile("Liquidbounce/Configs/"..game.PlaceId..".json")
	if data then
		config = HttpService:JSONDecode(data)
	end
end

if not isConfigAvailable() then
	saveConfig()
else
	loadConfig()
	task.wait(0.5)
end

local Gui = {
	GetInstance = function(instance,data)
		local inst = Instance.new(instance)

		for i,v in pairs(data) do
			inst[i] = v
		end

		return inst
	end,
}

local ScreenGui = Gui.GetInstance("ScreenGui",{
	Parent = lplr.PlayerGui,
	ResetOnSpawn = false,
	IgnoreGuiInset = true
})

local isInEditingMode = false

local Watermark = Gui.GetInstance("TextLabel",{
	Parent = ScreenGui,
	Size = UDim2.fromScale(0.13,0.04),
	Position = UDim2.fromScale(0.05,0.07),
	BackgroundTransparency = 1,
	Text = "Liquidbounce",
	TextSize = 24,
	TextColor3 = Color3.fromRGB(2, 93, 230),
	Active = true,
	Draggable = false,
	BorderSizePixel = 0,
})

local ArrayListFrame = Gui.GetInstance("Frame",{
	Parent = ScreenGui,
	Size = UDim2.fromScale(0.3,1),
	Position = UDim2.fromScale(0.68,0.05),
	BackgroundTransparency = 1,
})
local arrayItems = {}

local shadowAsset = "http://www.roblox.com/asset/?id=6288018083"

local Arraylist = {
	Create = function(name, subtext)
		task.spawn(function()
			repeat task.wait() until LiquidBounceLoaded
			local item =  Gui.GetInstance("TextLabel",{
				Parent = ArrayListFrame,
				BackgroundTransparency = 1,
				TextSize = 12,
				TextColor3 = Color3.fromRGB(2, 93, 230),
				Text = name .. " <font color=\"rgb(135,135,135)\">["..subtext.."]</font>",
				Size = UDim2.fromScale(1,0.03),
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 2,
				Name = name
			})

			if subtext ~= "" then
				item.RichText = true
				item.Text = name .. " <font color=\"rgb(135,135,135)\">["..subtext.."]</font>"
			else
				item.Text = name
			end

			table.insert(arrayItems,item)
			table.sort(arrayItems,function(a,b) return game.TextService:GetTextSize(a.Text.."  ",30,Enum.Font.SourceSans,Vector2.new(0,0)).X > game.TextService:GetTextSize(b.Text.."  ",30,Enum.Font.SourceSans,Vector2.new(0,0)).X end)
			for i,v in ipairs(arrayItems) do
				v.LayoutOrder = i
			end

		end)

	end,
	Remove = function(name)
		table.sort(arrayItems,function(a,b) return game.TextService:GetTextSize(a.Text.."  ",30,Enum.Font.SourceSans,Vector2.new(0,0)).X > game.TextService:GetTextSize(b.Text.."  ",30,Enum.Font.SourceSans,Vector2.new(0,0)).X end)
		for i,v in pairs(arrayItems) do
			if v.Name == name then
				v:Remove()
				table.remove(arrayItems,i)
			end
		end
	end,
}

local SortArrayList = Gui.GetInstance("UIListLayout",{
	Parent = ArrayListFrame,
	SortOrder = Enum.SortOrder.LayoutOrder
})

local EditHudButton = Gui.GetInstance("ImageButton",{
	Parent = ScreenGui,
	Position = UDim2.fromScale(0.01,0.92),
	Size = UDim2.fromScale(0.03,0.045),
	BorderSizePixel = 0,
	BackgroundColor3 = Color3.fromRGB(54, 71, 96),
	Image = "rbxassetid://11432847075",
})

local RoundEditHudButton = Gui.GetInstance("UICorner",{
	Parent = EditHudButton
})

local WindowInstances = {}
local ClickguiVisible = false

local toggleEditMode = function()
	isInEditingMode = not isInEditingMode
	EditHudButton.Visible = not isInEditingMode
	if isInEditingMode then
		for i,v in pairs(WindowInstances) do
			if ClickguiVisible then
				v.Visible = false
			end
		end
		Watermark.BackgroundTransparency = 0.5
		Watermark.Draggable = true
	else
		Watermark.BackgroundTransparency = 1
		Watermark.Draggable = false
	end
end

EditHudButton.MouseButton1Down:Connect(toggleEditMode)
EditHudButton.Visible = false

local Terminal = Gui.GetInstance("TextLabel", {
	Parent = ScreenGui,
	Position = UDim2.fromScale(0.7, 0.75),
	Size = UDim2.fromScale(0.2, 0.03),
	BorderColor3 = Color3.fromRGB(100, 100, 100),
	BorderSizePixel = 0,
	BackgroundColor3 = Color3.fromRGB(0,0,0),
	TextColor3 = Color3.fromRGB(255,255,255),
	Text = "   Command Prompt",
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	Active = true,
	Draggable = true,
	Visible = false
})

local TerminalFrame = Gui.GetInstance("Frame", {
	Parent = Terminal,
	Position = UDim2.fromScale(0, 1),
	Size = UDim2.fromScale(1, 4.5),
	BorderSizePixel = 0,
	BackgroundColor3 = Color3.fromRGB(25,25,25),
})
local sortTerminal = Gui.GetInstance("UIListLayout", {Parent = TerminalFrame})

local enterTerminalCode = Gui.GetInstance("TextBox", {
	Parent = TerminalFrame,
	BackgroundTransparency = 1,
	Text = "  Enter command . . .",
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = Color3.fromRGB(255,255,255),
	TextSize = 8,
	Size = UDim2.fromScale(1, 0.2),
	Name = "enterTerminalCode"
})

local AddToTerminal = function(stuff)
	local NewTextBox = Gui.GetInstance("TextLabel", {
		Parent = TerminalFrame,
		Size = UDim2.fromScale(1, 0.2),
		Position = UDim2.fromScale(0,0),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255,255,255),
		TextSize = 8,
		Text = "  "..stuff,
		TextXAlignment = Enum.TextXAlignment.Left
	})
end

local keybinds = {}

local getRemote = function(name)
	local remote
	for i,v in pairs(game:GetDescendants()) do
		if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
			if v.Name == name then
				remote = v
			end
		end
	end

	if remote == nil then
		return Instance.new("RemoteEvent")
	end

	return remote
end

enterTerminalCode.FocusLost:Connect(function()
	if enterTerminalCode.Text:lower():find("del all") or enterTerminalCode.Text:lower():find("delete all") then
		for i,v in pairs(TerminalFrame:GetChildren()) do
			if v.Name == "enterTerminalCode" then continue end
			v:Remove()
		end
	end

	local args = enterTerminalCode.Text:lower():split(" ")


	if args[1] == "bind" then
		if args[2] ~= nil and args[3] ~= nil then
			local module = args[2]
			local key = args[3]

			if keybinds[module] ~= nil then
				keybinds[module] = Enum.KeyCode[key:upper()]
				AddToTerminal("Succesfully bound "..module.. " to ".. key)
				config.Keybinds[module:lower()] = key:upper()
			end

			task.delay(0.2,function()
				saveConfig()
			end)
		end

	end

	enterTerminalCode.Text = "  Enter command . . ."
end)

AddToTerminal("LiquidBounce Roblox [Version 0.0.1]")

local isTogglingSounds = false

local WindowCount = 0
local GuiLibrary = {
	CreateWindow = function(name)
		local top = Gui.GetInstance("TextLabel",{
			Text = name,
			TextSize = 9,
			Size = UDim2.fromScale(0.1 * GuiScale,0.0395 * GuiScale),
			Position = UDim2.fromScale(0.1 + (0.11 * WindowCount),0.12),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(42,57,79),
			TextColor3 = Color3.fromRGB(255,255,255),
			Active = true,
			Draggable = true,
			Parent = ScreenGui,
			Visible = false,
			BorderSizePixel = 0
		})

		table.insert(WindowInstances,top)

		local dragging = false
		local draggingConnection

		top.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				draggingConnection = RunService.Heartbeat:Connect(function(delta)
					local MouseLocation = UserInputService:GetMouseLocation()
					top.Position = UDim2.fromOffset(MouseLocation.X, MouseLocation.Y)
				end)
			end
		end)

		top.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
				draggingConnection:Disconnect()
			end
		end)

		local hold = Gui.GetInstance("Frame", {
			Parent = top,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 10),
			BackgroundTransparency = 1,
		})

		local sort = Gui.GetInstance("UIListLayout", {
			Parent = hold
		})

		UserInputService.InputBegan:Connect(function(Key, GPE)
			if GPE then return end
			if Key.KeyCode == Enum.KeyCode.RightShift then
				top.Visible = not ClickguiVisible

				if name == "Combat" then
					Terminal.Visible = not Terminal.Visible
					ClickguiVisible = not ClickguiVisible

					if ClickguiVisible ~= EditHudButton.Visible then
						EditHudButton.Visible = ClickguiVisible
					end

					if isInEditingMode and not EditHudButton.Visible then
						toggleEditMode()
					end
				end
			end
		end)

		WindowCount += 1
		return {
			CreateButton = function(Table)
				local returnthing = {}

				local ShouldEnabled = false

				if config.Buttons[Table.Name] ~= nil then
					ShouldEnabled = config.Buttons[Table.Name].Enabled
				else
					config.Buttons[Table.Name] = {
						Enabled = false,
					}
				end

				local Button = Gui.GetInstance("TextButton", {
					Parent = hold,
					Size = UDim2.fromScale(1, 0.1),
					Position = UDim2.fromScale(0,0),
					BorderSizePixel = 0,
					Name = Table.Name,
					Text = "  " .. Table.Name,
					TextColor3 = Color3.fromRGB(255,255,255),
					BackgroundColor3 = Color3.fromRGB(54, 71, 96), -- 7,152,252 (ENABLED)
					TextXAlignment = Enum.TextXAlignment.Left,
					AutoButtonColor = false,
				})
				keybinds[Table.Name:lower()] = Enum.KeyCode.Unknown

				if config.Keybinds[Table.Name:lower()] ~= nil then
					keybinds[Table.Name:lower()] = Enum.KeyCode[config.Keybinds[Table.Name:lower()]]
				end

				local arrow = Gui.GetInstance("ImageButton", {
					Image = "rbxassetid://11419703997",
					BackgroundTransparency = 1,
					Parent = Button,
					Position = UDim2.fromScale(0.85, 0.3),
					Size = UDim2.fromScale(0.1, 0.4),
					Visible = false,
				})

				local dropdown = Gui.GetInstance("Frame", {
					Parent = Button,
					Size = UDim2.fromScale(1, 5),
					Position = UDim2.fromScale(1.02, 0),
					BackgroundTransparency = 1,
					Visible = false
				})

				local sortDropdown = Gui.GetInstance("UIListLayout", {
					Parent = dropdown
				})
				
				returnthing.SubText = ""
				returnthing.Enabled = false
				returnthing.ToggleButton = function()
					if isTogglingSounds then
						local clicksound = Instance.new("Sound")
						clicksound.SoundId = "rbxassetid://535716488" -- 535716488
						clicksound.Parent = workspace
						clicksound:Play()

						clicksound.Ended:Connect(function()
							clicksound:Remove()
						end)
					end

					returnthing.Enabled = not returnthing.Enabled
					Button.BackgroundColor3 = (returnthing.Enabled and Color3.fromRGB(7,152,252) or Color3.fromRGB(54, 71, 96))
					task.delay(0.1, function()
						task.spawn(function()
							repeat task.wait() until LiquidBounceLoaded
							Table.Function(returnthing.Enabled)
						end)
					end)

					config.Buttons[Table.Name].Enabled = returnthing.Enabled

					if returnthing.Enabled then
						if returnthing.SubText ~= "" then
							task.delay(0.1, function()
								Arraylist.Create(Table.Name, returnthing.SubText)
							end)
						else
							Arraylist.Create(Table.Name, "")
						end
					else
						Arraylist.Remove(Table.Name)
					end

					task.delay(0.1,function()
						saveConfig()
					end)
				end

				UserInputService.InputBegan:Connect(function(key, GPE)
					if GPE then return end

					if key.KeyCode == keybinds[Table.Name:lower()] and keybinds[Table.Name:lower()] ~= Enum.KeyCode.Unknown then
						returnthing.ToggleButton()
					end
				end)

				returnthing.ToggleDropdown = function()
					dropdown.Visible = not dropdown.Visible
				end

				Button.MouseButton1Down:Connect(function()
					returnthing.ToggleButton()
				end)

				if ShouldEnabled then
					returnthing.ToggleButton()
				end

				Button.MouseButton2Down:Connect(function()
					returnthing.ToggleDropdown()
				end)

				arrow.MouseButton1Down:Connect(function()
					returnthing.ToggleDropdown()
				end)

				returnthing.CreateToggle = function(Table2)
					arrow.Visible = true
					local ShouldEnabled2 = false

					local found = pcall(function()
						ShouldEnabled2 = config.Toggles[Table.Name.."_"..Table2.Name].Enabled
					end)
					if not found then
						config.Toggles[Table.Name.."_"..Table2.Name] = {
							Enabled = false,
						}
					end

					local newButton = Gui.GetInstance("TextButton", {
						Parent = dropdown,
						Size = UDim2.fromScale(0.8, 0.1),
						BackgroundColor3 = Color3.fromRGB(54, 71, 96),
						Text = "  " .. Table2.Name,
						Name = Table2.Name,
						BorderSizePixel = 0,
						TextColor3 = Color3.fromRGB(107, 107, 107),
						AutoButtonColor = false,
						TextStrokeTransparency = 0.85,
						TextXAlignment = Enum.TextXAlignment.Left
					})
					local funny = {}
					funny.Enabled = false

					funny.ToggleButton = function()
						funny.Enabled = not funny.Enabled

						config.Toggles[Table.Name.."_"..Table2.Name].Enabled = funny.Enabled

						newButton.TextColor3 = (funny.Enabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(107, 107, 107))
						task.spawn(function()
							if Table2.Function then
								Table2.Function(funny.Enabled)
							end
						end)

						task.delay(0.2,function()
							saveConfig()
						end)
					end

					if ShouldEnabled then
						funny.ToggleButton()
					end

					newButton.MouseButton1Down:Connect(function()
						funny.ToggleButton()
					end)

					return funny
				end

				returnthing.CreateDropdown = function(Table2)
					arrow.Visible = true
					local Mode = Table2.Options[1]

					local found = pcall(function()
						Mode = config.Dropdowns[Table.Name.."_"..Table2.Name].Mode
					end)
					if not found then
						config.Dropdowns[Table.Name.."_"..Table2.Name] = {
							Mode = Table2.Options[1],
						}
					end

					local newButton = Gui.GetInstance("TextButton", {
						Parent = dropdown,
						Size = UDim2.fromScale(0.8, 0.1),
						BackgroundColor3 = Color3.fromRGB(54, 71, 96),
						Text = "  " .. Table2.Name .. "               +",
						Name = Table2.Name,
						BorderSizePixel = 0,
						TextColor3 = Color3.fromRGB(255,255,255),
						AutoButtonColor = false,
						TextStrokeTransparency = 0.95,
						TextXAlignment = Enum.TextXAlignment.Left
					})

					local numbOfOptions = 0
					for i,v in pairs(Table2.Options) do numbOfOptions += 1 end

					if numbOfOptions < 2 then
						numbOfOptions = 2
					end

					local funnyFrame = Gui.GetInstance("Frame", {
						Parent = newButton,
						Size = UDim2.fromScale(1, numbOfOptions),
						Position = UDim2.fromScale(0, 1),
						Transparency = 1,
						Visible = false,
					})

					local sortDropdown = Gui.GetInstance("UIListLayout", {
						Parent = funnyFrame
					})

					local funny = {}
					funny.Option = Table2.Options[1]

					funny.ShowDropdown = function()
						for i,v in pairs(dropdown:GetChildren()) do
							if v:IsA("UIListLayout") then continue end
							if v.Name == Table2.Name then continue end
							v.Visible = not v.Visible
						end
						newButton.Text = (funnyFrame.Visible == false and "  " .. Table2.Name .. "               -" or "  " .. Table2.Name .. "               +")
						funnyFrame.Visible = not funnyFrame.Visible
					end

					local options = {}

					for i,v in pairs(Table2.Options) do
						local newthing = Gui.GetInstance("TextButton", {
							Name = v,
							Text = "  " .. v,
							Size = UDim2.fromScale(1, 0.4),
							Position = UDim2.fromScale(0,0),
							BackgroundColor3 = Color3.fromRGB(54, 71, 96),
							Parent = funnyFrame,
							TextColor3 = Color3.fromRGB(107, 107, 107),
							TextXAlignment = Enum.TextXAlignment.Left,
							BorderSizePixel = 0,
							AutoButtonColor = false,
						})

						table.insert(options,newthing)

						newthing.MouseButton1Down:Connect(function()
							for i,v in pairs(funnyFrame:GetChildren()) do
								if v:IsA("UIListLayout") then
									continue
								end
								v.TextColor3 = Color3.fromRGB(107, 107, 107)
							end
							newthing.TextColor3 = Color3.fromRGB(255,255,255)
							funny.Option = v

							config.Dropdowns[Table.Name.."_"..Table2.Name] = {
								Mode = v,
							}

							task.delay(0.2,function()
								saveConfig()
							end)
						end)

					end

					if found then
						for i,v in pairs(funnyFrame:GetChildren()) do
							if v:IsA("UIListLayout") then
								continue
							end
							v.TextColor3 = Color3.fromRGB(107, 107, 107)

							if v.Name == Mode then
								v.TextColor3 = Color3.fromRGB(255,255,255)
							end
						end

						funny.Option = Mode
					end

					newButton.MouseButton1Down:Connect(function()
						funny.ShowDropdown()
					end)

					return funny
				end

				return returnthing
			end,
		}
	end,
}

local getNearestPlayer = function(range)
	for i,v in pairs(PlayerService:GetPlayers()) do
		pcall(function()
			if v ~= lplr then
				if v.Character.Humanoid.Health > 0 then 
					if v.Character:FindFirstChild("PrimaryPart") then 
						if (v.Character.PrimaryPart.Position - lplr.Character.PrimaryPart.Position).Magnitude < range then
							return v
						end
					end
				end
			end
		end)
	end
	return nil
end

local Combat = GuiLibrary.CreateWindow("Combat")
local Player = GuiLibrary.CreateWindow("Player")
local Misc = GuiLibrary.CreateWindow("Misc")
local Movement = GuiLibrary.CreateWindow("Movement")
local Render = GuiLibrary.CreateWindow("Render")
local Exploit = GuiLibrary.CreateWindow("Exploit")
local World = GuiLibrary.CreateWindow("World")
local Fun = GuiLibrary.CreateWindow("Fun")

local lastPosOnGround = lplr.Character.PrimaryPart.CFrame
spawn(function()
	repeat
		if lplr.Character.Humanoid.Health > 0.1 then
			if lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
				lastPosOnGround = lplr.Character.PrimaryPart.CFrame
			end
		end
		task.wait(0.1)
	until false
end)

local HurtTime = 55
spawn(function()
	local lastHP = lplr.Character.Humanoid.Health
	repeat
		HurtTime += 1

		if lastHP > lplr.Character.Humanoid.Health then
			HurtTime = 0
		end

		lastHP = lplr.Character.Humanoid.Health
		task.wait(0.1)
	until false
end)

local weaponMeta = {
	{"rageblade", 100},
	{"emerald_sword", 99},
	{"deathbloom", 99},
	{"glitch_void_sword", 98},
	{"sky_scythe", 98},
	{"diamond_sword", 97}, 
	{"iron_sword", 96},
	{"stone_sword", 95},
	{"wood_sword", 94},
	{"emerald_dao", 93},
	{"diamond_dao", 99},
	{"diamond_dagger", 99},
	{"diamond_great_hammer", 99},
	{"diamond_scythe", 99},
	{"iron_dao", 97},
	{"iron_scythe", 97},
	{"iron_dagger", 97},
	{"iron_great_hammer", 97},
	{"stone_dao", 96},
	{"stone_dagger", 96},
	{"stone_great_hammer", 96},
	{"stone_scythe", 96},
	{"wood_dao", 95},
	{"wood_scythe", 95},
	{"wood_great_hammer", 95},
	{"wood_dagger", 95},
	{"frosty_hammer", 1},
}
local getInventory = function()
	return lplr.Character.InventoryFolder.Value or Instance.new("Folder")
end

local function hasItem(item)
	if getInventory():FindFirstChild(item) then
		return true, 1
	end
	return false
end

local function getBestWeapon()
	local bestSword
	local bestSwordMeta = 0
	for i, sword in ipairs(weaponMeta) do
		local name = sword[1]
		local meta = sword[2]
		if meta > bestSwordMeta and hasItem(name) then
			bestSword = name
			bestSwordMeta = meta
		end
	end
	return getInventory():FindFirstChild(bestSword)
end

local function getNearestPlayer(range)
	local nearest
	local nearestDist = math.huge
	for i,v in pairs(PlayerService:GetPlayers()) do
		pcall(function()
			if v ~= lplr or v.Team ~= lplr.Team then 
				if v.Character.Humanoid.health > 0 and (v.Character.PrimaryPart.Position - lplr.Character.PrimaryPart.Position).Magnitude < nearestDist and (v.Character.PrimaryPart.Position - lplr.Character.PrimaryPart.Position).Magnitude <= range then
					nearest = v
					nearestDist = (v.Character.PrimaryPart.Position - lplr.Character.PrimaryPart.Position).Magnitude
				end
			end
		end)
	end
	return nearest
end

local SetInvItem = getRemote("SetInvItem")
local function spoofHand(item)
	if hasItem(item) then
		SetInvItem:InvokeServer({
			["hand"] = getInventory():WaitForChild(item)
		})
	end
end

local knitRecieved, knit
knitRecieved, knit = pcall(function()
	repeat task.wait()
		return debugTest(require(lplr.PlayerScripts.TS.knit).setup, 6)
	until knitRecieved
end)

local getController = function(controller, placeholder)

	if knit == nil then
		knit = {Controllers = {}}
	end

	if knit.Controllers == nil then
		knit = {Controllers = {}}
	end

	local Controller = knit.Controllers[controller] ~= nil and knit.Controllers[controller] or placeholder

	return Controller
end

local getPath = function(path,method)
	return path ~= nil and path or Instance.new(method)
end

local Bedwars
Bedwars = {
	SwordHit = getRemote("SwordHit"),
	GroundHit = getRemote("GroundHit"),
	ProjectileFire = getRemote("ProjectileFire"),
	ConsumeRemote = getRemote("ConsumeItem"),
	PickupItemDrop = getRemote("PickupItemDrop"),
	Chest = getRemote("Inventory/ChestGetItem"),
	HangGliderController = getController("HangGliderController",{}),
	SprintController = getController("SprintController",{
		issprinting = false,
		startSprinting = function()
			print("THIS METHOD OF SPRINT IS UNSUPPORTED ON YOUR EXECUTOR")
		end,
		stopSprinting = function()
			print("THIS METHOD OF SPRINT IS UNSUPPORTED ON YOUR EXECUTOR")
		end
	}),
	JadeHammerController = getController("JadeHammerController",{}),
	PictureModeController = getController("PictureModeController", {}),
	SwordController = getController("SwordController", {}),
	Report = getController("report-controller", {}),
}

if hasDebugUpValue() then
	Bedwars.Knockback = debug.getupvalue(require(ReplicatedStorage.TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity, 1)
else
	Bedwars.Knockback = {
		kbDirectionStrength = 100,
		kbUpwardStrength = 100
	}
end

if ReplicatedStorage:FindFirstChild("TS") then
	if ReplicatedStorage:WaitForChild("TS"):FindFirstChild("combat") then
		if ReplicatedStorage:WaitForChild("TS"):FindFirstChild("combat"):FindFirstChild("combat-constant") then
			pcall(function()
				Bedwars.Reach = require(ReplicatedStorage:WaitForChild("TS"):FindFirstChild("combat"):FindFirstChild("combat-constant"))
			end)
		end
	end
end

function attackPlayer(nearest)
	local weapon = getBestWeapon()
	Bedwars.SwordHit:FireServer({
		chargedAttack = {
			chargeRatio = 0
		},
		entityInstance = nearest.Character,
		validate = {
			targetPosition = {
				value = nearest.Character.PrimaryPart.Position
			},
			selfPosition = {
				value = lplr.Character.PrimaryPart.Position
			},
		},
		weapon = weapon
	})
end

local Animations = {
	["Normal"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-65), math.rad(55), math.rad(-51)), Timer = 0.1},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-179), math.rad(94), math.rad(33)), Timer = 0.16},
	},
	["Spin"] = {
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.69, -0.7, 0.1) * CFrame.Angles(math.rad(-145), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-180), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-220), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-270), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-310), math.rad(0), math.rad(0)), Timer = 0.05},
		{CFrame = CFrame.new(0.16, -1.16, 0.5) * CFrame.Angles(math.rad(-360), math.rad(0), math.rad(0)), Timer = 0.05},
	},
	["Sigma"] = {
		{CFrame = CFrame.new(-0.69, -0.7, 0.6) * CFrame.Angles(math.rad(-10), math.rad(50), math.rad(-90)), Timer = 0.1},
		{CFrame = CFrame.new(-0.7, -0.71, 0.59) * CFrame.Angles(math.rad(-64), math.rad(70), math.rad(-38)), Timer = 0.2}
	},
	["Clean"] = {
		{CFrame = CFrame.new(0.7, -0.3, 0.612) * CFrame.Angles(math.rad(285), math.rad(65), math.rad(293)), Timer = 0.2},
		{CFrame = CFrame.new(0.61, -0.41, 0.6) * CFrame.Angles(math.rad(210), math.rad(70), math.rad(3)), Timer = 0.2},
	},
}

local ViewModel = workspace.Camera

if workspace.Camera:FindFirstChild("Viewmodel") then
	ViewModel = workspace.Camera.Viewmodel.RightHand.RightWrist
end

local weld
local oldweld

if ViewModel ~= workspace.Camera then
	weld = ViewModel.C0
	oldweld = ViewModel.C0
end

lplr.CharacterAdded:Connect(function()
	task.wait(1)
	ViewModel = workspace.Camera
	if workspace.Camera:FindFirstChild("Viewmodel") then
		ViewModel = workspace.Camera.Viewmodel.RightHand.RightWrist
	end
end)

local glowify = function(inst : Part,color)
	inst.CastShadow = false
	inst.Material = Enum.Material.Neon
	local c = Instance.new("Highlight",inst)
	c.FillColor = inst.Color
	c.OutlineTransparency = 1
	c.DepthMode = Enum.HighlightDepthMode.Occluded
	inst.Color = color.GlowColor

	if color.Rainbow then
		local t = 0
		local connection
		connection = RunService.Heartbeat:Connect(function(dt)
			t += 0.0003
			inst.Color = Color3.fromHSV(t%1,1,1)
		end)
		inst.Destroying:Once(function()
			connection:Disconnect()
		end)
	end
end

local Queue = function(Item, Time)
	task.spawn(function()
		if ScreenGui:FindFirstChild("QueueInst") then
			ScreenGui.QueueInst = nil
			ScreenGui.QueueInst:Destroy()
		end
		local QueueInst = Gui.GetInstance("TextLabel", {
			Parent = ScreenGui,
			Name = "QueueInst",
			Text = Item .. " Queued",
			Size = UDim2.fromScale(0.1, 0.03),
			Position = UDim2.fromScale(0.45,0.7),
			BackgroundColor3 = Color3.fromRGB(60,60,60),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 2,
		})
		local QueueInstFrame = Gui.GetInstance("Frame", {
			Parent = QueueInst,
			Position = UDim2.fromScale(0,0),
			Size = UDim2.fromScale(0,1),
			BackgroundColor3 = Color3.fromRGB(0,100,255),
			BorderSizePixel = 0,
			ZIndex = 1,
		})

		TweenService:Create(QueueInst, TweenInfo.new(Time), {
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(QueueInstFrame, TweenInfo.new(Time), {
			Size = UDim2.fromScale(1, 1)
		}):Play()

		task.delay(Time, function()
			QueueInst:Remove()
		end)
	end)
end

local AuraLoop
local AuraBox = Instance.new("Part",workspace)
AuraBox.CFrame = CFrame.new(10000,10000,10000)
AuraBox.Size = Vector3.new(4,6,4)
AuraBox.Color = Color3.fromRGB(255,0,0)
AuraBox.Anchored = true
AuraBox.CanCollide = false
AuraBox.CanQuery = false
AuraBox.Transparency = 0.5

glowify(AuraBox,{
	GlowColor = Color3.fromRGB(255,255,255),
	Rainbow = true,
})

KillAura = Combat.CreateButton({
	Name = "KillAura",
	Function = function(callback)
		if callback then
			local lastNearestHP = 100
			local Tick = 0
			AuraLoop = RunService.Heartbeat:Connect(function()
				local nearest = getNearestPlayer(18)
				if nearest then
					if ShowBox.Enabled then
						AuraBox.CFrame = nearest.Character.PrimaryPart.CFrame
					end
					if KillAuraMode.Option == "Normal" then
						attackPlayer(nearest)
					elseif KillAuraMode.Option == "Queue" then
						if nearest.Character.Humanoid.Health >= lastNearestHP and Tick > 35 then
							Queue("Aura", 0.2)
							attackPlayer(nearest)
							Tick = 0
						end
					elseif KillAuraMode.Option == "Tick" then
						if Tick > 24 then
							attackPlayer(nearest)
						end
					end
					lastNearestHP = nearest.Character.Humanoid.Health
				else
					AuraBox.CFrame = CFrame.new(10000,10000,10000)
				end
				Tick += 1
			end)

			repeat
				local nearest = getNearestPlayer(19)

				if nearest then
					local animation = Animations[KillAuraAnimation.Option]
					local allTime = 0
					task.spawn(function()
						if animation ~= "None"  then
							local animRunning = true
							for i,v in pairs(animation) do allTime += v.Timer end
							for i,v in pairs(animation) do
								local tween = TweenService:Create(ViewModel,TweenInfo.new(v.Timer),{C0 = oldweld * v.CFrame})
								tween:Play()
								task.wait(v.Timer - 0.01)
							end
							animRunning = false
							TweenService:Create(ViewModel,TweenInfo.new(1),{C0 = oldweld}):Play()
						end
					end)
					task.wait(allTime)
				end
				task.wait()
			until not KillAura.Enabled
		else
			pcall(function()
				AuraLoop:Disconnect()
			end)
			AuraBox.CFrame = CFrame.new(10000,10000,10000)
		end
	end,
})
KillAuraMode = KillAura.CreateDropdown({
	Name = "Method",
	Options = {"Normal", "Queue", "Tick"}
})
KillAuraAnimation = KillAura.CreateDropdown({
	Name = "Animations",
	Options = {"None", "Normal", "Spin", "Sigma", "Clean"}
})
ShowBox = KillAura.CreateToggle({
	Name = "Show Box"
})

--[[WTap = Combat.CreateButton({
	Name = "WTap",
	Function = function(callback)
		if callback then
			repeat
				local nearest = getNearestPlayer(12)

				if nearest then
					lplr.Character.PrimaryPart.Anchored = not lplr.Character.PrimaryPart.Anchored
					task.wait(math.random(0.4, 0.5))
				else
					lplr.Character.PrimaryPart.Anchored = false
				end
				task.wait()
			until not WTap.Enabled
		end
	end,
})]]

BackTrack = Combat.CreateButton({
	Name = "BackTrack",
	Function = function(callback)
		if callback then
			repeat
				for i,v in pairs(PlayerService:GetPlayers()) do
					if v ~= lplr and v.Team ~= lplr.Team then
						v.Character.PrimaryPart.Anchored = true
						task.wait(0.2)
						v.Character.PrimaryPart.Anchored = false
						task.wait(0.2)
					end
				end
				task.wait()
			until not BackTrack.Enabled
		end
	end,
})

FakeLag = Combat.CreateButton({
	Name = "FakeLag",
	Function = function(callback)
		if callback then
			repeat
				local nearest = getNearestPlayer(20)

				if nearest then
					lplr.Character.PrimaryPart.Anchored = true
					lplr.Character.PrimaryPart.CFrame += Vector3.new(3 * math.random(math.random(-1, 1)), 1 * math.random(math.random(-1, 1)), 3 * math.random(math.random(-1, 1)))
					task.wait(0.3)
					lplr.Character.PrimaryPart.Anchored = false
					task.wait(0.7)
				end
				task.wait()
			until not FakeLag.Enabled
		end
	end,
})

Sprint = Combat.CreateButton({
	Name = "Sprint",
	Function = function(callback)
		if callback then
			repeat
				if SprintMode.Option == "Table" then
					if not Bedwars.SprintController.issprinting then
						Bedwars.SprintController:startSprinting()
					end
				end
				if SprintMode.Option == "Spoof" then
					if lplr.Character.Humanoid.Health > 0.1 then
						lplr.Character.Humanoid.WalkSpeed = 20
						workspace.CurrentCamera.FieldOfView = 120
					end
				end
				task.wait()
			until not Sprint.Enabled
		end
	end,
})
SprintMode = Sprint.CreateDropdown({
	Name = "Mode",
	Options = {"Table", "Spoof"}
})

Velocity = Combat.CreateButton({
	Name = "Velocity",
	Function = function(callback)
		if callback then
			repeat
				if VeloMethod.Option == "Table" then
					Bedwars.Knockback.kbUpwardStrength = 0
					Bedwars.Knockback.kbDirectionStrength = 0
				end
				if VeloMethod.Option == "Anchor" then
					if HurtTime < 6 then
						lplr.Character.PrimaryPart.Anchored = true
						lplr.Character.PrimaryPart.Velocity = Vector3.zero
						task.wait(0.02)
						lplr.Character.PrimaryPart.Anchored = false
					end
				end
				task.wait()
			until not Velocity.Enabled
			Bedwars.Knockback.kbUpwardStrength = 1000
			Bedwars.Knockback.kbDirectionStrength = 1000
		end
	end,
})
VeloMethod = Velocity.CreateDropdown({
	Name = "Method",
	Options = {"Table", "Anchor"}
})

AutoEat = Combat.CreateButton({
	Name = "AutoEat",
	Function = function(callback)
		if callback then
			repeat
				if hasItem("health_apple") then
					Bedwars.ConsumeRemote:InvokeServer({
						["item"] = getInventory():WaitForChild("health_apple")
					})
				end
				if hasItem("gold_apple") then
					Bedwars.ConsumeRemote:InvokeServer({
						["item"] = getInventory():WaitForChild("gold_apple")
					})
				end
				if hasItem("pie") then
					Bedwars.ConsumeRemote:InvokeServer({
						["item"] = getInventory():WaitForChild("pie")
					})
				end
				task.wait()
			until not AutoEat.Enabled
		end
	end,
})

AutoPot = Combat.CreateButton({
	Name = "AutoPot",
	Function = function(callback)
		if callback then
			repeat
				if hasItem("speed_potion") then
					Bedwars.ConsumeRemote:InvokeServer({
						["item"] = getInventory():WaitForChild("speed_potion")
					})
				end
				if hasItem("jump_potion") then
					Bedwars.ConsumeRemote:InvokeServer({
						["item"] = getInventory():WaitForChild("jump_potion")
					})
				end
				if hasItem("invisibility_potion") then
					Bedwars.ConsumeRemote:InvokeServer({
						["item"] = getInventory():WaitForChild("invisibility_potion")
					})
				end
				if hasItem("big_head_potion") then
					Bedwars.ConsumeRemote:InvokeServer({
						["item"] = getInventory():WaitForChild("big_head_potion")
					})
				end
				if hasItem("forcefield_potion") then
					Bedwars.ConsumeRemote:InvokeServer({
						["item"] = getInventory():WaitForChild("forcefield_potion")
					})
				end
				task.wait()
			until not AutoPot.Enabled
		end
	end,
})

NoFall = Player.CreateButton({
	Name = "NoFall",
	Function = function(callback)
		if callback then
			repeat
				Bedwars.GroundHit:FireServer()
				task.wait(0.5)
			until not NoFall.Enabled
		end
	end,
})

AntiVoid = Movement.CreateButton({
	Name = "AntiVoid",
	Function = function(callback)
		if callback then
			repeat
				if AntiVoidMode.Option == "Legit" then
					if lplr.Character.PrimaryPart.Position.Y < 0 then
						for i = 1, 7 do
							local item = getInventory():FindFirstChild("wood_pickaxe")
							if item then spoofHand(item) end
							task.wait(0.01)
							spoofHand(getBestWeapon())
							task.wait(0.01)
						end
						lplr.Character.PrimaryPart.CFrame = lastPosOnGround
					end
				end
				task.wait()
			until not AntiVoid.Enabled
		end
	end,
})
AntiVoidMode = AntiVoid.CreateDropdown({
	Name = "Mode",
	Options = {"Legit", "Blatant"}
})

local ShootItem = function(bow, pos)
	if tostring(bow.Name):lower():find("bow") then
		Bedwars.ProjectileFire:InvokeServer({
			[1] = bow,
			[2] = "arrow",
			[3] = "arrow",
			[4] = pos,
			[5] = pos + Vector3.new(0,2,0),
			[6] = Vector3.new(0,-5,0),
			[7] = tostring(game:GetService("HttpService"):GenerateGUID(true)),
			[8] = {
				["drawDurationSeconds"] = 1,
				["shotId"] = tostring(game:GetService("HttpService"):GenerateGUID(false))
			},
			[9] = workspace:GetServerTimeNow() - 0.045
		})
	else
		Bedwars.ProjectileFire:InvokeServer({
			[1] = bow,
			[2] = tostring(bow.Name),
			[3] = tostring(bow.Name),
			[4] = pos,
			[5] = pos + Vector3.new(0,2,0),
			[6] = Vector3.new(0,-5,0),
			[7] = tostring(game:GetService("HttpService"):GenerateGUID(true)),
			[8] = {
				["drawDurationSeconds"] = 1,
				["shotId"] = tostring(game:GetService("HttpService"):GenerateGUID(false))
			},
			[9] = workspace:GetServerTimeNow() - 0.045
		})
	end
end

--[[FastPickup = Misc.CreateButton({
	Name = "FastPickup",
	Function = function(callback)
		if callback then
			repeat
				for i,v in pairs(workspace.ItemDrops:GetChildren()) do
					if (v.Position - lplr.Character.PrimaryPart.Position).Magnitude <= 20 then
						Bedwars.PickupItemDrop:InvokeServer({
							[1] = {["ItemDrop"] = v}
						})
					end
				end
				task.wait()
			until not FastPickup.Enabled
		end
	end,
})

RemoveSounds = Misc.CreateButton({
	Name = "RemoveSounds",
	Function = function(callback)
		if callback then
			repeat
				if FootSteps.Enabled then
					for i,v in pairs(workspace.GameSounds:GetChildren()) do
						if v.Name == "FootSteps" then
							v:Remove()
						end
					end
				end
				task.wait()
			until not RemoveSounds.Enabled
		end
	end,
})
FootSteps = RemoveSounds.CreateToggle({
	Name = "FootSteps"
})]]

local FlyFlagPart = Instance.new("Part",workspace)
FlyFlagPart.CFrame = CFrame.new(10000,10000,10000)
FlyFlagPart.Size = Vector3.new(4,1,4)
FlyFlagPart.Color = Color3.fromRGB(0,255,0)
FlyFlagPart.Anchored = true
FlyFlagPart.CanCollide = false
FlyFlagPart.CanQuery = false
FlyFlagPart.Transparency = 0.5
FlyFlagPart.Material = Enum.Material.SmoothPlastic

Fly = Movement.CreateButton({
	Name = "Fly",
	Function = function(callback)
		if callback then
			repeat
				local Velocity = lplr.Character.PrimaryPart.Velocity
				
				if FlyMode.Option == "Heatseeker" then
					lplr.Character.PrimaryPart.Velocity = Vector3.new(Velocity.X, 2.02, Velocity.Z)
					if UserInputService:IsKeyDown("Space") then
						lplr.Character.PrimaryPart.Velocity = Vector3.new(Velocity.X, 44, Velocity.Z)
					end
					if UserInputService:IsKeyDown("LeftShift") then
						lplr.Character.PrimaryPart.Velocity = Vector3.new(Velocity.X, -44, Velocity.Z)
					end
				elseif FlyMode.Option == "HeatseekerJump" then
					workspace.Gravity = 80
					lplr.Character.PrimaryPart.Velocity = Vector3.new(Velocity.X, 25, Velocity.Z)
					task.wait(0.6)
				end
				
				if FlyFlag.Enabled then FlyFlagPart.CFrame = lplr.Character.PrimaryPart.CFrame + Vector3.new(0, 2.5, 0) else FlyFlagPart.CFrame = CFrame.new(100000,1000000,1000000) end
				
				task.wait()
			until not Fly.Enabled
			FlyFlagPart.CFrame = CFrame.new(100000,1000000,1000000)
			workspace.Gravity = 196.2
		end
	end,
})
FlyMode = Fly.CreateDropdown({
	Name = "Mode",
	Options = {"Heatseeker", "HeatseekerJump"}
})
FlyFlag = Fly.CreateToggle({
	Name = "Flag"
})

LongJump = Movement.CreateButton({
	Name = "LongJump",
	Function = function(callback)
		if callback then
			repeat
				if LongJumpMode.Option == "Heatseeker1" then
					local Velocity = lplr.Character.PrimaryPart.Velocity

					lplr.Character.PrimaryPart.Velocity = Vector3.new(Velocity.X, 25, Velocity.Z)

					task.wait(0.23)
				end
				task.wait()
			until not LongJump.Enabled
		end
	end,
})
LongJumpMode = LongJump.CreateDropdown({
	Name = "Mode",
	Options = {"Heatseeker1"}
})

HighJump = Movement.CreateButton({
	Name = "HighJump",
	Function = function(callback)
		if callback then
			for i = 1, 44 do
				lplr.Character.PrimaryPart.Velocity += Vector3.new(0, 35, 0)
				task.wait(0.04)
			end
			HighJump.ToggleButton(false)
		else
			lplr.Character.PrimaryPart.Velocity = Vector3.new(0, 50, 0)
		end
	end,
})

local SpeedConnect
Speed = Movement.CreateButton({
	Name = "Speed",
	Function = function(callback)
		if callback then
			SpeedConnect = RunService.Heartbeat:Connect(function() 
				if HurtTime < 7 then
					lplr.Character.PrimaryPart.CFrame += (lplr.Character:GetAttribute("SpeedBoost") and 0.4 or 0.17) * lplr.Character.Humanoid.MoveDirection
				else
					lplr.Character.PrimaryPart.CFrame += (lplr.Character:GetAttribute("SpeedBoost") and 0.14 or 0.014) * lplr.Character.Humanoid.MoveDirection
				end
			end)
		else
			pcall(function()
				SpeedConnect:Disconnect()
			end)
		end
	end,
})
SpeedMode = Speed.CreateDropdown({
	Name = "Mode",
	Options = {"Heatseeker"}
})

local ChestsInWorkspace = {}
for i,v in pairs(workspace:GetChildren()) do
	if v.Name == "chest" then
		table.insert(ChestsInWorkspace, v)
	end
end
ChestStealer = World.CreateButton({
	Name = "ChestStealer",
	Function = function(callback)
		if callback then
			repeat
				for i,v in pairs(ChestsInWorkspace) do
					if (v.Position - lplr.Character.PrimaryPart.Position).Magnitude <= 25 then
						for _, items in pairs(v.ChestFolderValue.Value:GetChildren()) do
							if items:IsA("Accessory") then
								task.wait()
								Bedwars.Chest:InvokeServer(v.ChestFolderValue.Value, items)
							end
						end
					end
				end
				task.wait()
			until not ChestStealer.Enabled
		end
	end,
})
ChestStealerMode = ChestStealer.CreateDropdown({
	Name = "Mode",
	Options = {"Silent"}
})

AntiAFK = Player.CreateButton({
	Name = "AntiAFK",
	Function = function(callback)
		if callback then
			local startingPos = lplr.Character.PrimaryPart.Position
			repeat
				if AntiAFKMethod.Option == "AI" then
					lplr.Character.Humanoid:MoveTo(startingPos + Vector3.new(math.random(1, 10), 0, math.random(1, 10)))
					task.wait(5)
				end
				task.wait()
			until not AntiAFK.Enabled
		end
	end,
})
AntiAFKMethod = AntiAFK.CreateDropdown({
	Name = "Method",
	Options = {"AI"}
})

ArrayList = Render.CreateButton({
	Name = "ArrayList",
	Function = function(callback)
		ArrayListFrame.Visible = callback
	end,
})

local Messages = {
	["Normal"] = {
		"dísçórď gg / FzsC5Vjg - liquidbounce on top",
		"Get LiquidBounce if you know whats good for you",
		"LiquidBounce > every other garbage solaris script",
		"Cooking with LiquidBounce rn honestly",
		"Get LiquidBounce today :)",
		"Winning every match btw",
		"Top tier legit player btw",
	},
}

Spammer = Misc.CreateButton({
	Name = "Spammer",
	Function = function(callback)
		if callback then
			repeat
				ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Messages[SpammerMode.Option][math.random(1, #Messages[SpammerMode.Option])], "All")
				task.wait(10)
			until not Spammer.Enabled
		end
	end,
})
SpammerMode = Spammer.CreateDropdown({
	Name = "Mode",
	Options = {"Normal"}
})

ToggleSounds = Render.CreateButton({
	Name = "ToggleSounds",
	Function = function(callback)
		isTogglingSounds = callback
	end,
})
ToggleSoundsMode = ToggleSounds.CreateDropdown({
	Name = "Mode",
	Options = {"Minecraft"}
})

local addESP = function(char,plr)
	pcall(function()
		local ui = Instance.new("BillboardGui",char)
		ui.Size = UDim2.fromScale(1,1)
		ui.AlwaysOnTop = true
		local frame = Instance.new("Frame",ui)
		frame.Size = UDim2.fromScale(4.5,5.5)
		frame.AnchorPoint = Vector2.new(0.5,0.5)
		frame.Transparency = 0.8
		frame.BorderSizePixel = 0
		frame.BackgroundColor3 = plr.Team == lplr.Team and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
	end)
end

local ESPConnection
ESP = Render.CreateButton({
	Name = "ESP",
	Function = function(callback)
		if callback then
			local playerAdded = {}

			ESPConnection = PlayerService.PlayerAdded:Connect(function(plr)
				plr.CharacterAdded:Connect(function(char)
					task.spawn(function()
						repeat task.wait() until char ~= nil
						if plr ~= lplr then
							addESP(char,plr)
						end
					end)
				end)
			end)

			for i,v in pairs(PlayerService:GetPlayers()) do
				pcall(function()
					if v ~= lplr then
						addESP(v.Character,v)
					end
				end)
			end
		else
			ESPConnection:Disconnect()
		end
	end,
})

LiquidBounceLoaded = true
