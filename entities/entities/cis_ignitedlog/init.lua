AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:SpawnFunction( ply, tr )
  if ( !tr.Hit ) then return end
  local ent = ents.Create( self.ClassName )
  ent:SetPhysicsAttacker(ply)
  ent:SetPos( tr.HitPos + tr.HitNormal * 15 )
	ent:SetOwner(ply)
  ent:Spawn()
  ent:Activate()
  return ent
end

function ENT:Initialize()
  self:SetModel( self.Model )

  self:SetCollisionGroup( COLLISION_GROUP_NONE )
  self:SetCustomCollisionCheck( true )
  self:PhysicsInit( SOLID_VPHYSICS )
  self:SetSolid( SOLID_VPHYSICS )
  self:SetMoveType( MOVETYPE_VPHYSICS )

  local phys = self:GetPhysicsObject()
  if (phys and phys:IsValid()) then
    phys:SetMass(25)
    phys:EnableMotion(true)
    phys:Wake()
  end

    timer.Simple(math.random(2,5),function()
      if(!self:IsValid()) then return end
      self:Remove()
    end)
	   self:Fire("ignite")
end

function ENT:OnTakeDamage(DMG)
	if(DMG:GetAttacker():GetClass() != "entityflame")then
		self:SetOwner(DMG:GetAttacker())
		local viewPos = self:GetOwner():GetAimVector()
		local dirPos = Vector(viewPos.x,viewPos.y,0) + self:GetOwner():GetUp()
		local dirPosB = dirPos * 1000
		local phys = self:GetPhysicsObject()
		phys:AddVelocity(dirPosB)
		phys:AddVelocity(Vector(0,0,500))
	end
end

function ENT:OnRemove()
  -- Sound
	self:EmitSound( "sfx_cis_burninglog_break" )
end

hook.Add("ShouldCollide", "CIS.Hook.SC_IgnitedLog",
function(e1,e2)
	if (e1:GetClass() == e2:GetClass() && e1:GetClass() == "cis_ignitedlog") then return false end
end)