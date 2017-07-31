include("shared.lua")

function ENT:Initialize()
	self.alreadyLit = false
end

function ENT:Think()
	if (self:GetIsLit()) then
		if (self.VisExplodeTime == 0) then self.VisExplodeTime = os.time() + self.ExplodeTime
		elseif (self.VisExplodeTime > os.time()) then self.ExplodeTime = self.VisExplodeTime - os.time()
		else self.ExplodeTime = 0 end

		if (!self.alreadyLit) then
			self.alreadyLit = true
			ParticleEffectAttach( "cis_bomb_fuse01", PATTACH_ABSORIGIN_FOLLOW, self, 1 )
		end
	end
	return true
end

function ENT:Draw()
	self:DrawModel()

	if(LocalPlayer():GetPos():Distance(self:GetPos()) > self.BlastRadius + 100)then return end

	local tr = LocalPlayer():GetEyeTrace()
	local trEnt = tr.Entity
	
	local offset = Vector( 0, 0, 35 )
	local ang = LocalPlayer():EyeAngles()
	local ang_ent = self:GetLocalAngles()
	local pos = self:GetPos() + offset + ang:Up()

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
		
	if (self:GetIsLit()) then
		cam.Start3D2D( pos, Angle( ang.x, ang.y, ang.z), 0.25 )
			draw.DrawText( self.ExplodeTime, "CS_ENT_LG", 2, 2, Color( 255, 125, 125, 255 ), TEXT_ALIGN_CENTER )
		cam.End3D2D()

		cam.Start3D2D( self:GetPos(), Angle(ang.x, ang.y, 0), 1)
			for i=1,7 do
				surface.DrawCircle( 0, 0, self.BlastRadius - i, 255, 125, 125, 255 )
			end
		cam.End3D2D()
	elseif (trEnt == self) then
		cam.Start3D2D( pos, Angle( ang.x, ang.y, ang.z), 0.2 )
			draw.DrawText( "Press 'E' or use to freeze in place", "CS_ENT_SM", 2, 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		cam.End3D2D()
	end
end

function ENT:OnRemove()
	ParticleEffect( "cis_basebomb_explosion_small", self:GetPos(), self:GetAngles() )
end
