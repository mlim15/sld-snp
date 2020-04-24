ScriptName _LEARN_tolfdirChestAlias extends ReferenceAlias

;_LEARN_ControlScript property ControlScript auto
GlobalVariable property _LEARN_SpawnItems auto
ObjectReference property MerchantWCollegeTolfdirChest auto
;GlobalVariable property GameDaysPassed auto

Book property _LEARN_SetHomeSpBook auto

Event OnInit()
    if (_LEARN_SpawnItems.GetValue() == 1)
        if (MerchantWCollegeTolfdirChest.GetItemCount(_LEARN_SetHomeSpBook) == 0)
            MerchantWCollegeTolfdirChest.AddItem(_LEARN_SetHomeSpBook, 1, true)
        endIf
    endIf        
endEvent

function RemoveItems()
    ; Remove any items we might have added
    MerchantWCollegeTolfdirChest.RemoveItem(_LEARN_SetHomeSpBook, chest.GetItemCount(_LEARN_SetHomeSpBook), true)
endFunction

Event OnReset()
    if (_LEARN_SpawnItems.GetValue() == 1)
        OnInit()
    else
        RemoveItems()
    endIf
EndEvent