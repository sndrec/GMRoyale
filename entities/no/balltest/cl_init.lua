include('shared.lua')

function ENT:Draw()
	local camDir = Angle(self:GetCamPitch() + 10, self:GetCamYaw(), 0)
	debugoverlay.Axis(self:GetPos() + Vector(0,0,50) + (camDir:Forward() * -200), camDir, 32, FrameTime() * 2, true)
	self:SetModelScale(3.3)
	self:DrawModel()
end

local function MyCalcView(pl, pos, angles, fov)
	if pl.ball and not pl.ball:IsValid() then
		hook.Remove( "CalcView", "MyCalcView")
		return
	end
	local camDir = Angle(pl.ball:GetCamPitch() + 10, pl.ball:GetCamYaw(), 0)
	local camPos = pl.ball:GetPos() + Vector(0,0,50) + (camDir:Forward() * -200)
	local view = {}
	view.origin = camPos
	view.angles = camDir
	view.fov = 90
	view.drawviewer = true

	return view
end

function ENT:SpecialInitialize()
	if self:GetController() == LocalPlayer() then
		hook.Add( "CalcView", "MyCalcView", MyCalcView )
	end
end
