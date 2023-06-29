local Character = script.Parent
local Humanoid : Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart : BasePart = Humanoid.RootPart or Humanoid:GetPropertyChangedSignal("RootPart"):Wait()
Humanoid.UseJumpPower = true
Humanoid.WalkSpeed = 50

local function onFloorChange()
	local YVelocity = HumanoidRootPart.AssemblyLinearVelocity.Y
	if Humanoid.FloorMaterial and Humanoid.FloorMaterial ~= Enum.Material.Air and YVelocity < -75 then
		Humanoid.JumpPower = math.clamp(math.abs(YVelocity) * .75, 50, math.huge)
		Humanoid.Jumping:Once(function(a)
			if a then
				task.wait()
				Humanoid.JumpPower = 50
			end
		end)
	end
end

Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(onFloorChange)
