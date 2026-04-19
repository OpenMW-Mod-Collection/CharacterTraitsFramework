# Character Traits Framework (OpenMW)

Create your own chargen traits. Backgrounds, beliefs, lineages - you name it.

This framework allows anyone to create any additional chargen traits similar to [Merlord's Character Backgrounds](https://www.nexusmods.com/morrowind/mods/46795). They can range from simple stat changes to scripted events that completely alter the way you approach the game.

> Note: Any expansions created for the MWSE version of Character Backgrounds are not compatible with this mod and must be adapted to the OpenMW Lua API.

## Installation

### Requirements

- [Stats Window Extender (OpenMW)](https://www.nexusmods.com/morrowind/mods/57727) by Ralts

### Load Order

All trait modules need to be loaded after the `CharacterTraitsFramework.omwscripts`. For example:

- CharacterTraitsFramework.omwscripts
- CharacterTraits_Backgrounds.omwaddon
- CharacterTraits_Backgrounds.omwscripts
- CharacterTraits_Beliefs.omwaddon
- CharacterTraits_Beliefs.omwscripts
- ...

Trait packs might be load order sensitive by themselves or have their own requirements, so look out for any notices on their respective pages.

## Compatibility

Compatible with any mods.

Safe to install or update mid-playthrough. Removing the mod, though, might not revert all the effects granted by your traits.

### Soft Incompatibilities

Nothing gamebreaking, just a little whacky behavior.

- [OpenMW Daggerfall Character Creation](https://www.nexusmods.com/morrowind/mods/58464) by Slowchu - After chargen both UIs fire at the same time and one will temporarily cover the other

### Supported Trait Packs

A non-exhaustive list of mods adding new traits:

- Community Traits Ported by me and the MWSE community

## Adding your own Traits

New traits are created in player scripts using `I.CharacterTraitsFramework.addTrait()` in a player script. New trait types are registered automatically based on their `type` field. Traits with duplicate `id` get overriden based on load order: trait loaded first gets overriden by trait loaded last.

### Example

```lua
local I = require("openmw.interfaces")
local self = require("openmw.self")
local ui = require("openmw.ui")

I.CharacterTraits.addTrait {
    id = "test",
    type = "background",
    name = "Test Background",
    description = "This background does this, this, and that.",

    doOnce = function()
        -- Called only once when the trait is activated
        local strength = self.type.stats.attributes.strength(self)
        strength.base = strength.base + 15
    end,

    callback = function(data)
        -- Called when the trait is activated and during script initialization
        ui.showMessage("Test background successfully initialized!")
    end
}
```

## Credits

**Sosnoviy Bor** - Author  
**Greatness7** - Scrollable list template ([Virtual List](https://github.com/Greatness7/openmw_virtual_list/tree/main))  
**Ralts** - Button template ([Magic Window Extender](https://www.nexusmods.com/morrowind/mods/58064))  
**Merlord** - Design and inspiration ([Merlord's Character Backgrounds](https://www.nexusmods.com/morrowind/mods/46795))  
**MTR** - Design and inspiration ([mtrByTheDivines](https://www.nexusmods.com/morrowind/mods/48031), [mtrLineage](https://www.nexusmods.com/morrowind/mods/49996) and [mtrCultures](https://www.nexusmods.com/morrowind/mods/51282))  
**ownlyme, hyacinth and urm** - Invaluable help with figuring out the UI API  
**You, the community** - Inspiring to start and continue modding
