Scriptname _LEARN_dreadmilk_effect extends activemagiceffect  

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
	
	ControlScript._LEARN_consecutiveDreadmilk.SetValue(ControlScript._LEARN_consecutiveDreadmilk.GetValue() + 1)
    
    ; Immediate relief of withdrawal symptoms
    if (PlayerRef.HasSpell(Dreadstare))
        PlayerRef.RemoveSpell(Dreadstare)
        Debug.Notification(__l("dreadmilk_feels good", "Your withdrawal symptoms are relieved - for now..."))
    endif
    
    float fRand
    ; Don't do (too much) drugs, kids.
    if (ControlScript._LEARN_ConsecutiveDreadmilk.GetValue() > 0)
        fRand = Utility.RandomFloat(0, 1.0)
        if (fRand < (ControlScript._LEARN_DreadstareLethality.getValue() / 100) - (ControlScript._LEARN_ConsecutiveDreadmilk.GetValue()/10))
            Utility.wait(4)
            Debug.Notification(__l("dreadmilk_overdosed", "You have overdosed on Dreadmilk."))
            Utility.wait(2)
            PlayerRef.kill()
            Return
        endif
    endif
	
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
    Actor PlayerRef = Game.GetPlayer()
    
    if (Target != PlayerRef)
        Return
    EndIf
    
    float fRand
    fRand = Utility.RandomFloat(0.0, 1.0)
    if (fRand > 0.5)
        if (!PlayerRef.HasSpell(Dreadstare) || ControlScript._LEARN_ConsecutiveDreadmilk.GetValue() > 0)
            Debug.Notification(__l("dreadmilk_need more", "You feel an excruciating yearning for more Dreadmilk..."))
			PlayerRef.AddSpell(Dreadstare)
        endif
    else

    endif
endEvent
