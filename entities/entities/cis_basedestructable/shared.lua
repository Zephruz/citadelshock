ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- [[VARS]]
//Basic
ENT.Model = "models/zerochain/props_mystic/bomb_logs.mdl"
//Bombs
ENT.IsBomb = true
ENT.BombMass = 30
ENT.BombDrag = 0.01
ENT.BlastRadius = 350
ENT.BlastDamageMultiplier = 10
ENT.ExplodeTime = 1.6

-- [[EXTRA DUMMY VARS - Don't change these]]
ENT.VisExplodeTime = 0

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "IDLobby") -- The lobby it's in
	self:NetworkVar("Int", 1, "IDSide") -- The side it's on
	self:NetworkVar("Bool", 0, "IsLit") -- If the bomb's lit
end
