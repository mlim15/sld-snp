Scriptname _LEARN_dreadmilk_effect extends activemagiceffect  

_LEARN_ControlScript Property ControlScript  Auto  
MagicEffect Property AlchDreadmilkEffect Auto
MagicEffect Property AlchShadowmilkEffect Auto
Spell Property Dreadstare Auto
Spell Property _LEARN_DreadmilkOverdose auto
globalvariable property _LEARN_WaitForEffectFinish auto

string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction

Event OnEffectStart(Actor Target, Actor Caster)
	if(_LEARN_WaitForEffectFinish.GetValue() == 1)
		Utility.wait(5)
	endIf
    
    Actor PlayerRef = Game.GetPlayer()
    
    ; Don't want to give instakill ability to reverse-pickpockets
    if (Target != PlayerRef)
        Return
    EndIf
      
    float fRand
	bool overdose = false
    ; Don't do (too much) drugs, kids.
    if (ControlScript._LEARN_ConsecutiveDreadmilk.GetValue() > 0)
        fRand = Utility.RandomFloat(0, 1.0)
        if (fRand < (ControlScript._LEARN_DreadstareLethality.getValue() / 100) + (ControlScript._LEARN_ConsecutiveDreadmilk.GetValue()/10))
            Debug.Notification(__l("dreadmilk_overdosed", "You have overdosed."))
			overdose = true
			_LEARN_DreadmilkOverdose.Cast(PlayerRef)
        endif
    endif
	
	; Immediate relief of withdrawal symptoms if you're not dead
    if (PlayerRef.HasSpell(Dreadstare) && !overdose)
        PlayerRef.RemoveSpell(Dreadstare)
        Debug.Notification(__l("dreadmilk_feels good", "Your withdrawal symptoms are relieved - for now..."))
    endif
	
	; Increase blood toxicity
	ControlScript._LEARN_consecutiveDreadmilk.SetValue(ControlScript._LEARN_consecutiveDreadmilk.GetValue() + 1)
	
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
	_LEARN_WaitForEffectFinish.SetValue(1)

    Actor PlayerRef = Game.GetPlayer()
    
    if (Target != PlayerRef)
        Return
    EndIf
    
    float fRand
    fRand = Utility.RandomFloat(0.0, 1.0)
	; Addiction will always return if it has been used while blood is toxic.
	; Otherwise there is a 50% chance to get addicted.
	if ((!PlayerRef.HasSpell(Dreadstare) && (fRand > 0.5)) || ControlScript._LEARN_ConsecutiveDreadmilk.GetValue() > 0)
		Debug.Notification(__l("dreadmilk_need more", "You feel an excruciating yearning for more Dreadmilk..."))
		PlayerRef.AddSpell(Dreadstare)
	endif
	
	_LEARN_WaitForEffectFinish.SetValue(0)
endEvent
