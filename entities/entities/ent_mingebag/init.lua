AddCSLuaFile("cl_init.lua") -- Make sure clientside
AddCSLuaFile("shared.lua") -- and shared scripts are sent.
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Kleiner.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self.dir = math.random(0,360)
	self.changeAmount = (math.random() - 0.5) * 6
	self.speed = math.random(120,300)
	self.upVel = 0
	self.jumping = false
	self.jumpTimer = CurTime()
	self:SetAngles(Angle(0,self.dir,0))
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInitShadow(true, true)
end

function ENT:Think()
	local dangerTrace = util.TraceHull({
		start = self:GetPos() + Vector(0, 0, 5),
		endpos = self:GetPos() + Vector(0, 0, 10),
		mins = Vector(-8, -8, -8),
		maxs = Vector(8, 8, 8),
		filter = self
	})
	if dangerTrace.Hit and dangerTrace.Entity:IsPlayer() and dangerTrace.Entity:Alive() then
		dangerTrace.Entity:Kill()
	end
	self.changeAmount = math.Clamp(self.changeAmount + ((math.random() - 0.5) * 2), -3, 3)
	self.dir = (self.dir + self.changeAmount) % 360
	local ang = Angle(0, self.dir, 0)
	if not self:GetPhysicsObject():IsValid() then return end
	self:GetPhysicsObject():UpdateShadow(self:GetPos() + (ang:Forward() * FrameTime() * self.speed) + Vector(0,0,self.upVel * FrameTime()),ang,FrameTime())
	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0,0,10),
		filter = self
	})
	if tr.Hit then
		if CurTime() > self.jumpTimer then
			self.jumping = false
			local oldPos = self:GetPos()
			local newPos = Vector(oldPos.x, oldPos.y, tr.HitPos.z)
			self:GetPhysicsObject():UpdateShadow(newPos + (ang:Forward() * FrameTime() * self.speed) + Vector(0,0,self.upVel * FrameTime()),ang,FrameTime())
		end
		if math.random() < 0.01 then
			self.upVel = math.random(200,400)
			self.jumping = true
			self.jumpTimer = CurTime() + 0.1
		end
	else
		self.jumping = true
	end
	if self.jumping then
		self.upVel = self.upVel - (800 * FrameTime())
	else
		self.upVel = 0
	end

	self:NextThink(CurTime())
	return true
end