local Rigging = {}
Rigging.__index = Rigging

local Ragdoll6Sockets = {
	["LL"] = {"Torso", "Left Leg"},
	["RL"] = {"Torso", "Right Leg"},
	["LA"] = {"Torso", "Left Arm"},
	["RA"] = {"Torso", "Right Arm"},
	["Head"] = {"Torso", "Head"}
}

local Motor6Names = {
	"Right Hip",
	"Left Hip",
	"Left Shoulder",
	"Right Shoulder",
	"Neck"
}

local Ragdoll6Attachments = {
	["RA"] = {"Torso", "Right Arm", Vector3.new(0, 0.5, 0), Vector3.new(1.5, 0.5, 0)},
	["LA"] = {"Torso", "Left Arm", Vector3.new(0, 0.5, 0), Vector3.new(-1.5, 0.5, 0)},
	["RL"] = {"Torso", "Right Leg", Vector3.new(0, 0.5, 0), Vector3.new(0.5, -1.5, 0)},
	["LL"] = {"Torso","Left Leg", Vector3.new(0, 0.5, 0), Vector3.new(-0.5, -1.5, 0)},
	["Head"] = {"Torso", "Head", Vector3.new(0.15, -0.6, 0.1), Vector3.new(0, 1, 0)}
}

local ConstraintNameFolder = "RagdollConstraints"
local DefaultSocketName = "RagdollBallSocket"



function Rigging.GetRigger(Character: Model)
	local Rigger = {}
	table.insert(Rigger, Character)
	return setmetatable(Rigger, Rigging)
end

local function getAttachment0(CharModel, attachmentName)
	for _,child in pairs(CharModel:GetChildren()) do
		local attachment = child:FindFirstChild(attachmentName)
		if attachment then
			return attachment
		end
	end
end

function Rigging:AddAttachments()
	local Hum = self[1]:FindFirstChildOfClass("Humanoid")
	if not Hum then return end
	
	if Hum.RigType == Enum.HumanoidRigType.R6 then
		for i, v in pairs(Ragdoll6Attachments) do
			local Part0, Part1, attachment1C, attachment0C = unpack(v)
			Part0 = self[1]:FindFirstChild(Part0)
			Part1 = self[1]:FindFirstChild(Part1)
			if Part0 and Part1 then
				local Attach0 = Instance.new("Attachment")
				Attach0.Position = attachment0C
				Attach0.Name = i
				Attach0.Parent = Part0
					
				local Attach1 = Instance.new("Attachment")
				Attach1.Position = attachment1C
				Attach1.Name = i
				Attach1.Parent = Part1
			end
 		end
	end
end

function Rigging:AddRagdollSockets()
	local Hum = self[1]:FindFirstChildOfClass("Humanoid")
	if not Hum then return end
	Hum.BreakJointsOnDeath = false
	local RagConstraints = self[1]:FindFirstChild(ConstraintNameFolder)
	
	if not RagConstraints then
		local cons = Instance.new("Folder")
		cons.Name = ConstraintNameFolder
		cons.Parent = self[1]
		RagConstraints = cons
	end
	if Hum.RigType == Enum.HumanoidRigType.R6 then
		for i, v in pairs(Ragdoll6Sockets) do
			local Part0, Part1 = unpack(v)
			Part0 = self[1]:FindFirstChild(Part0)
			Part1 = self[1]:FindFirstChild(Part1)
			if Part0 and Part1 then
				local Ball = Instance.new("BallSocketConstraint")
				Ball.Attachment0 = Part0:FindFirstChild(i)
				Ball.Attachment1 = Part1:FindFirstChild(i)
				Ball.Enabled = false
				Ball.Parent = self[1]:FindFirstChild(ConstraintNameFolder)
			end
		end
	end
end

function Rigging:AddHatAttachments()
	local RagConstraints = self[1]:FindFirstChild(ConstraintNameFolder)

	if not RagConstraints then
		local cons = Instance.new("Folder")
		cons.Name = ConstraintNameFolder
		cons.Parent = self[1]
		RagConstraints = cons
	end
	for _,child in ipairs(self[1]:GetChildren()) do
		if child:IsA("Accoutrement") then
			--Loop through all parts instead of only checking for one to be forwards-compatible in the event
			--ROBLOX implements multi-part accessories
			for _,part in ipairs(child:GetChildren()) do
				if part:IsA("BasePart") then
					local attachment1 = part:FindFirstChildOfClass("Attachment")
					local attachment0 = getAttachment0(self[1],attachment1.Name)
					if attachment0 and attachment1 then
						local constraint = Instance.new("RigidConstraint")
						constraint.Attachment0 = attachment0
						constraint.Attachment1 = attachment1
						constraint.Parent = RagConstraints
						constraint.Enabled = false
					end
				end
			end
		end
	end
end

function Rigging:BuildRagdoll()
	self:AddAttachments()
	self:AddRagdollSockets()
end

return Rigging
