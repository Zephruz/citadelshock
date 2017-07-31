ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = true

-- [[VARS]]
ENT.StructureMdl = "models/zerochain/props_structure/wood_foundation.mdl"
ENT.BaseHealth = 750

-- [[DUMMY VARS - Don't edit these]]
--

function ENT:SetupDataTables()
	self.BaseHealth = self:Health()
	self:NetworkVar("Int", 0, "IDLobby") -- The lobby it's in
	self:NetworkVar("Int", 1, "IDSide") -- The side it's on
	self:NetworkVar("Entity", 0, "StrucOwner") -- The owner of the structure (can't use self:SetOwner() because no-collide with the owner)
end