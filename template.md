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

<!-- tweakdefs_readable -->

## Tweakunits

<!-- tweakunits_readable -->

## Tweakdefs encoded (URL-safe base64)

<!-- tweakdefs_encoding -->
