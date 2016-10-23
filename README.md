Skyrim Spell Learning Mod
=========================


Summary
-------

This is a gameplay mod for Skyrim Legendary Edition.
It adds realism and configurability to spell learning for the player.


Gameplay diff
-------------

Before (Vanilla Skyrim)

* Merchants are the only source for spells
* Reading a spell book gives spell knowledge immediately

Issues

* But lore tells us learning magic should require efforts
* Insta-learning breaks our suspension of disbelief
* How about self-development, research and magic discovery the lore tells us about?
* When trying to fix Skyrim's economy with "cutthroat merchants", spells become overly expensive

After this mod

* Player is prevented form insta-learning from spell books. When buying a book from a merchant or otherwise picking up any spellbook, "Spell learning notes" will be added to the player's inventory instead. (configurable)
* Corresponding spells are added to his todo list, which he studies every night before going to sleep. (no in-game representation, just pretend or use the "simple actions" mod)
* There's a dice roll after each rest (once a day) to check if a new spell has been learned from the books. (difficulty configurable)
* Learn by practice: The more often the player casts spells, the more chances he has to successfully learn new spells. Casting spells only help towards learning or inventing spells of the same school.
* Mages are researchers: There's also a chance to discover/invent a spell by oneself without having acquired its book. (difficulty configurable, can be set to 0% chance. School of interest is configurable)
* Roleplaying a mage also increases chances of spell learning. (configurable)
** By hoarding a personnal library of "Spell learning notes" (stackable in inventory)
** Discussing "magic theory" with mage NPCs
** Staying in inspiring locations (Winterhold college, temples)
** Consuming mind-enhancing concoctions, with mild or dangerous side effects
** Learning from daedra spirits through a midnight ritual
* Optional ESP: More and higher-end spellbooks can be found on opponent caster corpses, symbolizing their own ongoing study of the arcane arts

This enables to be more involved with mage roleplay (various flavours), gives incentive to sleep, enables self-reliance (grow your mastery of the arts by adventuring).


Mod status
----------

Mod is currently in beta state, missing only its uninstall feature.
It needs beta testers and some polish.

Todo

* Implement the mod's uninstall function for the MCM.
* NPC dialogue exit after talking about magic theory feels blunt, needs polish like with a fade-out fade-in and better-timed flavour text.
* Spirit tutor spell could also use a fade-out fade-in sequence for more cinematic effect.
* Maybe: Dreadstare disease could cure itself after a couple nights' rest. Easily implemented in the control script, need to add its property.

Known bugs

* _LEARN_ControlScript.psc line 147: addform should take a book record as a parameter, not a spell. This causes the "midnight spirit tutor" spell not to appear in the merchants' lists.


Requirements
------------

Mod requires SKSE and the Dragonborn extension to function.


Compatibility
-------------

Spell learning feature : Compatible with any spell book from any mod.

Spell discovery : Uses merchants leveled book lists, so spell mod has to add its content there to be compatible. Most spell mods do that, but for example Witchhunter prayers & spells doesn't IIRC.
