
AddCSLuaFile()

SWEP.ViewModel = Model( "models/weapons/c_arms_animations.mdl" )
SWEP.WorldModel = ""

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"


SWEP.PrintName	= "Psychic Hands"

SWEP.Slot		= 5
SWEP.SlotPos	= 1

SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.Spawnable		= false

if ( SERVER ) then

	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false

end

-- faster access to some math library functions
local abs   = math.abs
local Round = math.Round
local sqrt  = math.sqrt
local exp   = math.exp
local log   = math.log
local sin   = math.sin
local cos   = math.cos
local sinh  = math.sinh
local cosh  = math.cosh
local acos  = math.acos

local deg2rad = math.pi/180
local rad2deg = 180/math.pi

local delta = 0.0000001000000

Quaternion = {}
Quaternion.__index = Quaternion

function Quaternion.new(q,r,s,t)
	return setmetatable({q,r,s,t},Quaternion)
end
local quat_new = Quaternion.new

local function qmul(lhs, rhs)
	local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
	local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
	return quat_new(
		lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
		lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
		lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
		lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
	)
end
Quaternion.__mul = qmul

--- Converts <ang> to a quaternion
function Quaternion.fromAngle(ang)
	local p, y, r = ang.p, ang.y, ang.r
	p = p*deg2rad*0.5
	y = y*deg2rad*0.5
	r = r*deg2rad*0.5
	local qr = {cos(r), sin(r), 0, 0}
	local qp = {cos(p), 0, sin(p), 0}
	local qy = {cos(y), 0, 0, sin(y)}
	return qmul(qy,qmul(qp,qr))
end

function Quaternion.__add(lhs, rhs)
	return quat_new( lhs[1] + rhs[1], lhs[2] + rhs[2], lhs[3] + rhs[3], lhs[4] + rhs[4] )
end

function Quaternion.__sub(lhs, rhs)
	return quat_new( lhs[1] - rhs[1], lhs[2] - rhs[2], lhs[3] - rhs[3], lhs[4] - rhs[4] )
end

function Quaternion.__mul(lhs, rhs)
	if type(rhs) == "number" then
		return quat_new( rhs * lhs[1], rhs * lhs[2], rhs * lhs[3], rhs * lhs[4] )
	elseif type(rhs) == "Vector" then
		local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
		local rhs2, rhs3, rhs4 = rhs.x, rhs.y, rhs.z
		return quat_new(
			-lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			 lhs1 * rhs2 + lhs3 * rhs4 - lhs4 * rhs3,
			 lhs1 * rhs3 + lhs4 * rhs2 - lhs2 * rhs4,
			 lhs1 * rhs4 + lhs2 * rhs3 - lhs3 * rhs2
		)
	else
		local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
		local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
		return quat_new(
			lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
			lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
			lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
		)
	end
end

function Quaternion.__div(lhs, rhs)
	local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
	return quat_new(
		lhs1/rhs,
		lhs2/rhs,
		lhs3/rhs,
		lhs4/rhs
	)
end

function Quaternion:inv()
	local l = self[1]*self[1] + self[2]*self[2] + self[3]*self[3] + self[4]*self[4]
	return quat_new( self[1]/l, -self[2]/l, -self[3]/l, -self[4]/l )
end

function Quaternion:rotationAngle()
	local l2 = self[1]*self[1] + self[2]*self[2] + self[3]*self[3] + self[4]*self[4]
	if l2 == 0 then return 0 end
	local l = sqrt(l2)
	local ang = 2*acos(self[1]/l)*rad2deg  //this returns angle from 0 to 360
	if ang > 180 then ang = ang - 360 end  //make it -180 - 180
	return ang
end

--- Returns the axis of rotation
function Quaternion:rotationAxis()
	local m2 = self[2] * self[2] + self[3] * self[3] + self[4] * self[4]
	if m2 == 0 then return Vector( 0, 0, 1 ) end
	local m = sqrt(m2)
	return Vector( self[2] / m, self[3] / m, self[4] / m)
end

function Quaternion:__tostring()
	return string.format("<%01.4f,%01.4f,%01.4f,%01.4f>",self[1],self[2],self[3],self[4])
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Entity", 0, "HoldEnt" )
	self:NetworkVar( "Angle", 0, "HoldEntAng" )
	self:NetworkVar( "Angle", 1, "EyeAngStart" )
end

function SWEP:Initialize()
	self:SetHoldType( "none" )
end

function SWEP:Reload()

end

function SWEP:OnRemove()
	if CLIENT then return end
	if self:GetHoldEnt() and self:GetHoldEnt():IsValid() then
		self:GetHoldEnt():GetPhysicsObject():EnableGravity(true)
		if self:GetOwner().oldWep then
			self:GetOwner():SelectWeapon(self:GetOwner().oldWep)
			self:GetOwner().oldWep = nil
		end
	end
