ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName= "Benis Ammopack"
ENT.Author= "BENIS TEAM"
ENT.Contact= "Benis"
ENT.Purpose= "to benis"
ENT.Instructions= "Use wisely."
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("String",0, "ItemText")
	self:NetworkVar("Float",1, "ItemScale")
end