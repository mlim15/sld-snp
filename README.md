Spell Learning and Discovery SnP
=========================
A continuation of the Skyrim mod originally created by /u/bepo from Reddit. This mod has passed through many hands over the years, with versions on [Reddit](https://www.reddit.com/r/skyrimmods/comments/58lovp/please_adopt_my_mod_spell_learning/), [GitHub](https://github.com/ttrebuchon/Skyrim_Spell_Learning), and two published versions on Nexus Mods by [auie4545 for LE](https://www.nexusmods.com/skyrim/mods/87495) and [nexusishere for SSE](https://www.nexusmods.com/skyrimspecialedition/mods/17446).

Summary
-------

Isn't it weird that in vanilla Skyrim, you learn spells *instantly* by *destroying books*? This mod seeks to create a more immersive, realistic, and slow way of learning spells that is relatively lightweight, compatible with most spell mods without patching, and (mostly) lore-friendly. It aims to remain simple enough that you can install it and set it up, and it will keep working in the background in an understandable and non-immersion-breaking way without you ever having to reenter its MCM.

Instead of the vanilla system, with this mod any books you buy or pick up are automatically added to a list of spells your character is studying. Each time they sleep (with a configurable time limit), they will attempt to learn a spell from this list. Their chances to learn the spell successfully depend on their overall magical skill, their skill in the spell's specific school, the amount of spells of that school they have cast since last learning a spell, whether they have slept in a location that is "suited" for studying magic (like a temple, the College, or a player-set location), and more.

Optionally (and by default), the mod also deconstructs all books you recieve into notes on the spell's school of magic. The ideas is that these notes are used by mages in their research on similar spells. Keeping lots of Destruction notes on your character will help you learn new Destruction spells more effectively, for example. It also would make sense that if all mages use these notes, they are tradeable and in demand, and this preserves the value of spell tomes - the amount of notes generated is related to the value of the tome deconstructed, meaning you can still sell the notes for the same amount of gold if you wish. Alternatively, you can grow your collection and make learning new spells easier.

The mod also provides a simple spell discovery system - shouldn't mages be able to come up with new ideas for spells by themselves, without learning from a book? If it is enabled, your character can come up with ideas for spells themselves when they sleep. The chance for this to happen is configurable. By default, if this happens, the spell will be of the school they have cast most often since their last rest. Spells "discovered" this way are pulled from level-appropriate lists (the same ones the game uses to generate loot). They are added to the list of spells your character will try to learn when sleeping, without the need to buy or find its spellbook. 

Why another version of this mod?
-------------

When I was looking for mods that solve the problems of the vanilla game's spell learning system, I found quite a few things I liked quite a bit, but all of them had at least some problems:

* I like [Better Spell Learning](https://www.nexusmods.com/skyrimspecialedition/mods/4924) a lot, and it does solve the issue of learning spells seeming effortless - but it also makes it quite a chore, and it's *the player* that's forced to do that chore. I want my character to do the chores in the background, I don't want to manually waste my own time doing them. It also requires patches for any mods that add spells, because it works by replacing all spell books in the game with custom versions that have a script attached. 
* Something like [Spell Research](https://www.nexusmods.com/skyrimspecialedition/mods/20983) is also great, but it's a big mod that adds a lot of features and requires the use of menus. I wanted something that stayed closer to the vanilla experience, and typically I prefer mods that can be set up once they way I like them and then left forever, without being forced to go back into any menus at any point, because this breaks immersion.

Then I found this mod. It was perfectly suited to my preferences... but it felt unfinished. A lot of things seemed unpolished - for example, the dialogue option with mages was pretty unintuitive, and for some NPCs like Mirabelle, was missing voicing. Much of the mod's functionality was relatively opaque to the end-user - how was I supposed to know that the dialogue option costs money once you've already passed a certain percentage chance? And on top of that, I felt it could be a little more configurable. If I could have just disabled all the parts of the mod I didn't like, I would have done that and called it a day. But those options weren't exposed to the user.

So I decided to roll up my sleeves and fix it up, because bless all the people who have worked on this mod, they have *all* provided the sources (and under a great copyleft license, no less). Initially I just wanted to remove the immersion-breaking parts, like some of the debug messages and the NPC dialogue. Then I started adding a couple little features and config settings... and another... and another... and now we're here. The original mod, especially with the great more robust spell list nexusishere added to the SSE version, has a ton of promise.  All I've done is added a little SnP. What's SnP? I don't know. Maybe the base mod was a great meal that just needed a little salt and pepper. Maybe it was a nice pair of boots that needed a little spit and polish. It's SnP.

So here is Spell Learning and Discovery for Skyrim Special Edition... with a little SnP.

What's New
----------

* Removed the NPC dialogue option because it was the only thing that really made me say "ew" when installing the mod, and I don't think it adds much to the experience
* Changed the spell notes in inventory to be pages containing runes, instead of having 300 identical "notes" in your inventory that all have the same words on them. Also added a short explainer to the top of the note.
* Tightened up in-game descriptions like the Spell Study effect, capitals on the mod title, changed "Spirit Tutor" to "Daedric Tutor", and many more little fixes and tweaks that make the experience feel less immersion-breaking - e.g. messages related to Dreadmilk used to just show "I need more Dreadmilk" or "Overdosed" at the top of the screen, now it displays something like "You have overdosed on Dreadmilk."
* Enthir now sells items related to the mod, including its potions, recipes, and (singular) spell.
* Messages that let you know what's going on with the mod at each sleep in what I hope will be considered a non-immersion-breaking way - e.g. "It seems your mind isn't settled enough yet to learn any spells..." or "Lightning Bolt still makes no sense..." or "It makes sense now! Learned Lightning Bolt." This way you don't have to constantly look at the MCM pane to know what's happening with the mod.
* Configurable option to limit consecutive failures when learning spells - e.g. after failing 3 times, you learn it automagically(TM) on the next sleep. Alternatively, option to move spells to the bottom of the list after this amount of failures.
* Option to try and learn multiple spells (amount configurable) on each sleep
* Option when learning multiple spells to divide chance to learn by spells being learned (to approximate speed of learning one spell at a time, but still with the chance to get lucky and learn multiple spells on a sleep)
* Configurable option to automatically fail spells based on skill difference (e.g. novice can't learn master spells)
* Configurable option to let Dreadmilk (the potion added by the mod) to bypass this automatic failure (e.g. with Dreadmilk, a novice can still have the chance to learn master spells)
* Configurable option to automatically succeed when learning spells based on skill difference (e.g. master always succeeds at learning novice spells)
* Configurable option to let automatic successes not count towards the max amount of spells learned per sleep
* Chance of potion addiction to kill you is now configurable
* Configurable option for the chance to learn a spell to scale with its difficulty
* Configurable option for casting spells to not only make you more likely to learn spells, but reduce the amount of time you have to wait before learning again on sleep
* A massively expanded MCM menu to support all these new options

Development Status
----------

* Currently, this mod's items will not spawn by themselves in the world. I am trying to work on a script-side way to add the items to loot lists so that it is configurable from the MCM without the need for separate ESPs.
* Dreadmilk's addiction function is currently broken. The debuff does not actually apply to the player when it should. Its functions related to enhancing spell learning still work, however.
* Disabling the mod does not currently remove its effects properly. This shouldn't cause any issues, but is not ideal. This should be solvable by somehow removing or retargeting the alias added by the mod's tracking quest which points to the player.
* I am still planning on implementing a "quiet" mode somehow that disables most/all messages from the mod, for players that don't like messages being spammed at the top left corner. This doesn't bother me unless it's excessive, but I can understand it's immersion breaking.
* If I can figure out a good way to do it, I would also like to add the option for a notification that tells the player when they are eligible to learn new spells on sleep.
* Preferably, adding randomized messages instead of the same message every time would be nice.
* Adding a spell to set the player-defined bonus location would be nice, so that you don't have to do it through the MCM.

Requirements
------------

The mod requires [SKSE](https://skse.silverlock.org/) to function. If you want to backup and restore your spell list, you will also need [FISS](https://www.nexusmods.com/skyrimspecialedition/mods/13956).

Compatibility
-------------

The Spell Learning features should be compatible with any spell. The Spell Discovery feature uses the game's leveled loot lists, so any spell mod that adds is spells to these lists will be compatible. Most spell mods do so, but Witchhunter Prayers & Spells, for example, doesn't.

This mod does currently add its items to Enthir's merchant inventory using an alias. This does not edit his merchant chest record itself, but it may be incompatible with mods that do.
