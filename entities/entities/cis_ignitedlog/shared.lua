ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- [[VARS]]
//Basic
ENT.Model = "models/zerochain/props_mystic/bomb_logs_single.mdl"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "IDLobby") -- The lobby it's in
	self:NetworkVar("Int", 1, "IDSide") -- The side it's on
end
