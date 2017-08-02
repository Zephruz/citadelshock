include("shared.lua")

local function CS_CreateFont(name, tbl)
	surface.CreateFont(name, tbl)
end

CS_CreateFont("CS_ENTRES_LG",
{
	font = "Alegreya Sans SC",
	size = 52,
})

CS_CreateFont("CS_ENTRES_SM",
{
	font = "Alegreya Sans SC",
	size = 36,
})

local harvTrans = 1
local harvDotNext = os.time() + 1
local harvDots = {".", "..", "..."}
local harvSounds = {
	["wood"] = {
		"physics/wood/wood_box_impact_hard1.wav",
		"physics/wood/wood_box_impact_hard2.wav",
		"physics/wood/wood_box_impact_hard3.wav",
		"physics/wood/wood_box_Impact_hard4.wav",
		"physics/wood/wood_box_impact_hard5.wav",
		"physics/wood/wood_box_impact_hard6.wav",
		"physics/wood/wood_box_impact_soft1.wav",
		"physics/wood/wood_box_impact_soft2.wav",
		"physics/wood/wood_box_impact_soft3.wav",
	},
	["rock"] = {
		"physics/concrete/rock_impact_hard1.wav",
		"physics/concrete/rock_impact_hard2.wav",
		"physics/concrete/rock_impact_hard3.wav",
		"physics/concrete/rock_impact_hard4.wav",
		"physics/concrete/rock_impact_hard5.wav",
		"physics/concrete/rock_impact_hard6.wav",
		"physics/concrete/rock_impact_soft1.wav",
		"physics/concrete/rock_impact_soft2.wav",
		"physics/concrete/rock_impact_soft3.wav",
	},
}

ENT.NextParticleThink = os.time() + 1

function ENT:Think()
	if (self:GetNoDraw()) then return false end
	if (self.NextParticleThink > os.time()) then return false end
	self.NextParticleThink = os.time() + 1
	
	local harvSoundType = (harvSounds[self:GetHarvestSounds()] or harvSounds["wood"])

	if (self:GetHarvesting() && !self:GetAbortHarvest()) then
		if (LocalPlayer() != self:GetHarvester()) then return false end
		surface.PlaySound( harvSoundType[math.random(1,#harvSoundType)] )
		self:CreateParticleEffect( self:GetHarvestParticles(), 0 )
	end
end

function ENT:Draw()
	self:DrawModel()
	self:DrawShadow(false)
	
	if (LocalPlayer():GetEyeTrace().Entity != self) then return end
	if (LocalPlayer():GetPos():Distance(self:GetPos()) > 350)then return end

	if (harvDotNext <= os.time()) then harvDotNext = os.time() + 1 harvTrans = harvTrans + 1 end
	if (harvTrans > #harvDots) then harvTrans = 1 end

	local offset = Vector( 0, 0, 40 )
	local ang_ent = self:GetLocalAngles()
	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos() + offset
	pos = pos + 25 * -ang:Forward()

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	cam.Start3D2D( pos , Angle( ang.x, ang.y, ang.z), 0.1 )
		cam.IgnoreZ(true)
		if (self:GetAbortHarvest()) then
			draw.DrawText( "ABORTING HARVEST" .. harvDots[harvTrans], "CS_ENTRES_LG", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		elseif (self:GetHarvesting()) then
			local harvTimeLeft = self:GetHarvestTimeLeft() - os.time()
			draw.DrawText( "(" .. harvTimeLeft .. ") HARVESTING" .. harvDots[harvTrans], "CS_ENTRES_LG", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
			draw.DrawText( (self:GetHarvester():Nick() or "No harvester") .. " is", "CS_ENTRES_SM", 0, -20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
			
			local cDownW, cDownClamp = 200, math.Clamp(harvTimeLeft/self.HarvestTime, 0, 1) 
			cDownW = (cDownW*cDownClamp)
			draw.RoundedBox( 4, -cDownW/2, 50, cDownW, 5, Color(255,255,255,255) )
		elseif (self:GetRespawning()) then
			local respTimeLeft = self:GetRespawnTimeLeft() - os.time()
			draw.DrawText( "(" .. respTimeLeft .. ") RESPAWNING" .. harvDots[harvTrans], "CS_ENTRES_LG", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
			
			local cDownW, cDownClamp = 200, math.Clamp(respTimeLeft/self.RespawnTime, 0, 1) 
			cDownW = (cDownW*cDownClamp)
			draw.RoundedBox( 4, -cDownW/2, 50, cDownW, 5, Color(255,255,255,255) )
		else
			draw.DrawText( "READY TO HARVEST" .. harvDots[harvTrans], "CS_ENTRES_LG", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		end
		cam.IgnoreZ(false)
	cam.End3D2D()
end
