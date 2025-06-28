loadstring(game:HttpGet("https://raw.githubusercontent.com/2e2retard/retard/refs/heads/main/backpack.lua"))()

local wind_ui = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local players, rs = game:GetService("Players"), game:GetService("ReplicatedStorage")
local lp = players.LocalPlayer
local get_farm = require(rs.Modules.GetFarm)
local inv = require(rs.Modules.InventoryService)
local net = rs:WaitForChild("ByteNetReliable")
local buffer = buffer.fromstring("\1\1\0\1")
local farm = get_farm(lp)
local run, hidenotif = false, false

for _, v in ipairs(game:GetService("Lighting"):GetChildren()) do
	if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") then
		v.Enabled = false
	end
end

local char = lp.Character
if char then
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Enabled = false
		end
	end
end

local fruits = {
	"Pineapple", "Watermelon", "Cauliflower", "Green Apple", "Banana", "Avocado", "Kiwi",
	"Prickly Pear", "Feijoa", "Sugar Apple", "Loquat", "Wild Carrot", "Pear", "Cantaloupe",
	"Parasol Flower", "Rosy Delight", "Elephant Ears", "Bell Pepper", "Carrot",
	"Blueberry", "Tomato", "Strawberry"
}

local ui = wind_ui:CreateWindow({
	Title = "Summer Harvest",
	Icon = "rbxassetid://129260712070622",
	IconThemed = true,
	Author = "another21",
	Folder = "nah",
	Size = UDim2.fromOffset(580, 460),
	Transparent = true,
	Theme = "Dark",
	HideSearchBar = true,
	User = {Enabled = true},
	SideBarWidth = 200,
	ScrollBarEnabled = true,
})

local tab = ui:Section({ Title = "Menu", Opened = true }):Tab({ Title = "Main", Icon = "home" })
local collecting = false

local function collect()
	if collecting then return end
	collecting = true
	task.spawn(function()
		for _, p in ipairs(farm.Important.Plants_Physical:GetChildren()) do
			if not run then break end
			for _, f in ipairs(fruits) do
				if p.Name:find(f, 1, true) then
					net:FireServer(buffer, { p })
					local f2 = p:FindFirstChild("Fruits", true)
					if f2 then
						for _, i in ipairs(f2:GetChildren()) do
							if not run then break end
							if inv:IsMaxInventory(lp.Backpack) then
								rs.GameEvents.SummerHarvestRemoteEvent:FireServer("SubmitAllPlants")
								task.wait(0.05)
								break
							else
							    net:FireServer(buffer, { i })
							end
						end
					end
					break
				end
			end
			task.wait()
		end
		collecting = false
	end)
end

tab:Toggle({
	Title = "Auto Summer Event",
	Value = false,
	Callback = function(v) run = v end
})

tab:Button({
	Title = "Collect Summer Fruits",
	Callback = function() collect() end
})

tab:Button({
	Title = "Submit",
	Callback = function()
		rs.GameEvents.SummerHarvestRemoteEvent:FireServer("SubmitAllPlants")
	end,
})

tab:Toggle({
	Title = "Hide Notification",
	Value = false,
	Callback = function(v)
		hidenotif = v
		local g = lp:FindFirstChild("PlayerGui")
		if g and g:FindFirstChild("Top_Notification") then
			g.Top_Notification.Enabled = not v
		end
	end
})

tab:Divider()
local point = tab:Paragraph({ Title = "Points:", Desc = "" })
local time = tab:Paragraph({ Title = "Timer:", Desc = "" })

task.spawn(function()
	while true do
		if hidenotif then
			local notif = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Top_Notification")
			if notif then
				for _, f in ipairs(notif.Frame:GetChildren()) do
					if f:IsA("Frame") and f:FindFirstChildWhichIsA("TextLabel") then
						f:Destroy()
					end
				end
			end
		end

		for _, o in ipairs(workspace.SummerHarvestEvent.RewardSign:GetDescendants()) do
			if o:IsA("TextLabel") and o.Name == "PointTextLabel" then
				point:SetDesc(o.Text:match("%d+") or "0")
				break
			end
		end
		
		for _, o in ipairs(workspace.SummerHarvestEvent.RewardSign:GetDescendants()) do
			if o:IsA("TextLabel") and o.Name == "RewardTextLabel" then
			    point:SetTitle(o.Text)
			    break
			end
		end

		local s = workspace.SummerHarvestEvent.Sign:GetChildren()[4]
		if s and s:FindFirstChild("BillboardGui") then
			time:SetTitle(s.BillboardGui.TextLabel.Text)
			time:SetDesc(s.BillboardGui.Timer.Text)
		end

		if run and workspace:GetAttribute("SummerHarvest") then
			collect()
		end

		task.wait(0.1)
	end
end)
