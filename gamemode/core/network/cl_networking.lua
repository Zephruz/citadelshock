--[[
	Client Networking
]]

--[[------------------
	MISC.
------------------]]
net.Receive("CIS.Net.PlayerMessage", function(len)
	local msg = net.ReadString()

	CitadelShock:ChatMessage(msg)
end)

--[[------------------
	LOBBIES
------------------]]

-- [[RECEIVES]]
net.Receive("CIS.Net.SendLobbies", function(len)
	local lobbyid = net.ReadInt(32)
	local lobby = net.ReadTable()

	table.insert(CitadelShock.Lobby.lobbies, lobbyid, lobby)

	for k,v in pairs(CitadelShock.Lobby.lobbies) do
		setmetatable( CitadelShock.Lobby.lobbies[k], {__index = CitadelShock.Lobby.meta} )
	end
end)

net.Receive("CIS.Net.LobbyCreated", function(len)
	local lobby = net.ReadTable()
	local id = net.ReadInt(32)

	CitadelShock.Lobby.lobbies[id] = lobby
	
	setmetatable( CitadelShock.Lobby.lobbies[id], {__index = CitadelShock.Lobby.meta} )

	hook.Run("CIT.Hook.LobbiesUpdated", CitadelShock.Lobby.lobbies[id])
end)

net.Receive("CIS.Net.LobbyDeleted", function(len)
	local id = net.ReadInt(32)

	CitadelShock:ChatMessage("Lobby #" .. id .. " has been deleted/closed!")
	
	if (CitadelShock.Lobby.lobbies[id]) then CitadelShock.Lobby.lobbies[id] = nil end

	hook.Run("CIT.Hook.LobbiesUpdated", CitadelShock.Lobby.lobbies[id])
end)

net.Receive("CIS.Net.LobbyUpdated", function(len)
	local lobby = net.ReadTable()
	local id = net.ReadInt(32)

	CitadelShock.Lobby.lobbies[id] = lobby
	
	setmetatable( CitadelShock.Lobby.lobbies[id], {__index = CitadelShock.Lobby.meta} )

	hook.Run("CIT.Hook.LobbiesUpdated", CitadelShock.Lobby.lobbies[id])
end)

-- [[Game]]
net.Receive("CIS.Net.SendGameResults", function(len)
	local res = net.ReadTable()

	if !(res) then return false end
	CitadelShock.Game.Results = res
	
	RunConsoleCommand("gameresult")
end)