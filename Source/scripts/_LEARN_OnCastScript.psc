scriptName _LEARN_OnCastScript extends ReferenceAlias
; This script is attached to the player via an alias in the mod's main quest.
; It adds the mod's tracking status effect to the player and ensures
; that mod version upgrades and localization are handled when the player
; loads the game. Despite the name OnCastScript, it doesn't track spell casts or 
; do anything related to them - it does add the effect which is responsible for 
; doing so, however.

Actor property PlayerRef auto
Spell property PracticeSpell auto
Spell property StudyPower auto

Bool modDisabled = false

function OnInit()
    if (Self.GetActorReference())
        PlayerRef.AddSpell(PracticeSpell, false)
    endif
endFunction

event OnPlayerLoadGame()
    _LEARN_ControlScript cs = self.GetOwningQuest() as _LEARN_ControlScript
    Debug.Trace("[Spell Learning] ======== Initializing Spell Learning (Please ignore any warning(s)/error(s) below) ========")
    ;cs.CanUseLocalizationLib = (PapyrusUtil.GetScriptVersion() as Int) >= 34;
    cs.CanUseLocalizationLib = false
    if !cs.CanUseLocalizationLib
        Debug.Trace("[Spell Learning] You need to install PapyrusUtil version >= 3.4 for localization support. Localization support disabled.")
    else
        Debug.Trace("[Spell Learning] Localization support enabled.")
    endIf
    Debug.Trace("[Spell Learning] ======== Spell Learning Initialized ========")
    cs.InternalPrepare()
endEvent