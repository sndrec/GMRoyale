AddCSLuaFile("cl_init.lua") -- Make sure clientside
AddCSLuaFile("shared.lua") -- and shared scripts are sent.
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetTrigger(true)
	self:UseTriggerBounds(true, 512)
	self:SetBerryPos(self:GetPos())
	self:SetBerryHolder(nil)
	self:SetGroundTime(0)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
end

function ENT:Touch(ent)
	if not self:GetBerryHolder():IsValid() and ent:IsPlayer() then
		self:SetBerryHolder(ent)
		self:GetBerryHolder():EmitSound("platformer/misc/strawberry_touch.wav")
	end
end

function ENT:Collect()
	self:SetCollected(true)
	self:SetCollectedTime(CurTime())
	self:GetBerryHolder():EmitSound("platformer/misc/strawberry_red_get_1000.wav")
end

function ENT:Think()
	if self:GetCollected() then
		if CurTime() > self:GetCollectedTime() + 5 then
			self:SetCollected(false)
			self:SetBerryHolder(nil)
			self:SetCollectedTime(0)
			self:SetGroundTime(0)
			self:SetColor(Color(255,255,255,255))
		end
		self:NextThink(CurTime())
		return true
	end
	if not self:GetBerryHolder():IsValid() then
		self:SetBerryPos(self:GetPos())
	else
		local pl = self:GetBerryHolder()
		if pl:OnGround() then
			self:SetGroundTime(self:GetGroundTime() + FrameTime())
		else
			self:SetGroundTime(0)
		end
		if not pl:Alive() then
			self:SetBerryHolder(nil)
		end
	end
	if self:GetBerryHolder():IsValid() and self:GetGroundTime() >= 0.2 and not self:GetCollected() then
		self:Collect()
	end
	self:NextThink(CurTime())
	return true
end