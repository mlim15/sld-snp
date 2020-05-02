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
    
    MagicEffect eff = akSpell.GetNthEffectMagicEffect(0)
    String magicSchool = eff.GetAssociatedSkill()
    if magicSchool == "Alteration"
        _LEARN_CountAlteration.Mod(1)
        return
    elseIf magicSchool == "Conjuration"
        _LEARN_CountConjuration.Mod(1)
        return
    elseIf magicSchool == "Destruction"
        _LEARN_CountDestruction.Mod(1)
        return 
    elseIf magicSchool == "Illusion"
        _LEARN_CountIllusion.Mod(1)
        return 
    elseIf magicSchool == "Restoration"
        _LEARN_CountRestoration.Mod(1)
        return 
    endIf
endFunction

function OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    ; If the added item isn't a book, do nothing
    Book akBook = akBaseItem as Book
    if (! akBook)
        Return
    EndIf
    ; If it's not a book that is flagged to teach a spell, do nothing
    Spell sp = akBook.GetSpell()
    if (! sp)
        Return
    endif
    ; Don't do anything with quest essential spellbooks.
    ; This seems to be the only example so far, but we'll see. This is because
    ; completing the quest is actually scripted via an OnEquip event for the Power of the Elements
    ; book that teaches the Fire Storm spell. (It also immediately deletes itself and replaces itself
    ; with a non-spell-tome copy that has all of the text in it.)
    if (akBaseItem.GetName() == "Power of the Elements")
        return
    endIf
    cs.TryAddSpellBook(akBook, sp, aiItemCount)
EndFunction

event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    if (cs._LEARN_removedTomes.Find(akBaseObject as Book) != -1)
        ; try to do this fast and first to avoid a race condition with the game
        ; adding the spell to the player before we check if it's the first read or not
        return
    endIf
    ; If we are supposed to generate notes but not remove books, then generate notes here
    ; when the book is consumed for insta-learn functionality. This prevents the player
    ; from duplicating notes by dropping/picking up the book many times, which would
    ; be possible if we still gave them notes onitemadded under this scenario. A check
    ; has been added to the onitemadded to only give the notes
    if ((akBaseObject as Book)) ; if it's a book
        if ((akBaseObject as Book).GetSpell()) ; and it's a spellbook
            if (cs._LEARN_CollectNotes.GetValue() == 1) ; and settings are right
                cs.takeNotes(akBaseObject as Book) ; then add notes
                cs.addTomeToList(akBaseObject as Book); and add to list of tomes we've removed so we don't give notes on subsequent reads
            endIf
        endIf
    endIf
endEvent