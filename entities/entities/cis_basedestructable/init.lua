AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:Activate()

	self:SetModel( (self.Model or "models/zerochain/props_mystic/bomb_small.mdl") )
	
    self:SetCollisionGroup( COLLISION_GROUP_NONE )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if (phys and phys:IsValid()) then
		phys:SetMass(self.BombMass)
		phys:SetDragCoefficient(self.BombDrag)
		phys:EnableMotion(false)
		phys:Wake()
	end
		
	self.alreadyOnFire = false
	self.alreadyCreatedLogs = false
end


function ENT:Think()
	if (self:GetIsLit() && !self.alreadyOnFire) then
		self.alreadyOnFire = true
		self:Fire("ignite")
	end
end

function ENT:Use(act, cal)
	local phys = self:GetPhysicsObject()
	if (phys:IsMotionEnabled()) then phys:EnableMotion(false) else phys:EnableMotion(true) end
end

function ENT:Touch(e)
	if (!self:GetIsLit()) then return false end
	if(e:GetClass() == self:GetClass()) then return false end
	self:Explode()
end

function ENT:OnTakeDamage(DMG)
	local att = DMG:GetAttacker()

	if(att:GetClass() != "entityflame")then
		if (att:IsPlayer()) then if (self:GetIDLobby() != att:GetIDLobby() or self:GetIDSide() != att:GetSide()) then return false end end

		self:SetActive()
		self:SetOwner(att)
		local viewPos = self:GetOwner():GetAimVector()
		local dirPos = Vector(viewPos.x,viewPos.y,0) + self:GetOwner():GetUp()
		local dirPosB = dirPos * 1000
		local phys = self:GetPhysicsObject()
		phys:AddVelocity(dirPosB)
		phys:AddVelocity(Vector(0,0,5))
	end
end

local ownExplodeTime
function ENT:SetActive()
	local phys = self:GetPhysicsObject()
	if !(phys:IsMotionEnabled()) then phys:EnableMotion(true) end
	self:SetIsLit(true)
	ownExplodeTime = self.ExplodeTime + math.random(0.5,3)
	timer.Simple(ownExplodeTime, function()
		if (IsValid(self)) then
			self:Explode()
		end
	end) -- auto explode
end

function ENT:Explode()
	--local ents = ents.FindInSphere( self:GetPos(), self.BlastRadius )
	--if (#ents > 0) then self:DealBlastDamage(ents) end -- Only deal damage if there's entities in the blast radius
	if(!self.alreadyCreatedLogs)then
		self:SpawnLogs()
	end
	self:Remove()
end

function ENT:SpawnLogs()
	for i=1,math.random(3,10) do
		p =  ents.Create( "cis_ignitedlog" )
		p:SetPos(self:GetPos())
		p:SetAngles(Angle(math.random(360),math.random(360),math.random(360)))
		if(!p:IsValid())then return end
		p:Spawn()
		p:Activate()

		local phys = p:GetPhysicsObject()
		phys:AddVelocity(self:GetVelocity())
	end
	self.alreadyCreatedLogs = true
end

function ENT:DealBlastDamage(e)
	local ents = (e or ents.FindInSphere( self:GetPos(), self.BlastRadius ))
	for k,v in pairs(ents) do
		if(v:GetClass() == self:GetClass())then return end //Make sure the Entity is not a Bomb, later we replace it with a "Check If Bomb is Enemey Team"

		local dist = math.floor(self:GetPos():Distance( v:GetPos() ))

		if (dist <= self.BlastRadius) then
			local dmg = math.ceil((self.BlastRadius/dist) * self.BlastDamageMultiplier)

			local dinf = DamageInfo()
			dinf:SetDamage(dmg)
			dinf:SetDamageType(DMG_BLAST)
			dinf:SetReportedPosition(self:GetPos())
			dinf:SetAttacker(self:GetOwner())
			dinf:SetInflictor(self)
			v:TakeDamageInfo(dinf)
		end
	end
end
