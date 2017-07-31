--[[
	Player Meta File
	- File for the creation and modification of player meta
]]

CitadelShock.Player = (CitadelShock.Player or {})
local ply_Meta = {}

--[[-----------------------------------
		PLAYER META
--------------------------------------]]
local meta = FindMetaTable("Player")

function CitadelShock.Player:RegisterMeta(name, tbl)
	ply_Meta[name] = {}

	for k,v in pairs(tbl.meta) do
		-- Set accessor
		ply_Meta[name][k] = tbl.meta[k]
		meta[k .. name] = tbl.meta[k]
	end
end

function CitadelShock.Player:AccessMeta(name)
	if not (ply_Meta[name]) then CitadelShock:Message("Invalid meta name.") return ply_Meta end
	return ply_Meta[name]
end

--[[-------------------------------
			PLAYER META
----------------------------------]]

--[[
	Name: Message
	Meta:
		- Send - Sends a message to a player (SERVER)
]]
CitadelShock.Player:RegisterMeta("Message", {
	Description = "Sends a message to a player.",
	meta = {
		Send = function(self, msg)
			net.Start("CIS.Net.PlayerMessage")
				net.WriteString(msg)
			net.Send(self)
		end,
	},
})

--[[
	Name: SpectatedGame
	Meta:
		- Get - Gets a players spectated game (SHARED)
		- Set - Sets a players spectated game (SERVER)
		- Un - Stops a player from spectating a game (SERVER)
]]
CitadelShock.Player:RegisterMeta("SpectatedGame", {
	Description = "Sets/gets a players current spectated game.",
	meta = {
		Set = function(self, id)
			self:SetNW2Int("CIS.PNW.SpecGame", (id or -1))
			self:SetInstance(id)
			self:SetStatus(3)
		end,
		Get = function(self)
			return (self:GetNW2Int("CIS.PNW.SpecGame") or -1)
		end,
		Un = function(self)
			self:SetNW2Int("CIS.PNW.SpecGame", -1)
			self:SetInstance(0)
			self:SetStatus(0)
		end,
	}
})

--[[
	Name: Lobby
	Meta:
		- Set - Sets a players lobby/game lobby (SERVER)
		- Get - Gets a players lobby/game table (SHARED)
		- GetID - Gets a players lobby/game id (SHARED)
		- Join - Joins a lobby (CLIENT)
		- Leave - Leaves a lobby (CLIENT)
		- IsIn - Gets if a player's in a lobby (SHARED)
]]
CitadelShock.Player:RegisterMeta("Lobby", {
	Description = "Sets/gets or Join/Leave a players current lobby/game.",
	meta = {
		Get = function(self)
			if not (CitadelShock.Lobby.lobbies[self:GetIDLobby()]) then if (SERVER) then self:SetLobby(-1) end return false end
			return CitadelShock.Lobby.lobbies[self:GetIDLobby()]
		end,
		Set = function(self, id)
			self:SetNW2Int("CIS.PNW.LobbyID", (id or -1))
			self:SetReady(false)
		end,
		GetID = function(self)
			return (self:GetNW2Int("CIS.PNW.LobbyID") or -1)
		end,
		Join = function(self, id)
			net.Start("CIS.Net.JoinLobby")
				net.WriteInt(id, 32)
			net.SendToServer()
		end,
		Leave = function(self)
			if not (self:GetLobby()) then return false end

			net.Start("CIS.Net.LeaveLobby")
			net.SendToServer()
		end,
		IsIn = function(self)
			if not (self:GetLobby()) then return false end
			return true
		end,
	}
})

--[[
	Name: Game
	Meta:
		- IsIn - Gets if a player is in a game (SHARED)
		- SendResults - Sends the game ending results (SERVER)
]]
CitadelShock.Player:RegisterMeta("Game", {
	Description = "Gets a players game info.",
	meta = {
		IsIn = function(self)
			if not (self:IsInLobby()) then return false end
			local lobby = self:GetLobby()

			return (lobby.gameinfo.active or false)
		end,
		SendResults = function(self,tbl)
			if (SERVER) then
				net.Start("CIS.Net.SendGameResults")
					net.WriteTable(tbl)
				net.Send(self)
			end
		end,
	}
})

