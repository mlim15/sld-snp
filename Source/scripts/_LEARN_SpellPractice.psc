scriptName _LEARN_SpellPractice extends ActiveMagicEffect
; This script is attached to the player via the mod's Spell Learning status effect.
; Its functions could be tracked via the quest, but this method is slightly more modular
; It is responsible for tracking spell casts by school.

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
