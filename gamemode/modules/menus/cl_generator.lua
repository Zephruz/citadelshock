--[[
	Citadel Shock
	- GENERATOR MENU -
]]

MENU = {}

function MENU:Init()
	local genEnt = LocalPlayer():GetEyeTrace().Entity

	if not (genEnt) then return false end
	if not (genEnt.IsGenerator) then return false end
	
	if (self.frame) then self.frame:Remove() end

	self.frame = vgui.Create("CSFrame")
	self.frame:SetSize(750, 500)
	self.frame:ShowCSCloseButton(true)
	self.frame:SetTitleInfo("Generator Menu")
	self.frame:Center()
	self.frame:MakePopup()
	
	self:GeneratorPanel(genEnt)
end

function MENU:GeneratorPanel(genEnt)
	if not IsValid(self.frame) then return false end
	
	self.generatorPanel = vgui.Create("DPanel", self.frame)
	self.generatorPanel:Dock(FILL)
	self.generatorPanel:SetWide(self.frame:GetWide())
	self.generatorPanel.Paint = function(pnl,w,h) end
	
	-- [[GENERATOR INFO]]
	local genInfo = vgui.Create( "DPanel", self.generatorPanel )
	genInfo:Dock(RIGHT)
	genInfo:DockMargin(5,5,5,5)
	genInfo:DockPadding(0,20,0,0)
	genInfo:SetWide(150)
	genInfo.Paint = function(pnl,w,h)
		if !(IsValid(genEnt)) then self.frame:Remove() return end
		draw.RoundedBoxEx( 4, 0, 0, w, h, Color(75,75,75,55), true, true, true, true)

		draw.RoundedBoxEx( 4, 0, 0, w, 20, Color(75,75,75,155), true, true, false, false)
		draw.SimpleText( "Generator Info", "CS_DERMA_MD", w/2, 11, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		
		draw.SimpleText( "Health: " .. genEnt:Health(), "CS_DERMA_LG", w/2, 25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		draw.SimpleText( "$" .. math.floor(genEnt:Health() * 0.1) .. "/" .. CitadelShock.Game.MoneyGenerationInts .. " seconds (" .. (genEnt.moneyGenerate - os.time() or 0) .. ")", "CS_DERMA_LG", w/2, 45, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	
	-- [[BOMBS]]
	local bombsList = vgui.Create( "CSScrollPanel", self.generatorPanel )
	bombsList:Dock(FILL)
	bombsList:DockMargin(5,5,5,5)
	bombsList:GetCanvas():DockPadding(0,35,0,0)
	bombsList.Paint = function(pnl,w,h)
		draw.RoundedBoxEx( 4, 0, 0, w, h, Color(75,75,75,55), true, true, true, true)

		draw.RoundedBoxEx( 4, 0, 0, w, 35, Color(75,75,75,155), true, true, false, false)
		draw.SimpleText( "Bombs", "CS_DERMA_MD", w/2, 11, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( "(Select a Bomb To Purchase)", "CS_DERMA_MD", w/2, 25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	
	for k,v in SortedPairs(CitadelShock.Game.Bombs, true) do
		local bombPanel = vgui.Create("CSButton", bombsList)
		bombPanel:Dock(TOP)
		bombPanel:SetTall(65)
		bombPanel:DockMargin(0,5,0,0)
		bombPanel:SetText("")
		bombPanel.Paint = function(pnl,w,h)
			local bgCol = Color(55,55,55,255)
			if (!pnl:IsHovered() && !pnl:GetDisabled()) then bgCol = Color(75,75,75,255) end
			draw.RoundedBoxEx( 4, 0, 0, w, h, bgCol, true, true, true, true)
			
			draw.SimpleText( v.BombName, "CS_DERMA_XLG", 70, 6, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP ) -- name
			
			-- [[Stats]]
			draw.SimpleText( "Radius: " .. v.BlastRadius, "CS_DERMA_LG", w - 5, 14, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Dmg Multiplier: " .. v.BlastDamageMultiplier, "CS_DERMA_LG", w - 5, 26, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Mass: " .. v.BombMass, "CS_DERMA_LG", w - 5, 38, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Timer: " .. v.ExplodeTime, "CS_DERMA_LG", w - 5, 50, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			
			-- [[Level]]
			if (v.reqLevel) then
				draw.SimpleText( "Required Level: " .. v.reqLevel, "CS_DERMA_MD", 70, 28, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			end
			
			-- [[Costs]]
			local str = ""
			for i,d in pairs(v.BombCost) do
				str = (str == "" && str || str .. ", ") .. d .. " " .. i
			end
			draw.SimpleText( "Required Resources: " .. str, "CS_DERMA_MD", 70, 45, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end
		bombPanel.DoClick = function()
			net.Start("CIS.Net.LobbyBuyBomb")
				net.WriteString(k)
			net.SendToServer()
		end
		
		-- if (LocalPlayer():GetLevel() < v.reqLevel) then bombPanel:SetDisabled(true) end
		
		local bombIcon = vgui.Create( "DModelPanel", bombPanel )
		bombIcon:SetSize(64,64)
		bombIcon:SetModel(v.Model)
		bombIcon:Dock(LEFT)
		bombIcon:SetCamPos( Vector( 50, 50, 15 ) )
		bombIcon:SetLookAt( Vector( 0, 0, 0 ) )
	end
end

CitadelShock:RegisterMenu("Menu_gen", MENU, "cis_gen")
