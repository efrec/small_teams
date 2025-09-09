--------------------------------------------- [ small_teams_tweakdefs.lua ] ----
-- Experimenting with the tweakdefs format, especially the need to conserve char
-- count for very-very-large tweaks. This was originally around 24000 characters
-- before changes; this file is 15.7k; and the minified tweakdef is ~7300 chars.
--------------------------------------------------------------------------------

local UD = UnitDefs

if not UD.legcom then
	Spring.Echo('Error in small teams tweadefs: Legion not enabled.')
end

--------------------------------------------------------------------------------
-- Initialize ------------------------------------------------------------------

local function deep(tbl)
	local new = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			new[k] = deep(v)
		else
			new[k] = v
		end
	end
	return new
end

local function equal(old, new)
	return
		(type(old) == "string" and tonumber(old) and tonumber(old) ~= new) or
		((old == 0 or old == "false") and new ~= false) or
		((old == 1 or old == "true") and new ~= true)
end

local function tweak(old, new)
	local d = {}
	for k, v_o in pairs(old) do
		if type(k) ~= "number" then
			local v_n = new[k]
			if v_n == nil then
				d[k] = "nil"
			elseif type(v_o) == "table" and type(v_n) == "table" then
				d[k] = tweak(v_o, v_n)
			elseif v_o ~= v_n and (type(v_o) == type(v_n) or equal(v_o, v_n)) then
				d[k] = v_n
			end
		end
	end
	for k, v_n in pairs(new) do
		if old[k] == nil then
			d[k] = v_n
		end
	end
	if next(d) then
		return d
	end
end

-- This sets up a small designer language for making tweaks, which might not be
-- your cup of tea, exactly. For that, I keep a list of common variables to set
-- the active def being edited and to copy properties from other, related defs.
--
-- > unit("armpw")     -- This gets the Pawn def (iff exists) and puts it in `unitDef`.
-- > weapon("emg")     -- This gets the unitDef's emg def and stores it in `weaponDef`.
-- > custom(unitDef)   -- This gets the Pawn's customParams and stores it in `cparams`.
-- > custom(weaponDef) -- This gets the Pawn's EMG weapon customParams, etc., as above.
--
-- Then, you can modify the properties of a common variable, like so:
-- > unitDef.health = neat(unitDef.health * 2, 25) -- Give a clean number (round to 25).
-- > set(unitDef, "health", 2, 0, 25)              -- Same as above, but in fewer chars.
--
-- There are two helpers for common modifications:
-- > costs(1.2, 0, 0, 500) -- Modify unitDef costs (all x1.2, then +500 BP).
-- > damages(2, 10)        -- Modify weaponDef damages (all x2, then all +10).
--
-- And at a more basic level:
-- > unitDef.health = neat(unitDef.health, 50) -- Give things "nice, neat" values.

local unitDef, weaponDef, cparams, ref
local units = {}
local divisors = { 2, 4, 5, 8, 12, 20, 50, 125, 250 }
local m2e, m2b = 20, 30

local function unit(name)
	unitDef = UD[name]
	if unitDef and not units[name] then
		units[name] = deep(unitDef)
	end
	return unitDef
end

local function weapon(name)
	weaponDef = unitDef.weapondefs[name]
	return weaponDef
end

local function custom(def)
	cparams = def.customparams or {}
	def.customparams = cparams
	return cparams
end

local function copy(def, ...)
	for _, property in ipairs({ ... }) do
		def[property] = ref[property]
	end
end

local function neat(value, precision)
	if precision then
		value = value / precision
	else
		precision = 1
	end
	if value <= 30 then
		return math.floor(value + 0.5) * precision
	end
	local values = {}
	for _, v in ipairs(divisors) do
		values[v] = math.floor(value / v + 0.5) * v
	end
	local neatest = values[divisors[1]]
	local fitness = neatest - value
	fitness = fitness * fitness / divisors[1]
	for i = 2, #divisors do
		local divisor = divisors[i]
		local fitness2 = values[divisor] - value
		fitness2 = fitness2 * fitness2 / divisors[i]
		if fitness > fitness2 then
			neatest = values[divisor]
			fitness = fitness2
		end
	end
	return neatest * precision
end

local function set(tbl, key, mult, add, precision)
	local value = tonumber(tbl[key])
	if type(value) == "number" then
		tbl[key] = neat(value * (mult or 1) + (add or 0), precision)
	end
end

