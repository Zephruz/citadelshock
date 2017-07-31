-- [[HUD 1]]
local HUD = {}

-- [[Variables]]
HUD.Variables = {}
HUD.Variables.size = {350, 100, 3, 0} -- w, h, left & bottom margin, top margin
HUD.Variables.materials = {
	bg = Material("materials/citadelshock/hud/cis_ui_player_bg_2.png", "noclamp smooth nocull"), -- background material
	cbg = Material("materials/citadelshock/hud/cis_ui_player_bg_1.png", "noclamp smooth nocull"), -- clean background material
	pb = Material("materials/citadelshock/hud/cis_ui_player_fg.png", "noclamp smooth"), -- progressbar material
	ammo = Material("materials/citadelshock/hud/ammo_hud.png", "noclamp smooth"), -- ammo hud material
	ws = Material("materials/citadelshock/hud/weapon_switch_menu.png", "noclamp smooth"), -- weapon switch hud material
}

timer.Simple(1,
function()
-- [[Compile phase materials]]
for i=1,#CitadelShock.Game.Phases do
	local phs = CitadelShock.Game.Phases[i]
	if (phs && phs.ui.icon) then
		HUD.Variables.materials[(phs.name || "phase_" .. tostring(i))] = Material(phs.ui.icon, "noclamp smooth")
	end
end
end)

-- [[Background]]
HUD.Background = function() -- Draws the HUD background
	local bl_w, bl_h, b_margin, bt_margin = unpack(HUD.Variables.size)
	local base_x, base_y = b_margin, ScrH() - (bl_h + b_margin)

	surface.SetDrawColor( 40, 40, 40, 255 )
	surface.SetMaterial( HUD.Variables.materials.bg	)
	surface.DrawTexturedRect( base_x + 3, base_y + 4, bl_w - 6, bl_h - 8 )
end

-- [[Elements]]

