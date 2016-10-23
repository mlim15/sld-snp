;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname _LEARN_TIF_MagicTheory2 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; Utility.wait(2)
;    game.FadeOutGame(false, true, 5.00000, 10.0000)

    Debug.notification("An hour passes")

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
    
    if (ControlScript._LEARN_CountBonus.GetValue() <= 30)
        ControlScript._LEARN_CountBonus.Mod(40)
        debug.notification("Learned something very insightful")
    Else
        Debug.notification("Interesting")
    EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

_LEARN_ControlScript Property ControlScript  Auto  
