--[[
	LOBBY CONFIGURATION
]]

--[[
	CONFIG VARIABLES
]]
CitadelShock.Lobby.MaxLobbies = 1 			-- The maximum amount of lobbies (recommended to stay below 4 for performance)
CitadelShock.Lobby.MaxSize = 16 			-- The maximum size lobby 
CitadelShock.Lobby.MinSize = 2 				-- The minimum size lobby (this is also how many players are required to start the game!)

-- [[Lobby sizes]]
-- The sizes of selectable games, these are displayed on the lobby menu when "Open New Lobby" is clicked
CitadelShock.Lobby.Sizes = {
	["1 vs 1"] = 2, -- ["Text/name"] = lobby size,
	["2 vs 2"] = 4,
	["4 vs 4"] = 8,
	["5 vs 5"] = 10,
	["6 vs 6"] = 12,
	["7 vs 7"] = 14,
	["8 vs 8"] = 16,
}