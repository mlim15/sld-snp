;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname SF__LEARN_DialogueScene1_020048D8 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
_LEARN_ControlScript ControlScript = GetOwningQuest() as _LEARN_ControlScript
    Utility.wait(2)
    game.FadeOutGame(false, true, 5.00000, 10.0000)

    GlobalVariable GameHour = Game.GetForm(0x00000038) as GlobalVariable
    Int PassedTime = 1 ; 1 hour
    Float Time = GameHour.GetValue()
    Int Std = math.Floor(Time)
    Time -= Std as Float
    Time += PassedTime
    Time += Std as Float
    Int Hours = math.Floor(PassedTime)
    Int Minutes = math.Floor((PassedTime - Hours as Float) * 100 as Float * 3 as Float / 5 as Float)
    GameHour.SetValue(Time)
    
    if (ControlScript._LEARN_CountBonus.GetValue() <= 0)
        ControlScript._LEARN_CountBonus.Mod(30)
        debug.notification(ControlScript.__l("Insightful"))
    Else
        Debug.notification(ControlScript.__l("Interesting"))
    EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
