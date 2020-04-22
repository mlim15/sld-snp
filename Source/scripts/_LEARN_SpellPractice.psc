scriptName _LEARN_SpellPractice extends ActiveMagicEffect
; This script is attached to the player via the mod's Spell Learning status effect.
; Its functions could be tracked via the quest, but this method is slightly more modula
; It is responsible for tracking spell casts by school, as well as 
; detecing and removing books when they enter the player's inventory.

_LEARN_ControlScript property cs auto
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

float TimeWithoutEvent
float PreviousMagicka

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

function OnItemAdded(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Book akBook = akBaseItem as Book
    if (! akBook)
        Return
    EndIf
    Spell sp = akBook.GetSpell()
    if (! sp)
        Return
    endif
    TryAddSpellBook(akBook, sp, aiItemCount)
EndFunction

function TryAddSpellBook(Book akBook, Spell sp, int aiItemCount)
    ; maybe remove book
    if (_LEARN_RemoveSpellBooks.GetValue() != 0)
        PlayerRef.removeItem(akBook, aiItemCount, !cs.VisibleNotifications[NOTIFICATION_REMOVE_BOOK])
    EndIf
	; maybe add notes
	if (_LEARN_CollectNotes.GetValue() != 0)
		Int value = akBook.GetGoldValue()
		MagicEffect eff = sp.GetNthEffectMagicEffect(0)
		String magicSchool = eff.GetAssociatedSkill() 
		if magicSchool == SPELL_SCHOOL_ALTERATION
			PlayerRef.addItem(_LEARN_SpellNotesAlteration, value, !cs.VisibleNotifications[NOTIFICATION_ADD_SPELL_NOTE]) 
		elseIf magicSchool == SPELL_SCHOOL_CONJURATION
			PlayerRef.addItem(_LEARN_SpellNotesConjuration, value, !cs.VisibleNotifications[NOTIFICATION_ADD_SPELL_NOTE])
		elseIf magicSchool == SPELL_SCHOOL_DESTRUCTION
			PlayerRef.addItem(_LEARN_SpellNotesDestruction, value, !cs.VisibleNotifications[NOTIFICATION_ADD_SPELL_NOTE]) 
		elseIf magicSchool == SPELL_SCHOOL_ILLUSION
			PlayerRef.addItem(_LEARN_SpellNotesIllusion, value, !cs.VisibleNotifications[NOTIFICATION_ADD_SPELL_NOTE])
		elseIf magicSchool == SPELL_SCHOOL_RESTORATION
			PlayerRef.addItem(_LEARN_SpellNotesRestoration, value, !cs.VisibleNotifications[NOTIFICATION_ADD_SPELL_NOTE])
		endIf
	endIf
	
    ; add spell to the todo list if not already known or in list
	if (!PlayerRef.HasSpell(sp) && !cs.spell_fifo_has_ref(sp))
		cs.spell_fifo_push(sp)
		if (cs.canAutoLearn(sp, cs.spell_fifo_get_ref(sp)) && _LEARN_AutoNoviceLearningEnabled.GetValue() == 1)
			; if the spell is eligible for automatic success, move it to the top of the list.
			cs.MoveSpellToTop(cs.spell_fifo_get_ref(sp))
		EndIf
    endIf
	
	; note that setting books as read does not work in SSE,
	; as the skse extension used in LE has not been ported.
	; this is unfortunate but it's not a loss in comparison with vanilla,
	; which doesn't display which books are read in the menu anyway.
	; sucks for those who got used to that convenience in SkyUI though.
	bool isRead = akBook.isRead()
    if _canSetBookAsRead && !isRead
        BookExtension.SetReadWFB(akBook, true)
    endIf
endFunction 