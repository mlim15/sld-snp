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
    
    ; Don't do (too much) drugs, kids.
    if (PlayerRef.HasMagicEffect(AlchDreadmilkEffect))
        if (PlayerRef.HasSpell(Dreadstare) || PlayerRef.HasMagicEffect(AlchShadowmilkEffect))
            Utility.wait(4)
            Debug.Notification("Overdosed")
            Utility.wait(2)
            PlayerRef.kill()
        endif
        PlayerRef.AddSpell(Dreadstare)
    endif

EndEvent

; Event OnEffectFinish(Actor Target, Actor Caster)
;    Actor pl = Game.GetPlayer()
; endEvent