local function costs(mult, add_m, add_e, add_bp)
	local u = unitDef
	if not add_m then add_m = 0 end
	if not add_e then
		add_e = add_m * (u.metalcost and u.metalcost > 0 and u.energycost / u.metalcost or m2e)
	end
	if not add_bp then
		add_bp = add_m * (u.metalcost and u.metalcost > 0 and u.buildtime / u.metalcost or m2b)
	end
	local metal = neat(u.metalcost * mult + add_m, 10)
	local ratio = metal / u.metalcost
	u.metalcost = metal
	set(u, "energycost", mult, add_e, 10)
	set(u, "buildtime", mult, add_bp, 10)
	for _, fd in pairs(u.featuredefs or {}) do
		fd.metal = math.floor(ratio * fd.metal + 0.5)
	end
end

local function damages(mult, base)
	if not base then base = 0 end
	for armor in pairs(weaponDef.damage) do
		set(weaponDef.damage, armor, mult, base)
	end
end

--------------------------------------------------------------------------------
-- Commanders ------------------------------------------------------------------

-- More dangerous Tech 1 units often will force Commanders onto the defensive.
-- Ideally all commanders would have Legion's AA and torpedo weapons, as well.

for _, name in ipairs { "armcom", "corcom", "legcom" } do
	unit(name)
	set(unitDef, "airsightdistance", 1.5)
	set(unitDef, "cloakcost", 0.7)
	set(unitDef, "cloakcostmoving", 0.7)
end

--------------------------------------------------------------------------------
-- Tech level changes ----------------------------------------------------------

-- There are two types of changes, so it is just easier to summarize them first.

local techUp = {
	"armwar", "armjanus", "armroy", "armcir", "armamex",
	"corthud", "cormist", "corroy", "corerad", "corexp",
}

