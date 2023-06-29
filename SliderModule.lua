-- Please add LucasMZ_RBX FastSignal library to the child of this script https://www.roblox.com/library/6532460357/FastSignal-A-consistent-Signal-library or
-- change the FastSignal path to a copy of the module

local Slider = {}
Slider.__index = Slider

local UserInputService = game:GetService("UserInputService")

local FastSignal = require(script.FastSignal)

local Camera = workspace.CurrentCamera
local MouseMove = FastSignal.new()

local function ConvertUDim2ToOffset(Object: UDim2)
	if typeof(Object) == "UDim2" then
		local OffsetXScale = Object.X.Scale * Camera.ViewportSize.X
		local OffsetYScale = Object.Y.Scale * Camera.ViewportSize.Y
		return UDim2.fromOffset(Object.X.Offset + OffsetXScale, Object.Y.Offset + OffsetYScale)
	end
	return nil
end

local function ConvertUDim2ToScale(Object: UDim2)
	if typeof(Object) == "UDim2" then
		local ScaleXOffset = Object.X.Offset / Camera.ViewportSize.X
		local ScaleYOffset = Object.Y.Offset / Camera.ViewportSize.Y
		return UDim2.fromScale(Object.X.Scale + ScaleXOffset, Object.Y.Scale + ScaleYOffset)
	end
end

local function GetCenterOfGuiObject(GuiObject: GuiObject)
	if typeof(GuiObject) == "Instance" and GuiObject:IsA("GuiObject") then
		return UDim2.fromOffset(GuiObject.AbsolutePosition.X + (GuiObject.AbsoluteSize.X / 2), GuiObject.AbsolutePosition.Y - (GuiObject.AbsoluteSize.Y / 2))
	end	
	return nil
end

export type Slider = typeof(setmetatable(
	{
		SliderMoved = FastSignal.new() :: FastSignal.Class,
		IsHolding = false :: boolean,
		_LowerXLimit = 0 :: number,
		_UpperXLimit = 0 :: number,
		_YConstraint = 0 :: number
	}, Slider)
)

local function onInputChanged(input: InputObject)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		MouseMove:Fire(Vector2.new(input.Position.X, input.Position.Y))
	end
end

UserInputService.InputChanged:Connect(onInputChanged)

function Slider.new(GuiObject: GuiObject, GuiObjectRelativeTo: GuiObject): Slider
	if typeof(GuiObject) ~= "Instance" or not GuiObject:IsA("GuiObject") then
		error("Argument 1 missing or nil")
	elseif typeof(GuiObjectRelativeTo) ~= "Instance" or not GuiObjectRelativeTo:IsA("GuiObject") then
		error("Argument 2 missing or nil")
	end
	local self = {}
	local function SetLimits()
		self._UpperXLimit = GuiObjectRelativeTo.AbsolutePosition.X + GuiObjectRelativeTo.AbsoluteSize.X
		self._LowerXLimit = GuiObjectRelativeTo.AbsolutePosition.X
		self._YConstraint = GuiObject.Position.Y.Offset + (GuiObject.Position.Y.Scale * Camera.ViewportSize.Y)
	end
	
	GuiObjectRelativeTo:GetPropertyChangedSignal("AbsoluteSize"):Connect(SetLimits)
	self.SliderMoved = FastSignal.new()
	self.IsHolding = false
	SetLimits()
	print(self._UpperXLimit, self._LowerXLimit)
	
	local function GuiObjectInputBegan(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.IsHolding = true
		end
	end
	
	local function GuiObjectInputEnded(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.IsHolding = false
		end
	end
	
	local function onMouseMove(Position: Vector2)
		if self.IsHolding then
			local XPosition = math.clamp(Position.X, self._LowerXLimit, self._UpperXLimit)
			local YPosition = ConvertUDim2ToOffset(UDim2.new(0, 0, GuiObject.Position.Y.Scale, GuiObject.Position.Y.Offset)).Y.Offset
			local Position = ConvertUDim2ToScale(UDim2.fromOffset(XPosition, self._YConstraint))
			GuiObject.Position = Position
			self.SliderMoved:Fire(XPosition / self._UpperXLimit)
		end
	end
	
	GuiObject.InputBegan:Connect(GuiObjectInputBegan)
	GuiObject.InputEnded:Connect(GuiObjectInputEnded)
	MouseMove:Connect(onMouseMove)
	return setmetatable(self, Slider)
end

return Slider

