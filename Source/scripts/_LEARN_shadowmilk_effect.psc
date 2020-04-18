Scriptname _LEARN_shadowmilk_effect extends activemagiceffect  

_LEARN_ControlScript Property ControlScript  Auto  
MagicEffect Property AlchDreadmilkEffect Auto
MagicEffect Property AlchShadowmilkEffect Auto
Spell Property Dreadstare Auto

Event OnEffectStart(Actor Target, Actor Caster)
    
    Actor PlayerRef = Game.GetPlayer()
    
    ; Don't want to give instakill ability to reverse-pickpockets
    if (Target != PlayerRef)
        Return
    EndIf
    
    float fRand
    ; Don't do (too much) drugs, kids.
    if (PlayerRef.HasMagicEffect(AlchDreadmilkEffect))
        fRand = Utility.RandomFloat(0, 1.0)
        if ((fRand / 4) < (ControlScript._LEARN_DreadstareLethality.GetValue() / 100))
            Utility.wait(4)
            Debug.Notification(ControlScript.__l("dreadmilk_overdosed", "You have overdosed on dreadmilk."))
            Utility.wait(2)
            PlayerRef.kill()
            Return
        endif
    endif

EndEvent
