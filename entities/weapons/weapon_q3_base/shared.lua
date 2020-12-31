if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= true
	SWEP.AutoSwitchFrom		= true
else
	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 90
	SWEP.ViewModelFlip		= false
	SWEP.BobScale			= 0
	SWEP.SwayScale			= .5
end

SWEP.UseHands		= true
SWEP.Author					= "Bites"
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions			= ""
SWEP.Category				= "Knockdown!"
SWEP.Spawnable				= false
SWEP.Primary.Automatic		= true	
SWEP.ViewModel				= "models/weapons/c_pistol.mdl"
SWEP.WorldModel				= "models/weapons/w_pistol.mdl"

function SWEP:SetupDataTables()
	self:NetworkVar("Bool",0,"WebEnabled")
	self:NetworkVar("Vector",0,"WebPos")
end

function SWEP:Initialize()
	self.webTime = CurTime()
end

function SWEP:Think()
	if CurTime() > self.webTime + 0.1 then
		self:SetWebEnabled(false)
	end

	if self:GetWebEnabled() then
		self:GetOwner():SetGravity(0.01)
		local pl = self:GetOwner()
		local pos = pl:GetPos()
		pl:SetVelocity((pos - self:GetWebPos()):GetNormalized() * -700 * FrameTime())
	else
		self:GetOwner():SetGravity(1)
	end

	self:NextThink(CurTime())
	return true
end

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:ShootWeb()
	local tr = self:GetOwner():GetEyeTrace()
	self:SetWebPos(tr.HitPos)
end

function SWEP:PrimaryAttack()
	if not self:GetWebEnabled() == true then
		self:ShootWeb()
	end
	self:SetWebEnabled(true)
	self.webTime = CurTime()
end

if CLIENT then
	
	local webMat = Material("effects/bluelaser1")

	function SWEP:DrawWorldModel()
		if self:GetWebEnabled() then
			render.SetMaterial(webMat)
			render.DrawBeam(self:GetOwner():GetShootPos() - Vector(0,0,24),self:GetWebPos(),3,0,1,Color(255,255,255))
		end
	end

	function SWEP:PostDrawViewModel(vm, weapon, pl)
		if weapon:GetClass() == "weapon_q3_base" then
			if self:GetWebEnabled() then
				render.SetMaterial(webMat)
				local matrix = vm:GetBoneMatrix(39)
				if not matrix then return end
				local pos = matrix:GetTranslation() + (EyeAngles():Forward() * 6)
				render.DrawBeam(pos,self:GetWebPos(),3,0,1,Color(255,255,255))
			end
		end
	end

else

	function SWEP:Equip(owner)
		self:SetOwner(owner)
	end

end