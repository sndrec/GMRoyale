ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName= "Ball"
ENT.Author= "BENIS TEAM"
ENT.Contact= "Benis"
ENT.Purpose= "to benis"
ENT.Instructions= "Use wisely."
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.BALL_DIAMETER = 100.0

ENT.BASECAMTABLE = {}
ENT.BASECAMTABLE.MAX_TURN_RATE = 0.6
ENT.BASECAMTABLE.MIN_TURN_RATE = 0.15
ENT.BASECAMTABLE.MIN_TURN_RATE_SPEED = 0.1
ENT.BASECAMTABLE.MAX_TURN_RATE_SPEED = 1.2
ENT.BASECAMTABLE.TRANSITION_ZONE = 0.1
ENT.BASECAMTABLE.EASE_ANGLE = 0.1

ENT.PITCHCAMTABLE = {}
ENT.PITCHCAMTABLE.MAX_TURN_RATE = 2
ENT.PITCHCAMTABLE.MIN_TURN_RATE = 0.1
ENT.PITCHCAMTABLE.MIN_TURN_RATE_SPEED = 0
ENT.PITCHCAMTABLE.MAX_TURN_RATE_SPEED = 15
ENT.PITCHCAMTABLE.TRANSITION_ZONE = 0
ENT.PITCHCAMTABLE.EASE_ANGLE = 0.20

function ENT:SetupDataTables()
	self:NetworkVar("Float",1, "CamYaw")
	self:NetworkVar("Float",2, "CamPitch")
	self:NetworkVar("Float",3, "ForwardMove")
	self:NetworkVar("Float",4, "RightMove")
	self:NetworkVar("Vector",1, "LastGroundVel")
	self:NetworkVar("Entity",1,"Controller")
end

function ENT:Initialize()
	if SERVER then
		local pl = player.GetAll()[1]
		pl.ball = self
		self:SetController(pl)

	elseif CLIENT then
		local pl = LocalPlayer()
		pl.ball = self
		self:SetController(pl)
	end
	self:SpecialInitialize()
end

function ENT:OnRemove()
end

function ENT:CalcCameraTurnRate(currentAngle, desiredAngle, velocity, camTable)
	local diff = math.AngleDifference(desiredAngle, currentAngle)
	local cappedDiff = math.Clamp(diff / 360, -camTable.EASE_ANGLE, camTable.EASE_ANGLE) / camTable.EASE_ANGLE
	local diamsPerSecond = velocity / self.BALL_DIAMETER
	local currentTurnRate = 0
	if diamsPerSecond < camTable.MIN_TURN_RATE_SPEED and diamsPerSecond >= camTable.MIN_TURN_RATE_SPEED -camTable.TRANSITION_ZONE then
	  local turnSensAlpha = math.min((diamsPerSecond - (camTable.MIN_TURN_RATE_SPEED - camTable.TRANSITION_ZONE)) / camTable.TRANSITION_ZONE, 1)
	  currentTurnRate = Lerp(turnSensAlpha, 0, camTable.MIN_TURN_RATE)
	elseif diamsPerSecond >= camTable.MIN_TURN_RATE_SPEED then
	  local turnSensAlpha = math.min((diamsPerSecond - camTable.MIN_TURN_RATE_SPEED) / (camTable.MAX_TURN_RATE_SPEED - camTable.MIN_TURN_RATE_SPEED), 1)
	  currentTurnRate = Lerp(turnSensAlpha, camTable.MIN_TURN_RATE, camTable.MAX_TURN_RATE)
	end
	return currentTurnRate * cappedDiff
end


hook.Add("PlayerTick", "BallMove", function(pl, mv)
	if pl.ball and pl.ball:IsValid() then
		pl.ball:SetForwardMove((mv:GetForwardSpeed() / 10000) * 23)
		pl.ball:SetRightMove((mv:GetSideSpeed() / 10000) * 23)
	end
end)

function ENT:CalcMove()
end