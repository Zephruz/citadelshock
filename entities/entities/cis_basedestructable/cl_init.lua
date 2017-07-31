include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	/*
	//Stops the UI Gets rendered at certain Distance
	if(LocalPlayer():GetPos():Distance(self:GetPos()) > self.BlastRadius + 100)then return end

	if (self:GetIsLit()) then
		local offset = Vector( 0, 0, 45 )
		local ang = LocalPlayer():EyeAngles()
		local ang_ent = self:GetLocalAngles()
		local pos = self:GetPos() + offset + ang:Up()

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )

		cam.Start3D2D( pos, Angle( ang.x, ang.y, ang.z), 0.25 )
			draw.DrawText( self.ExplodeTime, "CS_ENT_LG", 2, 2, Color( 255, 125, 125, 255 ), TEXT_ALIGN_CENTER )
		cam.End3D2D()

		cam.Start3D2D( self:GetPos(), Angle(ang.x, ang.y, 0), 1)
			for i=1,7 do
				surface.DrawCircle( 0, 0, self.BlastRadius - i, 255, 125, 125, 255 )
			end
		cam.End3D2D()
	end
	*/
end

function ENT:Remove()
		ParticleEffect( "cis_basebomb_explosion_small", self:GetPos(), self:GetAngles() )
end
