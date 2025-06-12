--------------------------------------------- [ small_teams_tweakdefs.lua ] ----
-- Adapted from and in relation to the Unofficial Tech Overhaul, by neb & encyc.
-- This version is hard for non-coders to read but offers some other advantages.
--------------------------------------------------------------------------------

if not UnitDefs.legcom then
	Spring.Echo('Error in small teams tweadefs: Legion not enabled.')
end

--------------------------------------------------------------------------------
-- Initialize ------------------------------------------------------------------

local unitDef, weaponDef, cparams, ref
local units = {}
local divisors = { 2, 4, 5, 8, 12, 20, 50, 125, 250 }
local m2e, m2b = 20, 30

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

local function costs(mult, base_m, base_e, base_b)
	if not base_m then base_m = 0 end
	if not base_e then
		base_e = base_m * (unitDef.metalcost and unitDef.metalcost > 0 and unitDef.energycost / unitDef.metalcost or m2e)
	end
	if not base_b then
		base_b = base_m * (unitDef.metalcost and unitDef.metalcost > 0 and unitDef.buildtime / unitDef.metalcost or m2b)
	end
	local metal = neat(unitDef.metalcost * mult + base_m, 10)
	local ratio = metal / unitDef.metalcost
	unitDef.metalcost = metal
	unitDef.energycost = neat(unitDef.energycost * mult + base_e, 10)
	unitDef.buildtime = neat(unitDef.buildtime * mult + base_b, 10)
	for name, def in pairs(unitDef.featuredefs or {}) do
		def.metal = math.floor(ratio * def.metal + 0.5)
	end
end

local function damages(mult, base)
	if not base then base = 0 end
	for armor, value in pairs(weaponDef.damage) do
		weaponDef.damage[armor] = neat(value * mult + base)
	end
end

local function unit(name)
	unitDef = UnitDefs[name]
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

local function dumb_equal(old, new)
	return
		(type(old) == "string" and tonumber(old) and tonumber(old) ~= new) or
		((old == 0 or old == "false") and new ~= false) or
		((old == 1 or old == "true") and new ~= true)
end

local function diff(old, new)
	local d = {}
	for k, v_o in pairs(old) do
		local v_n = new[k]
		if v_n == nil then
			d[k] = "nil"
		elseif type(v_o) == "table" and type(v_n) == "table" then
			d[k] = diff(v_o, v_n)
		elseif v_o ~= v_n and (type(v_o) == type(v_n) or dumb_equal(v_o, v_n)) then
			d[k] = v_n
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

--------------------------------------------------------------------------------
-- Commanders ------------------------------------------------------------------

-- More dangerous Tech 1 units often will force Commanders onto the defensive.
-- Ideally all commanders would have Legion's AA and torpedo weapons, as well.

for _, name in ipairs { "armcom", "corcom", "legcom" } do
	unit(name)
	unitDef.airsightdistance = neat(unitDef.sightdistance * 1.5)
	unitDef.cloakcost = neat(unitDef.cloakcost * 0.7)
	unitDef.cloakcostmoving = neat(unitDef.cloakcostmoving * 0.7)
end

--------------------------------------------------------------------------------
-- Tech level changes ----------------------------------------------------------

-- There are two types of changes, so it is just easier to summarize them first.

local techUp = {
	"armwar", "armjanus", "armroy", "armcir", "armamex",
	"corthud", "cormist", "corroy", "corerad", "corexp",
}