end

function SWEP:PrimaryAttack()
	if CLIENT then return end
	if self:GetHoldEnt() and self:GetHoldEnt():IsValid() then
		local phys = self:GetHoldEnt():GetPhysicsObject()
		phys:EnableGravity(true)
		local power = (750 / (math.sqrt(phys:GetMass()))) + 100
		phys:SetVelocity(phys:GetVelocity() + (self:GetOwner():EyeAngles():Forward() * power))
		self:SetHoldEnt(nil)
		if self:GetOwner().oldWep then
			self:GetOwner():SelectWeapon(self:GetOwner().oldWep)
			self:GetOwner().oldWep = nil
		end
		return
	end
end

function SWEP:GrabOverride()
	if CLIENT then return end
	if self:GetHoldEnt() and self:GetHoldEnt():IsValid() then
		self:GetHoldEnt():GetPhysicsObject():EnableGravity(true)
		self:SetHoldEnt(nil)
		print(self:GetOwner().oldWep)
		if self:GetOwner().oldWep then
			self:GetOwner():SelectWeapon(self:GetOwner().oldWep)
			self:GetOwner().oldWep = nil
		end
		return
	end
	local pickprop = util.TraceLine({
		start = self:GetOwner():GetShootPos(),
		endpos = self:GetOwner():GetShootPos() + (self:GetOwner():GetAimVector() * 128),
		filter = player.GetAll(),
		ignoreworld = true
	})
	if pickprop.Hit and pickprop.Entity:GetPhysicsObject():IsValid() then
		self:SetHoldEnt(pickprop.Entity)
		self:SetHoldEntAng(pickprop.Entity:GetAngles())
		self:SetEyeAngStart(self:GetOwner():EyeAngles())
		self:GetHoldEnt():GetPhysicsObject():EnableMotion(true)
		self:GetHoldEnt():GetPhysicsObject():EnableGravity(false)
		return true
	end
	pickprop = util.TraceHull({
		start = self:GetOwner():GetShootPos(),
		endpos = self:GetOwner():GetShootPos() + (self:GetOwner():GetAimVector() * 96),
		filter = player.GetAll(),
		mins = Vector(-16, -16, -16),
		maxs = Vector(16, 16, 16),
		ignoreworld = true
	})
	if pickprop.Hit and pickprop.Entity:GetPhysicsObject():IsValid() then
		self:SetHoldEnt(pickprop.Entity)
		self:SetHoldEntAng(pickprop.Entity:GetAngles())
		self:SetEyeAngStart(self:GetOwner():EyeAngles())
		self:GetHoldEnt():GetPhysicsObject():EnableMotion(true)
		self:GetHoldEnt():GetPhysicsObject():EnableGravity(false)
		return true
	end
	return false
end

if SERVER then

	hook.Add("AllowPlayerPickup", "PsychicHandsAllowPickup", function(pl, ent)
		if pl:HasWeapon("psychichands") then
			return false
		end
	end)
	hook.Add("KeyPress", "PsychicHandsPickupOverride", function( pl, key )
		if pl:Alive() and pl:HasWeapon("psychichands") then
			if key == IN_USE then
				if not pl.oldWep then
					pl.oldWep = pl:GetActiveWeapon():GetClass()
				end
				local pickprop = util.TraceLine({
					start = pl:GetShootPos(),
					endpos = pl:GetShootPos() + (pl:GetAimVector() * 128),
					filter = player.GetAll(),
					ignoreworld = true
				})
				local pickprop2 = util.TraceHull({
					start = pl:GetShootPos(),
					endpos = pl:GetShootPos() + (pl:GetAimVector() * 96),
					filter = player.GetAll(),
					mins = Vector(-16, -16, -16),
					maxs = Vector(16, 16, 16),
					ignoreworld = true
				})
				local grabbed = pickprop.Hit and pickprop.Entity:GetPhysicsObject():IsValid() or pickprop2.Hit and pickprop2.Entity:GetPhysicsObject():IsValid()
				if grabbed then
					pl:SelectWeapon("psychichands")
					if pl:GetActiveWeapon():GetClass() == "psychichands" then
						pl:GetActiveWeapon():GrabOverride()
					end
				end
			end
			if key == IN_GRENADE1 then
				local pickprop = util.TraceLine({
					start = pl:GetShootPos(),
					endpos = pl:GetShootPos() + (pl:GetAimVector() * 256),
					filter = player.GetAll(),
					ignoreworld = true
				})
				local grabbed = pickprop.Hit and pickprop.Entity:GetPhysicsObject():IsValid()
				if grabbed then
					local hands = pl:GetWeapon("psychichands")
					if hands.weldtarget1 then
						constraint.Weld( hands.weldtarget1, pickprop.Entity, 0, 0, 0, true, false )
						hands.weldtarget1 = nil
					else
						hands.weldtarget1 = pickprop.Entity
					end
				end
			end
			if key == IN_GRENADE2 then
				local pickprop = util.TraceLine({
					start = pl:GetShootPos(),
					endpos = pl:GetShootPos() + (pl:GetAimVector() * 256),
					filter = player.GetAll(),
					ignoreworld = true
				})
				local grabbed = pickprop.Hit and pickprop.Entity:GetPhysicsObject():IsValid()
				if grabbed then
					constraint.RemoveAll(pickprop.Entity)
				end
			end
		end
	end )
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	if self:GetHoldEnt() and self:GetHoldEnt():IsValid() then
		self:GetHoldEnt():GetPhysicsObject():EnableGravity(true)
		self:GetHoldEnt():GetPhysicsObject():EnableMotion(false)
		self:SetHoldEnt(nil)
		if self:GetOwner().oldWep then
			self:GetOwner():SelectWeapon(self:GetOwner().oldWep)
			self:GetOwner().oldWep = nil
		end
		return
	end
