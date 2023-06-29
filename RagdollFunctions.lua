local RagdollFunction = {}
local collectionService = game:GetService("CollectionService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

local TAG_NAME = "Ragdoll"
local RAGDOLL_STATES = {
	[Enum.HumanoidStateType.Dead] = true,
	[Enum.HumanoidStateType.Physics] = true,
}

local connections = {}


function RagdollFunction.ModMotors(CharModel, modval)
	local Hum = CharModel:FindFirstChildOfClass("Humanoid")
	if not Hum then
		return 
	end
	if Hum.RigType == Enum.HumanoidRigType.R6 then
		for _, Desc in pairs(CharModel:GetDescendants()) do
			if Desc.Name ~= "RootJoint" then
				if Desc:IsA("Weld") or Desc:IsA("Motor6D") then
					Desc.Enabled = modval
				end
			end
		end
	end
end


function RagdollFunction.setRagdollEnabled(humanoid, isEnabled)
	local ragdollConstraints = humanoid.Parent:FindFirstChild("RagdollConstraints")

	for _,constraint in pairs(ragdollConstraints:GetChildren()) do
		if constraint:IsA("Constraint") then
			constraint.Enabled = isEnabled
		end
	end
end

function RagdollFunction.hasRagdollOwnership(humanoid)
	if runService:IsServer() then
		-- Always set on the server, even if the owning client has already
		-- toggled the ragdoll. We don't want the server to be desynced in
		-- case the character changes ownership
		return true
	end

	local player = players:GetPlayerFromCharacter(humanoid.Parent)
	return player == players.LocalPlayer
end

function RagdollFunction.ragdollAdded(humanoid)
	connections[humanoid] = humanoid.StateChanged:Connect(function(oldState, newState)
		if RagdollFunction.hasRagdollOwnership(humanoid) then
			if RAGDOLL_STATES[newState] then
				RagdollFunction.setRagdollEnabled(humanoid, true)
				RagdollFunction.ModMotors(humanoid.Parent, false)
				humanoid.AutoRotate = false
			else
				RagdollFunction.setRagdollEnabled(humanoid, false)
				RagdollFunction.ModMotors(humanoid.Parent, true)
				humanoid.AutoRotate = true
			end
		end
	end)
end

function RagdollFunction.ragdollRemoved(humanoid)
	connections[humanoid]:Disconnect()
	connections[humanoid] = nil
end

for _,humanoid in pairs(collectionService:GetTagged(TAG_NAME)) do
	RagdollFunction.ragdollAdded(humanoid)
end

return RagdollFunction

