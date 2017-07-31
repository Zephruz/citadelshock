ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true 
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- [[VARS]]
ENT.IsBomb = true
ENT.BombMass = 15
ENT.BombDrag = 0.2
ENT.BlastRadius = 350
ENT.BlastDamageMultiplier = 10
ENT.ExplodeTime = 5

-- [[EXTRA DUMMY VARS - Don't change these]]
ENT.VisExplodeTime = 0

function ENT:SetupDataTables()
	self.ExplodeTime = math.ceil(self.ExplodeTime + math.random(0.7,1.5))

	self:NetworkVar("Int", 0, "IDLobby") -- The lobby it's in
	self:NetworkVar("Int", 1, "IDSide") -- The side it's on
	self:NetworkVar("Bool", 0, "IsLit") -- If the bomb's lit
end