end

function SWEP:Tick()
	if CLIENT then return end
	local cmd = self.Owner:GetCurrentCommand()
	if self:GetHoldEnt() and self:GetHoldEnt():IsValid() then
		local phys = self:GetHoldEnt():GetPhysicsObject()
		local startPos = self:GetHoldEnt():LocalToWorld(phys:GetMassCenter())
		local holdDist = math.max(24 + (self:GetHoldEnt():BoundingRadius() * 1.2), 48)
		local targetPos = self:GetOwner():GetShootPos() + (self:GetOwner():GetAimVector() * holdDist)
		local newVel = (targetPos - startPos) / (engine.TickInterval() * 2)
		phys:SetVelocity(newVel)
		local eyeAngDiff = self:GetOwner():EyeAngles() - self:GetEyeAngStart()
		self:SetEyeAngStart(self:GetOwner():EyeAngles())
		local trueHoldEntAng = self:GetHoldEntAng()
		if cmd:KeyDown( IN_RELOAD ) then
			trueHoldEntAng:RotateAroundAxis(Vector(0, 0, 1), cmd:GetMouseX() * 0.333)
			trueHoldEntAng:RotateAroundAxis(self:GetOwner():GetAngles():Right(), cmd:GetMouseY() * 0.333)
		end
		trueHoldEntAng:RotateAroundAxis(Vector(0, 0, 1), eyeAngDiff.y)
		trueHoldEntAng:RotateAroundAxis(self:GetOwner():GetAngles():Right(), -eyeAngDiff.p)
		self:SetHoldEntAng(trueHoldEntAng)
		local ang1 = Quaternion.fromAngle(phys:GetAngles())
		local ang2 = Quaternion.fromAngle(trueHoldEntAng)
		local diff = ang1:inv() * ang2
		local axis = diff:rotationAxis()
		local power = diff:rotationAngle()
		local desAngleVel = axis * power / (engine.TickInterval() * 2)
		phys:AddAngleVelocity(-phys:GetAngleVelocity() + desAngleVel)
	end
end

function SWEP:TranslateFOV( current_fov )
end

function SWEP:Deploy()
end

function SWEP:Equip()
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:DoShootEffect()
end

hook.Add("PlayerSwitchWeapon", "PsychicHandsHook", function(pl, oldWeapon, newWeapon)
	if CLIENT then return end
	if oldWeapon and oldWeapon:IsValid() and oldWeapon:GetClass() == "psychichands" then
		if oldWeapon:GetHoldEnt() and oldWeapon:GetHoldEnt():IsValid() then
			oldWeapon:GetHoldEnt():GetPhysicsObject():EnableGravity(true)
			oldWeapon:SetHoldEnt(nil)
			return
		end
	end
end)


if ( SERVER ) then return end -- Only clientside lua after this line

SWEP.WepSelectIcon = surface.GetTextureID( "vgui/gmod_camera" )

-- Don't draw the weapon info on the weapon selection thing
function SWEP:DrawHUD() end
function SWEP:PrintWeaponInfo( x, y, alpha ) end

function SWEP:FreezeMovement()

	-- Don't aim if we're holding the right mouse button
	if ( self.Owner:KeyDown( IN_RELOAD ) || self.Owner:KeyReleased( IN_RELOAD ) ) then
		return true
	end

	return false

end