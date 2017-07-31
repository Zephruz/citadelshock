--[[-----------------------------------
			CHAT COMMANDS
			
	- Chat command registration
	- Also adds a console command
--------------------------------------]]

CitadelShock.CMDS = {}

function CitadelShock:RegisterCommand(cmd, func, desc)
	self.CMDS[cmd] = {func = func, desc = (desc or false)}
	concommand.Add(cmd, func)
end

hook.Add("OnPlayerChat", "CIS.Hook.Menu.OnPlayerChat",
function( p, cmd, to, dead )
	if (p == LocalPlayer()) then
		for k,v in pairs(CitadelShock.CMDS) do
			if ("!" .. k == cmd) then v.func() return true end
		end
	end
end)

-- [[COMMANDS]]
CitadelShock:RegisterCommand("leavegame", 
function() LocalPlayer():LeaveLobby() end, 
"Leaves your current game")

CitadelShock:RegisterCommand("ready",
function()
	local ply = LocalPlayer()
	local rs = ply:GetReady()
	ply:SetReady((!rs && true || rs && false))
end,
"Sets your ready status to ready/not ready")

CitadelShock:RegisterCommand("unspectate",
function()
	local ply = LocalPlayer()
	
	local specGame = ply:GetSpectatedGame()
	if (specGame == -1) then return false end
	
	local lobby = CitadelShock.Lobby:FindByID(specGame)
	if !(lobby) then return false end
	
	lobby:UnSpectate()
end,
"Stops you from spectating")