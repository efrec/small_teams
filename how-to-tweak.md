# Basic modding guide

> **Important**
> 
> When playing in a public lobby, make sure the players actually want to play with mods. Not everyone does, and not everyone can be convinced. In addition, you will need to be the lobby boss to be able to set modoptions and/or apply tweaks.

## Tweakunits: Make specific changes to specific units

This is the most simple, open, and direct way to mod in Beyond All Reason. If you are new to the game's files, the first two steps may be the most cumbersome:

- **Find the unit's internal def name.** Search the `units.json` file in your language (here it is [in English](https://github.com/beyond-all-reason/Beyond-All-Reason/blob/master/language/en/units.json)) for the unit name to find its "internal" name. For example, the Pawn is named `armpw`.

- **Check the unit's base stats.** Find the file matching the unit's internal name in the [unit directory](https://github.com/beyond-all-reason/Beyond-All-Reason/blob/master/units). Read over the entire file before deciding on your changes. For example, the Pawn's def file is [armpw.lua](https://github.com/beyond-all-reason/Beyond-All-Reason/blob/master/units/ArmBots/armpw.lua).

  - To dive deeper into unit stats, you can reference the [SpringRTS wiki](https://springrts.com/wiki/Gamedev:UnitDefs).
  - To dive deeper into weapon stats, use the new [RecoilEngine docs](https://beyond-all-reason.github.io/RecoilEngine/guides/weapon-defs/) instead.

- **Create a file containing a Lua table.** Lua's table syntax is simple but picky, so ask for help if you get stuck. For now, here is a primer containing all you need to know:

  A *table* is a collection of data inside braces with named *keys* that are assigned *values*, like `{ key = value }`. Tables can act like values, too, meaning that tables can contain other tables. For example, in `{ a = 1, b = {} }`, the key `b` is assigned its own, empty table.

  You make changes to a unit by listing their internal name and assigning it a table containing the new values you want. For example, let's change the Pawn's metal cost to 10:

  ```lua
  {
    armpw = { metalcost = 10 }
  }
  ```

  To make multiple changes, you need to add commas to separate each assigned value. It is good practice to add trailing commas after every table and key-value pair inside the main, outer table, like so:

  ```lua
  {
    armpw = { metalcost = 10, energycost = 10, },
    corak = { metalcost = 10, energycost = 10, },
  }
  ```

- **Encode the table.** Copy and paste your tweak into the top field on [base64encode.org](https://www.base64encode.org/). Tick the box labeled "Perform URL-safe encoding", then press the button labeled Encode.

- **Become the lobby boss.** When playing online on a multiplayer server, you need to do this step. Type `!boss` in the lobby chat/console and press Enter to send the command.

- **Apply the tweakunits.** Copy the encoded result (it will look like gibberish) you got from [base64encode.org](https://www.base64encode.org/). Type `!bset tweakunits <your encoded text>` in the lobby chat/console, replacing `<your encoded text>` (do not include the brackets) with the copied text. Hit enter to send the command to the server.

## Tweakdefs: Make mass changes very efficiently

This type of tweak requires deeper knowledge of Lua and even, in rare cases, the specific oddities of *Beyond All Reason*'s Lua implementation. Once you get used to that, though, it's a much stronger tool for rapid iteration on a tweak.

- **Download more computer.** Download a code editor like [VS Code](https://code.visualstudio.com/download) and add a Lua language extension to identify basic syntax errors and help you to correct them. This is exceedingly easy to do even for non-developers. You have no excuse. Please do this step. Your feeble human brain cannot comprehend the existence of typos. It needs more computer.

- **Write the shortest possible Lua file to test.** You can loop through every single unit definition, filter for the ones that you want, and make changes. For your first attempt, that is plenty.

  For example, we can set the metal cost of all units to 10 *unless* they are tech-level 3:

  ```lua
  for name, unitDef in pairs(UnitDefs) do
    -- If the sub-table does not exist, then nor do any of its values. QED.
    if not unitDef.customparams or unitDef.customparams.techlevel ~= 3 then
        unitDef.metalcost = 10
    end
  end
  ```

- **Encode the script.** Copy and paste your tweak into the top field on [base64encode.org](https://www.base64encode.org/). Tick the box labeled "Perform URL-safe encoding", then press the button labeled Encode.

- **Become the lobby boss.** When playing online on a multiplayer server, you need to do this step. Type `!boss` in the lobby chat/console and press Enter to send the command.

- **Apply the tweakdefs.** Copy the encoded result (it will look like gibberish) you got from [base64encode.org](https://www.base64encode.org/). Type `!bset tweakdefs <your encoded text>` in the lobby chat/console, replacing `<your encoded text>` (do not include the brackets) with the copied text. Hit enter to send the command to the server.

## Multiple tweaks

You can change the final step in the previous sections slightly to apply more than one tweak:

- **Apply multiple tweaks.** Using the console method and the `!bset` command, you can enter up to nine distinct tweakunits (and/or tweakdefs). To do so, add an increasing number after `tweakunits` (or `tweakdefs`) for each additional tweak. For example, `tweakunits1` and `tweakunits2`, or `tweakdefs1` and `tweakdefs2`.

- **Advanced multi-tweak drifting.** You can prepare your commands ahead of time and enter them quickly by placing each `!bset` command on its own line. The server knows how to split on newlines and parse each tweak separately. You still need to number them and encode the text properly, of course.

## Additional References

#### Guides

- [ZK Guide](http://zero-k.info/mediawiki/Quick_Stat_Tweaks#Simple_Example)

#### Examples

Tweaks by @efrec:

- DUST-UP T1, a horribly over-wrought [tweakdefs](https://github.com/efrec/small_teams/blob/master/tweakdefs.lua)

Tweaks by @badosu:

- Reduce arty dmg by 10%: [tweakunits](https://codepen.io/badosu/pen/GRxPgqB?tweak=ewphcm1hcnQgPSB7CndlYXBvbkRlZnMgPSB7dGF3ZjExM193ZWFwb24gPSB7ZGFtYWdlID0ge2RlZmF1bHQgPSAyMzR9fX0sCn0sCmNvcndvbHYgPSB7CndlYXBvbkRlZnMgPSB7Y29yd29sdl9ndW4gPSB7ZGFtYWdlID0ge2RlZmF1bHQgPSAyNzB9fX0sCn0sCn0)
- Make t2 more expensive but stronger: [tweakdefs](https://codepen.io/badosu/pen/GRxPgqB?tweak=Zm9yIG5hbWUsIHVkIGluIHBhaXJzKFVuaXREZWZzKSBkbwogICBpZiB1ZC5jdXN0b21wYXJhbXMgYW5kIHVkLmN1c3RvbXBhcmFtcy50ZWNobGV2ZWwgYW5kIHVkLmN1c3RvbXBhcmFtcy50ZWNobGV2ZWwgPj0gMiB0aGVuCiAgICAgaWYgdWQuYnVpbGRjb3N0bWV0YWwgdGhlbiB1ZC5idWlsZGNvc3RtZXRhbCA9IDIqdWQuYnVpbGRjb3N0bWV0YWwgZW5kCiAgICB1ZC5idWlsZGNvc3RlbmVyZ3kgPSAyKnVkLmJ1aWxkY29zdGVuZXJneQogICAgdWQubWF4ZGFtYWdlID0gMip1ZC5tYXhkYW1hZ2UKICAgIHVkLmJ1aWxkdGltZSA9IDEuMyp1ZC5idWlsZHRpbWUKICAgIGlmIHVkLndlYXBvbmRlZnMgdGhlbgogICAgZm9yIHdkbmFtZSwgd2QgaW4gcGFpcnModWQud2VhcG9uZGVmcykgZG8KICAgICAgaWYgd2QuYXJlYW9mZWZmZWN0IHRoZW4gd2QuYXJlYW9mZWZmZWN0ID0gMS41KndkLmFyZWFvZmVmZmVjdCBlbmQKICAgICAgaWYgd2QucmVsb2FkdGltZSB0aGVuIHdkLnJlbG9hZHRpbWUgPSB3ZC5yZWxvYWR0aW1lLzEuNSBlbmQKICAgICAgaWYgd2QuZGFtYWdlIHRoZW4KICAgICAgZm9yIGRtZ25hbWUsIGRtZ2Ftb3VudCBpbiBwYWlycyh3ZC5kYW1hZ2UpIGRvCiAgICAgICAgd2QuZGFtYWdlW2RtZ25hbWVdID0gMS41KmRtZ2Ftb3VudAogICAgICBlbmQKICAgICAgZW5kCiAgICBlbmQKZW5kCiAKaWYgdWQuZmVhdHVyZWRlZnMgdGhlbgogICAgZm9yIGZlYXR1cmVuYW1lLCBmZCBpbiBwYWlycyh1ZC5mZWF0dXJlZGVmcykgZG8KICAgICAgZmQubWV0YWwgPSBmZC5tZXRhbCAqMgogICAgZW5kCiAgIGVuZAplbmQKZW5k)
- Decrease efficiency of energy conversion by 20%: [tweakdefs](https://codepen.io/badosu/pen/GRxPgqB?tweak=bG9jYWwgZGVsdGEgPSAtMC4yCmZvciBuYW1lLCB1ZCBpbiBwYWlycyhVbml0RGVmcykgZG8KICBpZiB1ZC5jdXN0b21wYXJhbXMuZW5lcmd5Y29udl9jYXBhY2l0eSB0aGVuCiAgICB1ZC5jdXN0b21wYXJhbXMuZW5lcmd5Y29udl9jYXBhY2l0eSA9IG1hdGgucm91bmQodWQuY3VzdG9tcGFyYW1zLmVuZXJneWNvbnZfY2FwYWNpdHkgKiAoMS1kZWx0YSkpCiAgZW5kCgogIGlmIHVkLmN1c3RvbXBhcmFtcy5lbmVyZ3ljb252X2VmZmljaWVuY3kgdGhlbgogICAgdWQuY3VzdG9tcGFyYW1zLmVuZXJneWNvbnZfZWZmaWNpZW5jeSA9IHVkLmN1c3RvbXBhcmFtcy5lbmVyZ3ljb252X2VmZmljaWVuY3kgKiAoMS8oMS1kZWx0YSkpCiAgZW5kCmVuZA)