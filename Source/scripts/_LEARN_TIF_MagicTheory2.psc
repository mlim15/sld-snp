;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname _LEARN_TIF_MagicTheory2 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
; Utility.wait(2)
;    game.FadeOutGame(false, true, 5.00000, 10.0000)


    GlobalVariable GameHour = Game.GetForm(0x00000038) as GlobalVariable
    Int PassedTime = 1 ; 1 hour
    Float Time = GameHour.GetValue()
    Int Std = math.Floor(Time)
    
    if (ControlScript._LEARN_CountBonus.GetValue() <= 30)
        Time -= Std as Float
        Time += PassedTime
        Time += Std as Float
        GameHour.SetValue(Time)
        Debug.notification(__l("An hour passes"))
        ControlScript._LEARN_CountBonus.Mod(40)
        debug.notification(__l("Learned something very insightful"))
    Else
        PassedTime = 4 ; 4 hours
        Time -= Std as Float
        Time += PassedTime
        Time += Std as Float
        GameHour.SetValue(Time)
        Debug.notification(__l("Half a day passes"))
        ControlScript._LEARN_CountBonus.Mod(40)
        Debug.notification(__l("Learned something practical"))
        ; remove gold for the service
        Game.Getplayer().removeitem(Game.getform(0xF), 150)
    EndIf
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

_LEARN_ControlScript Property ControlScript  Auto  
string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction