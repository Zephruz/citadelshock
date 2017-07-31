ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true 
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- [[VARS]]
ENT.Harvestable = true -- Whether this entity is harvestable or not
ENT.Models = {
	harvested = {model = "models/zerochain/props_foliage/tree01_stump.mdl", collide = COLLISION_GROUP_WORLD},
	notharvested = {model = "models/zerochain/props_foliage/tree01.mdl", collide = COLLISION_GROUP_NONE},
}
ENT.HarvestTime = 5 -- How long it takes to harvest (seconds)
ENT.RespawnTime = (CitadelShock.Game.ResourceRespawnTime or 10) -- How long it takes to respawn (seconds)
ENT.ResModelRadius = 40 -- The radius of the resources model
ENT.MaxHarvestDist = 150 -- The maximum harvest distance
ENT.ResourceType = "base"

-- [[DUMMY VARS - Don't edit these]]
-- None

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "IDLobby") -- The lobby it's in
	self:NetworkVar("Int", 3, "IDSide") -- The side it's on
	self:NetworkVar("Bool", 0, "IsHarvested") -- The lobby it's in
	self:NetworkVar("Entity", 0, "Harvester") -- The harvester

	self:NetworkVar("Bool", 1, "Harvesting") -- Is resource harvesting
	self:NetworkVar("Int", 1, "HarvestTimeLeft") -- How much time it has left to harvest

	self:NetworkVar("Bool", 2, "Respawning") -- Is resource respawning
	self:NetworkVar("Int", 2, "RespawnTimeLeft") -- How much time it has left to respawn

	self:NetworkVar("Bool", 3, "AbortHarvest") -- Is the resource aborting its harvest
	
	self:NetworkVar("String", 0, "HarvestParticles") -- Harvest particles
	self:NetworkVar("String", 1, "HarvestSounds") -- Harvest soundtype
end

function ENT:Initialize()
	self:SetIsHarvested(false)
	self:SetHarvesting(false)
	self:SetRespawning(false)
	self:SetAbortHarvest(false)
	self:SetHarvester(nil)
	self:SetRespawnTimeLeft(0)
	self:SetHarvestTimeLeft(0)
end