--[[
	Global HUD elements
]]
HUD.Elements = {}
HUD.Elements.Base = {
draw = function() -- Base HUD elements - Creates the players name and XP bar not dependent on the players active status
	local bl_w, bl_h, b_margin, bt_margin = unpack(HUD.Variables.size)
	local base_x, base_y = b_margin, ScrH() - (bl_h + b_margin)
	base_y = base_y + bt_margin

	-- [[Player Nick]]
	draw.SimpleText( LocalPlayer():Nick(), "CS_HUD_MD", base_x + 42, base_y + 24, Color(25,25,25,115), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( LocalPlayer():Nick(), "CS_HUD_MD", base_x + 40, base_y + 22, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	-- [[Player Points]]
	draw.SimpleText( LocalPlayer():GetPoints() .. " Points", "CS_HUD_SM", base_x + (bl_w - 36), base_y + 36, Color(25,25,25,115), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	draw.SimpleText( LocalPlayer():GetPoints() .. " Points", "CS_HUD_SM", base_x + (bl_w - 34), base_y + 34, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )

	-- [[Player Level]]
	local xpPerc = math.Clamp(LocalPlayer():GetEXP() / LocalPlayer():ToLevelEXP(), 0, 1)
	local xpBar_w, xpBar_h = (bl_w - 86) * xpPerc, 5
	local xpBar_y = 55

	draw.RoundedBox(0, base_x + 41, base_y + (xpBar_y) + 10, bl_w - 85, xpBar_h, Color(66,66,66,255))
	draw.RoundedBox(0, base_x + 41, base_y + (xpBar_y) + 10, xpBar_w, xpBar_h, Color(184,154,11,255))

	surface.SetDrawColor( 40, 40, 40, 255 )
	surface.SetMaterial( HUD.Variables.materials.pb	)
	surface.DrawTexturedRectUV( base_x + 40, base_y + (xpBar_y) + 10, bl_w - 84, xpBar_h, 0, 0, 1, 1)

	draw.SimpleText( "level: " .. LocalPlayer():GetLevel(), "CS_HUD_XSM", base_x + 48, base_y + (xpBar_y), Color(25,25,25,115), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( "level: " .. LocalPlayer():GetLevel(), "CS_HUD_XSM", base_x + 46, base_y + (xpBar_y - 1), Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	draw.SimpleText( LocalPlayer():GetEXP() .. "/" .. LocalPlayer():ToLevelEXP() .. " xp", "CS_HUD_XSM", base_x + (bl_w - 52), base_y + (xpBar_y), Color(25,25,25,115), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	draw.SimpleText( LocalPlayer():GetEXP() .. "/" .. LocalPlayer():ToLevelEXP() .. " xp", "CS_HUD_XSM", base_x + (bl_w - 50), base_y + (xpBar_y - 1), Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
end}

HUD.Elements.WeaponSelection = {
draw = function()
	if not (CitadelShock.HUD.WeaponHUD.active) then return false end
	if (CitadelShock.HUD.WeaponHUD.timeleft <= 0) then CitadelShock.HUD.WeaponHUD.active = false CitadelShock.HUD.WeaponHUD.timeleft = 0 return false end
	CitadelShock.HUD.WeaponHUD.timeleft = CitadelShock.HUD.WeaponHUD.timeleft - 1

	local base_x, base_y = ScrW()/2, 10
	local col_W, col_H = 140, 25
	local wep_W, wep_H = col_W, col_H
	local weapons = CitadelShock.HUD.WeaponHUD.weapons
	local maxCols = CitadelShock.HUD.WeaponHUD.maxcols
	local numCols = math.Clamp(#weapons, 0, maxCols)
	local split = numCols/2
	local columns = {}
	local nextCol = 1

	for cols=1,numCols do table.insert(columns, {}) end
	
	for id,wep in SortedPairs(weapons, true) do
		if !(wep) then return false end
		table.insert(columns[nextCol], wep)
		if (nextCol >= maxCols) then
			nextCol = 1
		else
			nextCol = nextCol + 1
		end
	end

	for k,v in pairs(columns) do
		local col_x = -(col_W*split)
		col_x = col_x + (col_W*(k-1))

		surface.SetDrawColor( 40, 40, 40, 255 )
		surface.SetMaterial( HUD.Variables.materials.cbg	)
		surface.DrawTexturedRect( base_x + col_x, base_y, col_W, col_H )

		draw.SimpleText( k, "CS_HUD_SM", base_x + (col_x + col_W/2), base_y + 1, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

		for _,weps in pairs(v) do
			if (IsValid(weps) && IsValid(LocalPlayer():GetActiveWeapon())) then
				wep_W, wep_H = col_W, 25
				wep_Y = _*25
				wepR, wepG, wepB, wepA = 40, 40, 40, 255
				if (weps:GetClass() == LocalPlayer():GetActiveWeapon():GetClass()) then
					wepR, wepG, wepB, wepA = 65, 65, 65, 255
				end

				surface.SetDrawColor( wepR, wepG, wepB, wepA )
				surface.SetMaterial( HUD.Variables.materials.cbg	)
				surface.DrawTexturedRect( base_x + col_x, base_y + (wep_Y), wep_W, wep_H )

				draw.SimpleText( weps:GetPrintName(), "CS_HUD_XXSM", base_x + (col_x + col_W/2), base_y + (wep_Y+5), Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			end
		end
	end
end}

HUD.Elements.AmmoHUD = {
draw = function()
	local bl_w, bl_h, b_margin, bt_margin = 140, 80, 3
	local base_x, base_y = ScrW() - (bl_w + b_margin), ScrH() - (bl_h + b_margin)
	local weapon = LocalPlayer():GetActiveWeapon()
	if (!LocalPlayer():Alive()) then return false end
	if (!weapon) then return false end
	if (not weapon.GetPrimaryAmmoType or weapon:GetPrimaryAmmoType() == -1) then return false end

	local primAmmo_clip, primAmmo_res = weapon:Clip1(), LocalPlayer():GetAmmoCount(weapon:GetPrimaryAmmoType())

	surface.SetDrawColor( 40, 40, 40, 255 )
	surface.SetMaterial( HUD.Variables.materials.ammo	)
	surface.DrawTexturedRect( base_x, base_y, bl_w, bl_h )

	-- [[Ammo]]
	draw.SimpleText( weapon:GetPrintName(), "CS_HUD_SM", base_x + (bl_w) - 12, base_y + 4, Color(25,25,25,115), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( weapon:GetPrintName(), "CS_HUD_SM", base_x + (bl_w) - 14, base_y + 2, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

	-- [[Ammo]]
	draw.SimpleText( primAmmo_clip, "CS_HUD_LG", base_x + 102, base_y + 12, Color(25,25,25,115), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	draw.SimpleText( primAmmo_clip, "CS_HUD_LG", base_x + 100, base_y + 10, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )

	surface.SetDrawColor(55,55,55,255)
	surface.DrawLine( base_x + 30, base_y + 40, base_x + 110, base_y + 40 )

	draw.SimpleText( primAmmo_res, "CS_HUD_LG", base_x + 102, base_y + 42, Color(25,25,25,115), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	draw.SimpleText( primAmmo_res, "CS_HUD_LG", base_x + 100, base_y + 40, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
end}

--[[
	Lobby HUD elements
]]
local readyMat = Material("icon16/accept.png")
local notReadyMat = Material("icon16/exclamation.png")

HUD.Elements.Lobby = {
status = {0},
draw = function() -- Lobby HUD element - Creates elements that display players information while lobbied
	HUD.Variables.size = {350, 100, 3, 0}

	local bl_w, bl_h, b_margin, bt_margin = unpack(HUD.Variables.size)
	local base_x, base_y = b_margin, ScrH() - (bl_h + b_margin)
	base_y = base_y + bt_margin
	
	-- [[Current Lobby Info]]
	if (LocalPlayer():IsInLobby()) then
		local lobby = CitadelShock.Lobby.lobbies[LocalPlayer():GetIDLobby()]
		local baseL_W, baseL_H = 350, 350
		local baseL_X, baseL_Y = ScrW() - (baseL_W+10), 0
		surface.SetDrawColor( 40, 40, 40, 255 )
		surface.SetMaterial( HUD.Variables.materials.cbg	)
		surface.DrawTexturedRectUV( baseL_X, baseL_Y, baseL_W, baseL_H, 1, 0, 0, 1)

		draw.SimpleText("Current Lobby", "CS_HUD_LG", baseL_X + baseL_W/2, baseL_Y + 30, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		local currentPlyY = 60
		for k,v in pairs(lobby:GetPlayers()) do
			draw.RoundedBox(4, baseL_X + 20, baseL_Y + currentPlyY, baseL_W - 40, 20, Color(35,35,35,255))
			draw.SimpleText(v:Nick() .. " (Lvl " .. (v:GetLevel() || 0) .. ")", "CS_HUD_XSM", baseL_X + 25, baseL_Y + currentPlyY + 2, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

			draw.SimpleText((v:GetReady() && "Ready" || "Not Ready"), "CS_HUD_XXSM", baseL_X + (baseL_W - 45), baseL_Y + currentPlyY + 3, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( (v:GetReady() && readyMat || notReadyMat)	)
			surface.DrawTexturedRect( baseL_X + (baseL_W - 40), baseL_Y + currentPlyY + 2, 16, 16 )

			currentPlyY = currentPlyY + 25
		end

		draw.SimpleText("Game will start when all players are ready or lobby is full", "CS_HUD_XXSM", baseL_X + baseL_W/2, baseL_Y + baseL_H - 50, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end}

--[[
	In-game/Active game HUD elements
]]
HUD.Elements.ActiveGame = {
status = {1},
draw = function() -- Active Game HUD element - Creates elements that display players information while in a game
	HUD.Variables.size = {350, 200, 3, 35}

	local bl_w, bl_h, b_margin, bt_margin = unpack(HUD.Variables.size)
	local base_x, base_y = b_margin, ScrH() - (bl_h + b_margin)
	base_y = base_y + bt_margin

	-- [[Player Health]]
	local hpPerc = math.Clamp(LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0, 1)
	local hpBar_w, hpBar_h = (bl_w - 86) * hpPerc, 5
	local hpBar_y = 75

	draw.RoundedBox(0, base_x + 41, base_y + (hpBar_y) + 10, bl_w - 85, hpBar_h, Color(66,66,66,255))
	draw.RoundedBox(0, base_x + 41, base_y + (hpBar_y) + 10, hpBar_w, hpBar_h, Color(255,66,66,255))

	surface.SetDrawColor( 40, 40, 40, 255 )
	surface.SetMaterial( HUD.Variables.materials.pb	)
	surface.DrawTexturedRectUV( base_x + 40, base_y + (hpBar_y) + 10, bl_w - 84, hpBar_h, 1, 0, 0, 1)

	draw.SimpleText( "health", "CS_HUD_XSM", base_x + 48, base_y + (hpBar_y), Color(25,25,25,115), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( "health", "CS_HUD_XSM", base_x + 46, base_y + (hpBar_y - 1), Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	draw.SimpleText( LocalPlayer():Health(), "CS_HUD_XSM", base_x + (bl_w - 52), base_y + (hpBar_y), Color(25,25,25,115), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	draw.SimpleText( LocalPlayer():Health(), "CS_HUD_XSM", base_x + (bl_w - 50), base_y + (hpBar_y - 1), Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )

	-- [[Player Armor]]
	local amPerc = math.Clamp(LocalPlayer():Armor() / 100, 0, 1)
	local amBar_w, amBar_h = (bl_w - 85) * amPerc, 5
	local amBar_y = 95

	draw.RoundedBox(0, base_x + 41, base_y + (amBar_y) + 10, bl_w - 85, amBar_h, Color(66,66,66,255))
	draw.RoundedBox(0, base_x + 41, base_y + (amBar_y) + 10, amBar_w, amBar_h, Color(45,95,255,255))

	surface.SetDrawColor( 40, 40, 40, 255 )
	surface.SetMaterial( HUD.Variables.materials.pb	)
	surface.DrawTexturedRectUV( base_x + 40, base_y + (amBar_y) + 10, bl_w - 84, amBar_h, 0, 0, 1, 1)

	draw.SimpleText( "armor", "CS_HUD_XSM", base_x + 48, base_y + (amBar_y), Color(25,25,25,115), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( "armor", "CS_HUD_XSM", base_x + 46, base_y + (amBar_y - 1), Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

	draw.SimpleText( LocalPlayer():Armor(), "CS_HUD_XSM", base_x + (bl_w - 52), base_y + (amBar_y), Color(25,25,25,115), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	draw.SimpleText( LocalPlayer():Armor(), "CS_HUD_XSM", base_x + (bl_w - 50), base_y + (amBar_y - 1), Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
end}

HUD.Elements.Timer = {
status = {1,2},
draw = function()
    if not (LocalPlayer():IsInLobby()) then return false end
    if not (LocalPlayer():IsInGame()) then return false end
    local lobby = CitadelShock.Lobby:FindByID(LocalPlayer():GetIDLobby())
    local gameInfo = lobby:GetGameInfo()
    local gameSides = lobby:GetGameSides()
	local curPhase = lobby:GetCurrentPhase()
	local curPhaseInfo = CShockGame_GetPhases(gameInfo.currentPhase)
	
	local rawTimeLeft = (curPhase.endtime-os.time())
    local timeleft = string.FormattedTime(rawTimeLeft, "%02im %02is")
	local baseX, baseY = ScrW(), 30
 
	--[[TIMER]]
	local tBarCalc = (rawTimeLeft/curPhaseInfo.timeLimit)
	
	local barW, barH = 200, 30
	draw.RoundedBox(4, baseX - barW, baseY, barW, barH, Color(45,45,45,205)) -- BG
	
	draw.RoundedBox(4, baseX - barW, baseY, barW*tBarCalc, barH, (curPhaseInfo.ui.color || Color(255,125,55,255))) -- Timer Bar
	
	-- icon
	local iconSize = 64
	
	if (HUD.Variables.materials[curPhaseInfo.name]) then
		surface.SetDrawColor( 45, 45, 45, 165 )
		surface.SetMaterial( (HUD.Variables.materials[curPhaseInfo.name]) )
		surface.DrawTexturedRectUV( ScrW() - (barW+iconSize+6) + 3, baseY-(iconSize*0.25) + 1, iconSize, iconSize, 1, 0, 0, 1)
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( (HUD.Variables.materials[curPhaseInfo.name]) )
		surface.DrawTexturedRectUV( ScrW() - (barW+iconSize+6), baseY-(iconSize*0.25), iconSize, iconSize, 1, 0, 0, 1)
	end
		
	draw.SimpleText( (curPhaseInfo.name || ""), "CS_HUD_SM", ScrW()-(barW)+6, baseY + barH/2 + 1, Color(55,55,55,175), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText( (curPhaseInfo.name || ""), "CS_HUD_SM", ScrW()-(barW)+4, baseY + barH/2, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	
    draw.SimpleText( timeleft, "CS_HUD_MD", ScrW()-2, baseY + barH/2 + 1, Color(55,55,55,175), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    draw.SimpleText( timeleft, "CS_HUD_MD", ScrW()-4, baseY + barH/2 - 1, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
end}

HUD.Elements.TeamData = {
status = {1,2},
draw = function()
	if not (LocalPlayer():IsInLobby()) then return false end
	if not (LocalPlayer():IsInGame()) then return false end
	local lobby = CitadelShock.Lobby:FindByID(LocalPlayer():GetIDLobby())
	local gameInfo = lobby:GetGameInfo()
	local gameSides = lobby:GetGameSides()
	
	local bl_w, bl_h, b_margin, bt_margin = unpack(HUD.Variables.size)
	local base_x, base_y = b_margin, ScrH() - (bl_h + b_margin)
	base_y = base_y + bt_margin

	local baseL_W, baseL_H = 250, 50 + (#CitadelShock.Game.Resources * 25)
	local baseL_X, baseL_Y = ScrW()-(baseL_W), 85
		
	if (#CitadelShock.Game.Resources > 0) then
		draw.RoundedBox(4, baseL_X, baseL_Y, baseL_W, baseL_H, Color(45,45,45,235))

		local sideInfo = gameSides[LocalPlayer():GetSide()]
		local resources = sideInfo.resources
		
		if (sideInfo) then
			-- [[RESOURCES]]
			local r_XPos = (baseL_X)
			local r_YPos = (baseL_Y + 20)
			draw.SimpleText( "TEAM RESOURCES", "CS_HUD_SM", r_XPos + 25, r_YPos, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			
			for id,r in pairs(CitadelShock.Game.Resources) do
				if (resources[r.name]) then
					local resData = resources[r.name]
					r_YPos = r_YPos + 23
					draw.SimpleText( r.name .. ": " .. resData, "CS_HUD_SM", r_XPos + 40, r_YPos, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
					
					if (r.icon) then
						surface.SetDrawColor( 255, 255, 255, 255 )
						surface.SetMaterial(Material(r.icon))
						surface.DrawTexturedRect( r_XPos + 21, r_YPos + 2, 16, 16 )
					end
				end
			end
		end
	end
	
	-- [[Generators]]
	for k,v in pairs(gameSides) do
		if (k != LocalPlayer():GetSide()) then
			local gen = nil
			for i=1,#v.ents do
				if (v.ents[i].IsGenerator) then gen = v.ents[i] end
			end
			
			if !(gen) then return false end
			
			local genHP = gen:Health()
			local genBarTXT =  "Enemy Generator HP: " .. gen:Health() .. "/" .. CitadelShock.Game.GeneratorHealth
			local genW, genH = 250, 18
			
			draw.RoundedBox(4, baseL_X, baseL_Y + baseL_H + 15, genW, genH, Color(45,45,45,235))
			draw.RoundedBox(4, baseL_X, baseL_Y + baseL_H + 15, genW*(gen:Health()/CitadelShock.Game.GeneratorHealth), genH, Color(255,75,75,255))
			
			draw.SimpleText( genBarTXT, "CS_HUD_XXSM", baseL_X + (genW/2), baseL_Y + baseL_H + 17, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		end
	end
end}

HUD.Elements.Respawning = {
status = {2},
draw = function()
	HUD.Variables.size = {350, 200, 3, 35}

	local bl_w, bl_h, b_margin, bt_margin = unpack(HUD.Variables.size)
	local base_x, base_y = b_margin, ScrH() - (bl_h + b_margin)
	base_y = base_y + bt_margin
	
	if not (LocalPlayer():IsInLobby()) then return false end
	if not (LocalPlayer():IsInGame()) then return false end
	-- [[Respawning Text]]
	draw.SimpleText( "YOU ARE RESPAWNING...", "CS_HUD_MD", ScrW()/2 + 2, 62, Color(25,25,25,115), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	draw.SimpleText( "YOU ARE RESPAWNING...", "CS_HUD_MD", ScrW()/2, 60, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
end}

HUD.Elements.Spectating = {
status = {3},
draw = function()
	local bl_w, bl_h, b_margin, bt_margin = unpack(HUD.Variables.size)
	local base_x, base_y = b_margin, ScrH() - (bl_h + b_margin)
	base_y = base_y + bt_margin
	
	local specID = LocalPlayer():GetSpectatedGame()
	
	if (specID == -1) then return false end

	-- [[Spectating Text]]
	draw.SimpleText( "YOU ARE SPECTATING", "CS_HUD_MD", ScrW()/2 + 2, 62, Color(25,25,25,115), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	draw.SimpleText( "YOU ARE SPECTATING", "CS_HUD_MD", ScrW()/2, 60, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

	draw.SimpleText( "LOBBY #" .. specID, "CS_HUD_SM", ScrW()/2 + 2, 88, Color(25,25,25,115), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	draw.SimpleText( "LOBBY #" .. specID, "CS_HUD_SM", ScrW()/2, 86, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
end}

CitadelShock:RegisterHUD(HUD) -- [[REGISTER THE HUD]]
