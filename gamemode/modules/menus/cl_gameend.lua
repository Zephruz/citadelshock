--[[
	Citadel Shock
	- GAME END/RESULT MENU -
]]

MENU = {}
local gameResults

function MENU:Init()
	if not (CitadelShock.Game.Results) then return false end
	
	if (self.frame) then self.frame:Remove() end
	
	self.frame = vgui.Create("CSFrame")
	self.frame:SetSize(450, 500)
	self.frame:ShowCSCloseButton(true)
	self.frame:SetTitleInfo("Game Results")
	self.frame:Center()
	self.frame:MakePopup()
	PrintTable(CitadelShock.Game.Results)
	self:GameResultPanel(CitadelShock.Game.Results)
	CitadelShock.Game.Results = false
end

function MENU:GameResultPanel(res)
	local res = res
	if not IsValid(self.frame) then return false end
	local plySide = (res.plyside or 0)
	
	self.gResPanel = vgui.Create("DPanel", self.frame)
	self.gResPanel:Dock(FILL)
	self.gResPanel:SetWide(self.frame:GetWide())
	self.gResPanel.Paint = function(pnl,w,h) end
	
	local infoContainer = vgui.Create("CSScrollPanel", self.gResPanel)
	infoContainer:Dock(FILL)
	infoContainer:DockMargin(5,5,5,5)
	infoContainer:GetCanvas():DockPadding(0,35,0,0)
	infoContainer.Paint = function(s,w,h) 
		local resText = (res.draw && "Draw/Tie Game" || res.sides[plySide].win && "Your side won!" || !res.sides[plySide].win && "Your side lost!" || "Invalid")
		local resColor = (res.draw && Color(204,204,204,255) || res.sides[plySide].win && Color(162,235,90,255) || !res.sides[plySide].win && Color(205,75,75,255) || Color(255,255,255,255))
		
		draw.SimpleText(resText, "CS_DERMA_XLG", w/2+2, 5+2, Color(35,35,35,125), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		draw.SimpleText(resText, "CS_DERMA_XLG", w/2, 5, resColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	
	-- [[Rewards]]
	local rewardPnl = vgui.Create("DPanel", infoContainer)
	rewardPnl:Dock(TOP)
	rewardPnl:DockMargin(0,0,0,5)
	rewardPnl:SetTall(60)
	rewardPnl.Paint = function(s,w,h)
		draw.RoundedBoxEx( 4, 0, 0, w, h, Color(75,75,75,55), true, true, true, true)
		
		draw.SimpleText("Rewards", "CS_DERMA_XLG", w/2, 5, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		
		-- [[Rewards]]
		local rewTbl = (res.draw && CitadelShock.Game.DrawRewards || res.sides[plySide].win && CitadelShock.Game.DrawRewards)
		
		local str = "None"
		if (rewTbl) then
			for k,v in pairs(rewTbl) do
				if (str == "None") then str = "" end
				str = (str == "" && str || str .. ", ") .. v .. " " .. k
			end
		end
		draw.SimpleText( str, "CS_DERMA_LG", w/2, 30, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	
	-- [[Side Results]]
	for k,v in SortedPairs(res.sides, false) do
		-- vars
		local maxGenHP = CitadelShock.Game.GeneratorHealth
		
		local sidePnl = vgui.Create("DPanel", infoContainer)
		sidePnl:Dock(TOP)
		sidePnl:DockMargin(0,0,0,5)
		sidePnl:SetTall(85)
		sidePnl.Paint = function(s,w,h)
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color(75,75,75,55), true, true, true, true)
		
			draw.SimpleText("Side " .. k .. (k == plySide && " (Your side)" || ""), "CS_DERMA_XLG", w/2, 5, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			
			-- Generator HP
			draw.RoundedBoxEx( 4, 5, 30, w-10, 20, Color(35,35,35,55), true, true, true, true)
			draw.RoundedBoxEx( 4, 7, 32, (w-14)*(v.genHP/maxGenHP), 16, Color(243,86,86,55), true, true, true, true)
			
			draw.SimpleText("Generator Health: " .. v.genHP .. "/" .. maxGenHP, "CS_DERMA_MD", w/2, 33, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		
			-- Team Win/Lose
			local resText = (res.draw && "Draw/Tie Game" || res.sides[k].win && "WINNER" || !res.sides[k].win && "LOSER" || "Invalid")
			local resColor = Color(255,255,255,255)
			
			draw.SimpleText(resText, "CS_DERMA_LG", w/2, h - 26, resColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		end
	end
end

CitadelShock:RegisterMenu("Menu_gameresults", MENU, "gameresult")