AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

--[[------------------------
	INITIALIZE
--------------------------]]
function ENT:Initialize()
	self:Activate()
	
	self.ResourceSize = math.Rand(0.5, 0.90)

	self:UpdateCurrentStatus()

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


--[[------------------------
	UPDATE MODEL
--------------------------]]
function ENT:UpdateCurrentStatus()
	if (self.Models) then
		self:SetModel(self:GetIsHarvested() && self.Models.harvested.model || self.Models.notharvested.model)
		self:SetCollisionGroup(self:GetIsHarvested() && self.Models.harvested.collide || self.Models.notharvested.collide)
		if (self.ResourceSize) then self:SetModelScale(self.ResourceSize) end
		return (self:GetIsHarvested() && self.Models.harvested.model || self.Models.notharvested.model)
	end
end


--[[------------------------
	THINK/ABORT THINK
--------------------------]]
function ENT:Think()
	if (self:GetHarvesting() && self:GetHarvester()) then
		local harvTr = self:GetHarvester():GetEyeTrace()
		local dist = self:GetPos():Distance(self:GetHarvester():GetPos())
		if (dist > self.MaxHarvestDist) then
			self:SetAbortHarvest(true)
		elseif (harvTr.Entity != self) then
			self:SetAbortHarvest(true)
		else
			self:SetAbortHarvest(false)
		end
	end
end

--[[------------------------
	ABORT HARVEST
--------------------------]]
function ENT:AbortHarvest()
	self:SetIsHarvested(false)
	self:SetHarvesting(false)
	self:SetAbortHarvest(false)
	self:UpdateCurrentStatus()
end

--[[------------------------
	START HARVEST
--------------------------]]
function ENT:Harvest(ply)
	if (self:GetIsHarvested() or self:GetHarvesting()) then return false end
	self:SetHarvestTimeLeft(os.time() + self.HarvestTime)
	self:SetHarvester(ply)
	self:SetHarvesting(true)

	timer.Simple(self.HarvestTime, function()
		if not (IsValid(self)) then return false end
		if (self:GetAbortHarvest()) then self:AbortHarvest() return false end 
		hook.Run("CIS.Game.GiveResource", self)
		self:SetIsHarvested(true)
		self:SetHarvesting(false)
		self:UpdateCurrentStatus()
		self:StartRespawnHarvest()
	end)
end

--[[------------------------
	START RESPAWNING HARVEST
--------------------------]]
function ENT:StartRespawnHarvest()
	if not (self:GetIsHarvested()) then return false end
	self:SetRespawnTimeLeft(os.time() + self.RespawnTime)

	self:SetRespawning(true)
	timer.Simple(self.RespawnTime,
	function()
		if not IsValid(self) then return false end
		self:SetIsHarvested(false)
		self:SetRespawning(false)
		self:SetHarvester(nil)
		self:UpdateCurrentStatus()
	end)
end