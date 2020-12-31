
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	for i, v in ipairs(player.GetAll()) do
		self:SetPreventTransmit( v, true )
	end
	local modelTable = {}
	--table.insert(modelTable, "models/hunter/blocks/cube075x8x025.mdl")
	--table.insert(modelTable, "models/hunter/blocks/cube1x4x025.mdl")
	--table.insert(modelTable, "models/hunter/blocks/cube05x105x05.mdl")
	--table.insert(modelTable, "models/hunter/blocks/cube1x1x05.mdl")
	--table.insert(modelTable, "models/hunter/blocks/cube075x2x075.mdl")
	--table.insert(modelTable, "models/hunter/blocks/cube075x2x1.mdl")
	table.insert(modelTable, "models/hunter/blocks/cube1x1x1.mdl")
	table.insert(modelTable, "models/hunter/blocks/cube1x2x1.mdl")
	table.insert(modelTable, "models/hunter/blocks/cube2x2x1.mdl")
	--table.insert(modelTable, "models/hunter/blocks/cube4x8x025.mdl")
	table.insert(modelTable, "models/hunter/blocks/cube4x4x1.mdl")
	table.insert(modelTable, "models/hunter/blocks/cube4x4x2.mdl")
	table.insert(modelTable, "models/hunter/blocks/cube4x6x2.mdl")
	self:SetModel(table.Random(modelTable))
	local angleTable = {}
	table.insert(angleTable, 0)
	--table.insert(angleTable, 15)
	--table.insert(angleTable, 75)
	table.insert(angleTable, 90)
	--table.insert(angleTable, 105)
	--table.insert(angleTable, 165)
	table.insert(angleTable, 180)
	--table.insert(angleTable, 195)
	--table.insert(angleTable, 255)
	table.insert(angleTable, 270)
	--table.insert(angleTable, 285)
	--table.insert(angleTable, 345)
	self:SetAngles(Angle(table.Random(angleTable),table.Random(angleTable),table.Random(angleTable)))
	self:PhysicsInitShadow( false, false )
	self:SetSolid(SOLID_VPHYSICS)
	self.firstThink = true
end

function ENT:Think()

	for i, v in ipairs(player.GetAll()) do
		if self:GetPos():DistToSqr(v:GetPos()) <= 3600000 then
			self:SetPreventTransmit( v, false )
		else
			self:SetPreventTransmit( v, true )
		end
	end
	if self.firstThink == true then
		self.firstThink = false
		self:NextThink(CurTime() + 1 + self.perfTimer)
		return true
	else
		self:NextThink(CurTime() + 1)
		return true
	end
end