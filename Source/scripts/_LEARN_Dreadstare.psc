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
	; This could possibly be used with OnUpdate or GameTime events to change how the toxicity system works in a future update
endEvent

Event OnUpdate()
	; This could possibly be used with OnUpdate or GameTime events to change how the toxicity system works in a future update
endEvent

