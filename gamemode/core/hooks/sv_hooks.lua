--[[-----------------
	SERVER HOOKS
-------------------]]

--[[-------------------------
	Name: Lobby Created
	- Called when a lobby is created.
---------------------------]]
hook.Add("CIS.Hook.LobbyCreated", "CIS_HOOK_LobbyCreated", 
function(l, c)
	c:ResetLobbyInfo()
	c:SetLobby(l.id)
	c:SendMessage("You created a " .. (l.size/2) .. " vs " .. (l.size/2) .. " lobby!")
	
	net.Start("CIS.Net.LobbyCreated")
		net.WriteTable(l)
		net.WriteInt(l:GetID(), 32)
	net.Broadcast()
end)

--[[-------------------------
	Name: Lobby Deleted
	- Called when a lobby is deleted.
---------------------------]]
hook.Add("CIS.Hook.LobbyDeleted", "CIS_HOOK_LobbyDeleted", 
function(l)
	if (l:GetGameInfo().active) then
		l:EndGame()
	end
	
	if (#l:GetPlayers() > 0) then
		for k,v in pairs(l:GetPlayers()) do
			v:ResetLobbyInfo()
		end
	end
	
	-- [[Instance removal]]
	if (Instances:GetByID(l.id)) then
		Instances:Delete(l.id)
	end

	CitadelShock.Lobby.lobbies[l.id] = nil

	net.Start("CIS.Net.LobbyDeleted")
		net.WriteInt(l.id, 32)
	net.Broadcast()
end)

--[[--------------------------
	Name: Player Spawned
----------------------------]]
hook.Add("CIS.PlayerSpawned",
function(p)
	p:RunClass()
end)