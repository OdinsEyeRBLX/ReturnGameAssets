-- [!] PLACE THIS LOCAL SCRIPT IN StarterPlayer -> StarterPlayerScripts

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RemoteEvent = ReplicatedStorage:WaitForChild("AssetScannerUpdate") -- [!] CREATE A REMOTE EVENT WITHIN REPLICATED STORAGE IF NOT DONE ALREADY!

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create main GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AssetScannerGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.5, 0, 0.6, 0)
frame.Position = UDim2.new(0.25, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = true
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

local padding = Instance.new("UIPadding", frame)
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)

-- Tabs
local tabs = { "Meshes", "Sounds", "Animations", "Scripts" }
local tabButtons = {}
local tabFrames = {}
local selectedTab = "Meshes"

local buttonBar = Instance.new("Frame")
buttonBar.Size = UDim2.new(1, 0, 0, 30)
buttonBar.BackgroundTransparency = 1
buttonBar.Parent = frame

-- Tab buttons
for i, tabName in ipairs(tabs) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 100, 1, 0)
	btn.Position = UDim2.new(0, (i - 1) * 105, 0, 0)
	btn.Text = tabName
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Parent = buttonBar

	tabButtons[tabName] = btn

	local contentFrame = Instance.new("ScrollingFrame")
	contentFrame.Size = UDim2.new(1, 0, 1, -40)
	contentFrame.Position = UDim2.new(0, 0, 0, 35)
	contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	contentFrame.Visible = (tabName == selectedTab)
	contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentFrame.ScrollBarThickness = 8
	contentFrame.ClipsDescendants = true
	contentFrame.Parent = frame

	local tb = Instance.new("TextBox")
	tb.Size = UDim2.new(1, -10, 0, 0)
	tb.Position = UDim2.new(0, 5, 0, 5)
	tb.AutomaticSize = Enum.AutomaticSize.Y
	tb.BackgroundTransparency = 1
	tb.ClearTextOnFocus = false
	tb.MultiLine = true
	tb.TextWrapped = false
	tb.TextEditable = false
	tb.Text = ""
	tb.TextColor3 = Color3.new(1, 1, 1)
	tb.Font = Enum.Font.Code
	tb.TextSize = 14
	tb.TextXAlignment = Enum.TextXAlignment.Left
	tb.TextYAlignment = Enum.TextYAlignment.Top
	tb.Parent = contentFrame

	tabFrames[tabName] = { frame = contentFrame, textbox = tb }

	btn.MouseButton1Click:Connect(function()
		selectedTab = tabName
		for name, data in pairs(tabFrames) do
			data.frame.Visible = (name == tabName)
		end
	end)
end

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
local corner11 = Instance.new("UICorner", reopenBtn)
corner11.CornerRadius = UDim.new(0, 6)
corner11.Parent = closeBtn
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

-- Reopen Button
local reopenBtn = Instance.new("ImageButton")
reopenBtn.Size = UDim2.new(0, 40, 0, 40)
reopenBtn.Position = UDim2.new(1, -50, 1, -50)
reopenBtn.Image = "rbxassetid://74742955012320"
reopenBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
reopenBtn.BackgroundTransparency = 0.4
reopenBtn.Parent = gui

local corner2 = Instance.new("UICorner", reopenBtn)
corner2.CornerRadius = UDim.new(0, 6)

reopenBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
end)

-- Handle incoming updates
RemoteEvent.OnClientEvent:Connect(function(data)
	for tabName, lines in pairs(data) do
		if tabFrames[tabName] then
			local tb = tabFrames[tabName].textbox
			tb.Text = tb.Text .. table.concat(lines, "\n") .. "\n"
		end
	end
	frame.Visible = true
end)
