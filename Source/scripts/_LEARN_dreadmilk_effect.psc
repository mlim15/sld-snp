Scriptname _LEARN_dreadmilk_effect extends activemagiceffect  

_LEARN_ControlScript Property ControlScript  Auto  
MagicEffect Property AlchDreadmilkEffect Auto
MagicEffect Property AlchShadowmilkEffect Auto
Spell Property Dreadstare Auto
Spell Property _LEARN_DreadmilkOverdose auto

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
	Spell DreadmilkOverdose = Game.GetFormFromFile(0x045E63, "Spell Learning.esp") as Spell
    if (ControlScript._LEARN_ConsecutiveDreadmilk.GetValue() > 0)
        fRand = Utility.RandomFloat(0, 1.0)
        if (fRand < (ControlScript._LEARN_DreadstareLethality.getValue() / 100) + (ControlScript._LEARN_ConsecutiveDreadmilk.GetValue()/10))
            Debug.Notification(__l("dreadmilk_overdosed", "You have overdosed."))
			overdose = true
			DreadmilkOverdose.Cast(PlayerRef, PlayerRef)
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

    Actor PlayerRef = Game.GetPlayer()
    
    if (Target != PlayerRef)
        Return
    EndIf
    
    float fRand
    fRand = Utility.RandomFloat(0.0, 1.0)
	; Addiction will always return if it has been used while blood is toxic.
	; Otherwise there is a 50% chance to get addicted.
	if ((!PlayerRef.HasSpell(Dreadstare) && (!PlayerRef.HasMagicEffect(AlchDreadmilkEffect) && (fRand > 0.5))) || (ControlScript._LEARN_ConsecutiveDreadmilk.GetValue() > 0 && (!PlayerRef.HasMagicEffect(AlchDreadmilkEffect))))
		Debug.Notification(__l("dreadmilk_need more", "You feel an excruciating yearning for more Dreadmilk..."))
		PlayerRef.AddSpell(Dreadstare)
	endif
	
endEvent
