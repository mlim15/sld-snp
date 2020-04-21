Scriptname _LEARN_StudyPowerEffect extends ActiveMagicEffect 

_LEARN_ControlScript property ControlScript auto
GlobalVariable property GameHour auto
Actor property PlayerRef auto
GlobalVariable property _LEARN_StudyIsRest auto
GlobalVariable property _LEARN_StudyRequiresNotes auto
GlobalVariable property _LEARN_LastDayStudied auto
GlobalVariable property _LEARN_CountBonus auto

ImageSpaceModifier property FadeToBlackImod auto
ImageSpaceModifier property FadeToBlackBackImod auto
ImageSpaceModifier property FadeToBlackHoldImod auto

Idle property IdleBook_Reading auto
Idle property IdleBook_TurnManyPages auto
Idle property IdleBookSitting_Reading auto
Idle property IdleBookSitting_TurnManyPages auto
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
	
	; Check all the reasons we might not want to study and display proper messages,
	; then quit without studying if any situation is true.
	if ((_LEARN_StudyIsRest.GetValue() == 1) && (ControlScript.hours_before_next_ok_to_learn() > 0))
		Debug.Notification(__l("notification_slept_too_soon", "It seems your mind isn't settled enough yet to learn any spells..."))
		return
	elseIf (_LEARN_LastDayStudied.GetValue() == 1)
		Debug.Notification(__l("notification_study_too_soon", "You've already studied today."))
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
	; Sitting or standing animations
	if (PlayerRef.GetSitState() >= 3)
		PlayerRef.PlayIdle(IdleBookSitting_Reading)
		Utility.wait(3)
		PlayerRef.PlayIdle(IdleBookSitting_TurnManyPages)
		Utility.Wait(4)
	else
		PlayerRef.PlayIdle(IdleBook_Reading)
		Utility.Wait(3)
		PlayerRef.PlayIdle(IdleBook_TurnManyPages)
		Utility.Wait(4)
	endIf
	; Fade out
	FadeToBlackImod.Apply()
	Utility.Wait(2)
	FadeToBlackImod.PopTo(FadeToBlackHoldImod)
	; Change time
	Utility.Wait(2)
	GameHour.SetValue(GameHour.Mod(1))
	; Free player from idle animation hell
	; and give back control
	PlayerRef.PlayIdle(IdleStop_Loose)
	Game.EnablePlayerControls()
	; Fade in
	FadeToBlackHoldImod.PopTo(FadeToBlackBackImod)
	FadeToBlackHoldImod.Remove()
	
	; Give bonus or do rest effect
	if (_LEARN_StudyIsRest.GetValue() == 1)
		ControlScript.OnSleepStop(false)
	else
		_LEARN_CountBonus.Mod(33)
		_LEARN_LastDayStudied.SetValue(1)
		Debug.Notification(__l("notification_study_progress", "You feel you've made some progress."))
	endIf
	
endEvent