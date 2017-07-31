--[[-----------------------------------
		SOUND LIBRARY CREATION
--------------------------------------]]

sound.Add({
	name = "sfx_cis_shockwave_small",
	channel = CHAN_STATIC,
	volume = 0.3,
	level = 100,
	pitch = { 95, 105 },
	sound = {
		"ambient/explosions/explode_1.wav",
		"ambient/explosions/explode_2.wav",
		"ambient/explosions/explode_3.wav",
		"ambient/explosions/explode_4.wav",
		"ambient/explosions/explode_5.wav",
		"ambient/explosions/explode_6.wav"
	}
})

sound.Add({
	name = "sfx_cis_burninglog_break",
	channel = CHAN_STATIC,
	volume = 0.7,
	level = 70,
	pitch = { 95, 105 },
	sound = {
		"physics/wood/wood_plank_break1.wav",
		"physics/wood/wood_plank_break2.wav",
		"physics/wood/wood_plank_break3.wav",
		"physics/wood/wood_plank_break4.wav"
	}
})

sound.Add({
	name = "sfx_cis_battle_start",
	channel = CHAN_STATIC,
	volume = 0.3,
	level = 100,
	pitch = { 95, 105 },
	sound = {
		"citadelshock/cis_battle_start03.wav",
	}
})
