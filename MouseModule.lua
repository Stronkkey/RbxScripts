-- Please add LucasMZ_RBX FastSignal library to the child of this script https://www.roblox.com/library/6532460357/FastSignal-A-consistent-Signal-library or
   -- change the FastSignal path to a copy of the module

local Mouse = {}
Mouse.__index = Mouse
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if RunService:IsServer() or _G.MouseModule then
	return nil
end

local FastSignal = require(script.FastSignal)
local EventTable = {
	["MouseMoveEvent"] = FastSignal.new(),
	["HitChangedEvent"] = FastSignal.new(),
	["TargetChangedEvent"] = FastSignal.new(),
	["IdlePositionEvent"] = FastSignal.new(),
	["Button1Up"] = FastSignal.new(),
	["Button1Down"] = FastSignal.new(), 
	["Button2Up"] = FastSignal.new(),
	["Button2Down"] = FastSignal.new(),
}

local LastTarget = nil
local FilterList = {}
local FilterType = Enum.RaycastFilterType.Blacklist
local CurrentCamera = workspace.CurrentCamera

Mouse.Target = nil 
Mouse.Hit = CFrame.new() :: CFrame

Mouse.Move = EventTable["MouseMoveEvent"]
Mouse.TargetChanged = EventTable["TargetChangedEvent"]
Mouse.HitChanged = EventTable["HitChangedEvent"]
Mouse.Button1Down = EventTable["Button1Down"]
Mouse.Button1Up = EventTable["Button1Up"]
Mouse.Button2Up = EventTable["Button2Up"]
Mouse.Button2Down = EventTable["Button2Down"]

function Mouse:ChangeFilterList(list: {any})
	list = list or {}
	FilterList = list
end

function Mouse:ChangeFilterType(filtertype: EnumItem)
	filtertype = filtertype or Enum.RaycastFilterType.Blacklist
	FilterType = filtertype
end

function Mouse:ChangeMouseIcon(Icon: string)
  Icon = tostring(Icon) and Icon or ""
  UserInputService.MouseIcon = Icon
end

function Mouse:ShowMouse(Bool)
  UserInputService.MouseIconEnabled = Bool
end

local function Raycast()
	local params = RaycastParams.new()
	params.FilterType = FilterType
	params.FilterDescendantsInstances = FilterList
	local ViewportSize = workspace.CurrentCamera.ViewportSize
	local MousePosition = UserInputService:GetMouseLocation()
	local r = workspace.CurrentCamera:ViewportPointToRay(MousePosition.X, MousePosition.Y)
	return workspace:Raycast(r.Origin, r.Direction*500, params)
end

local function onInputBegan(input, proccessed)
	if proccessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Mouse.Button1Down:Fire()
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		Mouse.Button2Down:Fire()
	end
end

local function onInputEnded(input, proccessed)
	if proccessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Mouse.Button1Up:Fire()
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		Mouse.Button2Up:Fire()
	end
end

local function onInputChanged(input, proccessed)
	if proccessed then
		return
	end
	
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		Mouse.Move:Fire(Vector2.new(input.Position.X, input.Position.Y))
	end
end

local function onMouseMoveAndCameraCFrameChange()
	local RaycastResults = Raycast()
	if RaycastResults then
		Mouse.Target = RaycastResults.Instance
		Mouse.Hit = CFrame.new(RaycastResults.Position)

		if Mouse.Target ~= LastTarget then
			Mouse.TargetChanged:Fire(Mouse.Target)
		end

		Mouse.HitChanged:Fire(Mouse.Hit)

		LastTarget = Mouse.Target
	end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)
UserInputService.InputChanged:Connect(onInputChanged)

RunService.RenderStepped:Connect(onMouseMoveAndCameraCFrameChange)

_G.MouseModule = Mouse

return Mouse

