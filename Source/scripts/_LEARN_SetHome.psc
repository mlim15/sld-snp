Scriptname _LEARN_SetHome extends ActiveMagicEffect

_LEARN_ControlScript property ControlScript auto
GlobalVariable property _LEARN_LastSetHome auto
GlobalVariable property GameDaysPassed auto

string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction


string function __fs1(string source, string p1)
    return _LEARN_Strings.StringReplaceAll(source, "{0}", p1)
endFunction

event OnEffectStart(Actor Target, Actor Caster)

	; Check to see if we've already changed it in the last 7 days. If so, return without doing anything.
	if ((GameDaysPassed.GetValue() - _LEARN_LastSetHome.GetValue()) < 7)
		ControlScript.notify(__fs1(__l("notification_cannot_attune", "You can only attune once per week. Wait {0} day(s)."), ((_LEARN_LastSetHome.GetValue() - GameDaysPassed.GetValue() + 7) as int) as String), ControlScript.NOTIFICATION_FORCE_DISPLAY)
		return
	endIf
	
	; Get location
	Location l = Game.GetPlayer().GetCurrentLocation()
	if (ControlScript.customLocation != l)
		; If location isn't the current custom location, change it to 
		ControlScript.customLocation = l
		_LEARN_LastSetHome.SetValue(GameDaysPassed.GetValue())
		ControlScript.notify(__fs1(__l("notification_attune_success", "Successfully attuned to {0}."), l.GetName()), ControlScript.NOTIFICATION_FORCE_DISPLAY)
		return
	else
		; Already attuned to this environment or outside (which is undefined)?
		ControlScript.notify(__l("notification_already_attuned", "You cannot attune to this environment or have already attuned here."), ControlScript.NOTIFICATION_FORCE_DISPLAY)
		return
	endIf
		
endEvent