for name, def in pairs(UnitDefs) do
	if custom(def).techlevel == 1.5 then
		techUp[#techUp + 1] = name
	end
end

for _, name in ipairs(techUp) do
	custom(unit(name)).techlevel = 1.5
	cparams.paralyzemultiplier = 0.7
end

custom(unit("corroach")).techlevel = 1

--------------------------------------------------------------------------------
-- Basic economy ---------------------------------------------------------------

-- Scout leaks are not high-APM gameplay but high-attention gameplay.
-- We want you to act strategically early on until you are warmed up.

for name, def in ipairs(UnitDefs) do
	if (custom(def).techlevel or 1) < 1.5 then
		if def.extractsmetal and def.extractsmetal > 0 then
			def.health = neat(unit(name).health * 2, 25)
		elseif def.windgenerator and def.windgenerator > 0 then
			def.health = neat(unit(name).health * 1.1, 25)
		elseif cparams.solar and (def.energyupkeep and def.energyupkeep < -50) or (def.energymake and def.energymake > 50) then
			def.health = neat(unit(name).health * 1.125, 25)
			def.energystorage = neat((def.energystorage or 0) * 1.125)
		elseif next(def.buildoptions) and string.find(def.movementclass or "", "BOT") then
			def.health = neat(unit(name).health * 1.12, 25)
		end
	end
end

--------------------------------------------------------------------------------
-- Raiding and counter-raiding -------------------------------------------------

-- Sturdier economy buildings allow you to chase down leaks using combat units.
-- More combat units being built, in general, acts as its own scout deterrence.

unit("armpw")
costs(1, 0, 0, 132)
unitDef.speed = neat(unitDef.speed * 1.08)

unit("armflash")
unitDef.speed = neat(unitDef.speed * 1.08)

unit("armkam")
weapon("emg")
weaponDef.sprayangle = neat(weaponDef.sprayangle * 0.6)
weaponDef.weaponvelocity = neat(weaponDef.weaponvelocity * 1.1)
weaponDef.firetolerance = 3600

unit("corlevlr")
unitDef.speed = neat(unitDef.speed * 1.1)
weapon("corlevlr_weapon")
weaponDef.range = neat(weaponDef.range * 0.92)

-- This gives ground-to-ground capabilities to AA weapons (though pitifully weak).
-- The true intent is to add a short-range point defense as a swapped weapon load.

-- Air units are the best raiders in the game and often its best counter-raiders.
-- With more ground AA, air, especially air scouts, can be balanced for survival.

for name, wname in pairs { armrl = "armrl_missile", armcir = "arm_cir", corrl = "corrl_missile", corerad = "cor_erad", legrl = "legrl_missile", legrhapsis = "burst_aa_missile" } do
	unit(name)
	unitDef.weapons[1].fastautoretargeting = true
	unitDef.weapons[1].onlytargetcategory = "NOTSUB"
	weapon(wname)
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
for name, def in pairs(UnitDefs) do
	if custom(def).techlevel == 2 then
		def.buildtime = neat(unit(name).buildtime * 1.5)
	elseif cparams.techlevel == 3 then
		def.buildtime = neat(unit(name).buildtime * 2)
	end
end
for _, name in ipairs { "armageo", "corageo", "legageo" } do
	unit(name)
	costs(1, 100, 4000, 0)
end

for _, faction in ipairs { "arm", "cor", "leg" } do
	for _, factory in ipairs { "lab", "vp", "ap", "sy" } do
		if unit(faction .. factory) then
			costs(0.5, 300, 900, 4000)
			unitDef.workertime = neat(unitDef.workertime * 2.5, 50)
		end
	end
	for _, factory in ipairs { "plat", "amsub", "amphlab" } do
		if unit(faction .. factory) then
			unitDef.workertime = neat(unitDef.workertime * 3 + 100, 50)
		end
	end
	for _, factory in ipairs { "alab", "avp", "aap", "asy" } do
		if unit(faction .. factory) then
			costs(1, -500, 2000, 5000)
			unitDef.workertime = neat(unitDef.workertime * 5)
		end
	end
	for _, factory in ipairs { "gant", "gantuw", "shltx", "shltxuw" } do
		if unit(faction .. factory) then
			costs(1.5, 1000, 10000, 2000)
			unitDef.workertime = neat(unitDef.workertime * 7.5, 500)
		end
	end

	-- NB: Construction turrets can't be too expensive or cons replace them.
	for _, turret in ipairs { "nanotc", "nanotcplat" } do
		if unit(faction .. turret) then
			costs(1, 50, 500, 1000)
			-- We need ways to justify the expense, then:
			unitDef.metalstorage = 50
			unitDef.energystorage = 50
			if faction == "cor" then
				unitDef.health = neat(unitDef.health * 1.125, 25)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Tech 1.5 --------------------------------------------------------------------

-- T1.5 is not a reified game mechanic but a classification schema for units.
-- They are more expensive, more powerful, and have better resistance to EMP.

unit("armwar")
costs(1.2, 0, 0, 300)
unitDef.health = neat(unitDef.health * 1.25, 25)
unitDef.idleautoheal = 10
unitDef.speed = neat(unitDef.speed * 1.3333)
weapon("armwar_laser")
weaponDef.range = neat(weaponDef.range - 30)
damages(1.25)

unit("armjanus")
costs(1.3333)
unitDef.health = neat(unitDef.health * 1.1667, 25)
unitDef.speed = neat(unitDef.speed * 1.125)
weapon("janus_rocket")
weaponDef.reloadtime = weaponDef.reloadtime * 0.925

unit("armamex")
costs(1.125)
unitDef.health = neat(unitDef.health * 1.25, 25)
unitDef.explodeas = "mediumBuildingExplosionGeneric"
unitDef.energymake = unitDef.cloakcost
unitDef.radardistance = 1000
unitDef.radaremitheight = 24
unitDef.sightdistance = 200

unit("corthud")
costs(2)
unitDef.health = neat(unitDef.health * 2, 25)
unitDef.speed = neat(unitDef.speed * 1.1667)
unitDef.turnrate = unitDef.turnrate * 1.05
weapon("arm_ham")
weaponDef.areaofeffect = neat(weaponDef.areaofeffect * 1.1667)
weaponDef.burst = 2
weaponDef.burstrate = 0.25
weaponDef.reloadtime = weaponDef.reloadtime * 1.5

unit("cormist")
costs(2)
unitDef.health = neat(unitDef.health * 1.3333, 25)
for _, wname in ipairs { "cortruck_aa", "cortruck_missile" } do
	weapon(wname)
	weaponDef.areaofeffect = UnitDefs.corstorm.weapondefs.cor_bot_rocket.areaofeffect + 2
	weaponDef.burst = 3
	weaponDef.burstrate = 0.375
	weaponDef.reloadtime = weaponDef.reloadtime * 2
end

unit("corexp")
costs(1.5)
unitDef.health = neat(unitDef.health * 1.3333, 25)
unitDef.idleautoheal = 10
unitDef.sightdistance = neat(unitDef.sightdistance * 1.5)
weaponDef = unitDef.weapondefs.hllt_bottom
weaponDef.range = neat(weaponDef.range + 50)
damages(1.125)

--------------------------------------------------------------------------------
-- Cortex bots -----------------------------------------------------------------

unit("corak")
costs(0.8888)
unitDef.health = neat(unitDef.health * 0.8888, 25)
weaponDef = unitDef.weapondefs.gator_laser
weaponDef.range = neat(weaponDef.range * 1.05)

unit("corroach")
costs(0.5, 0, -2000, -2000)
unitDef.maxwaterdepth = 16
unitDef.movementclass = "BOT1"
unitDef.radardistance = UnitDefs.armflea.sightdistance + 30
unitDef.radaremitheight = 18
unitDef.speed = neat(unitDef.speed * 1.3333)
unitDef.explodeas = "mediumExplosionGenericSelfd"
unitDef.selfdestructas = "fb_blastsml"
unitDef.customparams.techlevel = nil
for name, def in ipairs(UnitDefs) do
	if def.builder and type(def.buildoptions) == "table" then
		for i, bo in pairs(def.buildoptions) do
			if bo == "corroach" then
				unit(name)
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
ref = UnitDefs.armkam.weapondefs.emg
for name, wname in pairs { armwar = "armwar_laser", armhlt = "arm_laserh1" } do
	unit(name)
	weapon(wname).name = "Heavy EMG"
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
ref = UnitDefs.armmav.weapondefs.armmav_weapon
for name, wname in pairs { armham = "arm_ham" } do
	unit(name)
	costs(1.1) -- Not a neutral conversion.
	weapon(wname).name = "Gauss Plasma Cannon"
	copy(weaponDef, 'impulsefactor', 'weaponvelocity')
	weaponDef.reloadtime = neat(weaponDef.reloadtime * 1.75, 0.01)
	damages(1.75)
end

-- LSFR
for name, wname in pairs { cormist = "cortruck_missile", corstorm = "cor_bot_rocket" } do
	unit(name)
	weapon(wname).name = "Light Solid-Fuel Rocket"
	weaponDef.model = "legsmallrocket.s3o"
	weaponDef.burnblow = false
	weaponDef.mygravity = 0
	weaponDef.tracks = true
	weaponDef.trajectoryheight = 0.25
	weaponDef.turnrate = 8000
	weaponDef.startvelocity = unitDef.speed + 1
	weaponDef.weaponvelocity = neat(weaponDef.weaponvelocity * 2.2)
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
	tweaks[name] = diff(old, UnitDefs[name])
end
Spring.Echo(tweaks)
