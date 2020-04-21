Scriptname _LEARN_shadowmilk_effect extends ActiveMagicEffect  

_LEARN_ControlScript property ControlScript  auto 
Actor property PlayerRef auto
GlobalVariable property _LEARN_consecutiveDreadmilk auto
GlobalVariable property _LEARN_DreadstareLethality auto
MagicEffect property AlchDreadmilkEffect auto
MagicEffect property AlchShadowmilkEffect auto
Spell property _LEARN_DiseaseDreadmilk auto
Spell property ShadowmilkOverdose auto

string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction

Event OnEffectStart(Actor Target, Actor Caster)
    
    ; Don't want to give instakill ability to reverse-pickpockets
    if (Target != PlayerRef)
        Return
    EndIf
   
    float fRand
	bool overdose = false
    ; Don't do (too much) drugs, kids.
    if (_LEARN_ConsecutiveDreadmilk.GetValue() > 5)
        fRand = Utility.RandomFloat(0, 1.0)
        if ((fRand / 4) < ((_LEARN_DreadstareLethality.GetValue() / 100) + (_LEARN_ConsecutiveDreadmilk.GetValue() / 40)))
            Debug.Notification(__l("notification_dreadmilk_overdosed", "You have overdosed."))
			overdose = true
			ShadowmilkOverdose.Cast(PlayerRef, PlayerRef)
        endif
    endif

	; Tell player it won't stave off dreadstare
    if (PlayerRef.HasSpell(_LEARN_DiseaseDreadmilk) && !overdose)
        Debug.Notification(__l("notification_dreadmilk_feels_bad_man", "You feel a little better, but it's not enough..."))
    endif
	
	; Increase blood toxicity if it's above 0.5 (i.e. dreadmilk has been used)
	if (ControlScript._LEARN_ConsecutiveDreadmilk.GetValue() > 0.5)
		_LEARN_consecutiveDreadmilk.Mod(0.5)
	endIf
EndEvent