--[[
	Name: Lobbies
	Meta:
		- Send - Sends a player lobbies (SERVER)
]]
CitadelShock.Player:RegisterMeta("Lobbies", {
	Description = "Sends a player the server-lobbies.",
	meta = {
		Send = function(self)
			for k,v in pairs(CitadelShock.Lobby.lobbies) do
				net.Start("CIS.Net.SendLobbies")
					net.WriteInt(k, 32)
					net.WriteTable(v)
				net.Send(self)
			end
		end,
	}
})

--[[
	Name: Side
	Meta:
		- Set - Sets a players lobby/game side (SERVER)
		- Get - Gets a players lobby/game side (SHARED)
]]
CitadelShock.Player:RegisterMeta("Side", {
	Description = "Sets/gets a players current lobby/game side.",
	meta = {
		Set = function(self, id)
			self:SetNW2Int("CIS.PNW.SideID", (id or -1))
		end,
		Get = function(self)
			return (self:GetNW2Int("CIS.PNW.SideID") or -1)
		end,
	}
})

--[[
	Name: Status
	Meta:
		- Set - Sets a players status (SERVER)
		- Get - Gets a players status (SHARED)
]]
CitadelShock.Player:RegisterMeta("Status", {
	Description = "Sets/gets a players status.",
	meta = {
		Set = function(self, s)
			local stat = self:SetNW2Int("CIS.PNW.Status", (s or 0))
			local class = "player_" .. (CitadelShock.Player.teams[(s or self:GetStatus() or 0)].name)
			player_manager.ClearPlayerClass( self )
			player_manager.SetPlayerClass(self, class)
			player_manager.RunClass(self, "Spawn")
			player_manager.RunClass(self, "Loadout")
		end,
		Get = function(self)
			return (self:GetNW2Int("CIS.PNW.Status") or 0)
		end,
	}
})

--[[
	Name: Ready
	Meta:
		- Set - Set ready (CLIENT)
]]
CitadelShock.Player:RegisterMeta("Ready", {
	Description = "Sets/gets if a player is ready.",
	meta = {
		Set = function(self, bool)
			if (CLIENT) then
				if not (self:GetLobby()) then return false end
				net.Start("CIS.Net.SetReady")
					net.WriteBool((bool or false))
				net.SendToServer()
			elseif (SERVER) then
				self:SetNW2Bool("CIS.PNW.LobbyReady", bool)
			end
		end,
		Get = function(self)
			return (self:GetNW2Bool("CIS.PNW.LobbyReady") or false)
		end,
	}
})

--[[
	Name: Points
	Meta: 
		- Set - Sets a players points (SERVER)
		- Get - Gets a players points (SHARED)
]]	
CitadelShock.Player:RegisterMeta("Points", {
	Description = "Gets/sets a players points.",
	meta = {
		Get = function(self)
			return self:GetNW2Int("CIS.PNW.points")
		end,
		Set = function(self, val)
			self:SetNW2Int("CIS.PNW.points", val)
			self:SetSQLValue("points", val)
		end,
		Add = function(self, val)
			self:SetNW2Int("CIS.PNW.points", (self:GetPoints() + val))
			self:SetSQLValue("points", (self:GetPoints() + val))
		end,
	}
})

--[[
	Name: Wins
	Meta: 
		- Set - Sets a players wins (SERVER)
		- Get - Gets a players wins (SHARED)
]]	
CitadelShock.Player:RegisterMeta("Wins", {
	Description = "Gets/sets a players wins.",
	meta = {
		Get = function(self)
			return self:GetNW2Int("CIS.PNW.wins")
		end,
		Set = function(self, val)
			self:SetNW2Int("CIS.PNW.wins", val)
			self:SetSQLValue("wins", val)
		end,
		Add = function(self, val)
			self:SetNW2Int("CIS.PNW.wins", (self:GetWins() + val))
			self:SetSQLValue("wins", (self:GetWins() + val))
		end,
	}
})

--[[
	Name: Losses
	Meta: 
		- Set - Sets a players losses (SERVER)
		- Get - Gets a players losses (SHARED)
]]	
CitadelShock.Player:RegisterMeta("Losses", {
	Description = "Gets/sets a players losses.",
	meta = {
		Get = function(self)
			return self:GetNW2Int("CIS.PNW.losses")
		end,
		Set = function(self, val)
			self:SetNW2Int("CIS.PNW.losses", val)
			self:SetSQLValue("losses", val)
		end,
		Add = function(self, val)
			self:SetNW2Int("CIS.PNW.losses", (self:GetLosses() + val))
			self:SetSQLValue("losses", (self:GetLosses() + val))
		end,
	}
})

