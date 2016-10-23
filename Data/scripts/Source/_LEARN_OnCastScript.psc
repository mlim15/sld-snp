scriptName _LEARN_OnCastScript extends ReferenceAlias

;-- Properties --------------------------------------
Spell property PracticeSpell auto

;-- Variables ---------------------------------------
Bool modDisabled = false

;-- Functions ---------------------------------------

;function OnUpdate()
;    globalMult = 1.00000
;endFunction

function OnInit()
    ; Debug.Notification("LEARN Oncastscript init")
    Actor learningme = Self.getActorRef()
    if (learningme)
        learningme.addspell(PracticeSpell, true)
    endif
endFunction

;function OnPlayerLoadGame()
    ;if EnableGameSettingsMod == true && modDisabled == false
    ;    utility.wait(5.00000)
    ;    game.SetGameSettingFloat("fCombatMagickaRegenRateMult", CustomGameSettingsVal)
    ;endIf
;endFunction
