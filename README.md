Spell Learning and Discovery SnP
=========================

A continuation of the Skyrim mod originally created by /u/bepo from Reddit. This mod has passed through many hands over the years, with versions on [Reddit](https://www.reddit.com/r/skyrimmods/comments/58lovp/please_adopt_my_mod_spell_learning/), [GitHub](https://github.com/ttrebuchon/Skyrim_Spell_Learning), and two published versions on Nexus Mods by [auie4545 for LE](https://www.nexusmods.com/skyrim/mods/87495) and [nexusishere for SSE](https://www.nexusmods.com/skyrimspecialedition/mods/17446). This version of the mod is for Skyrim Special Edition (SSE).

Summary
-------

Isn't it weird that in vanilla Skyrim, you learn spells *instantly* by *destroying books*? This mod seeks to create a more immersive, realistic, and slow way of learning spells that is relatively lightweight, compatible with most spell mods without patching, and (mostly) lore-friendly. It aims to remain simple enough that you can install it and set it up, and it will keep working in the background in an understandable and non-immersion-breaking way without you ever having to reenter its MCM.

Instead of the vanilla system, with this mod any books you buy or pick up are automatically added to a list of spells your character is studying. Each time they sleep or use a new 'Study' lesser power (with a configurable time limit), they will attempt to learn a spell from this list. Their chances to learn the spell successfully depend on their overall magical skill, their skill in the spell's specific school, the amount of spells of that school they have cast since last learning a spell, whether they have slept in a location that is "suited" for studying magic (like a temple, the College, or a player-set location), and more.

Optionally (and by default), the mod also deconstructs all books you recieve into notes on the spell's school of magic. The idea is that these notes are used by mages in their research on similar spells. Keeping lots of Destruction notes on your character will help you learn new Destruction spells more effectively, for example. It also would make sense that if all mages use these notes, they are tradeable and in demand, and this preserves the value of spell tomes - the amount of notes generated is related to the value of the tome deconstructed, meaning you can still sell the notes for the same amount of gold if you wish. Alternatively, you can grow your collection and make learning new spells easier.

The mod also provides a simple spell discovery system - shouldn't mages be able to come up with new ideas for spells by themselves, without learning from a book? If it is enabled, your character can come up with ideas for spells themselves when they sleep. The chance for this to happen is configurable. By default, if this happens, the spell will be of the school they have cast most often since their last rest. Spells "discovered" this way are pulled from level-appropriate lists (the same ones the game uses to generate loot). They are added to the list of spells your character will try to learn when sleeping, without the need to buy or find its spellbook.

Why
-------------

Similar mods that take differing approaches to this problem:

* [Better Spell Learning](https://www.nexusmods.com/skyrimspecialedition/mods/4924)
* [Challenging Spell Learning](https://www.nexusmods.com/skyrimspecialedition/mods/20521)
* [Immersive Spell Learning](https://www.nexusmods.com/skyrimspecialedition/mods/33375)
* [Spell Research](https://www.nexusmods.com/skyrimspecialedition/mods/20983)

A lot of people have made mods tackling this problem. Some of them have been staples for me in the past. But now I have a lot of free time on my hands, so I figured I would try to put something together totally suited to my personal preferences. What are those preferences?

* Gameplay should not be a chore for the player. I want my character to do the chores in the background. No repeatedly using specific items, or micromanaging anything.
* Should not require patches to support other mods if possible.
* Do not force the use of menus for gameplay. I want to play the game, not the menu. Set it up once and leave it alone.

Then I found this mod. It was a great balance... but it felt somewhat unpolished, the mod's functionality was relatively opaque to the end-user, and I wanted it to be a little more configurable. If I could have just disabled all the parts of the mod I didn't like, I would have done that and called it a day. But those options weren't exposed to the user. Thankfully, sources were provided under permissive terms for this project by all the authors involved. Initially I just wanted to make a couple tweaks, then I started adding a couple little features and config settings... and another... and another... and now we're here. All I've really done is added a little SnP. What's SnP? Maybe the base mod was a great meal that just needed a little salt and pepper. Maybe it was a nice pair of boots that needed a little spit and polish. It's SnP.

Requirements
------------

The mod requires [SKSE](https://skse.silverlock.org/) to function. If you want to backup and restore your spell list, you will also need [FISS](https://www.nexusmods.com/skyrimspecialedition/mods/13956). For localization support, you'll also need [PapyrusUtil SE](https://www.nexusmods.com/skyrimspecialedition/mods/13048).

Compatibility
-------------

The Spell Learning features should be compatible with any spell. The Spell Discovery feature uses the game's leveled loot lists, so any spell mod that adds its spells to these lists will be compatible. Most spell mods do so.

Installation
-------------

As usual, you can install the mod by adding the zip file from [GitHub's Releases page](https://github.com/mlim15/Skyrim_Spell_Learning/releases) to Mod Organizer or whatever tool you prefer. Alternatively, drag its contents to your Data folder.

Once you get in-game, the mod will set itself up without your intervention. Note that the mod only removes spellbooks when they enter your inventory. This means you can still read books that you already had in your inventory before you installed the mod to instantly learn the spells, as in vanilla. If you want to learn those spells with the mod instead, just drop the books on the floor and pick them up. Then the mod will process them according to your configuration.

Development Status
----------

I have basically added all of the features and options that I thought were interesting, and at this point the level of polish is satisfactory to me.

* I am still planning on trying to implement a "quiet" mode at some point to disables most/all messages from the mod, for players that don't like messages being spammed at the top left corner. This doesn't bother me unless it's excessive, but I can understand it's immersion breaking.
* Adding randomized messages instead of the same message every time might also be nice.
* Replacing the alias used to spawn items in Enthir's inventory with something scriptable/configurable

Known Problems
----------

* For some reason, it can sometimes literally take several minutes of real time for the MCM menu to be registered. I don't know why this happens but the mod is still functional while the menu is inaccessible. Just be aware.
* The way Skyrim handles picking up books seems to mean that if you drop a stack of them on the floor, picking up that stack only adds one copy to your inventory. As a result, dropping notes on the floor and picking them up will result in you losing all but one of the notes you dropped. So don't drop your notes on the ground.
