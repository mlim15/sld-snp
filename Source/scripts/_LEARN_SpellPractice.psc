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

;/
string function __l(string keyName, string defaultValue = "")
    return ControlScript.__l(keyName, defaultValue);
endFunction
/;
function OnItemAdded(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Book akBook = akBaseItem as Book
    if (! akBook)
        Return
    EndIf
    Spell sp = akBook.GetSpell()
    if (! sp)
        Return
    endif
    ControlScript.TryAddSpellBook(akBook, sp, aiItemCount); single call to ControlScript is much more faster
EndFunction
