Scriptname _LEARN_shadowmilk_effect extends activemagiceffect  

_LEARN_ControlScript Property ControlScript  Auto  
MagicEffect Property AlchDreadmilkEffect Auto
MagicEffect Property AlchShadowmilkEffect Auto
Spell Property Dreadstare Auto

string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction

Event OnEffectStart(Actor Target, Actor Caster)
    
    Actor PlayerRef = Game.GetPlayer()
    
    ; Don't want to give instakill ability to reverse-pickpockets
    if (Target != PlayerRef)
        Return
    EndIf
	
	; Tell player it won't stave off dreadstare
    if (PlayerRef.HasSpell(Dreadstare))
        Debug.Notification(__l("dreadmilk_feels good", "You feel a little better, but it's not enough..."))
    endif
    
    float fRand
    ; Don't do (too much) drugs, kids.
    if (ControlScript._LEARN_ConsecutiveDreadmilk.GetValue() > 0)
        fRand = Utility.RandomFloat(0, 1.0)
        if ((fRand / 4) < (ControlScript._LEARN_DreadstareLethality.GetValue() / 100 - (ControlScript._LEARN_ConsecutiveDreadmilk.GetValue()/40)))
            Utility.wait(4)
            Debug.Notification(__l("dreadmilk_overdosed", "You have overdosed on Dreadmilk."))
            Utility.wait(2)
            PlayerRef.kill()
            Return
        endif
    endif

EndEvent
