Scriptname _LEARN_dreadmilk_effect extends ActiveMagicEffect  

_LEARN_ControlScript property ControlScript  auto 
Actor property PlayerRef auto
GlobalVariable property _LEARN_consecutiveDreadmilk auto
GlobalVariable property _LEARN_DreadstareLethality auto
MagicEffect property AlchDreadmilkEffect auto
MagicEffect property AlchShadowmilkEffect auto
Spell property _LEARN_DiseaseDreadmilk auto
Spell property DreadmilkOverdose auto

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
    if (_LEARN_ConsecutiveDreadmilk.GetValue() > 0)
        fRand = Utility.RandomFloat(0, 1.0)
        if (fRand < (_LEARN_DreadstareLethality.getValue() / 100) + (_LEARN_ConsecutiveDreadmilk.GetValue()/10))
            Debug.Notification(__l("dreadmilk_overdosed", "You have overdosed."))
			overdose = true
			DreadmilkOverdose.Cast(PlayerRef, PlayerRef)
        endif
    endif
	
	; Immediate relief of withdrawal symptoms if you're not dying
    if (PlayerRef.HasSpell(_LEARN_DiseaseDreadmilk) && !overdose)
        PlayerRef.RemoveSpell(_LEARN_DiseaseDreadmilk)
        Debug.Notification(__l("dreadmilk_feels good", "Your withdrawal symptoms are relieved - for now..."))
    endif
	
	; Increase blood toxicity
	_LEARN_consecutiveDreadmilk.Mod(1)
	
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
    
    if (Target != PlayerRef)
        Return
    EndIf
    
    float fRand
    fRand = Utility.RandomFloat(0.0, 1.0)
	; Addiction will always return if it has been used while blood is toxic.
	; Otherwise there is a 50% chance to get addicted.
	if ((!PlayerRef.HasSpell(_LEARN_DiseaseDreadmilk) && (!PlayerRef.HasMagicEffect(AlchDreadmilkEffect) && (fRand > 0.5))) || (_LEARN_ConsecutiveDreadmilk.GetValue() > 0 && (!PlayerRef.HasMagicEffect(AlchDreadmilkEffect))))
		Debug.Notification(__l("dreadmilk_need more", "You feel an excruciating yearning for more Dreadmilk..."))
		PlayerRef.AddSpell(_LEARN_DiseaseDreadmilk)
	endif
	
endEvent
