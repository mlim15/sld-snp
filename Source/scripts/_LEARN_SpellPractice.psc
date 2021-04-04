scriptName _LEARN_SpellPractice extends ActiveMagicEffect
; This script is attached to the player via the mod's Spell Learning status effect.
; Its functions could be tracked via the quest, but this method is slightly more modula
; It is responsible for tracking spell casts by school, as well as 
; detecing and removing books when they enter the player's inventory.

_LEARN_ControlScript property cs auto
GlobalVariable property _LEARN_CountAlteration auto
GlobalVariable property _LEARN_CountConjuration auto
GlobalVariable property _LEARN_CountDestruction auto
GlobalVariable property _LEARN_CountIllusion auto
GlobalVariable property _LEARN_CountRestoration auto

String property SPELL_SCHOOL_ALTERATION = "Alteration" autoReadOnly
String property SPELL_SCHOOL_CONJURATION = "Conjuration" autoReadOnly
String property SPELL_SCHOOL_DESTRUCTION = "Destruction" autoReadOnly
String property SPELL_SCHOOL_ILLUSION = "Illusion" autoReadOnly
String property SPELL_SCHOOL_RESTORATION = "Restoration" autoReadOnly

Book property _LEARN_SpellNotesAlteration auto
Book property _LEARN_SpellNotesConjuration auto
Book property _LEARN_SpellNotesDestruction auto
Book property _LEARN_SpellNotesIllusion auto
Book property _LEARN_SpellNotesRestoration auto

function OnSpellCast(Form akForm)
    Spell akSpell = akForm as Spell
    if ! akSpell
        Return
    endif
    ; Cannot determine spell school without SKSE. Count everything in resto counter.
    _LEARN_CountRestoration.Mod(1)
    return 
endFunction

function OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    ; TODO this can be much easier/cleaner with AddInventoryEventFilter, especially now that we will have a formlist
    ; ready and populated with all the spells we plan on supporting through the mod.
    ;
    ; If the added item isn't a book, do nothing
    Book akBook = akBaseItem as Book
    if (! akBook)
        Return
    EndIf
    ; Don't do anything with quest essential spellbooks.
    ; This seems to be the only example so far, but we'll see. This is because
    ; completing the quest is actually scripted via an OnEquip event for the Power of the Elements
    ; book that teaches the Fire Storm spell. (It also immediately deletes itself and replaces itself
    ; with a non-spell-tome copy that has all of the text in it.)
    ; Power of the elements form IDs
    ;0009C8C0 -> 641216 decimal
    ;0009C8C6 -> 641222 decimal
    ;0009C8C1 -> 641217 decimal
    ;000F37D0 -> 997328 decimal
    int formID = akBaseItem.GetFormID()
    if (formID == 641216 || formID == 641222 || formID == 641217 || formID == 997328)
        ; Book is "Power of the Elements" and taking it will break the quest. Stop now.
        return
    endIf
    ; Determine if the book is a spell book by checking the QA chest and Enai's Odin/Apocalypse cheat chests
    ; Other books are considered unsupported and can be learned with vanilla functionality.
    if (cs.isSpellBook(akBook))
        ; If it's a recognized spell book, start processing it with the mod.
        Debug.Trace("[Spell Learning] Processing acquired spell book")
        cs.TryAddSpellBook(akBook, aiItemCount)
    else
        Debug.Trace("[Spell Learning] Item added was a book but not registered in the mod's chest as a spell book. Doing nothing.")
        return
    endIf
EndFunction

event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    ; If we are supposed to generate notes but not remove books, then generate notes here
    ; when the book is consumed for insta-learn functionality. This prevents the player
    ; from duplicating notes by dropping/picking up the book many times, which would
    ; be possible if we still gave them notes onitemadded under this scenario. A check
    ; has been added to the onitemadded to only give the notes if tomes are also removed.
    if ((akBaseObject as Book)) ; if it's a book
        if (cs.isSpellBook(akBaseObject as Book)) ; and it's a spellbook
            if (cs._LEARN_CollectNotes.GetValue() == 1) ; and settings are right
                if (cs._LEARN_removedTomes.Find(akBaseObject as Book) != -1); and we haven't already given notes for it
                    cs.takeNotes(akBaseObject as Book) ; then add notes
                    cs.addTomeToRemovedList(akBaseObject as Book); and add to list of tomes we've removed so we don't give notes on subsequent reads
                endIf
            endIf
        endIf
    endIf
endEvent