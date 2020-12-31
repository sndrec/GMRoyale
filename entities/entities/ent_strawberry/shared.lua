ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName= "Strawberry"
ENT.Author= "BENIS TEAM"
ENT.Contact= "Benis"
ENT.Purpose= "to benis"
ENT.Instructions= "Use wisely."
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar( "Vector", 0, "BerryPos" )
	self:NetworkVar( "Entity", 0, "BerryHolder" )
	self:NetworkVar( "Float", 0, "GroundTime" )
	self:NetworkVar( "Float", 1, "CollectedTime" )
	self:NetworkVar( "Bool", 0, "Collected")
end