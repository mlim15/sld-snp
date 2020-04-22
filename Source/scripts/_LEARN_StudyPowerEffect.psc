Scriptname _LEARN_StudyPowerEffect extends ActiveMagicEffect 

_LEARN_ControlScript property ControlScript auto
GlobalVariable property GameHour auto
Actor property PlayerRef auto
GlobalVariable property _LEARN_StudyIsRest auto
GlobalVariable property _LEARN_StudyRequiresNotes auto
GlobalVariable property _LEARN_LastDayStudied auto
GlobalVariable property _LEARN_CountBonus auto
GlobalVariable property _LEARN_DiscoverOnStudy auto
GlobalVariable property _LEARN_LearnOnStudy auto

ImageSpaceModifier property FadeToBlackImod auto
ImageSpaceModifier property FadeToBlackBackImod auto
ImageSpaceModifier property FadeToBlackHoldImod auto

Idle property IdleBook_Reading auto
Idle property IdleBook_TurnManyPages auto
Idle property IdleStop_Loose auto

string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction

Event OnEffectStart(Actor Target, Actor Caster)

	; Check independently configurable option separately
	if (_LEARN_StudyRequiresNotes.GetValue() == 1 && ControlScript.getTotalNotes() == 0)
		Debug.Notification(__l("notification_study_no_notes", "You can't study without any notes..."))
		return
	endIf
	
	; Ensure there are actually spells to study if StudyIsRest is on
	if (_LEARN_StudyIsRest.GetValue() == 1 && ControlScript.spell_fifo_get_count() == 0)
		Debug.Notification(__l("notification_study_no_spells", "You don't have any spell ideas to research right now."))
		return
	endIf
	
	; Check all the reasons we might not want to study and display proper messages,
	; then quit without studying if any situation is true.
	if ((_LEARN_StudyIsRest.GetValue() == 1) && (ControlScript.hours_before_next_ok_to_learn() > 0))
		Debug.Notification(__l("notification_studied_too_soon", "Your mind isn't yet settled enough to do more research."))
		return
	elseIf (_LEARN_LastDayStudied.GetValue() == 1 && (_LEARN_StudyIsRest.GetValue() == 1))
		Debug.Notification(__l("notification_studied_too_soon", "Your mind isn't yet settled enough to do more research."))
		return
	elseIf (PlayerRef.IsInCombat())
		Debug.Notification(__l("notification_study_in_combat", "You can't study in combat!"))
		return
	elseIf (PlayerRef.IsTrespassing())
		Debug.Notification(__l("notification_study_trespassing", "You'll surely be discovered if you stop to study here!"))
		return
	elseIf (PlayerRef.IsSwimming())
		Debug.Notification(__l("notification_study_swimming", "You'll ruin your notes if you try to study here!"))
		return
	endIf
	
	; If we've reached here, the player can study. 
	; Start our animations and things.
	Game.DisablePlayerControls()		
	Game.ForceThirdPerson()
	PlayerRef.PlayIdle(IdleBook_Reading)
	Utility.Wait(2)
	PlayerRef.PlayIdle(IdleBook_TurnManyPages)
	Utility.Wait(2)
	; Fade out
	FadeToBlackImod.Apply()
	Utility.Wait(2)
	FadeToBlackImod.PopTo(FadeToBlackHoldImod)
	; Change time while screen is black
	Utility.Wait(4)
	GameHour.SetValue(GameHour.Mod(1))
	; Free player from idle animation hell
	; and give back control
	PlayerRef.PlayIdle(IdleStop_Loose)
	Game.EnablePlayerControls()
	; Fade back in
	FadeToBlackHoldImod.PopTo(FadeToBlackBackImod)
	FadeToBlackHoldImod.Remove()
	
	; Give bonus or do rest effect
	if (_LEARN_StudyIsRest.GetValue() == 1)
		if (_LEARN_LearnOnStudy.GetValue() == 1)
			ControlScript.doLearning()
		endIf
		if (_LEARN_DiscoverOnStudy.GetValue() == 1)
			ControlScript.doDiscovery()
		endIf
		ControlScript.doReset()
	else
		float bonus = 0
		; Give scaling bonus based on amount of notes in inventory
		; The number of notes possessed by the player is related to the value of the spells they have read.
		; So this value is normalized by comparing the value of a core spellbook 
		; (in this case Candlelight) to accomodate some mods which alter the spell tome values. 
		Book refCandleLight = Game.GetForm(0x0009E2A7) as Book
		float priceFactor = refCandleLight.GetGoldValue() / 44
		float notes = ControlScript.getTotalNotes()
		notes = notes / pricefactor
		bonus = notes / 600
		; Formula is gives 1/9 of max chance (value of 30) for studying when carrying total 18000 
		; gold worth of notes. 2/9 is given using only school-specific notes in the roll script 
		; and is capped at a value of 3600. So for 5 schools, we cap at a value of 18k.
		if bonus > 30
			bonus = 30
		endIf
		_LEARN_CountBonus.Mod(bonus)
		_LEARN_LastDayStudied.SetValue(1)
		Debug.Notification(__l("notification_study_progress", "You feel you've made some progress."))
	endIf
	
endEvent