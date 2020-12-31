ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Monitors"
ENT.Category = "SCP"
ENT.Author = "Bites"
ENT.Contact = ""
ENT.Purpose = ""
ENT.Instructions = ""
ENT.Spawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"CanShoot")
end