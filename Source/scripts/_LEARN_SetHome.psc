Scriptname _LEARN_SetHome extends ActiveMagicEffect

_LEARN_ControlScript property ControlScript auto
GlobalVariable property _LEARN_LastSetHome auto
GlobalVariable property GameDaysPassed auto

string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction

string function __f1(string target, string replace = "")
    return ControlScript.formatString1(target, replace);
endFunction

event OnEffectStart(Actor Target, Actor Caster)

	; Check to see if we've already changed it in the last 7 days. If so, return without doing anything.
	if ((GameDaysPassed.GetValue() - _LEARN_LastSetHome.GetValue()) < 7)
		Debug.Notification(__f1(__l("notification_cannot_attune", "You can only attune once per week. Wait {0} day(s)."), (GameDaysPassed.GetValue() - _LEARN_LastSetHome.GetValue() as String)))
		return
	endIf
	
	; Get location
	Location l = Game.GetPlayer().GetCurrentLocation()
	if (ControlScript.customLocation != l)
		; If location isn't the current custom location, change it to 
		ControlScript.customLocation = l
		_LEARN_LastSetHome.SetValue(GameDaysPassed.GetValue())
		Debug.Notification(__f1(__l("notification_attune_success", "Successfully attuned to {0}."), l.GetName()))
		return
	else
		; Already attuned to this environment or outside (which is undefined)?
		Debug.Notification(__l("notification_already_attuned", "You cannot attune to this environment or have already attuned here."))
		return
	endIf
		
endEvent