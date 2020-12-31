include('shared.lua')

function ENT:Draw()
	self.height = 0
	cam.Start3D2D(self:GetPos() + (self:GetAngles():Up() * 8),self:GetAngles(),self:GetItemScale())
	draw.SimpleTextOutlined(self:GetItemText(),"DermaLarge",0,0,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(0,0,0))
	cam.End3D2D()
end