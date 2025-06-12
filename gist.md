# DUST-UP T1

**A Duels and Small Teams Unit Patch for T1**

> **Note:** This is not the [Unofficial Tech Overhaul](https://gist.github.com/BAR-Neb/60b5051685891de93e0d697038ecae94) but an even-less-official-than-that patch. You have stumbled upon a door in time and space, a door to which your mind is the only key, a door to that which came before and shall follow after. Or whatever.

*Beyond All Reason* supports user mods through widgets and tweaks—and this is an entirely tweak-based mod project. You can take these tweakdefs (or tweakunits) and easily make [your own changes](https://gist.github.com/efrec/153081a7d43db3ad7a3c4fc5c9a689f8). Balance packs focus on the community meta so rely on people taking an interest to keep them alive. We hope to make something you'd be willing not just to test but to help evolve.

- Mod support: [neb_](https://discord.com/users/320254986154147841), [encyclopedia.](https://discord.com/users/761830414070579211), and [\[boneless\]](https://discord.com/users/227953252723982338) (Discord)
- Talk about it: [Beyond All Reason](https://discord.com/channels/549281623154229250/1376965918659182764) (Discord)
- Plan a match: [Fight Night](https://discord.com/channels/1295134383250083870/1295170995044487188) (Discord)

This tweak is not *quite* a balance pack, yet, instead pushing toward a larger overhaul. Extensive reworks are given preference over balance-oriented "adjustments" to fit the meta. The meta *itself* needs a tweak—so just buffing or nerfing Grunts won't cut it.

After the v1.0 releases and gets sufficient blessing, then the tweak will be maintained as a balance pack, with weekly reviews and monthly wrap-ups focused on more competitive levels of play.

## How to use this tweak

1. **Boss yourself in the lobby.** Enter `!boss` in the console and hit enter to send the command.

2. **Enable the Legion faction.** You can enable it in the Advanced Options menu on the Experimental options tab.

3. **Apply this tweak.** Copy the encoded tweak from the [bottom of this document](#tweakdefs-encoded-url-safe-base64) and either:
   - enter it in the TweakDef field in the Cheat options tab, or
   - enter `!bset tweakdefs <text>` in the console.

## Patch summary

- **Early raiding and counter-raiding.** Basic economy buildings have more health, basic combat units are faster and cheaper, and the Banshee and Pounder are better at focusing single targets.

  - We wanted to increase the skill required to dish out early eco damage with scout raids.
  - Also, anti-air missiles now target ground units to act as an effective deterrent.

- **Factory costs (modified) test patch.** We liked the patch so much that we stole it. Johannes' test patch got a minor re-patching and fit right in with the rest of our changes.

  - I, uh, dunno what's in this thing.

- **Tech 1.5 units.** Unusually expensive and powerful Basic-tech units now join the likes of Legion's specialized tier-and-a-half unit roster.

  - Armada: Centurion, Janus, Corsair, Chainsaw, and Twilight.
  - Cortex: Thug, Lasher, Oppressor, Eradicator, and Exploiter.
  - Buffs to these units have the seemingly-contradictory effect of posing a game-end threat early in the T1 phase while also extending that threat against any potential T2 transitions and rushes.
  - To deal with the extra threat to commanders, we gave a 30% reduction to the cost to cloak.

- **Faction-unique weapons.** More units have unique weapons. Armada specializes in EMG and Gauss weapons, and Cortex in lasers and explosives.

- **Cortex bot lab.** Bedbug reworked into a fast, low-vision, high-radar scout in T1.

  - Cortex has a *very* limited roster in this T1 lab and two crawling bombs in a single T2 lab. Something had to give. The new Bedbug provides excellent mobile radar and retains just enough punch to be worth using on limited risky raids (or a desperate defense).

### Dev diary

In short, we asked ourselves what changes are desirable to get away from the current game state and decided, kind of, all of them? *Yes?* Dear reader, it was not a very good question. This patch has alternated between a longer and shorter Basic tech phase, more expensive and cheaper Advanced tech, and buffing and nerfing mono-spam in its brief two-and-a-half week long history.

Easy answers haven't been easy to come by.

At high-level play in particular, we face a lot of pain points. Some are born of the indestructible artifacts of BAR's extended lifetime. Some, of the pace of volunteer-driven development. Change in this *ye olde* game is very needed, indeed, but good change isn't easy to come by, either.

Rather, it trickles in over time.

Many of the problems we want to address were taken up by the core developers a long time ago\*. Their solutions are often better than any tweak can hope to achieve, but many remain in that long limbo of being *in progress*. This rework is something we can do, right now, both for fun and for the community. It takes back some agency to "be the change" and hopefully influence the future of the game.

Thank you for attending my TED talk. —🍍

*\* Note: We have access to private forums that are not available to non-contributors. If you think that's unfair or something: Join the development team. The future of BAR is exceedingly bright and, at worst, only inconveniently far away.*

## Tweakdefs

```lua
---small_teams_tweak
local unitDef, weaponDef, cparams, ref
local divisors = { 2, 4, 5, 8, 12, 20, 50, 125, 250 }
local m2e, m2b = 20, 30

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
```

## Tweakunits

<!-- tweakunits_readable -->

## Tweakdefs encoded (URL-safe base64)

> bG9jYWwgYSxiLGMsZDtsb2NhbCBlPXsyLDQsNSw4LDEyLDIwLDUwLDEyNSwyNTB9bG9jYWwgZixnPTIwLDMwO2xvY2FsIGZ1bmN0aW9uIGgoaSwuLi4pZm9yIGosayBpbiBpcGFpcnMoey4uLn0pZG8gaVtrXT1kW2tdZW5kIGVuZDtsb2NhbCBmdW5jdGlvbiBsKG0sbilpZiBuIHRoZW4gbT1tL24gZWxzZSBuPTEgZW5kO2lmIG08PTMwIHRoZW4gcmV0dXJuIG1hdGguZmxvb3IobSswLjUpKm4gZW5kO2xvY2FsIG89e31mb3IgaixwIGluIGlwYWlycyhlKWRvIG9bcF09bWF0aC5mbG9vcihtL3ArMC41KSpwIGVuZDtsb2NhbCBxPW9bZVsxXV1sb2NhbCByPXEtbTtyPXIqci9lWzFdZm9yIHM9MiwjZSBkbyBsb2NhbCB0PWVbc11sb2NhbCB1PW9bdF0tbTt1PXUqdS9lW3NdaWYgcj51IHRoZW4gcT1vW3Rdcj11IGVuZCBlbmQ7cmV0dXJuIHEqbiBlbmQ7bG9jYWwgZnVuY3Rpb24gdih3LHgseSx6KWlmIG5vdCB4IHRoZW4geD0wIGVuZDtpZiBub3QgeSB0aGVuIHk9eCooYS5tZXRhbGNvc3QgYW5kIGEubWV0YWxjb3N0PjAgYW5kIGEuZW5lcmd5Y29zdC9hLm1ldGFsY29zdCBvciBmKWVuZDtpZiBub3QgeiB0aGVuIHo9eCooYS5tZXRhbGNvc3QgYW5kIGEubWV0YWxjb3N0PjAgYW5kIGEuYnVpbGR0aW1lL2EubWV0YWxjb3N0IG9yIGcpZW5kO2xvY2FsIEE9bChhLm1ldGFsY29zdCp3K3gsMTApbG9jYWwgQj1BL2EubWV0YWxjb3N0O2EubWV0YWxjb3N0PUE7YS5lbmVyZ3ljb3N0PWwoYS5lbmVyZ3ljb3N0KncreSwxMClhLmJ1aWxkdGltZT1sKGEuYnVpbGR0aW1lKncreiwxMClmb3IgQyxpIGluIHBhaXJzKGEuZmVhdHVyZWRlZnMgb3J7fSlkbyBpLm1ldGFsPW1hdGguZmxvb3IoQippLm1ldGFsKzAuNSllbmQgZW5kO2xvY2FsIGZ1bmN0aW9uIEQodyxFKWlmIG5vdCBFIHRoZW4gRT0wIGVuZDtmb3IgRixtIGluIHBhaXJzKGIuZGFtYWdlKWRvIGIuZGFtYWdlW0ZdPWwobSp3K0UpZW5kIGVuZDtsb2NhbCBmdW5jdGlvbiBHKEMpYT1Vbml0RGVmc1tDXXJldHVybiBhIGVuZDtsb2NhbCBmdW5jdGlvbiBIKEMpYj1hLndlYXBvbmRlZnNbQ11yZXR1cm4gYiBlbmQ7bG9jYWwgZnVuY3Rpb24gSShpKWM9aS5jdXN0b21wYXJhbXMgb3J7fWkuY3VzdG9tcGFyYW1zPWM7cmV0dXJuIGMgZW5kO2ZvciBqLEMgaW4gaXBhaXJzeyJhcm1jb20iLCJjb3Jjb20iLCJsZWdjb20ifWRvIEcoQylhLmFpcnNpZ2h0ZGlzdGFuY2U9bChhLnNpZ2h0ZGlzdGFuY2UqMS41KWEuY2xvYWtjb3N0PWwoYS5jbG9ha2Nvc3QqMC43KWEuY2xvYWtjb3N0bW92aW5nPWwoYS5jbG9ha2Nvc3Rtb3ZpbmcqMC43KWVuZDtsb2NhbCBKPXsiYXJtd2FyIiwiYXJtamFudXMiLCJhcm1yb3kiLCJhcm1jaXIiLCJhcm1hbWV4IiwiY29ydGh1ZCIsImNvcm1pc3QiLCJjb3Jyb3kiLCJjb3JlcmFkIiwiY29yZXhwIn1mb3IgQyxpIGluIHBhaXJzKFVuaXREZWZzKWRvIGlmIEkoaSkudGVjaGxldmVsPT0xLjUgdGhlbiBKWyNKKzFdPUMgZW5kIGVuZDtmb3IgaixDIGluIGlwYWlycyhKKWRvIEkoRyhDKSkudGVjaGxldmVsPTEuNTtjLnBhcmFseXplbXVsdGlwbGllcj0wLjcgZW5kO0koRygiY29ycm9hY2giKSkudGVjaGxldmVsPTE7Zm9yIEMsaSBpbiBpcGFpcnMoVW5pdERlZnMpZG8gaWYoSShpKS50ZWNobGV2ZWwgb3IgMSk8MS41IHRoZW4gaWYgaS5leHRyYWN0c21ldGFsIGFuZCBpLmV4dHJhY3RzbWV0YWw-MCB0aGVuIGkuaGVhbHRoPWwoRyhDKS5oZWFsdGgqMiwyNSllbHNlaWYgaS53aW5kZ2VuZXJhdG9yIGFuZCBpLndpbmRnZW5lcmF0b3I-MCB0aGVuIGkuaGVhbHRoPWwoRyhDKS5oZWFsdGgqMS4xLDI1KWVsc2VpZiBjLnNvbGFyIGFuZChpLmVuZXJneXVwa2VlcCBhbmQgaS5lbmVyZ3l1cGtlZXA8LTUwKW9yIGkuZW5lcmd5bWFrZSBhbmQgaS5lbmVyZ3ltYWtlPjUwIHRoZW4gaS5oZWFsdGg9bChHKEMpLmhlYWx0aCoxLjEyNSwyNSlpLmVuZXJneXN0b3JhZ2U9bCgoaS5lbmVyZ3lzdG9yYWdlIG9yIDApKjEuMTI1KWVsc2VpZiBuZXh0KGkuYnVpbGRvcHRpb25zKWFuZCBzdHJpbmcuZmluZChpLm1vdmVtZW50Y2xhc3Mgb3IiIiwiQk9UIil0aGVuIGkuaGVhbHRoPWwoRyhDKS5oZWFsdGgqMS4xMiwyNSllbmQgZW5kIGVuZDtHKCJhcm1wdyIpdigxLDAsMCwxMzIpYS5zcGVlZD1sKGEuc3BlZWQqMS4wOClHKCJhcm1mbGFzaCIpYS5zcGVlZD1sKGEuc3BlZWQqMS4wOClHKCJhcm1rYW0iKUgoImVtZyIpYi5zcHJheWFuZ2xlPWwoYi5zcHJheWFuZ2xlKjAuNiliLndlYXBvbnZlbG9jaXR5PWwoYi53ZWFwb252ZWxvY2l0eSoxLjEpYi5maXJldG9sZXJhbmNlPTM2MDA7RygiY29ybGV2bHIiKWEuc3BlZWQ9bChhLnNwZWVkKjEuMSlIKCJjb3JsZXZscl93ZWFwb24iKWIucmFuZ2U9bChiLnJhbmdlKjAuOTIpZm9yIEMsSyBpbiBwYWlyc3thcm1ybD0iYXJtcmxfbWlzc2lsZSIsYXJtY2lyPSJhcm1fY2lyIixjb3JybD0iY29ycmxfbWlzc2lsZSIsY29yZXJhZD0iY29yX2VyYWQiLGxlZ3JsPSJsZWdybF9taXNzaWxlIixsZWdyaGFwc2lzPSJidXJzdF9hYV9taXNzaWxlIn1kbyBHKEMpYS53ZWFwb25zWzFdLmZhc3RhdXRvcmV0YXJnZXRpbmc9dHJ1ZTthLndlYXBvbnNbMV0ub25seXRhcmdldGNhdGVnb3J5PSJOT1RTVUIiSChLKWxvY2FsIEw9KGIuYnVyc3Qgb3IgMSkqKGIucHJvamVjdGlsZXMgb3IgMSliLmRhbWFnZS5kZWZhdWx0PWwoKDIwKzAuMipiLmRhbWFnZS52dG9sKkwpL0wpZW5kO2ZvciBqLEMgaW4gaXBhaXJzeyJhcm1tb2hvIiwiY29ybW9obyIsImNvcm1leHAiLCJsZWdtb2hvIiwibGVnbW9obyIsImxlZ21vaG9icCIsImxlZ21vaG9jb24ifWRvIEcoQyl2KDEsMTAwLDIwMDAsOTAwKWVuZDtmb3IgQyxpIGluIHBhaXJzKFVuaXREZWZzKWRvIGlmIEkoaSkudGVjaGxldmVsPT0yIHRoZW4gaS5idWlsZHRpbWU9bChHKEMpLmJ1aWxkdGltZSoxLjUpZWxzZWlmIGMudGVjaGxldmVsPT0zIHRoZW4gaS5idWlsZHRpbWU9bChHKEMpLmJ1aWxkdGltZSoyKWVuZCBlbmQ7Zm9yIGosQyBpbiBpcGFpcnN7ImFybWFnZW8iLCJjb3JhZ2VvIiwibGVnYWdlbyJ9ZG8gRyhDKXYoMSwxMDAsNDAwMCwwKWVuZDtmb3IgaixNIGluIGlwYWlyc3siYXJtIiwiY29yIiwibGVnIn1kbyBmb3IgaixOIGluIGlwYWlyc3sibGFiIiwidnAiLCJhcCIsInN5In1kbyBpZiBHKE0uLk4pdGhlbiB2KDAuNSwzMDAsOTAwLDQwMDApYS53b3JrZXJ0aW1lPWwoYS53b3JrZXJ0aW1lKjIuNSw1MCllbmQgZW5kO2ZvciBqLE4gaW4gaXBhaXJzeyJwbGF0IiwiYW1zdWIiLCJhbXBobGFiIn1kbyBpZiBHKE0uLk4pdGhlbiBhLndvcmtlcnRpbWU9bChhLndvcmtlcnRpbWUqMysxMDAsNTApZW5kIGVuZDtmb3IgaixOIGluIGlwYWlyc3siYWxhYiIsImF2cCIsImFhcCIsImFzeSJ9ZG8gaWYgRyhNLi5OKXRoZW4gdigxLC01MDAsMjAwMCw1MDAwKWEud29ya2VydGltZT1sKGEud29ya2VydGltZSo1KWVuZCBlbmQ7Zm9yIGosTiBpbiBpcGFpcnN7ImdhbnQiLCJnYW50dXciLCJzaGx0eCIsInNobHR4dXcifWRvIGlmIEcoTS4uTil0aGVuIHYoMS41LDEwMDAsMTAwMDAsMjAwMClhLndvcmtlcnRpbWU9bChhLndvcmtlcnRpbWUqNy41LDUwMCllbmQgZW5kO2ZvciBqLE8gaW4gaXBhaXJzeyJuYW5vdGMiLCJuYW5vdGNwbGF0In1kbyBpZiBHKE0uLk8pdGhlbiB2KDEsNTAsNTAwLDEwMDApYS5tZXRhbHN0b3JhZ2U9NTA7YS5lbmVyZ3lzdG9yYWdlPTUwO2lmIE09PSJjb3IidGhlbiBhLmhlYWx0aD1sKGEuaGVhbHRoKjEuMTI1LDI1KWVuZCBlbmQgZW5kIGVuZDtHKCJhcm13YXIiKXYoMS4yLDAsMCwzMDApYS5oZWFsdGg9bChhLmhlYWx0aCoxLjI1LDI1KWEuaWRsZWF1dG9oZWFsPTEwO2Euc3BlZWQ9bChhLnNwZWVkKjEuMzMzMylIKCJhcm13YXJfbGFzZXIiKWIucmFuZ2U9bChiLnJhbmdlLTMwKUQoMS4yNSlHKCJhcm1qYW51cyIpdigxLjMzMzMpYS5oZWFsdGg9bChhLmhlYWx0aCoxLjE2NjcsMjUpYS5zcGVlZD1sKGEuc3BlZWQqMS4xMjUpSCgiamFudXNfcm9ja2V0IiliLnJlbG9hZHRpbWU9Yi5yZWxvYWR0aW1lKjAuOTI1O0coImFybWFtZXgiKXYoMS4xMjUpYS5oZWFsdGg9bChhLmhlYWx0aCoxLjI1LDI1KWEuZXhwbG9kZWFzPSJtZWRpdW1CdWlsZGluZ0V4cGxvc2lvbkdlbmVyaWMiYS5lbmVyZ3ltYWtlPWEuY2xvYWtjb3N0O2EucmFkYXJkaXN0YW5jZT0xMDAwO2EucmFkYXJlbWl0aGVpZ2h0PTI0O2Euc2lnaHRkaXN0YW5jZT0yMDA7RygiY29ydGh1ZCIpdigyKWEuaGVhbHRoPWwoYS5oZWFsdGgqMiwyNSlhLnNwZWVkPWwoYS5zcGVlZCoxLjE2NjcpYS50dXJucmF0ZT1hLnR1cm5yYXRlKjEuMDU7SCgiYXJtX2hhbSIpYi5hcmVhb2ZlZmZlY3Q9bChiLmFyZWFvZmVmZmVjdCoxLjE2NjcpYi5idXJzdD0yO2IuYnVyc3RyYXRlPTAuMjU7Yi5yZWxvYWR0aW1lPWIucmVsb2FkdGltZSoxLjU7RygiY29ybWlzdCIpdigyKWEuaGVhbHRoPWwoYS5oZWFsdGgqMS4zMzMzLDI1KWZvciBqLEsgaW4gaXBhaXJzeyJjb3J0cnVja19hYSIsImNvcnRydWNrX21pc3NpbGUifWRvIEgoSyliLmFyZWFvZmVmZmVjdD1Vbml0RGVmcy5jb3JzdG9ybS53ZWFwb25kZWZzLmNvcl9ib3Rfcm9ja2V0LmFyZWFvZmVmZmVjdCsyO2IuYnVyc3Q9MztiLmJ1cnN0cmF0ZT0wLjM3NTtiLnJlbG9hZHRpbWU9Yi5yZWxvYWR0aW1lKjIgZW5kO0coImNvcmV4cCIpdigxLjUpYS5oZWFsdGg9bChhLmhlYWx0aCoxLjMzMzMsMjUpYS5pZGxlYXV0b2hlYWw9MTA7YS5zaWdodGRpc3RhbmNlPWwoYS5zaWdodGRpc3RhbmNlKjEuNSliPWEud2VhcG9uZGVmcy5obGx0X2JvdHRvbTtiLnJhbmdlPWwoYi5yYW5nZSs1MClEKDEuMTI1KUcoImNvcmFrIil2KDAuODg4OClhLmhlYWx0aD1sKGEuaGVhbHRoKjAuODg4OCwyNSliPWEud2VhcG9uZGVmcy5nYXRvcl9sYXNlcjtiLnJhbmdlPWwoYi5yYW5nZSoxLjA1KUcoImNvcnJvYWNoIil2KDAuNSwwLC0yMDAwLC0yMDAwKWEubWF4d2F0ZXJkZXB0aD0xNjthLm1vdmVtZW50Y2xhc3M9IkJPVDEiYS5yYWRhcmRpc3RhbmNlPVVuaXREZWZzLmFybWZsZWEuc2lnaHRkaXN0YW5jZSszMDthLnJhZGFyZW1pdGhlaWdodD0xODthLnNwZWVkPWwoYS5zcGVlZCoxLjMzMzMpYS5leHBsb2RlYXM9Im1lZGl1bUV4cGxvc2lvbkdlbmVyaWNTZWxmZCJhLnNlbGZkZXN0cnVjdGFzPSJmYl9ibGFzdHNtbCJhLmN1c3RvbXBhcmFtcy50ZWNobGV2ZWw9bmlsO2ZvciBDLGkgaW4gaXBhaXJzKFVuaXREZWZzKWRvIGlmIGkuYnVpbGRlciBhbmQgdHlwZShpLmJ1aWxkb3B0aW9ucyk9PSJ0YWJsZSJ0aGVuIGZvciBzLFAgaW4gcGFpcnMoaS5idWlsZG9wdGlvbnMpZG8gaWYgUD09ImNvcnJvYWNoInRoZW4gRyhDKXRhYmxlLnJlbW92ZShpLmJ1aWxkb3B0aW9ucyxzKWVuZCBlbmQgZW5kIGVuZDtHKCJjb3JsYWIiKWEuYnVpbGRvcHRpb25zWyNhLmJ1aWxkb3B0aW9ucysxXT0iY29ycm9hY2giZD1Vbml0RGVmcy5hcm1rYW0ud2VhcG9uZGVmcy5lbWc7Zm9yIEMsSyBpbiBwYWlyc3thcm13YXI9ImFybXdhcl9sYXNlciIsYXJtaGx0PSJhcm1fbGFzZXJoMSJ9ZG8gRyhDKUgoSykubmFtZT0iSGVhdnkgRU1HImgoYiwid2VhcG9udHlwZSIsImNvcmV0aGlja25lc3MiLCJleHBsb3Npb25nZW5lcmF0b3IiLCJpbnRlbnNpdHkiLCJsYXNlcmZsYXJlc2l6ZSIsInJnYmNvbG9yIiwidGhpY2tuZXNzIiwic2l6ZSIsInNvdW5kaGl0d2V0Iiwic291bmRzdGFydCIsImJ1cnN0cmF0ZSIsImJlYW1idXJzdCIsImJlYW10aW1lIiwiY3lsaW5kZXJ0YXJnZXRpbmciLCJlbmVyZ3lwZXJzaG90IiwiaW1wYWN0b25seSIsInRvbGVyYW5jZSIsInByZWRpY3Rib29zdCIsIndlYXBvbnZlbG9jaXR5IiliLmltcHVsc2VmYWN0b3I9MC44O0QoKGIuYnVyc3Qgb3IgMSkvKGQuYnVyc3QrMSkpYi5idXJzdD1kLmJ1cnN0KzE7bG9jYWwgQj1kLnJlbG9hZHRpbWUvYi5yZWxvYWR0aW1lKmQucmFuZ2UvYi5yYW5nZTtiLnNwcmF5YW5nbGU9ZC5zcHJheWFuZ2xlKm1hdGguc3FydChCKWVuZDtkPVVuaXREZWZzLmFybW1hdi53ZWFwb25kZWZzLmFybW1hdl93ZWFwb247Zm9yIEMsSyBpbiBwYWlyc3thcm1oYW09ImFybV9oYW0ifWRvIEcoQyl2KDEuMSlIKEspLm5hbWU9IkdhdXNzIFBsYXNtYSBDYW5ub24iaChiLCdpbXB1bHNlZmFjdG9yJywnd2VhcG9udmVsb2NpdHknKWIucmVsb2FkdGltZT1sKGIucmVsb2FkdGltZSoxLjc1LDAuMDEpRCgxLjc1KWVuZDtmb3IgQyxLIGluIHBhaXJze2Nvcm1pc3Q9ImNvcnRydWNrX21pc3NpbGUiLGNvcnN0b3JtPSJjb3JfYm90X3JvY2tldCJ9ZG8gRyhDKUgoSykubmFtZT0iTGlnaHQgU29saWQtRnVlbCBSb2NrZXQiYi5tb2RlbD0ibGVnc21hbGxyb2NrZXQuczNvImIuYnVybmJsb3c9ZmFsc2U7Yi5teWdyYXZpdHk9MDtiLnRyYWNrcz10cnVlO2IudHJhamVjdG9yeWhlaWdodD0wLjI1O2IudHVybnJhdGU9ODAwMDtiLnN0YXJ0dmVsb2NpdHk9YS5zcGVlZCsxO2Iud2VhcG9udmVsb2NpdHk9bChiLndlYXBvbnZlbG9jaXR5KjIuMiliLndlYXBvbmFjY2VsZXJhdGlvbj1iLndlYXBvbnZlbG9jaXR5LWIuc3RhcnR2ZWxvY2l0eTtsb2NhbCBRPShiLndlYXBvbnZlbG9jaXR5LWIuc3RhcnR2ZWxvY2l0eSkvYi53ZWFwb25hY2NlbGVyYXRpb247bG9jYWwgUj1tYXRoLm1pbihiLnJhbmdlLFEqKGIuc3RhcnR2ZWxvY2l0eStiLndlYXBvbnZlbG9jaXR5KSowLjUpYi5mbGlnaHR0aW1lPVErKGIucmFuZ2UtUikqMC45L2Iud2VhcG9udmVsb2NpdHk7Yi5kYW5jZT02O2Iud29iYmxlPTYwMDtJKGIpLm92ZXJyYW5nZV9kaXN0YW5jZT1iLnJhbmdlO2MucGxhY2VfdGFyZ2V0X29uX2dyb3VuZD10cnVlO2MucHJvamVjdGlsZV9kZXN0cnVjdGlvbl9tZXRob2Q9ImRlc2NlbmQiZW5k

