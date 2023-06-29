local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local RootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
local FilterList = RaycastParams.new()
FilterList.FilterType = Enum.RaycastFilterType.Blacklist
FilterList.FilterDescendantsInstances = {}
local MinSpeed = -10000
local MaxSpeed = 10000

local function ClampVector3(Vector: Vector3, Min: number, Max: number)
	local X = math.clamp(Vector.X, Min, Max)
	local Y = math.clamp(Vector.Y, Min, Max)
	local Z = math.clamp(Vector.Z, Min, Max)
	return Vector3.new(X, Y, Z)
end

local function onStepped()
	if not RootPart then
		return
	end
	RootPart.AssemblyLinearVelocity = ClampVector3(RootPart.AssemblyLinearVelocity, MinSpeed, MaxSpeed)
	local RayCast = workspace:Raycast(RootPart.Position, RootPart.AssemblyLinearVelocity*.025, FilterList)
	if RayCast then
		print(RayCast.Instance)
		RootPart.AssemblyLinearVelocity = Vector3.zero
		RootPart.CFrame = CFrame.new(RayCast.Position) * RootPart.CFrame.Rotation
	end
end

local function onCharacterAdded(Character: Model)
	FilterList.FilterDescendantsInstances = {Character}
	RootPart = Character:WaitForChild("HumanoidRootPart")
end

RunService.Stepped:Connect(onStepped)
Player.CharacterAdded:Connect(onCharacterAdded)

