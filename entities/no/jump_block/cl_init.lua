include('shared.lua')

function ENT:Initialize()
	self:DestroyShadow()
end

function ENT:Draw()
	if self:GetPos():DistToSqr(EyePos()) < 3240000 then
		self:DrawModel()
	end
end

function ENT:Think()

end