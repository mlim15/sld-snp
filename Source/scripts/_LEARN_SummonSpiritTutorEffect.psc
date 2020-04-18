Scriptname _LEARN_SummonSpiritTutorEffect extends ActiveMagicEffect  

;======================================================================================;
;               PROPERTIES  /
;=============/

ImageSpaceModifier property IntroFX auto
{IsMod applied at the start of the spell effect}
ImageSpaceModifier property MainFX auto
{main isMod for spell}
ImageSpaceModifier property OutroFX auto
{IsMod applied at the end of the spell effect}
sound property IntroSoundFX auto ; create a sound property we'll point to in the editor
sound property OutroSoundFX auto ; create a sound property we'll point to in the editor

_LEARN_ControlScript Property ControlScript  Auto  

string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction

;======================================================================================;
;               EVENTS                     /
;=============/

Event OnEffectStart(Actor Target, Actor Caster)
    GlobalVariable GameHour = Game.GetForm(0x00000038) as GlobalVariable
    Float Time = GameHour.GetValue()
    Int Std = math.Floor(Time)
    
    if ! (Std <= 3 || Std == 23)
        Debug.Notification(__l("spirit_summon only at midnight", "The ritual only has effect around midnight..."))
        Return
    EndIf

    int instanceID = IntroSoundFX.play((target as objectReference))          ; play IntroSoundFX sound from my self
    introFX.apply()                                  ; apply isMod at full strength
    
    game.DisablePlayerControls()
    Utility.waitmenumode(2)
    game.FadeOutGame(false, true, 2.00000, 4.0000)

    introFX.remove()                             ; remove initial FX
    mainFX.apply()

    Utility.waitmenumode(5)
    ControlScript._LEARN_CountBonus.Mod(100) ; same bonus as shadowmilk
    debug.notification(__l("spirit_glimpsed", "The dark whispers give a glimpse of the unfathomable..."))
    game.EnablePlayerControls()
    
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)

    int instanceID = OutroSoundFX.play((target as objectReference))         ; play OutroSoundFX sound from my self
    introFX.remove()
    mainFX.remove()
    OutroFX.apply()

endEvent
