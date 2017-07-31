--[[
	Citadel Shock
	- SCOREBOARD MODULE -
	- CL SCOREBOARD -
]]

local SCOREBOARD = {}

-- [[fonts]]
local function CS_CreateFont(name, tbl)
	surface.CreateFont(name, tbl)
end

CS_CreateFont("CS_SB_HUGE",
{
	font = "Alegreya Sans SC",
	size = 52,
})

CS_CreateFont("CS_SB_LG",
{
	font = "Alegreya Sans SC",
	size = 32,
})

CS_CreateFont("CS_SB_MD",
{
	font = "Alegreya Sans SC",
	size = 22,
})

CS_CreateFont("CS_SB_SM",
{
	font = "Alegreya Sans SC",
	size = 18,
})

-- [[variables]]
SCOREBOARD.Vars = {}

-- [[materials]]
SCOREBOARD.Mats = {}
SCOREBOARD.Mats.bg = Material("materials/citadelshock/gui/derma_grunge_panel.png", "noclamp smooth")

local function SB_Mats()
	return SCOREBOARD.Mats
end

function SCOREBOARD:Create()
	local mats = SB_Mats()

	-- [[Frame]]
	self.sbFrame = vgui.Create("DPanel")
	self.sbFrame:SetSize((ScrW() > 750 && 750 || ScrW()*0.95),(ScrH() <= 650 && 650 || ScrH()*0.95))
	self.sbFrame:Center()
	self.sbFrame:MakePopup()
	self.sbFrame.Paint = function(self, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(40,40,40,255))
	end
	
	-- [[Title]]
	local titlePanel = vgui.Create("DPanel", self.sbFrame)
	titlePanel:Dock(TOP)
	titlePanel:DockMargin(5,5,5,5)
	titlePanel:SetTall(75)
	titlePanel.Paint = function(self,w,h)
		draw.RoundedBox(4, 0, 0, w, h, Color(35,35,35,255))
		
		draw.SimpleText( CitadelShock.Scoreboard.Title, "CS_SB_HUGE", w/2, h/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	
	-- [[Panels]]
	self:CreatePlayers() -- Create players without a lobby
	self:CreateLobbies() -- Create lobbies (& players)
end

function SCOREBOARD:CreatePlayers()
	local cols = {
		["Player"] = {
			pos = function(w,h)
				return 5, h/2
			end,
			val = function(ply)
				return (ply:Nick() or "NIL")
			end,
			align = {x = TEXT_ALIGN_LEFT, y = TEXT_ALIGN_CENTER}
		},
		["Wins/Losses"] = {
			pos = function(w,h)
				return w*0.25, h/2
			end,
			val = function(ply)
				return ((ply:GetWins() or "NIL") .. "/" .. (ply:GetLosses() or "NIL"))
			end,
			align = {x = TEXT_ALIGN_CENTER, y = TEXT_ALIGN_CENTER}
		},
		["Level"] = {
			pos = function(w,h)
				return w/2, h/2
			end,
			val = function(ply)
				return (ply:GetLevel() or "NIL")
			end,
			align = {x = TEXT_ALIGN_CENTER, y = TEXT_ALIGN_CENTER}
		},
		["Rank"] = {
			pos = function(w,h)
				return w*0.75, h/2
			end,
			val = function(ply)
				return (ply:GetUserGroup() or "NIL")
			end,
			align = {x = TEXT_ALIGN_CENTER, y = TEXT_ALIGN_CENTER}
		},
		["Lobby"] = {
			pos = function(w,h)
				return w-5, h/2
			end,
			val = function(ply)
				return (ply:GetIDLobby() > 0 && "Lobby #" .. ply:GetIDLobby() || "No Lobby") or "NIL"
			end,
			align = {x = TEXT_ALIGN_RIGHT, y = TEXT_ALIGN_CENTER}
		},
	}
	

	-- [[Player List]]
	local playerList = vgui.Create("DScrollPanel", self.sbFrame)
	playerList:Dock(TOP)
	playerList:DockMargin(10,10,10,10)
	playerList:GetCanvas():DockPadding(0,30,0,0)
	playerList:SetTall(250)
	playerList.Paint = function(self, w, h)
		--draw.RoundedBox(4, 0, 0, w, h, Color(35,35,35,255))
		--draw.RoundedBoxEx(4, 0, 0, w, 25, Color(55,55,55,255), true, true, false, false)
			
		draw.SimpleText( "Players (" .. #player.GetAll() .. "/" .. game.MaxPlayers() .. ")", "CS_SB_MD", 10, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	end
	
	-- [[Header]]
	local header = vgui.Create("DPanel", playerList)
	header:Dock(TOP)
	header:DockMargin(0,0,0,5)
	header:SetTall(20)
	header.Paint = function(self, w, h)
		draw.RoundedBoxEx(4, 0, 0, w, h, Color(55,55,55,255), true, true, true, true)
			
		for k,v in pairs(cols) do
			local x,y = v.pos(w,h)
			local xal,yal = (v.align && v.align.x || TEXT_ALIGN_CENTER), (v.align && v.align.y || TEXT_ALIGN_CENTER)
			
			draw.SimpleText( k, "CS_SB_SM", x, y, Color(255,255,255,255), xal,yal )
		end
	end
	
	-- [[Players]]
	local players = player.GetAll()
	
	for i=1,#players do
		local ply = players[i]
		
		if (IsValid(ply)) then
			local player = vgui.Create("DPanel", playerList)
			player:Dock(TOP)
			player:DockMargin(0,0,0,5)
			player:SetTall(25)
			player.Paint = function(self, w, h)
				draw.RoundedBox(4, 0, 0, w, h, Color(35,35,35,255))

				for k,v in pairs(cols) do
					local x,y = v.pos(w,h)
					local val = v.val(ply)
					local xal,yal = (v.align && v.align.x || TEXT_ALIGN_CENTER), (v.align && v.align.y || TEXT_ALIGN_CENTER)
					
					draw.SimpleText( val, "CS_SB_SM", x, y, Color(255,255,255,255), xal,yal )
				end
			end
		end
	end
end

function SCOREBOARD:CreateLobbies()
	local lobbies = CitadelShock.Lobby:GetAll()
	
	if !(lobbies) then return false end

	-- [[Lobby List]]
	local lobbyList = vgui.Create("DScrollPanel", self.sbFrame)
	lobbyList:Dock(FILL)
	lobbyList:DockMargin(10,10,10,10)
	lobbyList:GetCanvas():DockPadding(0,30,0,0)
	lobbyList.Paint = function(self, w, h)
		--draw.RoundedBox(4, 0, 0, w, h, Color(35,35,35,255))
		--draw.RoundedBoxEx(4, 0, 0, w, 25, Color(55,55,55,255), true, true, false, false)
			
		draw.SimpleText( "Lobbies", "CS_SB_MD", 10, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	end
	
	if (table.Count(lobbies) <= 0) then
		local noLobbies = vgui.Create("DPanel", lobbyList)
		noLobbies:Dock(TOP)
		noLobbies:DockMargin(5,5,5,5)
		noLobbies:SetTall(30)
		noLobbies.Paint = function(self, w, h)
			draw.RoundedBox(4, 0, 0, w, h, Color(55,55,55,255))
			
			draw.SimpleText( "No open lobbies! Create one by typing !lobbies in chat.", "CS_SB_MD", w/2, h/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	
	for k,v in pairs(lobbies) do
		if !(v) then return false end
		local lobbyGameInfo = v:GetGameInfo()
	
		if !(lobbyGameInfo) then return false end
	
		local lobby = vgui.Create("DScrollPanel", lobbyList)
		lobby:Dock(TOP)
		lobby:DockMargin(5,5,5,5)
		lobby:GetCanvas():DockPadding(0,30,0,0)
		lobby:SetTall(150)
		lobby.Paint = function(self, w, h)
			--draw.RoundedBox(4, 0, 0, w, h, Color(35,35,35,255))
			draw.RoundedBox(4, 0, 0, w, 25, Color(55,55,55,255))
			
			draw.SimpleText( "Lobby #" .. k .. " (" .. (lobbyGameInfo.active && "In-game" || "Waiting") .. ")", "CS_SB_MD", 5, 2, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end
		
		-- [[Players]]
		local plys = v:GetPlayers()
		
		for i=1,#plys do
			local ply = plys[i]
			
			if (IsValid(ply)) then
				local player = vgui.Create("DPanel", lobby)
				player:Dock(TOP)
				player:DockMargin(0,0,0,5)
				player:SetTall(25)
				player.Paint = function(self, w, h)
					draw.RoundedBox(4, 0, 0, w, h, Color(35,35,35,255))
		
					draw.SimpleText( ply:Nick() .. (ply:IsInGame() && " (Side " .. (ply:GetSide() or "NIL") .. ")" || ""), "CS_SB_SM", 5, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
				end
			end
		end
	end
end

function SCOREBOARD:Remove()
	if !(self.sbFrame) then return false end
	
	self.sbFrame:Remove()
end

CitadelShock:RegisterScoreboard("cis_scoreboard", SCOREBOARD)