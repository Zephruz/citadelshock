--[[
	LOBBY META
	- File for the creation and modification of lobby meta
]]

CitadelShock.Lobby = (CitadelShock.Lobby or {})
CitadelShock.Lobby.lobbies = (CitadelShock.Lobby.lobbies or {})
CitadelShock.Lobby.meta = {}

--[[-----------
	SHARED META
-------------]]

--[[-------------------------
	Name: Create
	What it does: Creates a lobby
	Arguments:
		size - integer; the size of the lobby
---------------------------]]
function CitadelShock.Lobby:Create(s, c)
	local phases = CitadelShock.Game.Phases

	if (CLIENT) then
		net.Start("CIS.Net.LobbyCreate")
			net.WriteInt(s, 32)
		net.SendToServer()
	elseif (SERVER) then
		local lobby = {}
		lobby.size = s
		
		lobby.gameinfo = {}
		lobby.gameinfo.active = false
		lobby.gameinfo.sideData = {}
		
		lobby.gameinfo.currentPhase = -1
		lobby.gameinfo.phaseInfos = {}
		
		for i=1,#phases do
			lobby.gameinfo.phaseInfos[i] = {endtime = 0}
		end
		
		lobby.id = table.insert(CitadelShock.Lobby.lobbies, lobby)
		
		setmetatable( CitadelShock.Lobby.lobbies[lobby.id], {__index = CitadelShock.Lobby.meta} )

		hook.Run("CIS.Hook.LobbyCreated", CitadelShock.Lobby.lobbies[lobby.id], c)
	end
end

--[[-------------------------
	Name: Get All
	What it does: Gets all lobbies.
---------------------------]]
function CitadelShock.Lobby:GetAll()
	return self.lobbies
end

--[[-------------------------
	Name: Find By ID
	What it does: Finds a lobby by its id. Returns nil if not found.
---------------------------]]
function CitadelShock.Lobby:FindByID(id)
	if not (id) then return nil end
	if not (CitadelShock.Lobby.lobbies[id]) then return nil end
	return CitadelShock.Lobby.lobbies[id]
end

--[[-------------------------
	Name: Get Size
	What it does: Gets the size of a lobby.
---------------------------]]
function CitadelShock.Lobby.meta:GetSize()
	if not (self) then return 0 end
	return (self.size or 0)
end

--[[-------------------------
	Name: Get ID
	What it does: Gets the ID of a lobby.
---------------------------]]
function CitadelShock.Lobby.meta:GetID()
	if not (self) then return 0 end
	return (self.id or 0)
end

--[[-------------------------
	Name: Get Players
	What it does: Gets the players of a lobby.
---------------------------]]
function CitadelShock.Lobby.meta:GetPlayers()
	if not (self) then return false end
	local players = {}
	for k,v in pairs(player.GetAll()) do
		if (v:GetIDLobby() == self.id) then
			table.insert(players, v)
		end
	end
	return players
end

