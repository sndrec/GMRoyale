AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include("shared.lua")

function ENT:SpecialInitialize( )
	self:SetModel( "models/XQM/Rails/gumball_1.mdl" )
	self:PhysicsInitSphere(self.BALL_DIAMETER / 2)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMaterial("gmod_ice")
		phys:Wake()
		phys:SetAngleDragCoefficient(0)
		phys:SetDamping(0, 0)
		phys:SetDragCoefficient(0)
		phys:EnableGravity(true)
	end
	self.phys = self:GetPhysicsObject()
	self:SetCamYaw(0)
	self:SetCamPitch(0)
	self.oldVel = Vector(0,0,0)
	self:SetController(player.GetAll()[1])
end

function ENT:Think()
	local baseGravity = Angle(90, 0, 0)
	local forward = -Angle(0, self:GetCamYaw(), 0):Forward()
	local right = -Angle(0, self:GetCamYaw() + 90, 0):Forward()
	baseGravity:RotateAroundAxis(forward, self:GetRightMove())
	baseGravity:RotateAroundAxis(right, self:GetForwardMove())
	local realGravity = baseGravity:Forward() * 1400
	local vel = self.phys:GetVelocity()
	local noZ = Vector(vel.x, vel.y, 0)
	local desiredYaw = vel:Angle().y
	local desiredPitch = vel:Angle().p
	local turnRateYaw = self:CalcCameraTurnRate(self:GetCamYaw(), desiredYaw, noZ:Length(), self.BASECAMTABLE) * 360 * FrameTime()
	local turnRatePitch = self:CalcCameraTurnRate(self:GetCamPitch(), desiredPitch, vel:Length(), self.PITCHCAMTABLE) * 360 * FrameTime()
	self:SetCamYaw(self:GetCamYaw() + turnRateYaw)
	self:SetCamPitch(self:GetCamPitch() + turnRatePitch)
	self.phys:AddAngleVelocity(-self.phys:GetAngleVelocity())
	if self.phys:GetFrictionSnapshot() and self.phys:GetFrictionSnapshot()[1] then
		local colTable = self.phys:GetFrictionSnapshot()[1]
		local normal = colTable.Normal
		local velAtPoint = colTable.Other:GetVelocityAtPoint(colTable.ContactPoint)
		local combinedVel = self.oldVel - velAtPoint
		local impulse = combinedVel:Dot(normal) * -1.5
		self.phys:SetVelocity(self.oldVel + (normal * impulse) + (combinedVel * -FrameTime() * 0.6))
		physenv.SetGravity(realGravity * 2)
	else
		physenv.SetGravity(realGravity)
	end
	self.oldVel = vel
	self:NextThink(CurTime())
	return true
end

function ENT:PhysicsCollide(colData, collider)

	local oldVel = colData.OurOldVelocity
	self.phys:SetVelocity(oldVel)
end