--[[
	Name: EXP
	Meta: 
		- Set - Sets a players points (SERVER)
		- Get - Gets a players points (SHARED)
]]	
CitadelShock.Player:RegisterMeta("EXP", {
	Description = "Gets/sets a players points.",
	meta = {
		Get = function(self)
			return self:GetNW2Int("CIS.PNW.exp")
		end,
		Set = function(self, val)
			self:SetNW2Int("CIS.PNW.exp", val)
			self:SetSQLValue("exp", val)
			
			self:CheckLevel()
		end,
		Add = function(self, val)
			local nExp = self:GetEXP() + val
			self:SetNW2Int("CIS.PNW.exp", (nExp))
			self:SetSQLValue("exp", (nExp))
			
			self:CheckLevel()
		end,
		ToLevel = function(self)
			return self:GetLevel() * 100
		end,
	}
})

--[[
	Name: Level
	Meta:
		- Set - Sets a players level (SERVER)
		- Get - Gets a players level (SHARED)
]]
CitadelShock.Player:RegisterMeta("Level", {
	Description = "Gets/sets a players level.",
	meta = {
		Get = function(self)
			return (self:GetNW2Int("CIS.PNW.level") or 1)
		end,
		Set = function(self, val)
			self:SetNW2Int("CIS.PNW.level", val)
			self:SetSQLValue("level", val)
			
			self:SetEXP(0)
		end,
		Add = function(self, val)
			self:SetNW2Int("CIS.PNW.level", (self:GetLevel() + val))
			self:SetSQLValue("level", (self:GetLevel() + val))
		end,
		Check = function(self)
			local val = self:GetEXP()
			if (val >= self:ToLevelEXP()) then
				local lExp = val - self:ToLevelEXP()
				
				self:SetEXP(lExp)
				self:AddLevel(1)
			end
		end,
	}
})

--[[
	Name: Rewards
	Meta:
		- Give - Gives/takes a player rewards
		- This CAN be used to give AND take rewards!
]]
CitadelShock.Player:RegisterMeta("Rewards", {
	Description = "Gives a player rewards/deductions.",
	meta = {
		Give = function(self, tbl)
			if !(tbl) then return false end
			for rn,val in pairs(tbl) do
				local func = self["Add" .. rn]
				if (func && val) then func(self, val) end
			end
		end,
	}
})

--[[-------------------------------
		CLIENT PLAYER META
----------------------------------]]

--[[-------------------------------
		SHARED PLAYER META
----------------------------------]]
function meta:LoadVisibleEntities(ent) -- Loads all of the visible entities for players
	local function checkEnt(e) -- localize this so we can use it efficiently
		if not (IsValid(e)) then return false end
			
		if (IsValid(e)) then
			if (e.GetIDLobby && self.GetIDLobby) then
				if (e:GetIDLobby() == self:GetIDLobby()) then
					e:SetNoDraw(false)
				end
			else
				e:SetNoDraw(false)
			end
		end
	end
	
	if (ent) then
		checkEnt(ent)
	else
		for e_id,e in pairs(ents.GetAll()) do
			checkEnt(e)
		end
	end
end

function meta:ResetLobbyInfo() -- Resets a players lobby information
	self:SetStatus(0)
	self:SetLobby(-1)
	self:SetSide(-1)
	self:SetReady(false)
end

--[[
	DEBUG STUFF

	for k,v in pairs(player.GetAll()) do if not (v:IsInLobby()) then v:SetLobby(1) end end
	for k,v in pairs(player.GetAll()) do if (v:IsInLobby()) then v:SetReady(true) end end
]]
if (SERVER) then
	concommand.Add("cis_forcealljoin",
	function()
		for k,v in pairs(player.GetAll()) do if not (v:IsInLobby()) then v:SetLobby(1) end end
		for k,v in pairs(player.GetAll()) do if (v:IsInLobby()) then v:SetReady(true) end end
	end)
end
