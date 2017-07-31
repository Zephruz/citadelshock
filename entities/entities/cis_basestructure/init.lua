AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:Activate()

	self:SetModel(self.StructureMdl)
	
	self:SetUseType(SIMPLE_USE)
    self:SetCollisionGroup( COLLISION_GROUP_NONE )
	
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
	
	local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
        phys:EnableMotion(false)
    end
end

function ENT:OnTakeDamage(dmg)
	local atter = dmg:GetAttacker()
	local dmgAmt = dmg:GetDamage()

	if (atter:IsPlayer() && atter:GetSide() == self:GetIDSide()) then return false end

	if (self:Health() - dmgAmt > 0) then
		self:SetHealth(self:Health() - dmgAmt)
	else
		self:SetHealth(0)
		
		local phys = self:GetPhysicsObject()
		phys:EnableMotion(true)
		phys:AddVelocity(Vector(0,0,2))
		
		timer.Simple(math.random(2,3),
		function()
			if not (IsValid(self)) then return false end
			
			self:Remove()
		end)
	end
end

ENT.NextRepair = os.time()+1
function ENT:Use(act, cal, t, val)
	if (self.NextRepair > os.time()) then return false end
	self.NextRepair = os.time()+1

	if !(self.costs) then return false end
	local lobby = CitadelShock.Lobby:FindByID(self:GetIDLobby())
	if (!lobby or !self:GetIDSide()) then return false end
	if (cal:GetIDLobby() != self:GetIDLobby() or cal:GetSide() != self:GetIDSide()) then cal:SendMessage("You can't repair this!") return false end
	if (self:Health() >= self.BaseHealth) then cal:SendMessage("This structure is already at full health!") return false end

	local lobbySides = lobby:GetGameSides()
	local res = lobbySides[self:GetIDSide()].resources

	for k,v in pairs(self.costs) do
		if (res[k] && res[k] >= 10) then
			lobby:GiveResource(k,-10,self:GetIDLobby())
			
			self:SetHealth(self:Health() + 10)
			
			cal:SendMessage("Repaired structure (10 HP)!")
		else 
			cal:SendMessage("You need 10 " .. k .. " to repair this!") 
		end
	end
end