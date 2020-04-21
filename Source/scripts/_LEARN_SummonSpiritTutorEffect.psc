Scriptname _LEARN_SummonSpiritTutorEffect extends ActiveMagicEffect  

_LEARN_ControlScript property ControlScript  auto
;GlobalVariable property GameHour auto
GlobalVariable property GameDaysPassed auto
Actor property PlayerRef auto
GlobalVariable property _LEARN_CountBonus auto
GlobalVariable property _LEARN_ConsecutiveDreadmilk auto
GlobalVariable property _LEARN_AlreadyUsedTutor auto

ImageSpaceModifier property IntroFX auto
ImageSpaceModifier property MainFX auto
ImageSpaceModifier property OutroFX auto
ImageSpaceModifier property FadeToBlackImod auto
ImageSpaceModifier property FadeToBlackBackImod auto
ImageSpaceModifier property FadeToBlackHoldImod auto
Sound property IntroSoundFX auto
Sound property OutroSoundFX auto

Spell property _LEARN_DiseaseDreadmilk Auto
Spell property _LEARN_TutorPriceSp Auto
Spell property _LEARN_TutorPriceSp2 Auto

string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction

Event OnEffectStart(Actor Target, Actor Caster)

    ; This debug message will never appear anyway because the spell has a built-in condition with the time,
    ; and if it fails that condition, the spell is never cast so this script doesn't ever start.
    ;Int Std = math.Floor(GameHour.GetValue())
    ;if ! (Std <= 3 || Std == 23)
    ;    Debug.Notification(__l("notification_spirit_summon only at midnight", "The ritual only has effect around midnight..."))
    ;    Return
    ;EndIf

    int instanceID = IntroSoundFX.play((target as objectReference))
    introFX.apply()
    
    game.DisablePlayerControls()
    Utility.waitmenumode(3)
	
	; Fade out and back
	FadeToBlackImod.Apply()
	Utility.Wait(1)
	FadeToBlackImod.PopTo(FadeToBlackHoldImod)
	Utility.Wait(1)
	FadeToBlackHoldImod.PopTo(FadeToBlackBackImod)
	FadeToBlackHoldImod.Remove()
	Utility.Wait(1)
	
    introFX.remove()
    mainFX.apply()

    Utility.waitmenumode(5)
    _LEARN_CountBonus.Mod(100) ; same bonus as shadowmilk
    debug.notification(__l("notification_spirit_glimpsed", "The dark whispers give a glimpse of the unfathomable..."))
    
    game.EnablePlayerControls()
	
    ; Extract a price
    float fRand
    fRand = Utility.RandomFloat(0.0, 1.0)
	if (fRand > 0.95)
		; 5% chance to become addicted to Dreadmilk
		if (!PlayerRef.HasSpell(_LEARN_DiseaseDreadmilk))
			PlayerRef.AddSpell(_LEARN_DiseaseDreadmilk)
			Debug.Notification(__l("notification_spirit_need_more_sudden", "You suddenly feel an excruciating yearning for Dreadmilk..."))
		endIf
		_LEARN_ConsecutiveDreadmilk.Mod(2)
	elseIf (fRand > 0.9)
		; forget the last spell on your list
		ControlScript.spell_fifo_remove_last()
		Debug.Notification(__l("notification_spirit_forgot_spell", "You've forgotten something... but what?"))
	elseIf (fRand > 0.8)
		; lose gold
		PlayerRef.RemoveItem(Game.getform(0xF), 500)
		Debug.Notification(__l("notification_spirit_lost_money", "Your pockets suddenly feel lighter."))
	elseIf (fRand > 0.6)
		; reduce max destro and resto for 1 in-game day
		_LEARN_TutorPriceSp.Cast(PlayerRef, PlayerRef)
		Debug.Notification(__l("notification_spirit_drained", "You suddenly feel very drained..."))
	elseIf (fRand > 0.4)
		; reduce max health and magicka for 1 in-game day
		_LEARN_TutorPriceSp2.Cast(PlayerRef, PlayerRef)
		Debug.Notification(__l("notification_spirit_weaker", "You suddenly feel very tired..."))
	endIf

	; Prevent using tutor again until next spell learn attempt
	_LEARN_AlreadyUsedTutor.SetValue(1)
	
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)

    int instanceID = OutroSoundFX.play((target as objectReference))
    introFX.remove()
    mainFX.remove()
    OutroFX.apply()

endEvent
