include("shared.lua")

local function CS_CreateFont(name, tbl)
	surface.CreateFont(name, tbl)
end

CS_CreateFont("CS_ENTSTR_LG",
{
	font = "Alegreya Sans SC",
	size = 52,
})

CS_CreateFont("CS_ENTSTR_MD",
{
	font = "Alegreya Sans SC",
	size = 32,
})

function ENT:Draw()
	self:DrawModel()
	local trEnt = LocalPlayer():GetEyeTrace().Entity
	
	if (trEnt != self) then return false end
	if !(input.IsKeyDown( KEY_LSHIFT )) then return false end
	if (self:GetPos():Distance(LocalPlayer():GetPos()) > 150) then return false end
	
	local offset = Vector( 0, 0, 15 + (self:OBBCenter().z) )
	local ang_ent = self:GetLocalAngles()
	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos() + offset
	pos = pos + 25 * -ang:Forward()

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	cam.Start3D2D( pos , Angle( ang.x, ang.y, ang.z), 0.1 )
		--draw.DrawText( "owner: " .. (self:ZI_GetOwner():IsPlayer() && self:ZI_GetOwner():Nick() || "Unknown"), "CS_ENTSTR_LG", 0, -30, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.DrawText( "health: " .. self:Health(), "CS_ENTSTR_LG", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		if (self:Health() < self.BaseHealth) then
			draw.DrawText( "Press E to repair 10 health", "CS_ENTSTR_MD", 0, 35, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		end
	cam.End3D2D()
end