--[[
	PLAYER
	- SERVER
]]

-- [[PlayerInitialSpawn]]
function GM:PlayerInitialSpawn(ply)
	CitadelShock.data:InitPlayer(ply)
	hook.Run("CIS.PlayerInitialSpawn", ply)
end

-- [[PlayerSpawn]]
function GM:PlayerSpawn(ply)
	ply:SetupHands()
	--ply:CrosshairDisable()
	hook.Run("CIS.PlayerSpawned", ply)
end

-- [[PlayerDisconnected]]
function GM:PlayerDisconnected(ply)
	local id = ply:GetIDLobby()
	local lobby = CitadelShock.Lobby.lobbies[id]
	if not (lobby) then return false end
	if (lobby:GetPlayers() && #lobby:GetPlayers()-1 <= 0) then
		lobby:Delete()
	end
end

-- [[PlayerShouldTakeDamage]]
function GM:PlayerShouldTakeDamage( ply, att )
	if (att:IsPlayer() && att:GetIDLobby() == ply:GetIDLobby() && att:GetSide() == ply:GetSide()) then 
		return false 
	end

	return true
end