--[[
	Citadel Shock
	- MAIN MENU -
]]

MENU = {}

MENU.nav = {}
MENU.nav.default = "Welcome"
MENU.nav.buttons = {
	--[[
		Commands
	]]
	["Welcome"] = function(self)
		local pnl = vgui.Create("DScrollPanel", self.frame)
		pnl:Dock(FILL)
		pnl:DockMargin(5,self.frame:GetTall()*(45/450),self.frame:GetWide()*(50/600),self.frame:GetTall()*(45/450))
		pnl:GetCanvas():DockPadding(0,25,0,0)
		pnl.Paint = function(s,w,h) 
			draw.SimpleText( "Welcome to " .. GetHostName(), "CS_DERMA_TITLE", 5, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end
		
		local welcomeText = vgui.Create("DLabel",pnl)
		welcomeText:Dock(TOP)
		welcomeText:SetWrap(true)
		welcomeText:SetText(([[
			If you are new to CitadelShock, it is highly recommended to go through the tabs on the left.
			
			They will walk you through the basics of the gamemode so you can get started as soon as possible.
			
			Thank you for showing your interest in CitadelShock and we hope you enjoy your stay!
		]]))
		welcomeText:SetFont("CS_DERMA_LG")
		welcomeText:SetAutoStretchVertical(true)
		
		return pnl
	end,
	["Commands"] = function(self)
		if !(CitadelShock.CMDS) then return false end
		local pnl = vgui.Create("DScrollPanel", self.frame)
		pnl:Dock(FILL)
		pnl:DockMargin(5,self.frame:GetTall()*(45/450),self.frame:GetWide()*(50/600),self.frame:GetTall()*(45/450))
		pnl:GetCanvas():DockPadding(0,25,0,0)
		pnl.Paint = function(s,w,h) 
			draw.SimpleText( "Chat and Console Commands", "CS_DERMA_TITLE", 5, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end
		
		local function fetchCommands(search)
			for k,v in SortedPairs(CitadelShock.CMDS) do
				if (v.desc && k:find(search:GetValue())) then
					local cmd = vgui.Create("DButton", pnl)
					cmd:Dock(TOP)
					cmd:DockMargin(0,5,0,0)
					cmd:SetTall(30)
					cmd:SetText("")
					cmd.Paint = function(s,w,h)
						draw.RoundedBoxEx( 4, 0, 0, w, h, Color(35,35,35,185), true, true, true, true)
						draw.SimpleText( k, "CS_DERMA_LG", 5, h/2, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
						draw.SimpleText( v.desc, "CS_DERMA_MD", w-5, h/2, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
					end
					cmd.DoClick = function() RunConsoleCommand(k) end
				end
			end
		end

		local function createSearchBar()
			local search = vgui.Create("CSTextEntry", pnl)
			search:Dock(TOP)
			search:SetTall(25)
			search:SetInfoText("Search commands")
			search.OnEnter = function(self)
				pnl:Clear()
				createSearchBar()
				fetchCommands(self)
			end
			
			return search
		end
		
		local search = createSearchBar()
	
		fetchCommands(search)
		
		return pnl
	end,
	
	--[[
		How To Play
	]]
	["How To Play"] = function(self)
		local pnl = vgui.Create("CSScrollPanel", self.frame)
		pnl:Dock(FILL)
		pnl:DockMargin(5,self.frame:GetTall()*(45/450),self.frame:GetWide()*(50/600),self.frame:GetTall()*(45/450))
		pnl:GetCanvas():DockPadding(0,25,0,0)
		pnl.Paint = function(s,w,h) 
			draw.SimpleText( "How To Play", "CS_DERMA_TITLE", 5, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end
		
		-- [[Lobbies]]
		local lobbies = vgui.Create("DPanel", pnl)
		lobbies:Dock(TOP)
		lobbies:DockMargin(0,5,0,0)
		lobbies:DockPadding(0,25,0,0)
		lobbies:SetTall(125)
		lobbies.Paint = function(s,w,h) 
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color(35,35,35,255), true, true, true, true)
			draw.SimpleText( "Lobbies", "CS_DERMA_LG", 5, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end

		local lobbyTextPnl = vgui.Create("CSScrollPanel",lobbies)
		lobbyTextPnl:Dock(FILL)
		lobbyTextPnl:DockMargin(5,0,5,5)		

		local lobbiesText = vgui.Create("DLabel",lobbyTextPnl)
		lobbiesText:Dock(TOP)
		lobbiesText:SetWrap(true)
		lobbiesText:SetText(([[
			Lobbies are used for multiple on-going games.
			To join or open a new lobby, type !lobbies in chat.
			Type !ready in chat or ready on the lobby menu to signal you are ready to play.
			
			Once the lobby is full or all players are ready, the game will start.
		]]))
		lobbiesText:SetFont("CS_DERMA_LG")
		lobbiesText:SetAutoStretchVertical(true)
		
		-- [[Phases]]
		local phases = vgui.Create("CSScrollPanel", pnl)
		phases:Dock(TOP)
		phases:DockMargin(0,5,0,0)
		phases:GetCanvas():DockPadding(0,25,0,0)
		phases:SetTall(300)
		phases.Paint = function(s,w,h) 
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color(35,35,35,255), true, true, true, true)
			draw.SimpleText( "Phases", "CS_DERMA_LG", 5, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end

		local phasesInfo = vgui.Create("DLabel", phases)
		phasesInfo:Dock(TOP)
		phasesInfo:DockMargin(5,0,5,5)
		phasesInfo:SetWrap(true)
		phasesInfo:SetText([[
			Phases are what makes up a game. There are multiple phases that make up a game.
			
			Some phases you can only build in, some you can only fight in.
			
			Below is a list of the active phases.
		]])
		phasesInfo:SetFont("CS_DERMA_LG")
		phasesInfo:SetAutoStretchVertical(true)
		phasesInfo.Paint = function(s,w,h)
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color(35,35,35,255), true, true, true, true)
		end
		
		-- [[Phases]]
		
		if (CitadelShock.Game.Phases) then
			for k,v in SortedPairs(CitadelShock.Game.Phases, false) do
				local phasePanel = vgui.Create("DPanel", phases)
				phasePanel:Dock(TOP)
				phasePanel:DockMargin(5,0,5,5)
				phasePanel:DockPadding(0,25,0,0)
				phasePanel:SetTall(125)
				phasePanel.Paint = function(s,w,h) 
					draw.SimpleText( v.name .. " Phase", "CS_DERMA_LG", 5, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
				end
				
				if (v.ui.icon) then
					local phaseIcon = vgui.Create("DImage", phasePanel)
					phaseIcon:Dock(LEFT)
					phaseIcon:DockMargin(5,0,5,5)
					phaseIcon:SetSize(64,64)
					phaseIcon:SetImage( v.ui.icon )
					
					if (v.ui.color) then
						phaseIcon:SetImageColor(v.ui.color)
					end
				end
				
				local phaseDesc = vgui.Create("DLabel", phasePanel)
				phaseDesc:Dock(FILL)
				phaseDesc:SetWrap(true)
				phaseDesc:SetText([[
					This stage is ]] .. (string.FormattedTime(v.timeLimit, "%02im %02is")) .. [[ long.
					
					Building is ]] .. (v.canBuild && "allowed" || "not allowed") .. [[ during this phase.
					
					Fighting is ]] .. (v.canFight && "allowed" || "not allowed") .. [[ during this phase.
				]])
				phaseDesc:SetFont("CS_DERMA_LG")
				phaseDesc:SetAutoStretchVertical(true)
			end
		end
		
		-- [[Weapons]]
		local wepList = {
			["Shockwave Gun"] = {
				model = "models/zerochain/props_mystic/shockwavegun.mdl",
				htmldesc = [[
				The Shockwave Gun is used to launch bombs and harvest resources. This will be one of the main tools/weapons you use during the game.
				
				Left clicking will create a shockwave where you're aiming. The shockwave will launch bombs in the general direction you are aiming in.
				
				Right clicking will harvest resources. You must be aiming at a harvestable resource for this to work.
				]],
			},
			["Shockwave Builder"] = {
				model = "models/zerochain/props_mystic/hammer.mdl",
				htmldesc = [[The Shockwave Builder is used to build structures for protection.
			
				Left clicking will place the selected structure. Make sure you have the required resources and level. 
				
				Right click will cycle through the structures and their types. 
				
				Reload will rotate the current structure.
				]],
			},
		}
		
		local weapons = vgui.Create("CSScrollPanel", pnl)
		weapons:Dock(TOP)
		weapons:DockMargin(0,5,0,0)
		weapons:GetCanvas():DockPadding(0,25,0,0)
		weapons:SetTall(450)
		weapons.Paint = function(s,w,h) 
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color(35,35,35,255), true, true, true, true)
			draw.SimpleText( "Weapons", "CS_DERMA_LG", 5, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end
		
		for k,v in pairs(wepList) do
			local wep = vgui.Create("DPanel",weapons)
			wep:Dock(TOP)
			wep:DockPadding(5,5,5,5)
			wep:SetTall(200)
			wep.Paint = function(s,w,h) 
				draw.RoundedBoxEx( 4, 0, 0, w, h, Color(35,35,35,255), true, true, true, true)
				draw.SimpleText( k, "CS_DERMA_MD", 5, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			end
			
			local wepModel = vgui.Create("ModelImage",wep)
			wepModel:Dock(LEFT)
			wepModel:SetSize(128,128)
			wepModel:SetModel(v.model)
			wepModel:DockMargin(5,0,5,5)
			
			local wepTextPnl = vgui.Create("CSScrollPanel",wep)
			wepTextPnl:Dock(FILL)
			wepTextPnl:DockMargin(5,0,5,5)		

			local wepDesc = vgui.Create("DLabel",wepTextPnl)
			wepDesc:Dock(TOP)
			wepDesc:SetWrap(true)
			wepDesc:SetText(v.htmldesc)
			wepDesc:SetFont("CS_DERMA_LG")
			wepDesc:SetAutoStretchVertical(true)
		end
		
		-- [[Generator]]
		local generator = vgui.Create("DPanel", pnl)
		generator:Dock(TOP)
		generator:DockMargin(0,5,0,0)
		generator:DockPadding(0,25,0,0)
		generator:SetTall(150)
		generator.Paint = function(s,w,h) 
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color(35,35,35,255), true, true, true, true)
			draw.SimpleText( "Generator", "CS_DERMA_LG", 5, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end
		
		local generatorModel = vgui.Create("DModelPanel", generator)
		generatorModel:Dock(LEFT)
		generatorModel:DockMargin(5,0,5,5)
		generatorModel:SetModel("models/zerochain/props_mystic/magicgenerator.mdl")
		generatorModel:SetFOV(35)
		generatorModel:SetLookAt(Vector(0,0,60))
		generatorModel:SetCamPos(Vector(50,150,100))
		
		local generatorTextPnl = vgui.Create("CSScrollPanel",generator)
		generatorTextPnl:Dock(FILL)
		generatorTextPnl:DockMargin(5,0,5,5)
		
		local generatorText = vgui.Create("DLabel",generatorTextPnl)
		generatorText:Dock(TOP)
		generatorText:SetWrap(true)
		generatorText:SetFont("CS_DERMA_LG")
		generatorText:SetText([[
			Throughout the entire game you will be required to protect your teams generator.
			
			For protection, you will use structures to build around your generator.
			
			Your generator also serves another purpose and that's spawning bombs.
			You can buy bombs from it - for a cost - to use to destroy the other teams generator.
			
			Once you or the opposing teams generator is destroyed - the game will end (or if you guys run out of time).
		]])
		generatorText:SetAutoStretchVertical(true)
		
		-- [[Structures]]
		local structures = vgui.Create("DPanel", pnl)
		structures:Dock(TOP)
		structures:DockMargin(0,5,0,0)
		structures:DockPadding(0,25,0,0)
		structures:SetTall(125)
		structures.Paint = function(s,w,h) 
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color(35,35,35,255), true, true, true, true)
			draw.SimpleText( "Structures", "CS_DERMA_LG", 5, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end
		
		local structureModel = vgui.Create("DModelPanel", structures)
		structureModel:Dock(LEFT)
		structureModel:DockMargin(5,0,5,5)
		structureModel:SetModel("models/zerochain/props_structure/wood_foundation.mdl")
		--structureModel:SetFOV(35)
		structureModel:SetLookAt(Vector(0,0,0))
		structureModel:SetCamPos(Vector(50,70,60))
		
		local structureTextPnl = vgui.Create("CSScrollPanel",structures)
		structureTextPnl:Dock(FILL)
		structureTextPnl:DockMargin(5,0,5,5)
		
		local structureText = vgui.Create("DLabel",structureTextPnl)
		structureText:Dock(TOP)
		structureText:SetWrap(true)
		structureText:SetFont("CS_DERMA_LG")
		structureText:SetText([[
			Your generator needs to be protected, so you have the ability to utilize structures.
			
			There's multiple types of structures for you to select from such as: foundations, walls, beams, stairs, and roofs.
			There is also multiple types of materials that can a be used to build these structures such as: wood, stone, and metal.
			
			Structures can be repaired (by pressing 'E' or your use button on them).
			
			Once a structure is destroyed, your generator is vulnerable. So make sure to keep them repaired.
		]])
		structureText:SetAutoStretchVertical(true)
		
		return pnl
	end,
	
	--[[
		About CitadelShock
	]]
	["About CitadelShock"] = function(self)
		local aboutHTML = [[
		<head></head>
		<body style="color:#FFF;font-family:sans-serif;font-size:85%;">
			<p>
				<img src="https://media.discordapp.net/attachments/329322070515122197/341334967298555904/logo.png" style="width:100%;height:85px;">
				</br>
				</br>
				CitadelShock is a gamemode that was submitted in the 2017 GmodStore gamemode competition.
				</br>
				</br>
				Inspired by the game Shockwave Battle (Clonk). You compete against another team, protecting your generator. 
				Your generator is important, as it allows you to buy bombs and other useful things.
				You can protect your generator by building around it; using foundations, walls, beams, stairs, and other structures.
				While protecting your own generator, you must destroy the other teams. To inflict damage on the enemy
				generator, you <b>must</b> use bombs/projectiles. These are obtainable from the generator.
				The first team to destroy the others generator is the winner, if no generators are destroyed, the team
				with the most remaining generator health wins.
				</br>
				</br>
				This is a strategic-teamwork game and you must work with your teammates to be successful.
				</br>
				</br>
				Thanks for playing CitadelShock,</br>
				Best of luck!
				</br>
				</br>
				<b>Creators/Developers:</b></br>
				Zephruz - Developer</br>
				ZeroChain - 3D Artist/(Entity) Developer</br>
				</br>
				<b>Contributors & Bug testers:</b></br>
				Sir Thomas - Graphics Artist/Bug Tester</br>
			</p>
		</body>
		]]
	
		local pnl = vgui.Create("DPanel", self.frame)
		pnl:Dock(FILL)
		pnl:DockMargin(5,self.frame:GetTall()*(45/450),self.frame:GetWide()*(50/600),self.frame:GetTall()*(45/450))
		pnl:DockPadding(0,25,0,0)
		pnl.Paint = function(s,w,h) 
			draw.SimpleText( "About CitadelShock", "CS_DERMA_TITLE", 5, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end
		
		local about = vgui.Create("DHTML", pnl)
		about:Dock(FILL)
		about:SetHTML(aboutHTML)
		about:SetAllowLua( true )
		
		return pnl
	end,
}

function MENU:Init()
	if (self.frame) then self.frame:Remove() end

	self.frame = vgui.Create("CSFrame")
	self.frame:SetSize(750, 600)
	self.frame:ShowCSCloseButton(true)
	self.frame:SetTitleInfo("Main Menu")
	self.frame:Center()
	self.frame:MakePopup()
	
	self:NavBar()
end

function MENU:NavBar()
	local function openNavMenu(nvb, b)
		if (self.navBarPanel.active.button) then self.navBarPanel.active.button:SetDisabled(false) end
		if (self.navBarPanel.active.pnl) then self.navBarPanel.active.pnl:Remove() end
		
		self.navBarPanel.active.button = nvb
		self.navBarPanel.active.pnl = (b(self) or nil)
		
		nvb:SetDisabled(true)
	end

	self.navBarPanel = vgui.Create("CSScrollPanel", self.frame)
	self.navBarPanel:Dock(LEFT)
	self.navBarPanel:DockMargin(self.frame:GetWide()*(50/600),self.frame:GetTall()*(45/450),5,self.frame:GetTall()*(45/450))
	self.navBarPanel:SetWide(150)
	self.navBarPanel.active = {pnl = nil, button = nil}
	self.navBarPanel.Paint = function(self,w,h)
		draw.RoundedBoxEx( 4, 0, 0, w, h, Color(35,35,35,185), true, true, true, true)
	end
	
	for k,v in SortedPairs(self.nav.buttons, true) do
		local navButton = vgui.Create("CSButton",self.navBarPanel)
		navButton:SetBText(k)
		navButton:Dock(TOP)
		navButton:DockMargin(0,5,0,0)
		navButton:SetRounded(false)
		navButton.DoClick = function()
			openNavMenu(navButton, v)
		end
		
		if (k == self.nav.default) then
			openNavMenu(navButton, v)
		end
	end
end

CitadelShock:RegisterMenu("Menu_main", MENU, "mainmenu", "Opens the main menu")
