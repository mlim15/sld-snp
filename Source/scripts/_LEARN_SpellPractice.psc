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
GlobalVariable property _LEARN_RemoveSpellBooks auto
GlobalVariable property _LEARN_CollectNotes auto
GlobalVariable property _LEARN_AutoNoviceLearningEnabled auto
GlobalVariable property _LEARN_AddSpellsToList auto

String property SPELL_SCHOOL_ALTERATION = "Alteration" autoReadOnly
String property SPELL_SCHOOL_CONJURATION = "Conjuration" autoReadOnly
String property SPELL_SCHOOL_DESTRUCTION = "Destruction" autoReadOnly
String property SPELL_SCHOOL_ILLUSION = "Illusion" autoReadOnly
String property SPELL_SCHOOL_RESTORATION = "Restoration" autoReadOnly

Actor property PlayerRef auto
Book property _LEARN_SpellNotesAlteration auto
Book property _LEARN_SpellNotesConjuration auto
Book property _LEARN_SpellNotesDestruction auto
Book property _LEARN_SpellNotesIllusion auto
Book property _LEARN_SpellNotesRestoration auto

String function __l(String keyName, String defaultValue = "")
    return cs.__l(keyName, defaultValue)
endFunction

String function __fs1(String source, String p1)
    return _LEARN_Strings.StringReplaceAll(source, "{0}", p1)
endFunction

String function __fs2(String source, String p1, String p2)
    string r = __fs1(source, p1)
    return _LEARN_Strings.StringReplaceAll(r, "{1}", p2)
endFunction

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
    TryAddSpellBook(akBook, sp, aiItemCount)
EndFunction

function TryAddSpellBook(Book akBook, Spell sp, int aiItemCount)
    float value = 0
    ; maybe remove book
    if (_LEARN_RemoveSpellBooks.GetValue())
        PlayerRef.removeItem(akBook, aiItemCount, !cs.VisibleNotifications[cs.NOTIFICATION_REMOVE_BOOK])
    EndIf
	; maybe add notes
    if (_LEARN_CollectNotes.GetValue())
        MagicEffect eff = sp.GetNthEffectMagicEffect(0)
        String magicSchool = eff.GetAssociatedSkill() 
        float skillDiff = cs.getSkillDiffFactor(magicSchool, eff)*2
        ; If overall player skill is 50 and the spell is level 25, skillDiff will return 1/2 by default.
        ; If player skill is 25 and spell level is 50, it will return 2. 
        ; If player skill and spell level are equal, it returns 1.
        ; Multiplying by 2 means that later when we divide, the generated notes are according to our
        ; value design: at equal skill and spell level, half the notes are generated.
        ; We want to cap the factor to not go below 1 so that the notes generated are never more than the base value.
        ; We also want to cap the penalty so that the player never gets less than 1/4 of the base value.
        ; This 1/4 base value scenario only happens when player skill is less than half that of the spell level 
        ; (e.g. novice learning adept, apprentice learning expert).
        if (skillDiff < 1)
            skillDiff = 1
        elseIf (skillDiff > 4)
            skillDiff = 4
        endIf
        ; Scale the value of notes generated according to skill difference
        value = (akBook.GetGoldValue()/skillDiff)
		if magicSchool == SPELL_SCHOOL_ALTERATION
			PlayerRef.addItem(_LEARN_SpellNotesAlteration, value as int, !cs.VisibleNotifications[cs.NOTIFICATION_ADD_SPELL_NOTE]) 
		elseIf magicSchool == SPELL_SCHOOL_CONJURATION
			PlayerRef.addItem(_LEARN_SpellNotesConjuration, value as int, !cs.VisibleNotifications[cs.NOTIFICATION_ADD_SPELL_NOTE])
		elseIf magicSchool == SPELL_SCHOOL_DESTRUCTION
			PlayerRef.addItem(_LEARN_SpellNotesDestruction, value as int, !cs.VisibleNotifications[cs.NOTIFICATION_ADD_SPELL_NOTE]) 
		elseIf magicSchool == SPELL_SCHOOL_ILLUSION
			PlayerRef.addItem(_LEARN_SpellNotesIllusion, value as int, !cs.VisibleNotifications[cs.NOTIFICATION_ADD_SPELL_NOTE])
		elseIf magicSchool == SPELL_SCHOOL_RESTORATION
			PlayerRef.addItem(_LEARN_SpellNotesRestoration, value as int, !cs.VisibleNotifications[cs.NOTIFICATION_ADD_SPELL_NOTE])
		endIf
	endIf
    
    ; Notify with additional note information if vanilla note notifications are off
    if (cs.spell_fifo_has_ref(sp))
        if ((_LEARN_CollectNotes.GetValue()) && !(cs.VisibleNotifications[cs.NOTIFICATION_ADD_SPELL_NOTE]))
            cs.notify(__fs2(__l("notification_spell_not_added_studying_notes", "Already studying {0}. Tome deconstructed into {1} notes."), sp.GetName(), (value as int) as String), cs.NOTIFICATION_ADD_SPELL_LIST_FAIL)
        else
            cs.notify(__fs1(__l("notification_spell_not_added_studying", "Already studying {0}."), sp.GetName()), cs.NOTIFICATION_ADD_SPELL_LIST_FAIL)
        endIf
    endIf

    ; Notify with additional note information if vanilla note notifications are off
    if (PlayerRef.HasSpell(sp))
        if ((_LEARN_CollectNotes.GetValue()) && !(cs.VisibleNotifications[cs.NOTIFICATION_ADD_SPELL_NOTE]))
            cs.notify(__fs2(__l("notification_spell_not_added_notes", "Already knew {0}. Tome deconstructed into {1} notes."), sp.GetName(), (value as int) as String), cs.NOTIFICATION_ADD_SPELL_LIST_FAIL)
        else
            cs.notify(__fs1(__l("notification_spell_not_added", "Already knew {0}."), sp.GetName()), cs.NOTIFICATION_ADD_SPELL_LIST_FAIL)
        endIf
    endIf

    ; add spell to the todo list if not already known or in list
    if (!PlayerRef.HasSpell(sp) && !cs.spell_fifo_has_ref(sp))
        cs.spell_fifo_push(sp)
        ; Notify with additional note information if vanilla note notifications are off
        if (_LEARN_CollectNotes.GetValue() && (!cs.VisibleNotifications[cs.NOTIFICATION_ADD_SPELL_NOTE]))
            cs.notify(__fs2(__l("notification_spell_added_notes", "{0} added to study list. Tome deconstructed into {1} notes."), sp.GetName(), (value as int) as String), cs.NOTIFICATION_ADD_SPELL_LIST)
        else
            cs.notify(__fs1(__l("notification_spell_added", "{0} added to study list."), sp.GetName()), cs.NOTIFICATION_ADD_SPELL_LIST)
        endIf
        if (cs.canAutoLearn(sp, cs.spell_fifo_get_ref(sp)) && (_LEARN_AutoNoviceLearningEnabled.GetValue() == 1))
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
    if (cs.bookExtensionEnabled() && !isRead)
        BookExtension.SetReadWFB(akBook, true)
    endIf
endFunction 