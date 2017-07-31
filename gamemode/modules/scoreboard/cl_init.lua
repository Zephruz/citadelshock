--[[
	Citadel Shock
	- SCOREBOARD MODULE -
	- CL INIT -
]]

CitadelShock.Scoreboard = {}
CitadelShock.ActiveScoreboard = "cis_scoreboard"

--[[
	CONFIG
]]
CitadelShock.Scoreboard.Title = "CitadelShock" 		-- Scoreboard title

--[[
	SCOREBOARD FUNCTIONS
]]
function CitadelShock:GetActiveScoreboard()
	local sb = self.Scoreboard[self.ActiveScoreboard]
	if !(sb) then return end

	return sb
end

function CitadelShock:RegisterScoreboard(nm, tbl)
	CitadelShock.Scoreboard[nm] = tbl
end

function GM:ScoreboardShow()  
	local sb = CitadelShock:GetActiveScoreboard()
	if (!sb or !sb.Create) then return end
	
	sb:Create()
end

function GM:ScoreboardHide()  
	local sb = CitadelShock:GetActiveScoreboard()
	if (!sb or !sb.Remove) then return end
	
	sb:Remove()
end
