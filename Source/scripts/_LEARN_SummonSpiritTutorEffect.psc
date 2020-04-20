Scriptname _LEARN_SummonSpiritTutorEffect extends ActiveMagicEffect  

ImageSpaceModifier property IntroFX auto
ImageSpaceModifier property MainFX auto
ImageSpaceModifier property OutroFX auto
sound property IntroSoundFX auto
sound property OutroSoundFX auto

Spell Property Dreadstare Auto
Spell Property TutorPrice01 Auto
Spell Property TutorPrice02 Auto

_LEARN_ControlScript Property ControlScript  Auto

string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction

Event OnEffectStart(Actor Target, Actor Caster)

    GlobalVariable GameHour = Game.GetForm(0x00000038) as GlobalVariable
    Actor PlayerRef = Game.GetPlayer()
    Float Time = GameHour.GetValue()
    Int Std = math.Floor(Time)
    
    ; This debug message will never appear anyway because the spell has a built-in condition with the time,
    ; and if it fails that condition, the spell is never cast so this script doesn't ever start.
    ;if ! (Std <= 3 || Std == 23)
    ;    Debug.Notification(__l("notification_spirit_summon only at midnight", "The ritual only has effect around midnight..."))
    ;    Return
    ;EndIf

    int instanceID = IntroSoundFX.play((target as objectReference))
    introFX.apply()
    
    game.DisablePlayerControls()
    Utility.waitmenumode(2)
    game.FadeOutGame(false, true, 2.00000, 4.0000)

    introFX.remove()
    mainFX.apply()

    Utility.waitmenumode(5)
    ControlScript._LEARN_CountBonus.Mod(100) ; same bonus as shadowmilk
    debug.notification(__l("notification_spirit_glimpsed", "The dark whispers give a glimpse of the unfathomable..."))
    
    game.EnablePlayerControls()
	
    ; Extract a price
	float fRand
	fRand = Utility.RandomFloat(0.0, 1.0)
	if (fRand > 0.95)
		; 5% chance to become addicted to Dreadmilk
		if (!PlayerRef.HasSpell(Dreadstare))
			PlayerRef.AddSpell(Dreadstare)
			Debug.Notification(__l("notification_spirit_need_more_sudden", "You suddenly feel an excruciating yearning for Dreadmilk..."))
		endIf
		ControlScript._LEARN_ConsecutiveDreadmilk.SetValue(ControlScript._LEARN_ConsecutiveDreadmilk.GetValue() + 2)
	elseIf (fRand > 0.9)
		; forget the last spell on your list
		ControlScript.spell_fifo_remove_last()
		Debug.Notification(__l("notification_spirit_forgot_spell", "You've forgotten something... but what?"))
	elseIf (fRand > 0.8)
		; lose gold
		PlayerRef.removeitem(Game.getform(0xF), 500)
		Debug.Notification(__l("notification_spirit_lost_money", "Your pockets suddenly feel lighter."))
	elseIf (fRand > 0.6)
		; reduce max destro and resto for 1 in-game day
		TutorPrice02.Cast(PlayerRef, PlayerRef)
		Debug.Notification(__l("notification_spirit_drained", "You suddenly feel very drained..."))
	elseIf (fRand > 0.4)
		; reduce max health and magicka for 1 in-game day
		TutorPrice01.Cast(PlayerRef, PlayerRef)
		Debug.Notification(__l("notification_spirit_weaker", "You suddenly feel very tired..."))
	endIf

	; Prevent using tutor again until next spell learn attempt
	ControlScript._LEARN_AlreadyUsedTutor.SetValue(1)
	
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)

    int instanceID = OutroSoundFX.play((target as objectReference))
    introFX.remove()
    mainFX.remove()
    OutroFX.apply()

endEvent
