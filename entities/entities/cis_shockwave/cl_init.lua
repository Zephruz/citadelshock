include("shared.lua")

function ENT:Initialize()
	ParticleEffect( "cis_shockwave_small", self:GetPos(), self:GetAngles() )
end

function ENT:Draw() end
