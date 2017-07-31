AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:Activate()

    self:SetUseType(SIMPLE_USE)
    self:SetModel( "models/zerochain/props_mystic/magicgenerator.mdl" )
    self:SetCollisionGroup( COLLISION_GROUP_NONE )

    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
	self:DropToFloor()

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
        phys:EnableMotion(false)
    end
	self:SetMaxHealth(self.BaseHealth)
	self:SetHealth(self.BaseHealth)
end

function ENT:Use(ply, c, ut, v)
	if (ply:GetIDLobby() == self:GetIDLobby() && ply:GetSide() == self:GetIDSide()) then
		ply:ConCommand("cis_gen")
	else ply:SendMessage("This isn't your generator!") end
end

function ENT:OnTakeDamage(DMG)
	local atter = DMG:GetAttacker()
	local dmgAmt = DMG:GetDamage()
	
	if (atter:IsPlayer() && atter:GetIDLobby() == self:GetIDLobby() && atter:GetSide() == self:GetIDSide()) then return false end
	
	self:SetHealth(self:Health() - dmgAmt)
	
	-- End Game
	if (self:Health() <= 0) then
		self:SetHealth(0)
		local id = self:GetIDLobby()
		local lobby = CitadelShock.Lobby:FindByID(id)
		if (lobby && lobby:GetGameInfo().active) then lobby:EndGame() end
	end
end