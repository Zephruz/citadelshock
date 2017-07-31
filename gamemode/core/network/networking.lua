--[[
	Shared Networking
]]


--[[
	NET LIBRARY
]]
function CitadelShock.Network:CreateNWLib(nm, desc)
	if (SERVER) then util.AddNetworkString("CIS.Net." .. nm) end
	table.insert(self.vars, {name = nm, desc = (desc or "None")})
	print("\t --> Registered NWLib: " .. nm)
end

--[[NET SETUP HOOK]]
hook.Add("CIS.Hook.GM_Setup", "CIS.Hook.NW_Setup",
function()
	CitadelShock:Message("Network setup: ", " --> ")
	CitadelShock.Network:CreateNWLib("PlayerMessage", "Net for player chat messaging")
	CitadelShock.Network:CreateNWLib("SendLobbies", "Sends an active list of lobbies")
	CitadelShock.Network:CreateNWLib("JoinLobby", "Joins a lobby")
	CitadelShock.Network:CreateNWLib("LeaveLobby", "Leaves a lobby")
	CitadelShock.Network:CreateNWLib("SetReady", "Sets a player as ready")
	CitadelShock.Network:CreateNWLib("SpectateLobby", "Spectates a lobby")
	CitadelShock.Network:CreateNWLib("UnSpectateLobby", "Un-spectates a lobby")
	CitadelShock.Network:CreateNWLib("LobbyCreate", "Creates a lobby")
	CitadelShock.Network:CreateNWLib("LobbyCreated", "Called when a lobby is created")
	CitadelShock.Network:CreateNWLib("LobbyDeleted", "Called when a lobby is deleted")
	CitadelShock.Network:CreateNWLib("LobbyUpdated", "Called when a lobby is updated")
	CitadelShock.Network:CreateNWLib("LobbyBuyBomb", "Purchases a bomb")
	
	CitadelShock.Network:CreateNWLib("SendGameResults", "Sends game results to a player")
end)