ScriptName _LEARN_Dreadstare extends ActiveMagicEffect

_LEARN_ControlScript property ControlScript  auto 
Actor property PlayerRef auto
GlobalVariable property _LEARN_ConsecutiveDreadmilk auto
MagicEffect property AlchDreadmilkEffect auto
Spell Property _LEARN_DiseaseDreadmilk Auto

string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction

Event OnInit()
	RegisterForSingleUpdateGameTime(24)
endEvent

Event OnUpdate()
	if (_LEARN_consecutiveDreadmilk.GetValue() > 0)
		_LEARN_consecutiveDreadmilk.Mod(-1)
		if (_LEARN_consecutiveDreadmilk.GetValue() <= 0 && !PlayerRef.HasMagicEffect(AlchDreadmilkEffect))
			_LEARN_consecutiveDreadmilk.SetValue(0)
			Debug.Notification(__l("notification_dreadmilk_out_of_system", "All the Dreadmilk is finally out of your system..."))
			if (PlayerRef.HasSpell(_LEARN_DiseaseDreadmilk))
				PlayerRef.RemoveSpell(_LEARN_DiseaseDreadmilk)
			endIf
		endIf
	endIf
	RegisterForSingleUpdateGameTime(24) ; If the magiceffect is removed, this registration will apparently automatically disappear. So no performance concern
endEvent

