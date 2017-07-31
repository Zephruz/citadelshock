--[[
	- CL Init Menus
]]

CitadelShock.Menus = (CitadelShock.Menus or {})

function CitadelShock:RegisterMenu(name, tbl, cmd, desc)
	tbl.cmd = cmd
	self.Menus[name] = tbl
	
	--print(name .. " - Registered (" .. tostring(tbl) .. ")")

	if (cmd) then
		CitadelShock:RegisterCommand(cmd, function() self.Menus[name]:Init() end, (desc or false))
	end
end