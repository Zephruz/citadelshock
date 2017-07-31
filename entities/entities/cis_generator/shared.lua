ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.AutomaticFrameAdvance = true 
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- [[VARS]]
ENT.BaseHealth = 10000

-- [[DUMMY VARS]]
ENT.IsGenerator = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "IDLobby") -- The lobby it's in
	self:NetworkVar("Int", 1, "IDSide") -- The side it's on
end

function ENT:Think()
	local sequence = self:LookupSequence( "idle" )
	self:SetSequence( sequence )
	self:ResetSequence( sequence )
	
	if !(self.moneyGenerate) then self.moneyGenerate = os.time() + CitadelShock.Game.MoneyGenerationInts
	elseif (os.time() >= self.moneyGenerate) then
		self.moneyGenerate = os.time() + CitadelShock.Game.MoneyGenerationInts
		if (SERVER) then
			local lobby = CitadelShock.Lobby:FindByID(self:GetIDLobby())
			if !(lobby) then return false end
			if !(self.GetIDSide) then return false end
			
			lobby:GiveResource("money", math.floor(self:Health() * 0.25), self:GetIDSide())
		end
	end
end