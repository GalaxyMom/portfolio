Config = {}

Config.Params = {
	Cops = 4,					-- Number of cops required to be on duty to spawn a truck
	AggroRange = 200.0,			-- Distance from truck and guards to aqcuire new targets
	ForceAttack = 1000,			-- Number of cycles before guards stop fleeing and attack (larger = longer)
	HackAttempts = 5,			-- Number of puzzles that must be completed to hack the tracker
	HackTiles = 6,				-- Number of tiles wide and tall the puzzle is
	HackTries = 3,				-- Number of wrong tiles allowed for each puzzle
	HackTimer = 15,				-- Length of time given to solve each puzzle in seconds
	HackCooldown = 5000,		-- Length of time in between each puzzle in milliseconds
	HackInitiateTime = 5000,	-- Length of time for the hacking progress bar
	Cash = true,				-- Whether to include straight cash in truck loot
	MinCash = 12000,				-- Minimum amount of cash in truck loot
	MaxCash = 16000,			-- Maximum amount of cash in truck loot
	BlipCooldown = 20000,		-- Time between truck blip updates in milliseconds
	Cooldown = {				-- Cooldown before next truck spawns in hours based on if there was an attempt and if it was successful
		Ignore = 1,
		Attempt = 24,
		Success = 48
	}
}

Config.Routes = {
	{
		vector4(-39.2527, -711.7792, 32.6933, 155.6643),	-- Location and heading of starting position
		vector3(3562.7727, 3666.7874, 33.9268)				-- Location of ending position
	},
	{
		vector4(-39.2527, -711.7792, 32.6933, 155.6643),
		vector3(-123.2644, 6480.2124, 31.4671)
	}
}

Config.Loot = {
	{
		name = "markedbills",
		min = 2,
		max = 3,
		minPay = 6000,
		maxPay = 8000
	}
}