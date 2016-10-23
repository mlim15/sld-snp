scriptName _LEARN_SpellPractice extends ActiveMagicEffect

;-- Properties --------------------------------------
globalvariable property _LEARN_CountAlteration auto
globalvariable property _LEARN_CountConjuration auto
globalvariable property _LEARN_CountDestruction auto
globalvariable property _LEARN_CountIllusion auto
globalvariable property _LEARN_CountRestoration auto
globalvariable property _LEARN_RemoveSpellBooks auto
globalvariable property _LEARN_CollectNotes auto

actor property PlayerRef auto
Book property _LEARN_SpellNotesAlteration auto
Book property _LEARN_SpellNotesConjuration auto
Book property _LEARN_SpellNotesDestruction auto
Book property _LEARN_SpellNotesIllusion auto
Book property _LEARN_SpellNotesRestoration auto

_LEARN_ControlScript property ControlScript auto



;-- Variables ---------------------------------------
float TimeWithoutEvent
float PreviousMagicka

;-- Functions ---------------------------------------

; Skipped compiler generated GotoState

function OnSpellCast(Form akForm)
    Spell akSpell = akForm as Spell
    if ! akSpell
        Return
    endif
    
    MagicEffect eff = akSpell.GetNthEffectMagicEffect(0)
    String magicSchool = eff.GetAssociatedSkill()
    ; Debug.Notification(magicSchool)
    if magicSchool == ControlScript.getSchools()[1]
        _LEARN_CountAlteration.Mod(1)
        return
    elseIf magicSchool == ControlScript.getSchools()[2]
        _LEARN_CountConjuration.Mod(1)
        return
    elseIf magicSchool == ControlScript.getSchools()[3]
        _LEARN_CountDestruction.Mod(1)
        return 
    elseIf magicSchool == ControlScript.getSchools()[4]
        _LEARN_CountIllusion.Mod(1)
        return 
    elseIf magicSchool == ControlScript.getSchools()[5]
        _LEARN_CountRestoration.Mod(1)
        return 
    endIf
    return
endFunction


function OnEffectStart(actor akTarget, actor akCaster)
    ; AddInventoryEventFilter(Book)

    ; _SFAU_ReloadVersionHitCheck.SetValue(1.00000)
endFunction


function OnItemAdded(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Book akBook = akBaseItem as Book
    if (! akBook)
        Return
    EndIf
    Spell sp = akBook.GetSpell()
    if (sp && (! PlayerRef.HasSpell(sp)) && _LEARN_RemoveSpellBooks.GetValue() != 0)
        PlayerRef.removeItem(akBook, aiItemCount)
    EndIf
    
    if ((! akBook.isRead()) && sp && (! PlayerRef.HasSpell(sp)) && _LEARN_CollectNotes.GetValue() != 0)
        Int value = akBook.GetGoldValue()
        
        MagicEffect eff = sp.GetNthEffectMagicEffect(0)
        String magicSchool = eff.GetAssociatedSkill() 
        ; Debug.Notification(magicSchool) 
        if magicSchool == ControlScript.getSchools()[1]
            PlayerRef.addItem(_LEARN_SpellNotesAlteration, value) 
        elseIf magicSchool == ControlScript.getSchools()[2] 
            PlayerRef.addItem(_LEARN_SpellNotesConjuration, value)
        elseIf magicSchool == ControlScript.getSchools()[3] 
            PlayerRef.addItem(_LEARN_SpellNotesDestruction, value) 
        elseIf magicSchool == ControlScript.getSchools()[4]
            PlayerRef.addItem(_LEARN_SpellNotesIllusion, value)
        elseIf magicSchool == ControlScript.getSchools()[5] 
            PlayerRef.addItem(_LEARN_SpellNotesRestoration, value)
        endIf
    endIf

    if ((! akBook.isRead()) && sp && (! PlayerRef.HasSpell(sp)))
        ControlScript.spell_fifo_push(sp)
        ; Lament at the fact that you can't set a book as read from this script
    EndIf
    
EndFunction