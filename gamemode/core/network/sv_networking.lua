--[[
	Server Networking
]]

-- [[Player NW]]
hook.Add("CIS.PlayerInitialSpawn", "CITSH_SendLobbiesPly",
function(ply)
	ply:SendLobbies()
end)

-- [[Player Lobby NW]]
net.Receive("CIS.Net.JoinLobby",
function(len, ply)
	local id = net.ReadInt(32)
	local previd = ply:GetIDLobby()
	local prevLobby = CitadelShock.Lobby:FindByID(previd)
	local newLobby = CitadelShock.Lobby.lobbies[id]
	if not (newLobby) then return false end
	if (id == previd) then ply:SendMessage("You can't join a lobby you're already in!") return false end
	if (newLobby:GetSize() <= #newLobby:GetPlayers()) then ply:SendMessage("This lobby is full!") return false end
	
	ply:ResetLobbyInfo()
	ply:SetLobby(id)
	ply:SendMessage("You joined lobby #" .. id .. "!")

	if (prevLobby && #prevLobby:GetPlayers() <= 0) then
		prevLobby:Delete()
	end

	if (newLobby:GetSize() <= #newLobby:GetPlayers()) then
		newLobby:StartGame()
	end
end)

net.Receive("CIS.Net.LeaveLobby",
function(len, ply)
	if not (ply:IsInLobby()) then return false end
	local previd = ply:GetIDLobby()
	local lobby = CitadelShock.Lobby:FindByID(previd)

	-- Set penalizations
	if (ply:IsInGame()) then
		ply:GiveRewards(CitadelShock.Game.LeavePenalty)
	end
	
	-- Set info & send message
	ply:ResetLobbyInfo()
	ply:SendMessage("You left the lobby!")
	
	if (lobby && #lobby:GetPlayers() <= lobby:GetSize()/2) then
		lobby:Delete()
	end
end)

net.Receive("CIS.Net.SetReady",
function(len, ply)
	if not (ply:IsInLobby()) then return false end
	local bool = net.ReadBool()
	local lobby = CitadelShock.Lobby:FindByID(ply:GetIDLobby())
	
	ply:SetReady(bool)

	if (lobby:ArePlayersReady()) then
		lobby:StartGame()
	end
end)

-- [[Lobby NW]]
net.Receive("CIS.Net.SpectateLobby",
function(len, ply)
	local id = net.ReadInt(8)
	local lobby = CitadelShock.Lobby:FindByID(id)
	local gameInfo = lobby:GetGameInfo()
	
	if (!id or !lobby or !gameInfo) then return false end
	if (!gameInfo.active) then return false end
	if (ply:IsInGame()) then return false end
	
	ply:SetSpectatedGame(id)
end)

net.Receive("CIS.Net.UnSpectateLobby",
function(len, ply)
	if (ply:IsInGame()) then return false end
	if (ply:GetSpectatedGame() == -1) then return false end
	
	ply:UnSpectatedGame()
end)

net.Receive("CIS.Net.LobbyCreate",
function(len, ply)
	local size = net.ReadInt(32)
	local pid = ply:GetIDLobby()
	local pl = CitadelShock.Lobby:FindByID(pid)
	if (table.Count(CitadelShock.Lobby:GetAll()) >= CitadelShock.Lobby.MaxLobbies) then ply:SendMessage("There is already the maximum amount of lobbies!") return false end
	if (size > CitadelShock.Lobby.MaxSize or size < CitadelShock.Lobby.MinSize) then ply:SendMessage("Lobby size is above/below the max/min size!") return false end
	
	CitadelShock.Lobby:Create(size, ply)

	if (pl && #pl:GetPlayers()	<= 0) then
		pl:Delete()
	end
end)

net.Receive("CIS.Net.LobbyBuyBomb",
function(len, ply)
	local btype = net.ReadString()
	local pid = ply:GetIDLobby()
	local pl = CitadelShock.Lobby:FindByID(pid)
	
	if not (pl) then return false end
	
	local side = ply:GetSide()
	
	local bBuy, res = hook.Run("CIS.Game.PreBombSpawn", ply, (btype or false))
	
	if (bBuy) then
		local pos = ply:GetPos() + Vector(0,0,105)
		for k,v in pairs(pl:GetEntities()) do
			if (v.IsGenerator && v:GetIDSide() == side) then
				pos = v:GetPos() + Vector(0,0,150)
			end
		end
	
		local bomb = CitadelShock.Game:SpawnBomb(btype, pos)
		bomb:SetIDLobby(pid)
		bomb:SetIDSide(side)
		bomb:ZI_SetOwner(ply)
		
		local bphys = bomb:GetPhysicsObject()
		if (bphys) then 
			bphys:EnableMotion(true)
			bphys:Wake()
		end
	end
	ply:SendMessage(res or "No response") 
end)