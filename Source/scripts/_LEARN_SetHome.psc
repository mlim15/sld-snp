Scriptname _LEARN_SetHome extends ActiveMagicEffect

_LEARN_ControlScript property ControlScript auto

string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction

string function formatString1(string target, string replace = "")
    return ControlScript.formatString1(target, replace);
endFunction

event OnEffectStart(Actor Target, Actor Caster)

	; Check to see if we've already changed it in the last 7 days. If so, return without doing anything.
	if (ControlScript._LEARN_SinceLastSetHome.GetValue() <= 6)
		Debug.Notification(__l("notification_cannot_attune", "You've attuned to a new environment too recently."))
		return
	endIf
	
	; Get location
	Location l = Game.GetPlayer().GetCurrentLocation()
	if (ControlScript.customLocation != l)
		; If location isn't the current custom location, change it to 
		ControlScript.customLocation = l
		ControlScript._LEARN_SinceLastSetHome.SetValue(0)
		Debug.Notification(formatString1(__l("notification_attune_success", "Successfully attuned to {0}."), l.GetName()))
	else
		; Already attuned to this environment or outside (which is undefined)?
		Debug.Notification(__l("notification_already_attuned", "You cannot attune to this environment or have already attuned here."))
	endIf
		
endEvent

Event OnEffectFinish(Actor Target, Actor Caster)

	; Not doing anything here for now but I might want it later

endEvent