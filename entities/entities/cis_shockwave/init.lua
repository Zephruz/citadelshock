AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/zerochain/props_mystic/bomb_small.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_NONE )

	local phys = self:GetPhysicsObject()
	if (phys and phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1)
		phys:EnableMotion(false)
	end

	self:Explode()
end


function ENT:Explode()
	-- Sound
	self:EmitSound( "sfx_cis_shockwave_small" )

	-- Set an explosion
	local ent = ents.Create( "env_physexplosion" )
	ent:SetParent(self)
	ent:SetKeyValue( "spawnflags", 1 )
	ent:SetKeyValue( "magnitude", 30000 )
	ent:SetKeyValue( "radius", self.BlastRadius )
	ent:SetPos(self:GetPos())
	ent:Spawn()
	ent:Fire("explode")

	//debugoverlay.Sphere( self:GetPos(), self.BlastRadius, 1,Color( 255, 255, 255,25 ), false )

	local bombs = ents.FindInSphere( self:GetPos(), self.BlastRadius )

	for k,v in pairs(bombs) do
		if (v.IsBomb && v.GetIDLobby && v:GetIDLobby() == self:GetOwner():GetIDLobby()) then
			local dmg = DamageInfo()
			dmg:SetAttacker(self:GetOwner())
			dmg:SetInflictor(self)
			v:TakeDamageInfo( dmg )
		end
	end

	timer.Simple(0.1, function() self:Remove() end)
end