--[[-------------------------
	Name: Players Ready
	What it does: Gets if all lobby players are ready.
----------------------------]]
function CitadelShock.Lobby.meta:ArePlayersReady()
	if not (self) then return false end
	local teamPlys = self:GetPlayers()
	local isReady = true
	if not (#teamPlys >= CitadelShock.Lobby.MinSize) then return false end
	for k,v in pairs(teamPlys) do
		if not (v:GetReady()) then isReady = false end
	end

	return isReady
end

--[[-------------------------
	Name: Get Game Info
	What it does: Gets the game info of a lobby.
---------------------------]]
function CitadelShock.Lobby.meta:GetGameInfo()
	if not (self) then return {} end
	return (self.gameinfo or {})
end

--[[-------------------------
	Name: Get Game Sides
	What it does: Gets the game sides and their info of a lobby.
---------------------------]]
function CitadelShock.Lobby.meta:GetGameSides()
	if (!self.gameinfo or !self.gameinfo.sideData) then return false end
	
	for i=1,#self.gameinfo.sideData do self.gameinfo.sideData[i].ents = {} end

	if (self:GetEntities()) then
		for k,v in pairs(self:GetEntities()) do
			if (v.GetIDSide && self.gameinfo.sideData[v:GetIDSide()]) then
				table.insert(self.gameinfo.sideData[v:GetIDSide()].ents, v)
			end
		end
	end
	
	return self.gameinfo.sideData
end

--[[-------------------------
	Name: Get Side Players
	What it does: Gets a lobby game-sides player.
---------------------------]]
function CitadelShock.Lobby.meta:GetSidePlayers(s)
	if not (self) then return false end

	local players = self:GetPlayers()
	
	for k,v in pairs(players) do
		if (v:GetSide() != s) then players[k] = nil end
	end
	
	return players
end

--[[-------------------------
	Name: Get Entities
	What it does: Gets the entities assigned to a lobby
---------------------------]]
function CitadelShock.Lobby.meta:GetEntities()
	if !(self) then return end
	
	local lents = {}

	for k,v in pairs(ents.GetAll()) do
		if (!v:IsPlayer() && v.GetIDLobby && v:GetIDLobby() == self:GetID()) then
			table.insert(lents, v)
		end
	end
	
	return lents
end

--[[-------------------------
	Name: Get Current Phase
	What it does: Gets the lobby's current phase.
---------------------------]]
function CitadelShock.Lobby.meta:GetCurrentPhase()
	if not (self) then return false end
	if not (self.gameinfo.phaseInfos[self.gameinfo.currentPhase]) then return false end
	
	return self.gameinfo.phaseInfos[self.gameinfo.currentPhase]
end

--[[-----------
	CLIENT META
-------------]]
if (CLIENT) then

function CitadelShock.Lobby.meta:Spectate()
	if !(self) then return end
	
	local gameInfo = self:GetGameInfo()
	
	if !(gameInfo.active) then return false end
	
	net.Start("CIS.Net.SpectateLobby")
		net.WriteInt(self:GetID(),8)
	net.SendToServer()
end

function CitadelShock.Lobby.meta:UnSpectate()
	if !(self) then return end
	
	local gameInfo = self:GetGameInfo()
	
	if !(gameInfo.active) then return false end

	net.Start("CIS.Net.UnSpectateLobby")
	net.SendToServer() 
end

end

--[[-----------
	SERVER META
-------------]]
if (SERVER) then

--[[-------------------------
	Name: Set ID
	What it does: Sets the ID of a lobby.
---------------------------]]
function CitadelShock.Lobby.meta:SetID(id)
	self.id = id
	return id
end

--[[-------------------------
	Name: Delete Lobby
	What it does: Deletes a lobby.
----------------------------]]
function CitadelShock.Lobby.meta:Delete()
	if not (self) then return false end
	hook.Run("CIS.Hook.LobbyDeleted", self)
	self = nil
	return true
end

--[[-------------------------
	Name: Updated
	What it does: Broad casts a lobby update network.
---------------------------]]
function CitadelShock.Lobby.meta:Updated(ply)
	if not (self) then return false end

	net.Start("CIS.Net.LobbyUpdated")
		net.WriteTable(self)
		net.WriteInt(self:GetID(), 32)
	if (ply) then net.Send(ply) else net.Broadcast() end
end

--[[----------LOBBY GAME META--------------]]

--[[-------------------------
	Name: Set Game Status
	What it does: Sets the lobby's current game status.
---------------------------]]
function CitadelShock.Lobby.meta:SetGameStatus(bool)
	if not (self) then return false end
	local id = self:GetID()
	if (bool) then self:SetCurrentPhase(1) else self:ResetPhases() end
	self.gameinfo.active = (bool or false)
	self:Updated()
	
	hook.Run("CIS.Hook.LobbyGameStatus", self, bool)

	for k,v in pairs(player.GetAll()) do v:SendMessage("A game has " .. (bool && "started" || "ended") .. " for lobby #" .. id .. "!") end
	return bool
end

--[[-------------------------
	Name: Next Phase
	What it does: Moves a lobby's game to the next phase or returns false for no more phases
---------------------------]]
function CitadelShock.Lobby.meta:NextPhase()
	if not (self) then return false end
	if not (self.gameinfo.phaseInfos[self.gameinfo.currentPhase]) then return false end
	
	local nextPhaseID = self.gameinfo.currentPhase+1
	local nextPhase = self.gameinfo.phaseInfos[nextPhaseID]
	
	if not (nextPhase) then return false end
	
	self:SetCurrentPhase(nextPhaseID)

	return nextPhase
end

--[[-------------------------
	Name: Set Current Phase
	What it does: Sets the lobby's current phase.
---------------------------]]
function CitadelShock.Lobby.meta:SetCurrentPhase(val)
	if not (self) then return false end
	if not (self.gameinfo.phaseInfos[val]) then return false end
	
	local curPhaseInfo = CShockGame_GetPhases(val)
	
	if not (curPhaseInfo) then return false end
	
	self.gameinfo.currentPhase = val
	self.gameinfo.phaseInfos[val].endtime = os.time() + curPhaseInfo.timeLimit
	
	if (curPhaseInfo.custFunc) then curPhaseInfo.custFunc(self) end

	self:Updated()
	
	return self.gameinfo
end

--[[-------------------------
	Name: Reset Phases
	What it does: Resets the lobbies phases
---------------------------]]
function CitadelShock.Lobby.meta:ResetPhases()
	if not (self) then return false end
	
	self.gameinfo.currentPhase = -1
	
	for i=1,#self.gameinfo.phaseInfos do
		self.gameinfo.phaseInfos.endtime = 0
	end
	
	return self.gameinfo
end

--[[-------------------------
	Name: Start Game
	What it does: Starts a lobby's game.
---------------------------]]
function CitadelShock.Lobby.meta:StartGame()
	if not (self) then return false end
	local id = self:GetID()
	local lobbyPlys = self:GetPlayers()
	
	-- [[INSTANCE]]
	local instID, instTBL = Instances:New({
		name = "game_",		-- it's a game; so we'll change the name
		lobby = id,			-- lets set this just incase
		joinable = false, 	-- not joinable from the instance menu
	}, id)
	
	-- [[SETUP SIDES]]
	local sides = CitadelShock.Game.Sides
	
	-- [[SETUP PLAYERS]]
	local split = (#lobbyPlys/#sides)
	split = math.floor(split)

	for k,v in pairs(lobbyPlys) do
		if (k <= split) then v:SetSide(1)
		elseif (k > split) then v:SetSide(2)
		end
	end
	
	-- [[SETUP ENTITIES]]
	for i=1,#sides do
		local sidePlayers = self:GetSidePlayers(i)
	
		self.gameinfo.sideData[i] = {}

		-- [[RESOURCE SETUP]]
		self.gameinfo.sideData[i].resources = {}
		for _,r in pairs(CitadelShock.Game.Resources) do
			r.genRes(self, sides[i], i)
			self.gameinfo.sideData[i].resources[r.name] = (r.val or 0)
		end

		-- [[GENERATOR SETUP]]
		local generator = ents.Create( "cis_generator" )
		if ( !IsValid( generator ) ) then return end
		generator:SetPos( sides[i].gen.pos )
		generator:SetAngles( sides[i].gen.ang )
		generator.BaseHealth = (CitadelShock.Game.GeneratorHealth or 5000)
		generator:Spawn()
		generator:DropToFloor()
		generator:SetIDLobby(id)
		generator:SetIDSide(i)

		-- [[SETUP PLAYERS]]
		-- position all players
		for p=1,#sidePlayers do
			if (IsValid(sidePlayers[p])) then
				sidePlayers[p]:SetPos(sides[i].spos)
			end
		end
	end

	self:SetGameStatus(true) -- Update all players

	for k,v in pairs(self:GetEntities()) do
		v:SetInstance(instID)
	end
	
	for k,v in pairs(lobbyPlys) do
		v:SetStatus(1) -- set status
		v:SetInstance(instID) -- set the players instance
	end
end

--[[-------------------------
	Name: End Game
	What it does: Ends a lobby's game.
---------------------------]]
function CitadelShock.Lobby.meta:EndGame()
	if not (self) then return false end

	local lPlys = self:GetPlayers()
	local lEnts = self:GetEntities()
	local id = self:GetID()

	local results = self:RewardSides() -- Reward game sides
	
	self:SetGameStatus(false) -- Set game status

	-- Update all players (spectators & in-game players)
	for k,v in pairs(player.GetAll()) do
		if (v:GetIDLobby() == id or v:GetInstance() == id or v:GetSpectatedGame() == id) then
			v:SetStatus(0)
			v:SetInstance(0)
			
			if (v:GetIDLobby() == id) then results.plyside = v:GetSide() v:SendResultsGame(results) end
			
			v:SetSide(-1)
		end
	end
	
	-- Remove lobby entities
	for k,v in pairs(lEnts) do
		v:Remove()
	end
	
	-- Remove instance
	if (Instances:GetByID(id)) then
		Instances:Delete(id)
	end
end

--[[-------------------------
	Name: Reward Sides
	What it does: Rewards a lobbies sides/teams.
		- Used for end-game rewarding
		- Returns the results
---------------------------]]
function CitadelShock.Lobby.meta:RewardSides()
	if not (self) then return false end

	local lPlys = self:GetPlayers()
	local sides = self:GetGameSides()

	if not (sides) then return false end
	
	-- Retreive generators
	local gens = {}

	for i=1,#sides do
		local sents = sides[i].ents
		for e=1,#sents do
			if (IsValid(sents[e]) && sents[e].IsGenerator) then gens[i] = sents[e]:Health() end
		end
	end
	
	-- Check if it's a draw
	local draw = true
	local maxGenHP = math.max(unpack(gens))
	
	for i=1,#gens do
		if (gens[i] != maxGenHP) then draw = false end
	end
	
	-- Retreive winning sides/teams
	local results = {}
	results.draw = draw
	results.sides = {}
	
	for i=1,#gens do
		results.sides[i] = {}
		results.sides[i].genHP = gens[i] 
		if (gens[i] >= maxGenHP) then results.sides[i].win = true end
		if (gens[i] < maxGenHP) then results.sides[i].win = false end
	end
	
	-- Reward players
	for k,v in pairs(lPlys) do
		if (draw) then
			v:GiveRewards(CitadelShock.Game.DrawRewards)
		else
			for i=1,#results.sides do
				if (results.sides[i].win && v:GetSide() == i) then 
					v:GiveRewards(CitadelShock.Game.WinRewards)
					v:AddWins(1)
				elseif (!results.sides[i].win && v:GetSide() == i) then
					v:AddLosses(1)
				end
			end
		end
	end
	
	return results
end

--[[-------------------------
	Name: Give Resource
	What it does: Gives a resource (type) to a lobby side
---------------------------]]
function CitadelShock.Lobby.meta:GiveResource(nm, amt, s)
	local sides = self:GetGameSides()
	if !(sides) then return false end
	
	if (!nm or !amt or !s) then return false end
	if (!sides[s] or !sides[s].resources[nm]) then return false end
	
	self.gameinfo.sideData[s].resources[nm] = (self.gameinfo.sideData[s].resources[nm] + amt)

	for k,v in pairs(self:GetPlayers()) do
		self:Updated(v)
	end
end

--[[-------------------------
	Name: Generate Spawn Pos
	What it does: Generates a random and *open* spawn position within an area for an entity.
---------------------------]]
function CitadelShock.Lobby.meta:GenerateSpawnPos(box, posTbl)
	local claimedPos = (posTbl)
	local spawnPos = Vector(math.random(box[1].x, box[2].x), math.random(box[1].y, box[2].y), math.random(box[1].z, box[2].z))

	local pass = true
	if (#claimedPos > 0) then
		for cp=1,#claimedPos do
			if (claimedPos[cp]:Distance(spawnPos) < 150) then pass = false end
		end

		if !(pass) then
			spawnPos = self:GenerateSpawnPos(resBoxB)
		else
			table.insert(claimedPos, spawnPos)
		end
	end

	return spawnPos, claimedPos
end

end

--[[----------------------------------]]

_R.Lobby = CitadelShock.Lobby.meta -- Set the meta table for global retreival

--[[----------------------------------]]