ScriptName _LEARN_SpellChestAlias extends ObjectReference

; This script is attached to the mod's chest that stores all spell tomes. 
; When the mod is initialized (onUpgrade method in ControlScript) we add all 
; detected spell tomes to this chest from the base game and some mods' debug chests.
; Each item added triggers the below OnItemAdded event which allows us to add these spells
; to a formlist which has much better script options in papyrus (basic things like get length,
; get the item at a certain index, etc, which are lacking from levelled lists/containers etc.)

FormList property _LEARN_discoveryPossibilities auto

Event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    ; If the added tome is not a discovery possibility, add it to the formlist
    ; that stores discoverable tomes.
    if (!akBaseItem as Book)
        ; If it's not a book we don't care about it.
        ; This should never happen but whatever.
        return
    endIf
    if (_LEARN_discoveryPossibilities.Find(akBaseItem) == -1) 
        _LEARN_discoveryPossibilities.AddForm(akBaseItem)
    endIf
endEvent