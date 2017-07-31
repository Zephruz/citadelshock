include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Remove()
		ParticleEffect( "cis_basebomb_explosion_small", self:GetPos(), self:GetAngles() )
end
