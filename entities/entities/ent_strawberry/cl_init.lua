include('shared.lua')

function ENT:Initialize()
	self.renderPos = self:GetBerryPos()
	self:SetRenderBounds(Vector(-1024, -1024, -1024), Vector(1024, 1024, 1024), Vector(8192, 8192, 8192))
	self.mat = Matrix()
	self.mat:SetScale(Vector(3, 3, 3))
	self:EnableMatrix("RenderMultiply", self.mat)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
end

function ENT:Think()
	if self:GetBerryHolder():IsValid() then
		local target = self:GetBerryHolder():GetPos() + self:GetBerryHolder():OBBCenter()
		target = target + ((self.renderPos - target):GetNormalized() * 100)
		self.renderPos = LerpVector(FrameTime() * 4, self.renderPos, target )
	end
	if self:GetCollected() then
		local fark = math.Clamp((CurTime() - self:GetCollectedTime()) * 5, 0, 1)
		local unfark = 1 - fark
		self.mat:SetScale(Vector(3 + (fark * 3), 3 + (fark * 3), (3 * unfark) + 0.1 ))
		self:SetColor(Color(255, 255, 255, 255 * unfark * 3))
		self:EnableMatrix("RenderMultiply", self.mat)
	elseif not self:GetBerryHolder():IsValid() then
		self.renderPos = self:GetBerryPos()
		self:SetColor(Color(255,255,255,255))
		self.mat:SetScale(Vector(3, 3, 3))
		self:EnableMatrix("RenderMultiply", self.mat)
	end
end

function ENT:DrawTranslucent()
	self:SetRenderAngles(Angle(0, CurTime() * 90, 0))
	self:SetRenderOrigin(self.renderPos)
	self:DrawModel()
end