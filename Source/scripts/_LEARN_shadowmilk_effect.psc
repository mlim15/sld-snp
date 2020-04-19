Scriptname _LEARN_shadowmilk_effect extends activemagiceffect  

_LEARN_ControlScript Property ControlScript  Auto  
MagicEffect Property AlchDreadmilkEffect Auto
MagicEffect Property AlchShadowmilkEffect Auto
Spell Property Dreadstare Auto
Spell Property ShadowmilkOverdose auto

string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction

Event OnEffectStart(Actor Target, Actor Caster)
    
    Actor PlayerRef = Game.GetPlayer()
    
    ; Don't want to give instakill ability to reverse-pickpockets
    if (Target != PlayerRef)
        Return
    EndIf
   
    float fRand
	bool overdose = false
    ; Don't do (too much) drugs, kids.
    if (ControlScript._LEARN_ConsecutiveDreadmilk.GetValue() > 5)
        fRand = Utility.RandomFloat(0, 1.0)
        if ((fRand / 4) < ((ControlScript._LEARN_DreadstareLethality.GetValue() / 100) + (ControlScript._LEARN_ConsecutiveDreadmilk.GetValue() / 40)))
            Debug.Notification(__l("dreadmilk_overdosed", "You have overdosed."))
			overdose = true
			ShadowmilkOverdose.Cast(PlayerRef, PlayerRef)
        endif
    endif

	; Tell player it won't stave off dreadstare
    if (PlayerRef.HasSpell(Dreadstare) && !overdose)
        Debug.Notification(__l("dreadmilk_feels bad man", "You feel a little better, but it's not enough..."))
    endif
	
	; Increase blood toxicity if it's above 0.5 (i.e. dreadmilk has been used)
	if (ControlScript._LEARN_ConsecutiveDreadmilk.GetValue() > 0.5)
		ControlScript._LEARN_consecutiveDreadmilk.SetValue(ControlScript._LEARN_consecutiveDreadmilk.GetValue() + 0.5)
	endIf
EndEvent
