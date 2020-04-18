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



;======================================================================================;
;               EVENTS                     /
;=============/

Event OnEffectStart(Actor Target, Actor Caster)

    GlobalVariable GameHour = Game.GetForm(0x00000038) as GlobalVariable
    Float Time = GameHour.GetValue()
    Int Std = math.Floor(Time)
    
    if (Std != 0)
        Debug.notification("The summoning can only work at midnight")
        Return
    EndIf

    Int PassedTime = 1 ; 1 hour

    Time -= Std as Float
    Time += PassedTime
    Time += Std as Float
    Int Hours = math.Floor(PassedTime)
    Int Minutes = math.Floor((PassedTime - Hours as Float) * 100 as Float * 3 as Float / 5 as Float)
    

    Actor pl = Game.GetPlayer()

    int instanceID = IntroSoundFX.play((target as objectReference))          ; play IntroSoundFX sound from my self
    introFX.apply()                                  ; apply isMod at full strength
    
    
    game.DisablePlayerControls()
    Utility.wait(2)
    game.FadeOutGame(false, true, 2.00000, 4.0000)

    introFX.remove()                             ; remove initial FX
    mainFX.apply()

    Utility.wait(5)
    if (ControlScript._LEARN_CountBonus.GetValue() <= 30)
        ControlScript._LEARN_CountBonus.Mod(40)
        debug.notification("Learned something very insightful")
    Else
        Debug.notification("Interesting")
    EndIf    
    game.EnablePlayerControls()
    

    GameHour.SetValue(Time)
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)

    Actor pl = Game.GetPlayer()
    
    int instanceID = OutroSoundFX.play((target as objectReference))         ; play OutroSoundFX sound from my self
    introFX.remove()
    mainFX.remove()
    OutroFX.apply()


endEvent
