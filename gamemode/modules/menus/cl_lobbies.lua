--[[
	Citadel Shock
	- LOBBIES MENU -
]]

MENU = {}

local leavePenalty = CitadelShock.Game.LeavePenalty

function MENU:Init()
	if (LocalPlayer():IsInGame()) then 
		CitadelShock:ChatMessage([[You can't open the lobby menu in-game!
If you want to leave type !leavegame. You WILL be penalized!]])
		
		return false 
	end
	
	if (self.frame) then self.frame:Remove() end
	
	self.frame = vgui.Create("CSFrame")
	self.frame:SetSize(750, 500)
	self.frame:ShowCSCloseButton(true)
	self.frame:SetTitleInfo("Lobbies Menu")
	self.frame:Center()
	self.frame:MakePopup()

	self:LobbiesPanel()
end

function MENU:LobbiesPanel()
	if not IsValid(self.frame) then return false end
	
	self.lobbiesPanel = vgui.Create("DPanel", self.frame)
	self.lobbiesPanel:Dock(FILL)
	self.lobbiesPanel:SetWide(self.frame:GetWide())
	self.lobbiesPanel.Paint = function(pnl,w,h) end

	local lobbiesList = vgui.Create( "CSScrollPanel", self.lobbiesPanel )
	lobbiesList:Dock(FILL)
	lobbiesList:DockMargin(self.frame:GetWide()*(50/750),self.frame:GetTall()*(45/500),10,self.frame:GetTall()*(40/500))
	lobbiesList:GetCanvas():DockPadding(0,25,0,0)
	lobbiesList.Paint = function(pnl,w,h)
		--draw.RoundedBox( 4, 0, 0, w, 35, Color(75,75,75,155))
		draw.SimpleText( "Lobbies (" .. table.Count(CitadelShock.Lobby:GetAll()) .. "/" .. CitadelShock.Lobby.MaxLobbies .. ")", "CS_DERMA_LG", 5, 11, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( "(Click to join and/or view info)", "CS_DERMA_MD", w-5, 11, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	end

	self.lobbyInfo = vgui.Create("DPanel", self.frame)
	self.lobbyInfo:Dock(RIGHT)
	self.lobbyInfo:SetWide(250)
	self.lobbyInfo.Paint = function(pnl,w,h) end

	local lobbyInfoPanel = vgui.Create("DPanel", self.lobbyInfo)
	lobbyInfoPanel:Dock(FILL)
	lobbyInfoPanel:DockMargin(0,self.frame:GetTall()*(45/500),self.frame:GetWide()*(50/750),0)
	lobbyInfoPanel:DockPadding(0,20,0,0)
	lobbyInfoPanel.Paint = function(pnl,w,h)
		--draw.RoundedBoxEx( 4, 0, 0, w, h, Color(75,75,75,55), true, true, true, true)

		draw.RoundedBox( 4, 0, 0, w, 20, Color(75,75,75,155) )
		draw.SimpleText( "Selected Lobby Info", "CS_DERMA_MD", w/2, 10, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local createLobby = vgui.Create("CSButton", self.lobbyInfo)
	createLobby:Dock(BOTTOM)
	createLobby:DockMargin(0,5,self.frame:GetWide()*(50/750),self.frame:GetTall()*(45/500))
	createLobby:SetTall(25)
	createLobby:SetBText("Open New Lobby")
	createLobby.DoClick = function()
		local newLobby = DermaMenu()
		local lobbySize = newLobby:AddSubMenu( "Select Lobby Size" )
		
		for k,v in pairs(CitadelShock.Lobby.Sizes) do
			lobbySize:AddOption(k, function() CitadelShock.Lobby:Create(v) end)
		end

		newLobby:Open()
	end

	function LoadLobbies()
		local allLobbies = CitadelShock.Lobby:GetAll()
	
		if (table.Count(allLobbies) <= 0) then
			local noLobbiesPanel = vgui.Create("DPanel", lobbiesList)
			noLobbiesPanel:Dock(TOP)
			noLobbiesPanel:SetTall(20)
			noLobbiesPanel:DockMargin(0,5,0,0)			
			noLobbiesPanel.Paint = function(pnl,w,h)
				draw.RoundedBoxEx( 4, 0, 0, w, h, Color(45,45,45,255), true, true, true, true)
				draw.SimpleText( "No open lobbies! Create one by clicking 'open new lobby'!", "CS_DERMA_MD", w/2, h/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		end
	
		for k,v in pairs(allLobbies) do
			local gameInfo = v:GetGameInfo()
			
			local lobbyPanel = vgui.Create("DButton", lobbiesList)
			lobbyPanel:Dock(TOP)
			lobbyPanel:SetTall(20)
			lobbyPanel:DockMargin(0,5,0,0)
			lobbyPanel:SetText("")
			lobbyPanel.Paint = function(pnl,w,h)
				local bgCol = Color(35,35,35,255)
				if not (pnl:IsEnabled()) then
					bgCol = Color(50,50,50,255)
				end
				draw.RoundedBoxEx( 4, 0, 0, w, h, bgCol, true, true, true, true)
				draw.SimpleText( "Lobby " .. k .. " (" .. (gameInfo.active && "In-Game" || "Waiting") .. ")", "CS_DERMA_LG", 5, h/2, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( v.size/2 .. " vs " .. v.size/2, "CS_DERMA_LG", w/2, h/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( "Players: " .. (table.Count(v:GetPlayers())) .. "/" .. v.size, "CS_DERMA_LG", w - 5, h/2, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			end
			lobbyPanel.DoClick = function()
				for i,d in pairs(lobbiesList:GetCanvas():GetChildren()) do
					if not (d:IsEnabled()) then d:SetEnabled(true) end
				end
				lobbyPanel:SetEnabled(false)
				lobbyInfoPanel:Clear()

				local readyMat = Material("icon16/accept.png")
				local notReadyMat = Material("icon16/exclamation.png")

				for _,ply in pairs(player.GetAll()) do
					if (ply:GetIDLobby() == k && IsValid(ply)) then
						local player = vgui.Create("DPanel", lobbyInfoPanel)
						player:Dock(TOP)
						player:SetTall(15)
						player:DockMargin(0,5,0,0)
						player.Paint = function(pnl,w,h)
							if not (IsValid(ply)) then pnl:Remove() return false end
							draw.RoundedBoxEx( 4, 0, 0, w, h, Color(35,35,35,255), true, true, true, true)
							draw.SimpleText(ply:Nick(), "CS_DERMA_LG", 5, h/2, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
							draw.SimpleText((ply:GetReady() && "Ready" || "Not Ready"), "CS_DERMA_LG", w - 20, h/2, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

							surface.SetDrawColor( 255, 255, 255, 255 )
							surface.SetMaterial( (ply:GetReady() && readyMat || notReadyMat)	)
							surface.DrawTexturedRect( w - 16, 1, 13, 13 )
						end
					end
				end

				local joinLobby = vgui.Create("CSButton", lobbyInfoPanel)
				joinLobby:Dock(BOTTOM)
				joinLobby:SetTall(20)
				joinLobby:DockMargin(5,5,5,5)
				joinLobby:SetBText("Join Lobby")
				joinLobby.DoClick = function()
					LocalPlayer():JoinLobby(k)
					updLobby()
				end
					
				-- Current lobby buttons
				if (LocalPlayer():GetIDLobby() == k) then
					joinLobby:SetBText("Leave Lobby")
					joinLobby.DoClick = function()
						LocalPlayer():LeaveLobby()
						updLobby()
					end

					local isReady = vgui.Create("CSButton", lobbyInfoPanel)
					isReady:Dock(BOTTOM)
					isReady:SetTall(20)
					isReady:DockMargin(5,5,5,5)
					isReady:SetBText("Ready")
					isReady.DoClick = function()
						LocalPlayer():SetReady(true)
						updLobby()
					end
					if (LocalPlayer():GetReady()) then
						isReady:SetBText("Not Ready")
						isReady.DoClick = function()
							LocalPlayer():SetReady(false)
							updLobby()
						end
					end
				elseif (v:GetGameInfo().active) then
					joinLobby:Remove()
						
					local spectateLobby = vgui.Create("CSButton", lobbyInfoPanel)
					spectateLobby:Dock(BOTTOM)
					spectateLobby:SetTall(20)
					spectateLobby:DockMargin(5,5,5,5)
					spectateLobby:SetBText("Spectate Game")
					spectateLobby.DoClick = function()
						v:Spectate()
					end
				end
			end
		end
	end

	function updLobby()
		if not IsValid(lobbiesList) then hook.Remove("CITSH_LMREF") return false end
		if (LocalPlayer():IsInGame()) then self.frame:Remove() return false end

		lobbiesList:Clear()
		lobbyInfoPanel:Clear()
		LoadLobbies()
	end
	hook.Add("CIT.Hook.LobbiesUpdated", "CITSH_LMREF", updLobby)

	LoadLobbies()
end

CitadelShock:RegisterMenu("Menu_lobbies", MENU, "lobbies", "Opens lobbies menu")
