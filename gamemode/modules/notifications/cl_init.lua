--[[
	Citadel Shock
	- NOTIFICATIONS MODULE -
]]

CitadelShock.Notifs = {}

CitadelShock.Notifs.notifications = {}

-- [[Config]]
CitadelShock.Notifs.config = {}
CitadelShock.Notifs.config.notifSpeed = 10
CitadelShock.Notifs.config.notifLength = 5
CitadelShock.Notifs.config.defSizes = {
	w = 200,
	h = 35,
}
CitadelShock.Notifs.config.defPositions = {
	x = 5,
	y = 5,
}

local notifConf = CitadelShock.Notifs.config
local notifications = (CitadelShock.Notifs.notifications or {})

function CitadelShock.Notifs:Create(msg, icon)
	local newNotif = {}
	newNotif.msg = msg
	newNotif.icon = (icon or false)
	newNotif.delAt = (os.time() + notifConf.notifLength)
	newNotif.curPos = {x = -200, y = notifConf.defPositions.y}
	
	-- [[notification size]]
	newNotif.size = {}
	newNotif.size.w = notifConf.defSizes.w
	newNotif.size.h = notifConf.defSizes.h
	
	table.insert(notifications, newNotif)
end

function CitadelShock.Notifs:Remove(id)
	if !(notifications[id]) then return false end
	table.remove(notifications, id)
end

hook.Add("HUDPaint", "CIS.Hook.NotifsDraw",
function()
	for i=1,#notifications do
		local notif = notifications[i]

		if (notif) then
			local nW, nH = notif.size.w, notif.size.h
			local nX, nY = (notif.curPos.x < notifConf.defPositions.x && notif.curPos.x || notifConf.defPositions.x), notif.curPos.y
			
			if (i>1) then nY = nY + (nH*(i-1)) end
			nY = nY + (5*i)
			
			if (notif.delAt <= os.time()) then
				notif.curPos.x = notif.curPos.x-notifConf.notifSpeed
				if (notif.curPos.x < -nW) then CitadelShock.Notifs:Remove(i) end
			else notif.curPos.x = notif.curPos.x+notifConf.notifSpeed end
			
			surface.SetFont( "CS_HUD_XSM" )

			local msg = (notif.msg or "No message")
			local w, h = surface.GetTextSize(msg)
			
			nW, nH = w+10, h+10

			draw.RoundedBoxEx(4, nX, nY, nW, nH, Color(45,45,45,235), true, true, true, true)
			
			draw.SimpleText( msg, "CS_HUD_XSM", nX + 5, nY + (nH/2), Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	end
end)

-- [[Chat messages to notifs]]
hook.Add("CIS.Hook.ChatMessage", "CIS.NotifsChat",
function(msg)
	CitadelShock.Notifs:Create(msg)
end)