for name, def in pairs(UD) do
	if custom(def).techlevel == 1.5 then
		techUp[#techUp + 1] = name
	end
end

for _, name in ipairs(techUp) do
	custom(unit(name)).techlevel = 1.5
	cparams.paralyzemultiplier = 0.7 -- No real reason. T1.5 == EMP resist.
end

custom(unit("corroach")).techlevel = 1

--------------------------------------------------------------------------------
-- Basic economy ---------------------------------------------------------------

-- Scout leaks are not high-APM gameplay but high-attention gameplay.
-- We want you to act strategically early on until you are warmed up.

for name, def in pairs(UD) do
	if (custom(def).techlevel or 1) < 1.5 then
		if def.extractsmetal and def.extractsmetal > 0 then
			set(unit(name), "health", 2, 0, 25)
		elseif def.windgenerator and def.windgenerator > 0 then
			set(unit(name), "health", 1.1, 0, 25)
		elseif cparams.solar and (def.energyupkeep and def.energyupkeep < -50) or (def.energymake and def.energymake > 50) then
			set(unit(name), "health", 1.125, 0, 25)
			set(unit(name), "energystorage", 1.125)
		elseif next(def.buildoptions) and string.find(def.movementclass or "", "BOT") then
			set(unit(name), "health", 1.12, 0, 25)
		end
	end
end

--------------------------------------------------------------------------------
-- Raiding and counter-raiding -------------------------------------------------

-- Sturdier economy buildings allow you to chase down leaks using combat units.
-- More combat units being built, in general, acts as its own scout deterrence.

unit("armpw")
costs(1, 0, 0, 132)
set(unitDef, "speed", 1.08)

unit("armflash")
set(unitDef, "speed", 1.08)

unit("armkam") weapon("emg")
set(weaponDef, "sprayangle", 0.6)
set(weaponDef, "weaponvelocity", 1.1)
weaponDef.firetolerance = 3600

unit("corlevlr") weapon("corlevlr_weapon")
set(unitDef, "health", 1.1)
set(unitDef, "speed", 1.1)
set(weaponDef, "range", 0.92)

-- This gives ground-to-ground capabilities to AA weapons (though pitifully weak).
-- The true intent is to add a short-range point defense as a swapped weapon load.

-- Air units are the best raiders in the game and often its best counter-raiders.
-- With more ground AA, air, especially air scouts, can be balanced for survival.

for name, wname in pairs { armrl = "armrl_missile", armcir = "arm_cir", corrl = "corrl_missile", corerad = "cor_erad", legrl = "legrl_missile", legrhapsis = "burst_aa_missile" } do
	unit(name) weapon(wname)
	unitDef.weapons[1].fastautoretargeting = true
	unitDef.weapons[1].onlytargetcategory = "NOTSUB"
	local salvo = (weaponDef.burst or 1) * (weaponDef.projectiles or 1)
	weaponDef.damage.default = neat((20 + 0.2 * weaponDef.damage.vtol * salvo) / salvo)
end

--------------------------------------------------------------------------------
-- Factory costs test patch ----------------------------------------------------

-- 1. Expensive build power except through factories, which are more efficient.
-- 2. Factories become prohibitively expensive the higher you progress in tech.

for _, name in ipairs { "armmoho", "cormoho", "cormexp", "legmoho", "legmoho", "legmohobp", "legmohocon" } do
	unit(name)
	costs(1, 100, 2000, 900)
end
for name, def in pairs(UD) do
	if custom(def).techlevel == 2 then
		set(unit(name), "buildtime", 1.5)
	elseif cparams.techlevel == 3 then
		set(unit(name), "buildtime", 2)
	end
end
for _, name in ipairs { "armageo", "corageo", "legageo" } do
	unit(name)
	costs(1, 100, 4000, 0)
end

for _, faction in ipairs { "arm", "cor", "leg" } do
	for _, factory in ipairs { "lab", "vp", "ap", "sy" } do
		if unit(faction .. factory) then
			costs(0.5, 300, 900, 1000)
			set(unitDef, "workertime", 2.5, 0, 50)
		end
	end
	for _, factory in ipairs { "plat", "amsub", "amphlab" } do
		if unit(faction .. factory) then
			set(unitDef, "workertime", 3, 100)
		end
	end
	for _, factory in ipairs { "alab", "avp", "aap", "asy" } do
		if unit(faction .. factory) then
			costs(1, -500, 2000, 2500)
			set(unitDef, "workertime", 5)
		end
	end
	for _, factory in ipairs { "gant", "gantuw", "shltx", "shltxuw" } do
		if unit(faction .. factory) then
			costs(1.25)
			set(unitDef, "workertime", 7.5, 0, 500)
		end
	end

	for _, turret in ipairs { "nanotc", "nanotcplat" } do
		if unit(faction .. turret) then
			costs(1, 20)
			unitDef.metalstorage = 25
			unitDef.energystorage = 50
			if faction == "cor" then
				set(unitDef, "health", 1.125, 0, 25)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Tech 1.5 --------------------------------------------------------------------

-- T1.5 is not a reified game mechanic but a classification schema for units.
-- They are more expensive, more powerful, and have better resistance to EMP.

unit("armwar") weapon("armwar_laser")
costs(1.2, 0, 0, 300)
set(unitDef, "health", 1.25, 0, 25)
set(unitDef, "speed", 1.3333)
unitDef.idleautoheal = 10
set(weaponDef, "range", 0, -30)
damages(1.25)

unit("armjanus") weapon("janus_rocket")
costs(1.3333)
set(unitDef, "health", 1.1667, 0, 25)
set(unitDef, "speed", 1.125)
set(weaponDef, "reloadtime", 0.925)

unit("armamex")
costs(1.125)
set(unitDef, "health", 1.25, 0, 25)
unitDef.explodeas = "mediumBuildingExplosionGeneric"
unitDef.energymake = unitDef.cloakcost
unitDef.radardistance = 1000
unitDef.radaremitheight = 24
unitDef.sightdistance = 200

unit("corthud") weapon("arm_ham")
costs(2)
set(unitDef, "health", 2)
set(unitDef, "speed", 1.1667)
set(unitDef, "turnrate", 1.05)
set(weaponDef, "areaofeffect", 1.1667)
set(weaponDef, "reloadtime", 1.5)
weaponDef.burst = 2
weaponDef.burstrate = 0.25

unit("cormist")
costs(2)
set(unitDef, "health", 1.3333, 0, 25)
for _, wname in ipairs { "cortruck_aa", "cortruck_missile" } do
	weapon(wname)
	set(weaponDef, "reloadtime", 2)
	weaponDef.areaofeffect = UD.corstorm.weapondefs.cor_bot_rocket.areaofeffect + 2
	weaponDef.burst = 3
	weaponDef.burstrate = 0.375
end

unit("corexp") weapon("hllt_bottom")
costs(1.5)
set(unitDef, "health", 1.3333, 0, 25)
unitDef.idleautoheal = 10
set(unitDef, "sightdistance", 1.5)
set(weaponDef, "range", 0, 50)
damages(1.125)

--------------------------------------------------------------------------------
-- Cortex bots -----------------------------------------------------------------

unit("corak") weapon("gator_laser")
costs(0.8888)
set(unitDef, "health", 0.8888, 0, 25)
set(weaponDef, "range", 1.05)

unit("corroach")
costs(0.5, 0, -2000, -2000)
set(unitDef, "speed", 1.3333)
unitDef.maxwaterdepth = 16
unitDef.movementclass = "BOT1"
unitDef.radardistance = UD.armflea.sightdistance + 30
unitDef.radaremitheight = 18
unitDef.explodeas = "mediumExplosionGenericSelfd"
unitDef.selfdestructas = "fb_blastsml"
unitDef.customparams.techlevel = nil
for name, def in pairs(UD) do
	if type(def.buildoptions) == "table" then
		for i, bo in pairs(def.buildoptions) do
			if bo == "corroach" then
				table.remove(def.buildoptions, i)
			end
		end
	end
end
unit("corlab")
unitDef.buildoptions[#unitDef.buildoptions + 1] = "corroach"

--------------------------------------------------------------------------------
-- Weapon conversions ----------------------------------------------------------

-- These are total conversions that otherwise preserve the stats of the weapon.
-- Overall stat changes (eg total burst size) should be done in other sections.

-- HEMG
ref = UD.armkam.weapondefs.emg
for name, wname in pairs { armwar = "armwar_laser", armhlt = "arm_laserh1" } do
	unit(name) weapon(wname)
	weaponDef.name = "Heavy EMG"
	copy(weaponDef,
		"weapontype",
		"corethickness", "explosiongenerator", "intensity", "laserflaresize", "rgbcolor", "thickness", "size",
		"soundhitwet", "soundstart",
		"burstrate", "beamburst", "beamtime",
		"cylindertargeting", "energypershot", "impactonly", "tolerance", "predictboost", "weaponvelocity"
	)
	weaponDef.impulsefactor = 0.8
	damages((weaponDef.burst or 1) / (ref.burst + 1))
	weaponDef.burst = ref.burst + 1
	local ratio = (ref.reloadtime / weaponDef.reloadtime) * (ref.range / weaponDef.range)
	weaponDef.sprayangle = ref.sprayangle * math.sqrt(ratio)
end

-- Gauss
ref = UD.armmav.weapondefs.armmav_weapon
for name, wname in pairs { armham = "arm_ham" } do
	unit(name) weapon(wname)
	costs(1.1) -- Not a neutral conversion.
	weaponDef.name = "Gauss Plasma Cannon"
	copy(weaponDef, 'impulsefactor', 'weaponvelocity')
	set(weaponDef, "reloadtime", 1.75, 0, 0.01)
	damages(1.75)
end

-- LSFR
for name, wname in pairs { cormist = "cortruck_missile", corstorm = "cor_bot_rocket" } do
	unit(name) weapon(wname)
	weaponDef.name = "Light Solid-Fuel Rocket"
	weaponDef.model = "legsmallrocket.s3o"
	weaponDef.burnblow = false
	weaponDef.mygravity = 0
	weaponDef.tracks = true
	weaponDef.trajectoryheight = 0.25
	weaponDef.turnrate = 8000
	weaponDef.startvelocity = unitDef.speed + 1
	set(weaponDef, "weaponvelocity", 2.2)
	weaponDef.weaponacceleration = weaponDef.weaponvelocity - weaponDef.startvelocity
	local accelTime = (weaponDef.weaponvelocity - weaponDef.startvelocity) / weaponDef.weaponacceleration
	local accelDistance = math.min(weaponDef.range,
		accelTime * (weaponDef.startvelocity + weaponDef.weaponvelocity) * 0.5)
	weaponDef.flighttime = accelTime + (weaponDef.range - accelDistance) * 0.9 / weaponDef.weaponvelocity
	weaponDef.dance = 6
	weaponDef.wobble = 600
	custom(weaponDef).overrange_distance = weaponDef.range
	cparams.place_target_on_ground = true
	cparams.projectile_destruction_method = "descend"
end

--------------------------------------------------------------------------------
-- Convert to tweakunits -------------------------------------------------------

local tweaks = {}
for name, old in pairs(units) do
	tweaks[name] = tweak(old, UD[name])
end
Spring.Echo(tweaks)
