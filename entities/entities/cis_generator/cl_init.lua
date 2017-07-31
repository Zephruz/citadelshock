include("shared.lua")

local function CS_CreateFont(name, tbl)
	surface.CreateFont(name, tbl)
end

CS_CreateFont("CS_ENT_LG",
{
	font = "Alegreya Sans SC",
	size = 154,
})

CS_CreateFont("CS_ENT_MD",
{
	font = "Alegreya Sans SC",
	size = 82,
})

CS_CreateFont("CS_ENT_SM",
{
	font = "Alegreya Sans SC",
	size = 32,
})

function ENT:Initialize() end

function ENT:Draw()
	self:DrawModel()

	if(LocalPlayer():GetPos():Distance(self:GetPos()) > 500)then return end

	local offset = Vector( 0, 0, 180 )
	local ang = LocalPlayer():EyeAngles()
	local ang_ent = self:GetLocalAngles()
	local pos = self:GetPos() + offset + ang:Up()
 
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
 
	cam.Start3D2D( pos, Angle( ang.x, ang.y, ang.z), 0.25 )
		draw.DrawText( "Health: " .. (self:Health() or "0"), "CS_ENT_LG", 2, 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	cam.End3D2D()
end
