scriptname _LEARN_MCMConfigQuest extends SKI_ConfigBase
; This is the mod's MCM configuration menu. It is attached to the player by
; another quest, as usual for MCM modules. It contains everything related
; to the MCM and otherwise remains mostly stateless, aside from an enabled/disabled
; local variable that is used by the MCM to enable/disable the quest and main script
; on the player.

import FISSFactory
FISSInterface fiss

_LEARN_ControlScript property ControlScript auto
String ModName = "Spell Learning"

bool isEnabled
bool wasDisabled = False
int isEnabledOption
int showDebugOutputOption ; Toggle for showing debug output messages

Actor property PlayerRef auto
Quest property _LEARN_SpellControlQuest auto
GlobalVariable property GameDaysPassed auto
GlobalVariable property _LEARN_MinChanceStudy auto
GlobalVariable property _LEARN_MaxChanceStudy auto
GlobalVariable property _LEARN_MinChanceDiscover auto
GlobalVariable property _LEARN_MaxChanceDiscover auto
GlobalVariable property _LEARN_BonusScale auto
GlobalVariable property _LEARN_MaxFailsBeforeCycle auto
GlobalVariable property _LEARN_RemoveSpellBooks auto
GlobalVariable property _LEARN_CollectNotes auto
GlobalVariable property _LEARN_ForceDiscoverSchool auto
GlobalVariable property _LEARN_StudyInterval auto
GlobalVariable property _LEARN_AutoNoviceLearningEnabled auto
GlobalVariable property _LEARN_AutoNoviceLearning auto
GlobalVariable property _LEARN_ParallelLearning auto
GlobalVariable property _LEARN_HarderParallel auto
GlobalVariable property _LEARN_DreadstareLethality auto
GlobalVariable property _LEARN_EffortScaling auto
GlobalVariable property _LEARN_AutoSuccessBypassesLimit auto
GlobalVariable property _LEARN_TooDifficultEnabled auto
GlobalVariable property _LEARN_TooDifficultDelta auto
GlobalVariable property _LEARN_PotionBypass auto
GlobalVariable property _LEARN_IntervalCDR auto
GlobalVariable property _LEARN_IntervalCDREnabled auto
GlobalVariable property _LEARN_MaxFailsAutoSucceeds auto
GlobalVariable property _LEARN_DynamicDifficulty auto
GlobalVariable property _LEARN_ConsecutiveDreadmilk auto
GlobalVariable property _LEARN_AlreadyUsedTutor auto
GlobalVariable property _LEARN_LastSetHome auto
GlobalVariable property _LEARN_StudyIsRest auto
GlobalVariable property _LEARN_StudyRequiresNotes auto
GlobalVariable property _LEARN_LastDayStudied auto
GlobalVariable property _LEARN_DiscoverOnSleep auto
GlobalVariable property _LEARN_LearnOnSleep auto
GlobalVariable property _LEARN_DiscoverOnStudy auto
GlobalVariable property _LEARN_LearnOnStudy auto
GlobalVariable property _LEARN_maxNotes auto
GlobalVariable property _LEARN_maxNotesBonus auto
GlobalVariable property _LEARN_ResearchSpells auto
GlobalVariable property _LEARN_ReturnTomes auto
GlobalVariable property _LEARN_RemoveUnknownOnly auto
MagicEffect Property _LEARN_PracticeEffect auto
Spell property _LEARN_DiseaseDreadmilk auto
Spell property _LEARN_PracticeAbility auto
Spell property _LEARN_StudyPower auto
Spell property _LEARN_SummonSpiritTutor auto
Spell property _LEARN_SetHomeSp auto
Spell property _LEARN_SpellsToLearn auto
MagicEffect Property AlchDreadmilkEffect auto
MagicEffect Property AlchShadowmilkEffect auto
MagicEffect property _LEARN_ShadowmilkHangover auto

;OID is OptionID (for posterity)
int minChanceStudyOID
int maxChanceStudyOID
int minChanceDiscoverOID
int maxChanceDiscoverOID
float bonusScaleOID
int collectOID
int removeOID
int infoStudyOID
int infoDiscoverOID
int infoSchoolOID
int forceSchoolOID
int forceSchoolIndex = 0
int effortScalingOID
int effortScalingIndex = 0
int fissExportOID
int fissImportOID
int CustomLocationOID
int StudyIntervalOID
int maxConsecutiveFailuresOID
int autoNoviceLearningOID
int autoSuccessBypassesLimitOID
int noviceLearningEnabledOID
int dreadstareLethalityOID
int parallelLearningOID
int harderParallelOID
int tooDifficultEnabledOID
int tooDifficultDeltaOID
int potionBypassOID
int intervalCDRenabledOID
float intervalCdrOID
int dynamicDiffOID
int maxFailsAutoSucceedsOID
int nootropicStatusOID
int tutorStatusOID
int attunementStatusOID
int studyRequiresNotesOID
int studyIsRestOID
int removeSpellsOID
int removePowerOID
int removeStatusEffectsOID
int addPowerOID
int addStatusTrackerOID
int learnOnStudyOID
int discoverOnStudyOID
int learnOnSleepOID 
int discoverOnSleepOID
int alreadyStudiedOID
int maxNotesOID
int maxNotesBonusOID
int addToListOID
int returnTomesOID
int removeUnknownOnlyOID

int[] spellListStates; 0=count,1=pageCount;2=currentPageIndex,3=pageItemIndex
int[] spellOidList
Form[] spellsInPage
String[] spellCommandsMenu
int property SPELLS_COUNT = 0 autoReadOnly
int property SPELLS_PAGECOUNT = 1 autoReadOnly
int property SPELLS_CURRENT_PAGEINDEX = 2 autoReadOnly
int property SPELLS_PAGE_ITEMINDEX = 3 autoReadOnly
int property SPELLS_CURRENTPAGE_OID = 4 autoReadOnly
int property SPELLS_PAGE_ITEMCOUNT = 5 autoReadOnly
bool isSpellListInitialized

int property SPELL_COMMAND_NONE = 0 autoReadOnly
int property SPELL_COMMAND_REMOVE = 1 autoReadOnly
int property SPELL_COMMAND_LEARN = 2 autoReadOnly
bool _useLocalizationLib

; == Initialization
event OnConfigInit()
	; Called when the menu is first registered, grab the values as the first-run data
    Debug.Trace(_LEARN_Strings.formatString2("[Spell Learning] MCM Configuring... Menu version is {0}.{1} ...", 10, ControlScript.GetMenuLangId()))
    InternalPrepare()

    if (!ControlScript.isRunning())
        ControlScript.Start()
    endif
    
    IsEnabled = True
endEvent

; === Tab Definitions
function InternalPrepare()
    if (!Pages || Pages.Length < 5)
        Pages = new string[5]
    endIf
    _useLocalizationLib = ControlScript.CanUseLocalizationLib
    Pages[0] = __l("mcm_tab_status", "Current Status")
    Pages[1] = __l("mcm_tab_learning","Learning and Discovery")
	Pages[2] = __l("mcm_tab_spell_list", "Manage Spell List")
    Pages[3] = __l("mcm_tab_miscellaneous", "Items and Functionality")
    Pages[4] = __l("mcm_tab_notifications", "Notifications")
endFunction

event OnGameReload()
	parent.OnGameReload() 
	
	InternalPrepare()
endEvent

; === Localization and Formatting
string function __l(string keyName, string defaultValue = "")
	; since menu uses this function a lot while resetting page nexusishere inlined it here for better performance
    if _useLocalizationLib
        string r = JsonUtil.GetStringValue("SpellLearning_Strings.json", keyName, "");
        if (!r || r == "")
            Debug.Trace("[Spell Learning] Localization entry not found => " + keyName);
            if (defaultValue == "")
                return keyName;
            endIf
            return defaultValue 
        endIf
        return r;
    endIf
    if (defaultValue == "")
        return keyName;
    endIf
    return defaultValue 
endFunction

string function __f1(string source, string p1)
    return _LEARN_Strings.StringReplaceAll(source, "{0}", p1)
endFunction

; === Version Management
int function GetVersion()
    ; menu version will be multiplies of 10 for allowing user to change language 9 more times
    return 20 + ControlScript.GetMenuLangId();
endFunction

event OnVersionUpdate(int a_version)
    if (a_version > 1)
        InternalPrepare()
    endIf
endEvent

Event OnConfigClose()
	; Called every time the menu is closed (actually saves the data)
    If(!isEnabled && !wasDisabled)
        wasDisabled = True
		disableModEffects()
		Utility.wait(2)
		disableModEffects() ; You can never be too sure
		; Then stop the quest. This will de-register all updates on aliases etc and stop script from running on sleep.
		_LEARN_SpellControlQuest.Stop()
        disableModEffects() ; beat a dead horse
    EndIf
    ; ======== RESET ========
    ; Basically reset; If they disable, close the menu, open, enable, close again, this will turn it back on
    If(isEnabled && wasDisabled)
        wasDisabled = False
		_LEARN_SpellControlQuest.Start()
    EndIf
    ; sometimes weird warnings occur when assigning None to an array
    Form[] nullFormArray = Utility.CreateFormArray(0)
    int[] nullIntArray = Utility.CreateIntArray(0)
    string[] nullStringArray = Utility.CreateStringArray(0)
    spellsInPage = nullFormArray
    spellListStates = nullIntArray
    spellOidList = nullIntArray
    spellCommandsMenu = nullStringArray
    isSpellListInitialized = false
EndEvent

; === Menu Definitions
event OnPageReset(string page)
{Called when a new page is selected, including the initial empty page}
    ; Make dynamically determined flags to grey out options
    int NO_CATEGORY_FLAG = OPTION_FLAG_NONE
    int SPELL_LEARNING_FLAG = OPTION_FLAG_NONE
    int STUDY_BONUS_FLAG = OPTION_FLAG_NONE
    int NO_STUDY_BONUS_FLAG = OPTION_FLAG_NONE
    int LEARNING_OR_NO_STUDY_BONUS_FLAG = OPTION_FLAG_NONE
    int TAKING_NOTES_FLAG = OPTION_FLAG_NONE
    int NOT_RETURNING_TOMES_FLAG = OPTION_FLAG_NONE
    int AUTO_LEARN_FLAG = OPTION_FLAG_NONE
    int AUTO_FAIL_FLAG = OPTION_FLAG_NONE
    int CDR_FLAG = OPTION_FLAG_NONE
    ; Default flags to on. Switch off if needed with conditions.
    if (!_LEARN_ResearchSpells.GetValue())
        SPELL_LEARNING_FLAG = OPTION_FLAG_DISABLED
        LEARNING_OR_NO_STUDY_BONUS_FLAG = OPTION_FLAG_DISABLED
        NOT_RETURNING_TOMES_FLAG = OPTION_FLAG_DISABLED
        AUTO_LEARN_FLAG = OPTION_FLAG_DISABLED
        AUTO_FAIL_FLAG = OPTION_FLAG_DISABLED
    endIf
    if (!_LEARN_StudyIsRest.GetValue())
        NO_STUDY_BONUS_FLAG = OPTION_FLAG_DISABLED
        LEARNING_OR_NO_STUDY_BONUS_FLAG = OPTION_FLAG_DISABLED
    else
        STUDY_BONUS_FLAG = OPTION_FLAG_DISABLED
    endIf
    if (!_LEARN_CollectNotes.GetValue())
        TAKING_NOTES_FLAG = OPTION_FLAG_DISABLED
    endIf
    if (_LEARN_ReturnTomes.GetValue())
        NOT_RETURNING_TOMES_FLAG = OPTION_FLAG_DISABLED
    endIf
    if (!_LEARN_AutoNoviceLearningEnabled.GetValue())
        AUTO_LEARN_FLAG = OPTION_FLAG_DISABLED
    endIf
    if (!_LEARN_TooDifficultEnabled.GetValue())
        AUTO_FAIL_FLAG = OPTION_FLAG_DISABLED
    endIf
    if (!_LEARN_IntervalCDREnabled.GetValue())
        CDR_FLAG = OPTION_FLAG_DISABLED
    endIf
    ; If mod is disabled, set all flags to disabled no matter what they were set to above.
    if !(isEnabled)
        NO_CATEGORY_FLAG = OPTION_FLAG_DISABLED
        SPELL_LEARNING_FLAG = OPTION_FLAG_DISABLED
        STUDY_BONUS_FLAG = OPTION_FLAG_DISABLED
        NO_STUDY_BONUS_FLAG = OPTION_FLAG_DISABLED
        LEARNING_OR_NO_STUDY_BONUS_FLAG = OPTION_FLAG_DISABLED
        TAKING_NOTES_FLAG = OPTION_FLAG_DISABLED
        AUTO_LEARN_FLAG = OPTION_FLAG_DISABLED
        AUTO_FAIL_FLAG = OPTION_FLAG_DISABLED
        CDR_FLAG = OPTION_FLAG_DISABLED
    endIf
    if (page == "")
        _useLocalizationLib = ControlScript.CanUseLocalizationLib
        ;StartObjectProfiling()
    endIf
    if(page == "" || page == Pages[0])
        ; PAGE 1 LEFT SIDE
        SetCursorFillMode(TOP_TO_BOTTOM) ;starts are 0
        AddHeaderOption(__l("mcm_header_general_settings", "General Settings"), 0)
        isEnabledOption = AddToggleOption(__l("mcm_mod_enabled", "Mod is Enabled: "), IsEnabled, 0)
		AddEmptyOption()
        bonusScaleOID = AddSliderOption(__l("mcm_option_roleplaying_bonus", "Roleplaying Bonus Modifier"), _LEARN_BonusScale.GetValue(), "{1}", NO_CATEGORY_FLAG)
        effortScalingOID = AddMenuOption(__l("mcm_option_scaling", "Bonus Scaling Type"), ControlScript.getEffortLabels()[_LEARN_effortScaling.GetValueInt()], NO_CATEGORY_FLAG)
        string n = __l("mcm_current_location_none", "Undefined"); string none causes unexpected behaviors. avoid it
        if ControlScript.customLocation
            n = ControlScript.customLocation.GetName()
        endif
        CustomLocationOID = AddTextOption(__l("mcm_option_set_home", "Set Custom Study Location"), n, NO_CATEGORY_FLAG)
        AddEmptyOption()
        AddHeaderOption(__l("mcm_header_current_status", "Miscellaneous Status Effects"), 0)
        nootropicStatusOID = AddTextOption(__l("mcm_current_blood_toxicity", "Current Bloodstream Toxicity: "), __f1("{0}%", _LEARN_Strings.SubStringSafe(((_LEARN_ConsecutiveDreadmilk.GetValue() * 10) as String),0,5)), NO_CATEGORY_FLAG)
        if (_LEARN_AlreadyUsedTutor.GetValue() == 1)
            tutorStatusOID = AddTextOption(__l("mcm_current_tutor_used", "Already Used Tutor: "), __l("mcm_true", "True"), NO_CATEGORY_FLAG)
        else
            tutorStatusOID = AddTextOption(__l("mcm_current_tutor_used", "Already Used Tutor: "), __l("mcm_false", "False"), NO_CATEGORY_FLAG)
        endIf
        if ((GameDaysPassed.GetValue() - _LEARN_LastSetHome.GetValue()) >= 7)
            attunementStatusOID = AddTextOption(__l("mcm_current_days_left_attunement_now", "Can Change Attunement: "), __f1(__l("mcm_now", "Now"), "0"), NO_CATEGORY_FLAG)
        elseIf ((GameDaysPassed.GetValue() - _LEARN_LastSetHome.GetValue()) == 6)
            attunementStatusOID = AddTextOption(__l("mcm_current_days_left_attunement", "Can Change Attunement in: "), __f1(__l("mcm_x_day", "{0} Day"), "1"), NO_CATEGORY_FLAG)
        else
            attunementStatusOID = AddTextOption(__l("mcm_current_days_left_attunement", "Can Change Attunement in: "), __f1(__l("mcm_x_days", "{0} Days"), (((_LEARN_LastSetHome.GetValue() - GameDaysPassed.GetValue() + 7) as int) as String)), NO_CATEGORY_FLAG)
        endIf
        if (_LEARN_LastDayStudied.GetValue() == 1)
            alreadyStudiedOID = AddTextOption(__l("mcm_current_study_used", "Already Studied: "), __l("mcm_true", "True"), STUDY_BONUS_FLAG)
        else
            alreadyStudiedOID = AddTextOption(__l("mcm_current_study_used", "Already Studied: "), __l("mcm_false", "False"), STUDY_BONUS_FLAG)
        endIf
        ; PAGE 1 RIGHT SIDE
        SetCursorPosition(1) 
        AddHeaderOption(__l("mcm_header_current_learning", "Current Spell Learning Status"), 0)
        infoStudyOID = AddTextOption(__l("mcm_current_learning_chance", "Chance to Successfully Learn: "), __f1("{0}%", _LEARN_Strings.SubStringSafe(((ControlScript.baseChanceToStudy() * 100) as String),0,5)), SPELL_LEARNING_FLAG)
        int t = (controlscript.hours_before_next_ok_to_learn() as int)
        if t == 0
            AddTextOption(__l("mcm_current_learn_now", "You can try learning now!"), "", SPELL_LEARNING_FLAG)
        elseIf t == 1
            AddTextOption(__f1(__l("mcm_current_learn_1h", "You can try learning in 1h."), t), "", SPELL_LEARNING_FLAG)
        else
            AddTextOption(__f1(__l("mcm_current_learn_Xh", "You can try learning in {0}h."), t), "", SPELL_LEARNING_FLAG)
        endIf
		AddEmptyOption() 
        AddHeaderOption(__l("mcm_header_sleep_current_discovery", "Current Spell Discovery Status"), 0)
        infoDiscoverOID = AddTextOption(__l("mcm_current_discovery_chance", "Chance for Discovery: "), __f1("{0}%", _LEARN_Strings.SubStringSafe(((ControlScript.baseChanceToDiscover() * 100) as String),0,5)), NO_CATEGORY_FLAG)
        infoSchoolOID = AddTextOption(__l("mcm_current_school", "Current School of Interest: "), ControlScript.topSchoolToday(), NO_CATEGORY_FLAG) 
        int td = (controlscript.hours_before_next_ok_to_discover() as int)
        if td == 0
            AddTextOption(__l("mcm_current_discover_now", "You can try discovering now!"), "", NO_CATEGORY_FLAG)
        elseIf td == 1
            AddTextOption(__f1(__l("mcm_current_discover_1h", "You can try discovering in 1h."), td), "", NO_CATEGORY_FLAG)
        else
            AddTextOption(__f1(__l("mcm_current_discover_Xh", "You can try discovering in {0}h."), td), "", NO_CATEGORY_FLAG)
        endIf
        AddEmptyOption()
        AddHeaderOption(__l("mcm_header_backup_restore", "Backup/Restore Spell List"), 0)
        fissExportOID = AddTextOption(__l("mcm_option_export", "Export to FISS"), __l("mcm_click", "Click"), NO_CATEGORY_FLAG)
        fissImportOID = AddTextOption(__l("mcm_option_import", "Import from FISS"), __l("mcm_click", "Click"), NO_CATEGORY_FLAG)
    elseIf (page == Pages[1])
        ; PAGE 2 LEFT SIDE 
        SetCursorFillMode(TOP_TO_BOTTOM)
        AddHeaderOption(__l("mcm_header_interval_options", "Cooldown Options"), 0)
        StudyIntervalOID = AddSliderOption(__l("mcm_option_sleep_interval", "Days Between Chances"), _LEARN_StudyInterval.GetValue(), "{2}", NO_CATEGORY_FLAG)
        intervalCDRenabledOID = AddToggleOption(__l("mcm_option_practice_gives_cdr", "Practice Reduces Time"), _LEARN_IntervalCDREnabled.GetValue(), NO_CATEGORY_FLAG)
        intervalCdrOID = AddSliderOption(__l("mcm_option_max_cdr", "Maximum Reduction"), _LEARN_IntervalCDR.GetValue(), "{0}%", CDR_FLAG)
        AddHeaderOption(__l("mcm_header_spell_learning_options", "Spell Learning Options"), 0)
        minChanceStudyOID = AddSliderOption(__l("mcm_option_min_learn_chance", "Min Learn Chance"), _LEARN_MinChanceStudy.GetValue(), "{0}%", SPELL_LEARNING_FLAG)
        maxChanceStudyOID = AddSliderOption(__l("mcm_option_max_learn_chance", "Max Learn Chance"), _LEARN_MaxChanceStudy.GetValue(), "{0}%", SPELL_LEARNING_FLAG)
        dynamicDiffOID = AddToggleOption(__l("mcm_option_chance_scales_with_spell_level", "Chance Depends on Spell Level"), _LEARN_DynamicDifficulty.GetValue(), SPELL_LEARNING_FLAG)
        AddHeaderOption(__l("mcm_header_spell_discovery_options", "Spell Discovery Options"), 0)
        minChanceDiscoverOID = AddSliderOption(__l("mcm_option_min_discovery_chance", "Min Discovery Chance"), _LEARN_MinChanceDiscover.GetValue(), "{0}%", NO_CATEGORY_FLAG)
        maxChanceDiscoverOID = AddSliderOption(__l("mcm_option_max_discovery_chance", "Max Discovery Chance"), _LEARN_MaxChanceDiscover.GetValue(), "{0}%", NO_CATEGORY_FLAG)
        forceSchoolOID = AddMenuOption(__l("mcm_option_spell_school", "Spell School"), ControlScript.getSchools()[_LEARN_ForceDiscoverSchool.GetValueInt()], NO_CATEGORY_FLAG)
		; PAGE 2 RIGHT SIDE
        SetCursorPosition(1) ; Move cursor to top right position
        AddHeaderOption(__l("mcm_header_adv_spell_options", "Advanced Spell Learning Options"), 0)
        maxConsecutiveFailuresOID = AddSliderOption(__l("Limit Consecutive Failures To..."), _LEARN_MaxFailsBeforeCycle.GetValue(), "{0}", SPELL_LEARNING_FLAG)
        if (_LEARN_MaxFailsBeforeCycle.GetValue() > 0)
            maxFailsAutoSucceedsOID = AddToggleOption(__l("Auto Succeed When Max Failures Reached"), _LEARN_MaxFailsAutoSucceeds.GetValue(), SPELL_LEARNING_FLAG)
        else
            AddEmptyOption()
        endIf
        parallelLearningOID = AddSliderOption(__l("mcm_option_number_spells", "Daily Learning Limit"), _LEARN_ParallelLearning.GetValue(), __l("mcm_x_spell(s)", "{0} Spell(s)"), SPELL_LEARNING_FLAG)
        if (_LEARN_ParallelLearning.GetValue() > 1)
            harderParallelOID = AddToggleOption(__l("mcm_option_harder_multiple", "Learning Multiple Spells is Harder"), _LEARN_HarderParallel.GetValue(), SPELL_LEARNING_FLAG)
        else
            AddEmptyOption()
        endIf
        tooDifficultEnabledOID = AddToggleOption(__l("mcm_option_auto_failure", "Skill-based Automatic Failure"), _LEARN_TooDifficultEnabled.GetValue(), SPELL_LEARNING_FLAG)
        tooDifficultDeltaOID = AddSliderOption(__l("mcm_option_auto_failure_diff", "Max Skill Difference before Auto Fail"), _LEARN_TooDifficultDelta.GetValue(), "{0}", AUTO_FAIL_FLAG)
        potionBypassOID = AddToggleOption(__l("mcm_option_potion_bypass_auto_fail", "Potions Bypass Auto Fail"), _LEARN_PotionBypass.GetValue(), AUTO_FAIL_FLAG)
        AddEmptyOption()
        noviceLearningEnabledOID = AddToggleOption(__l("mcm_option_auto_success", "Skill-based Automatic Success"), _LEARN_AutoNoviceLearningEnabled.GetValue(), SPELL_LEARNING_FLAG)
        autoNoviceLearningOID = AddSliderOption(__l("mcm_option_auto_success_diff", "Req. Skill Difference for Auto Success"), _LEARN_AutoNoviceLearning.GetValue(), "{0}", AUTO_LEARN_FLAG)
        autoSuccessBypassesLimitOID = AddToggleOption(__l("mcm_option_auto_success_bypass", "Auto Success Bypasses Daily Limit"), _LEARN_AutoSuccessBypassesLimit.GetValue(), AUTO_LEARN_FLAG)	
    elseIf (page == Pages[2])
        ; PAGE 3
        CreatePageSpellList()
	elseIf(page == Pages[3])
        ; PAGE 4 LEFT SIDE
		SetCursorFillMode(TOP_TO_BOTTOM)
        AddHeaderOption(__l("mcm_header_study_options", "Sleeping and Studying Options"), 0)
        learnOnSleepOID = AddToggleOption(__l("mcm_option_learn_on_sleep", "Learn when Sleeping"), _LEARN_LearnOnSleep.GetValue(), SPELL_LEARNING_FLAG)
        discoverOnSleepOID = AddToggleOption(__l("mcm_option_discover_on_sleep", "Discover when Sleeping"), _LEARN_DiscoverOnSleep.GetValue(), NO_CATEGORY_FLAG)
        AddEmptyOption()
        studyRequiresNotesOID = AddToggleOption(__l("mcm_option_study_notes", "'Study' Requires Notes"), _LEARN_StudyRequiresNotes.GetValue(), TAKING_NOTES_FLAG)
        studyIsRestOID = AddToggleOption(__l("mcm_option_study_rest", "No Bonus from 'Study'..."), _LEARN_StudyIsRest.GetValue(), NO_CATEGORY_FLAG)
        learnOnStudyOID = AddToggleOption(__l("mcm_option_learn_on_study", "...Instead Learn when Studying"), _LEARN_LearnOnStudy.GetValue(), LEARNING_OR_NO_STUDY_BONUS_FLAG)
        discoverOnStudyOID = AddToggleOption(__l("mcm_option_discover_on_study", "...Instead Discover when Studying"), _LEARN_DiscoverOnStudy.GetValue(), NO_STUDY_BONUS_FLAG)
        ; PAGE 4 RIGHT SIDE
		SetCursorPosition(1) ; Move cursor to top right position
        AddHeaderOption(__l("mcm_header_item_options", "Advanced Item Options"), 0)
        addToListOID = AddToggleOption(__l("mcm_option_spell_learning", "Enable Spell Learning Functionality"), _LEARN_ResearchSpells.GetValue(), NO_CATEGORY_FLAG)
        ; The following option is currently purposefully hidden. Its setting matches Enable Spell Learning Functionality and is toggled when that option is toggled. 
        ;removeOID = AddToggleOption(__l("mcm_option_remove_books", "Remove Spell Tomes from Inventory"), _LEARN_RemoveSpellBooks.GetValue(), NO_CATEGORY_FLAG)
        removeUnknownOnlyOID = AddToggleOption(__l("mcm_option_remove_only_unknown", "Leave Known Spell Tomes Alone"), _LEARN_RemoveUnknownOnly.GetValue(), NOT_RETURNING_TOMES_FLAG)
        returnTomesOID = AddToggleOption(__l("mcm_option_return_tomes", "Give Back Removed Tome on Learn"), _LEARN_ReturnTomes.GetValue(), SPELL_LEARNING_FLAG)
        AddEmptyOption()
        collectOID = AddToggleOption(__l("mcm_option_collect_notes", "Take Notes from Removed Tomes"), _LEARN_CollectNotes.GetValue(), NO_CATEGORY_FLAG)
        maxNotesBonusOID = AddSliderOption(__l("mcm_option_max_notes_bonus", "Highest Chance Given by Notes"), _LEARN_maxNotesBonus.GetValue(), "{0}%", NO_CATEGORY_FLAG)
        maxNotesOID = AddSliderOption(__l("mcm_option_max_notes", "Max Per-School Notes Counted"), _LEARN_maxNotes.GetValue(), __l("mcm_x_g", "{0}g"), NO_CATEGORY_FLAG)
        AddEmptyOption()
        AddHeaderOption(__l("mcm_header_drug_options", "Nootropic Alchemy Options"), 0)
        dreadstareLethalityOID = AddSliderOption(__l("mcm_option_potion_toxicity", "Potion Toxicity"), _LEARN_DreadstareLethality.GetValue(), "{0}%", NO_CATEGORY_FLAG)
    elseIf(page == Pages[4])
        ; PAGE 5 LEFT SIDE
        SetCursorFillMode(TOP_TO_BOTTOM)
        if (isEnabled)
            AddHeaderOption(__l("mcm_header_item_spell_notifications", "Item and Spell Notifications"))
            AddToggleOptionST("ShowRemoveBookNotification", __l("mcm_notification_remove_book", "Vanilla Book Removal Notification"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_REMOVE_BOOK])
            AddToggleOptionST("ShowAddSpellNoteNotification", __l("mcm_notification_add_spell_note", "Vanilla Notes Added Notification"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_ADD_SPELL_NOTE])
            AddToggleOptionST("ShowAddSpellNotification", __l("mcm_notification_vanilla_add_spell", "Vanilla Spell Added Notification"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_VANILLA_ADD_SPELL])
            AddEmptyOption()
            AddToggleOptionST("ShowAddSpellListNotification", __l("mcm_notification_add_spell_list", "Adding Spell to List"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_ADD_SPELL_LIST]) 
            AddToggleOptionST("ShowFailAddSpellListNotification", __l("mcm_notification_add_spell_fail", "Already Knew Spell"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_ADD_SPELL_LIST_FAIL])
            AddToggleOptionST("ShowLearnSpellNotification", __l("mcm_notification_learn", "Learned Spell"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_LEARN_SPELL])
            AddToggleOptionST("ShowFailLearnSpellNotification", __l("mcm_notification_learn_fail", "Failed to Learn Spell"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_LEARN_FAIL])
            AddToggleOptionST("ShowDiscoverNotification", __l("mcm_notification_discover", "Discovered Spell"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_DISCOVERY])
            AddToggleOptionST("ShowSkipNotification", __l("mcm_notification_skip", "Skipping Spell"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_MOVING_ON])
            AddToggleOptionST("ShowTooSoonNotification", __l("mcm_notification_too_soon", "Too Soon to Learn"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_TOO_SOON])
        else
            AddTextOption(__l("mcm_current_disabled", "Mod is disabled."), "", OPTION_FLAG_NONE)
        endIf
        ; PAGE 5 RIGHT SIDE
        SetCursorPosition(1) ; Move cursor to top right position
        if (isEnabled)
            AddHeaderOption(__l("mcm_header_effect_notifications", "Effect Notifications"))
            AddToggleOptionST("ShowDreamNotification", __l("mcm_notification_dream", "Dream Effects"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_DREAM])
            AddToggleOptionST("ShowStudyNotification", __l("mcm_notification_study", "Post-Study Effects"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_STUDY])
            AddToggleOptionST("ShowDreadmilkNotification", __l("mcm_notification_dreadmilk", "Nootropic-Related Effects"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_DREADMILK])
            AddToggleOptionST("ShowTutorNotification", __l("mcm_notification_tutor", "Post-Tutor Effects"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_SPIRIT_TUTOR])
            AddToggleOptionST("ShowErrorNotification", __l("mcm_notification_error", "Error Messages"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_ERROR])
			AddHeaderOption(__l("mcm_header_add_remove_effects", "Add / Remove Spells and Effects"))
			removeSpellsOID = AddTextOption(__l("mcm_remove_spells", "Remove mod spells"), __l("mcm_click", "Click"), OPTION_FLAG_NONE)
			removePowerOID = AddTextOption(__l("mcm_remove_power", "Remove 'Study' ability"), __l("mcm_click", "Click"), OPTION_FLAG_NONE)
			removeStatusEffectsOID = AddTextOption(__l("mcm_purge_effects", "Remove mod status effects"), __l("mcm_click", "Click"), OPTION_FLAG_NONE)
			addPowerOID = AddTextOption(__l("mcm_add_power", "Add 'Study' ability"), __l("mcm_click", "Click"), OPTION_FLAG_NONE)
            addStatusTrackerOID = AddTextOption(__l("mcm_add_tracker", "Add mod status effect"), __l("mcm_click", "Click"), OPTION_FLAG_NONE)
        endIf
	endIf
endEvent

function CreatePageSpellList()
    InitializeSpellList()
    SetCursorFillMode(TOP_TO_BOTTOM) 
    AddHeaderOption(__l("mcm_header_spell_list", "Spell List"))
    int totalCount = spellListStates[SPELLS_COUNT]
    if totalCount == 0
        AddTextOption(__l("mcm_current_nothing", "Your list is empty."), "")
        return
    endIf
    int currentPageIndex = spellListStates[SPELLS_CURRENT_PAGEINDEX] 
    int pageCount = spellListStates[SPELLS_PAGECOUNT]
    int startIndex = currentPageIndex * 10
    int count = ControlScript.CopySpells(spellsInPage, startIndex, 10)
    spellListStates[SPELLS_PAGE_ITEMCOUNT] = count
    int i = 0
    int currentSpellIndex = spellListStates[SPELLS_PAGE_ITEMINDEX]
    if (currentSpellIndex < 0) && (count > 0)
        spellListStates[SPELLS_PAGE_ITEMINDEX] = 0
        currentSpellIndex = 0
    endIf
    string numText
    int oid

    while i < count
        if i == currentSpellIndex
            numText = "[" + (i + 1 + startIndex) + "]"
        else
            numText = (i + 1 + startIndex)
        endIf
        oid = AddTextOption(spellsInPage[i].GetName(), numText)
        spellOidList[i] = oid
        i += 1
    endWhile
    while i < 10
        oid = AddTextOption("", "")
        spellOidList[i] = oid
        i += 1
    endWhile
    string pageFormat = "{0}/" + pageCount
    AddSliderOptionST("CurrentPage", "=== " + __l("mcm_spell_list_current_page", "Current Page") + " ===", currentPageIndex + 1, pageFormat)

    SetCursorPosition(1)
    AddHeaderOption(__l("mcm_spell_list_actions", "List Actions"))
    int flag1 = GetEnabledOptionFlag(currentPageIndex > 0)
    AddTextOptionST("FirstPage", __l("mcm_spell_list_first_page", "First Page"), "|(", flag1)
    AddTextOptionST("PreviousPage", __l("mcm_spell_list_previous_page", "Previous Page"), "(", flag1)
    flag1 = GetEnabledOptionFlag(currentPageIndex < (pageCount - 1))
    AddTextOptionST("NextPage", __l("mcm_spell_list_next_page", "Next Page"), ")", flag1)
    AddTextOptionST("LastPage", __l("mcm_spell_list_last_page", "Last Page"), ")|", flag1)

    AddHeaderOption(__l("mcm_spell_list_selected", "Selected Spell"))
    flag1 = GetEnabledOptionFlag(count > 0)
    AddMenuOptionST("SpellCommand", __l("mcm_spell_list_execute_command", "Execute Command"), __l("mcm_spell_list_choose_command", "Choose"), flag1)
    AddSliderOptionST("MoveToIndex", __l("mcm_spell_list_move_to_location", "Move to Location"), startIndex + currentSpellIndex + 1, "{0}", flag1)
    flag1 = GetEnabledOptionFlag(currentPageIndex > 0 || currentSpellIndex > 0)
    AddTextOptionST("MoveFirst", __l("mcm_spell_list_move_to_top", "Move to Top"), "", flag1)
    AddTextOptionST("MoveUp", __l("mcm_spell_list_move_up", "Move Up"), "", flag1)
    flag1 = GetEnabledOptionFlag((count > 0) && ((startIndex + currentSpellIndex) < (totalCount - 1)))
    AddTextOptionST("MoveDown", __l("mcm_spell_list_move_down", "Move Down"), "", flag1)
    AddTextOptionST("MoveBottom", __l("mcm_spell_list_move_to_bottom", "Move to Bottom"), "", flag1)

endFunction

int function GetEnabledOptionFlag(bool enabled)
    if enabled
        return OPTION_FLAG_NONE
    else
        return OPTION_FLAG_DISABLED
    endIf
endFunction

; === Config Helper Functions
function enableModEffects()
	PlayerRef.AddSpell(_LEARN_PracticeAbility, true)
	PlayerRef.AddSpell(_LEARN_StudyPower, true)
endFunction

function disableModEffects()
	purgeStatusEffects()
	if (PlayerRef.HasSpell(_LEARN_StudyPower))
		PlayerRef.RemoveSpell(_LEARN_StudyPower)
	endIf
endFunction

function addPower()
	if (!PlayerRef.HasSpell(_LEARN_StudyPower))
		PlayerRef.AddSpell(_LEARN_StudyPower)
	endIf
endFunction

function purgeStatusEffects()
	; This should remove all potion and addiction effects
	PlayerRef.DispelAllSpells()
	Utility.wait(3)
	; Wait for OnRemoval effects to trigger because those add more status effects.
	PlayerRef.DispelAllSpells()
	if (PlayerRef.HasSpell(_LEARN_DiseaseDreadmilk))
		PlayerRef.RemoveSpell(_LEARN_DiseaseDreadmilk)
	endIf
	; status effects and powers
	if (PlayerRef.HasSpell(_LEARN_PracticeAbility))
		PlayerRef.RemoveSpell(_LEARN_PracticeAbility)
    endIf
	; status effects and powers
	if (PlayerRef.HasSpell(_LEARN_SpellsToLearn))
		PlayerRef.RemoveSpell(_LEARN_SpellsToLearn)
    endIf
endFunction

function removePower()
	if (PlayerRef.HasSpell(_LEARN_StudyPower))
		PlayerRef.RemoveSpell(_LEARN_StudyPower)
	endIf
endFunction

function addStatusTracker()
	if (!PlayerRef.HasSpell(_LEARN_PracticeAbility))
		PlayerRef.AddSpell(_LEARN_PracticeAbility)
    endIf
    ControlScript.updateSpellLearningEffect()
endFunction

function addModSpells()
	PlayerRef.AddSpell(_LEARN_SummonSpiritTutor, true)
	PlayerRef.AddSpell(_LEARN_SetHomeSp, true)
endFunction

function removeModSpells()
	if (PlayerRef.HasSpell(_LEARN_SummonSpiritTutor))
		PlayerRef.RemoveSpell(_LEARN_SummonSpiritTutor)
	EndIf
	if (PlayerRef.HasSpell(_LEARN_SetHomeSp))
		PlayerRef.RemoveSpell(_LEARN_SetHomeSp)
	EndIf
endFunction

; ====================================================================================
; === On Select, Highlight, and Accept definitions
Event OnOptionMenuOpen(int option)
    if (option == forceSchoolOID)
        setMenuDialogOptions(ControlScript.getSchools())
        setMenuDialogStartIndex(forceSchoolIndex)
        setMenuDialogDefaultIndex(1)
        return
    endif
    if (option == effortScalingOID)
        setMenuDialogOptions(ControlScript.getEffortLabels())
        setMenuDialogStartIndex(effortScalingIndex)
        setMenuDialogDefaultIndex(0)
        return
    endif
EndEvent

event OnOptionMenuAccept(int option, int index)
    if (option == forceSchoolOID)
        forceSchoolIndex = index
        SetMenuOptionValue(option, ControlScript.getSchools()[forceSchoolIndex], false)
        _LEARN_ForceDiscoverSchool.SetValue(index)
    endif
    if (option == effortScalingOID)
        effortScalingIndex = index
        SetMenuOptionValue(option, ControlScript.getEffortLabels()[effortScalingIndex], false)
        _LEARN_effortScaling.SetValue(index)
		forcepagereset()
    endif
EndEvent

Event OnOptionSliderOpen(Int a_option)    ; SLIDERS

    If (a_option == maxConsecutiveFailuresOID)
        SetSliderDialogStartValue(_LEARN_MaxFailsBeforeCycle.GetValue())
        SetSliderDialogDefaultValue(2)
        SetSliderDialogRange(0, 10)
        SetSliderDialogInterval(1)
        return
    EndIf
	
    If (a_option == autoNoviceLearningOID)
        SetSliderDialogStartValue(_LEARN_AutoNoviceLearning.GetValue())
        SetSliderDialogDefaultValue(30)
        SetSliderDialogRange(0, 100)
        SetSliderDialogInterval(5)
        return
    EndIf
	
	If (a_option == dreadstareLethalityOID)
        SetSliderDialogStartValue(_LEARN_DreadstareLethality.GetValue())
        SetSliderDialogDefaultValue(10)
        SetSliderDialogRange(0, 90)
        SetSliderDialogInterval(1)
        return
    EndIf
	
    If (a_option == parallelLearningOID)
        SetSliderDialogStartValue(_LEARN_ParallelLearning.GetValue())
        SetSliderDialogDefaultValue(1)
        SetSliderDialogRange(1, 10)
        SetSliderDialogInterval(1)
        return
    EndIf

    If (a_option == minChanceStudyOID)
        SetSliderDialogStartValue(_LEARN_MinChanceStudy.GetValue())
        SetSliderDialogDefaultValue(5)
        SetSliderDialogRange(0, _LEARN_MaxChanceStudy.GetValue())
        SetSliderDialogInterval(1)
        return
    EndIf

    If (a_option == maxChanceStudyOID)
        SetSliderDialogStartValue(_LEARN_MaxChanceStudy.GetValue())
        SetSliderDialogDefaultValue(80)
        SetSliderDialogRange(_LEARN_MinChanceStudy.GetValue(), 100)
        SetSliderDialogInterval(1)
        return
    EndIf

    If (a_option == minChanceDiscoverOID)
        SetSliderDialogStartValue(_LEARN_MinChanceDiscover.GetValue())
        SetSliderDialogDefaultValue(0)
        SetSliderDialogRange(0, _LEARN_MaxChanceDiscover.GetValue())
        SetSliderDialogInterval(1)
        return
    EndIf

    If (a_option == maxChanceDiscoverOID)
        SetSliderDialogStartValue(_LEARN_MaxChanceDiscover.GetValue())
        SetSliderDialogDefaultValue(10)
        SetSliderDialogRange(_LEARN_MinChanceDiscover.GetValue(), 100)
        SetSliderDialogInterval(1)
        return
    EndIf

    If (a_option == bonusScaleOID)
        SetSliderDialogStartValue(_LEARN_BonusScale.GetValue())
        SetSliderDialogDefaultValue(1.0)
        SetSliderDialogRange(0, 4)
        SetSliderDialogInterval(0.1)
        return
    EndIf

    If (a_option == studyIntervalOID)
        SetSliderDialogStartValue(_LEARN_StudyInterval.GetValue())
        SetSliderDialogDefaultValue(0.65)
        SetSliderDialogRange(0, 7)
        SetSliderDialogInterval(0.01)
        return
    EndIf
	
	If (a_option == tooDifficultDeltaOID)
        SetSliderDialogStartValue(_LEARN_TooDifficultDelta.GetValue())
        SetSliderDialogDefaultValue(30)
        SetSliderDialogRange(5, 100)
        SetSliderDialogInterval(5)
        return
    EndIf
	
	If (a_option == intervalCdrOID)
        SetSliderDialogStartValue(_LEARN_IntervalCDR.GetValue())
        SetSliderDialogDefaultValue(25)
        SetSliderDialogRange(1, 100)
        SetSliderDialogInterval(1)
        return
    EndIf

    If (a_option == maxNotesBonusOID)
        SetSliderDialogStartValue(_LEARN_maxNotesBonus.GetValue())
        SetSliderDialogDefaultValue(33)
        SetSliderDialogRange(1, 100)
        SetSliderDialogInterval(1)
        return
    EndIf

    If (a_option == maxNotesOID)
        SetSliderDialogStartValue(_LEARN_maxNotes.GetValue())
        SetSliderDialogDefaultValue(750)
        SetSliderDialogRange(1, 10000)
        SetSliderDialogInterval(1)
        return
    EndIf

EndEvent

Event OnOptionSliderAccept(Int a_option, Float a_value)

    If (a_option == maxConsecutiveFailuresOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        _LEARN_MaxFailsBeforeCycle.SetValue(a_value)
        if (_LEARN_ParallelLearning.GetValue() != 1 && a_value > 0)
            _LEARN_ParallelLearning.SetValue(1)
            Debug.MessageBox(__l("mcm_message_multiple_consecutive_exclusive", "Learning multiple spells at once and limiting maximum consecutive failures are mutually exclusive. Your settings have been changed accordingly."))
        endIf
		forcepagereset()
        return
    EndIf
	
	If (a_option == autoNoviceLearningOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        _LEARN_AutoNoviceLearning.SetValue(a_value)
        return
    EndIf
	
	If (a_option == dreadstareLethalityOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        _LEARN_DreadstareLethality.SetValue(a_value)
        return
    EndIf
	
	If (a_option == parallelLearningOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        _LEARN_ParallelLearning.SetValue(a_value)
        if (_LEARN_MaxFailsBeforeCycle.GetValue() != 0 && a_value > 1)
            _LEARN_MaxFailsBeforeCycle.SetValue(0)
            Debug.MessageBox(__l("mcm_message_multiple_consecutive_exclusive", "Learning multiple spells at once and limiting maximum consecutive failures are mutually exclusive. Your settings have been changed accordingly."))
        endIf
		forcepagereset()
        return
    EndIf

    If (a_option == minChanceStudyOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        _LEARN_MinChanceStudy.SetValue(a_value)
        return
    EndIf

    If (a_option == maxChanceStudyOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        _LEARN_MaxChanceStudy.SetValue(a_value)
        return
    EndIf

    If (a_option == minChanceDiscoverOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        _LEARN_MinChanceDiscover.SetValue(a_value)
        return
    EndIf

    If (a_option == maxChanceDiscoverOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        _LEARN_MaxChanceDiscover.SetValue(a_value)
        return
    EndIf

    If (a_option == bonusScaleOID)   
        SetSliderOptionValue(a_option, a_value, "{1}", false)
        _LEARN_BonusScale.SetValue(a_value)
		forcepagereset()
        return
    EndIf

    If (a_option == studyIntervalOID)   
        SetSliderOptionValue(a_option, a_value, "{2}", false)
        _LEARN_studyInterval.SetValue(a_value)
        return
    EndIf
	
	If (a_option == tooDifficultDeltaOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        _LEARN_TooDifficultDelta.SetValue(a_value)
        return
    EndIf
	
	If (a_option == intervalCdrOID)
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        _LEARN_IntervalCDR.SetValue(a_value)
        return
    EndIf

    If (a_option == maxNotesBonusOID)
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        _LEARN_maxNotesBonus.SetValue(a_value)
        return
    EndIf

    If (a_option == maxNotesOID)
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        _LEARN_maxNotes.SetValue(a_value)
        return
    EndIf

EndEvent

event OnOptionSelect(int option)
    if (option != 0 && CurrentPage == Pages[2] && SelectSpellItem(option))
        return
    endIf
	; === Enabling/Disabling Mod
    If (Option == isEnabledOption)
        IsEnabled = !IsEnabled
        SetToggleOptionValue(option, IsEnabled, False)
        if (IsEnabled)
			_LEARN_SpellControlQuest.Start()
			ControlScript.start()
			enableModEffects()
        Else
            disableModEffects()
			ControlScript.stop()
			_LEARN_SpellControlQuest.Stop()
        EndIf
	; === Setting Custom Location
    ElseIf (Option == customLocationOID)
        Location l = Game.GetPlayer().GetCurrentLocation()
        if (ControlScript.customLocation != l)
            ControlScript.customLocation = l
        Else
            ControlScript.customLocation = None
        endif
        forcepagereset()
    ElseIf (Option == removeOID)
        SetToggleOptionValue(option, toggleRemove(), False)
        forcepagereset()
    ElseIf (Option == collectOID)
        SetToggleOptionValue(option, toggleCollect(), False)
        ; If we just stopped taking notes, make sure Studying doesn't require them.
        if (_LEARN_CollectNotes.GetValue() == 0 && _LEARN_StudyRequiresNotes.GetValue() == 1)
            toggleStudyRequiresNotes()
        endIf
        ; If turning on taking notes, also turn on 'Study requires notes' because it's a default.
        ; this isn't enforced, the user can still toggle it off, but if they are collecting
        ; notes they probably want this setting on.
        if (_LEARN_CollectNotes.GetValue() == 1)
            toggleStudyRequiresNotes()
        endIf
        forcepagereset()
	ElseIf (Option == harderParallelOID)
		SetToggleOptionValue(option, toggleHarderParallel(), False)
	ElseIf (Option == autoSuccessBypassesLimitOID)
		SetToggleOptionValue(option, toggleAutoSuccessBypassesLimit(), False)	
	ElseIf (Option == noviceLearningEnabledOID)
		SetToggleOptionValue(option, toggleNoviceLearningEnabled(), False)	
		forcepagereset()
	ElseIf (Option == potionBypassOID)
		SetToggleOptionValue(option, togglePotionBypass(), False)
	ElseIf (Option == tooDifficultEnabledOID)
		SetToggleOptionValue(option, toggleTooDifficultEnabled(), False)
		forcepagereset()
	ElseIf (Option == intervalCDRenabledOID)
		SetToggleOptionValue(option, toggleIntervalCDREnabled(), False)
		forcepagereset()
	ElseIf (Option == dynamicDiffOID)
		SetToggleOptionValue(option, toggleDynamicDifficulty(), False)
	ElseIf (Option == maxFailsAutoSucceedsOID)
		SetToggleOptionValue(option, toggleMaxFailsAutoSucceeds(), False)
	ElseIf (Option == studyIsRestOID)
        SetToggleOptionValue(option, toggleStudyIsRest(), False)
        ; if we turned it on, make sure at least one of the functions of the power is enabled.
        if (_LEARN_StudyIsRest.GetValue())
            _LEARN_DiscoverOnStudy.SetValue(1)
        endIf
        forcepagereset()
	ElseIf (Option == studyRequiresNotesOID)
		SetToggleOptionValue(option, toggleStudyRequiresNotes(), False)
	ElseIf (Option == removeSpellsOID)
		removeModSpells()
	ElseIf (Option == removePowerOID)
		removePower()
	ElseIf (Option == removeStatusEffectsOID)
		purgeStatusEffects()
	ElseIf (Option == addPowerOID)
		addPower()
	ElseIf (Option == addStatusTrackerOID)
        addStatusTracker()
    ElseIf (Option == learnOnStudyOID)
        SetToggleOptionValue(option, toggleLearnOnStudy(), False)
        ; If we turned this off and discoveronstudy is also off, turn off studyisrest.
        if ((_LEARN_DiscoverOnStudy.GetValue() == 0) && (_LEARN_LearnOnStudy.GetValue() == 0))
            _LEARN_StudyIsRest.SetValue(0)
            ; this doesn't grey out any options on toggle, so we don't need to force
            ; a page refresh no matter what, only if we did actually change something.
            forcepagereset()
        endIf
        ; If we turned this off and learnonsleep is also off, disable learning functionality.
        if ((_LEARN_LearnOnSleep.GetValue() == 0) && (_LEARN_LearnOnStudy.GetValue() == 0))
            _LEARN_ResearchSpells.SetValue(0)
            _LEARN_RemoveSpellBooks.SetValue(0)
            forcepagereset()
        endIf
    ElseIf (Option == discoverOnStudyOID)
        SetToggleOptionValue(option, toggleDiscoverOnStudy(), False)
        ; If we turned this off and learnonstudy is also off, turn off studyisrest.
        if ((_LEARN_DiscoverOnStudy.GetValue() == 0) && (_LEARN_LearnOnStudy.GetValue() == 0))
            _LEARN_StudyIsRest.SetValue(0)
            forcepagereset()
        endIf
    ElseIf (Option == learnOnSleepOID)
        SetToggleOptionValue(option, toggleLearnOnSleep(), False)
        ; If we turned this off and learnonstudy is also off, disable learning functionality.
        if ((_LEARN_LearnOnSleep.GetValue() == 0) && (_LEARN_LearnOnStudy.GetValue() == 0))
            _LEARN_ResearchSpells.SetValue(0)
            _LEARN_RemoveSpellBooks.SetValue(0)
            forcepagereset()
        endIf
    ElseIf (Option == discoverOnSleepOID)
        SetToggleOptionValue(option, toggleDiscoverOnSleep(), False)
    ElseIf (Option == addToListOID)
        SetToggleOptionValue(option, toggleAddToList(), False)
        if ((_LEARN_ResearchSpells.GetValue()) && !(_LEARN_RemoveSpellBooks.GetValue()))
            ; if we just turned spell learning on and remove spellbooks is off, turn it on too.
            toggleRemove()
        elseIf(!(_LEARN_ResearchSpells.GetValue()) && (_LEARN_RemoveSpellBooks.GetValue()))
            ; if we just turned spell learning off and remove spellbooks is on, turn it off too.
            toggleRemove()
        endIf
        ; If it's been toggled off, turn off learn on sleep and learn on study.
        if (!(_LEARN_ResearchSpells.GetValue()))
            _LEARN_LearnOnSleep.SetValue(0)
            _LEARN_LearnOnStudy.SetValue(0)
        else
            ; If it's been toggled on, make sure at least one way of learning is enabled.
            _LEARN_LearnOnSleep.SetValue(1)
        endIf
        forcepagereset()
    ElseIf (Option == returnTomesOID)
        SetToggleOptionValue(option, toggleReturnTomes(), False)
        ; If we've just turned it on, check to ensure that leave known tomes alone is on
        if (_LEARN_ReturnTomes.GetValue() == 1 && _LEARN_RemoveUnknownOnly.GetValue() == 0)
            toggleRemoveUnknownOnly()
        endIf
        forcepagereset()
    ElseIf (Option == removeUnknownOnlyOID)
        SetToggleOptionValue(option, toggleRemoveUnknownOnly(), False)
    ElseIf (Option == fissExportOID)
        fiss = getFISS()
        if (fiss == None)
            Debug.MessageBox(__l("mcm_message_fiss_not_working", "FISS is not working"))
        else
            Debug.MessageBox(__l("mcm_message_fiss_wait", "Please wait until the next message box. Do not quit this MCM menu yet."))
            fiss.beginSave("SpellLearning.xml", "SpellLearning")
            ; loop through spell study list
            int i = 0
            Spell sp = ControlScript.spell_fifo_peek(i)
            if (sp != None)
                While (sp && (i< 128))
                    fiss.saveString("SpellName"+i, sp.getName())
                    fiss.saveInt("SpellID"+i, Math.LogicalAnd(sp.getFormID(), 0x00FFFFFF))
                    fiss.saveString("SpellMod"+i, Game.GetModName(Math.RightShift(sp.getFormID(), 6*4)))
                    i += 1
                    sp = ControlScript.spell_fifo_peek(i)
                EndWhile
                fiss.saveInt("SpellCount", i)
            EndIf
            fiss.endSave()
            Debug.MessageBox(__l("mcm_message_fiss_done", "Done. You are free to leave this MCM menu."))
        EndIf
    ElseIf (Option == fissImportOID)
        fiss = getFISS()
        if (fiss == None)
            Debug.MessageBox(__l("mcm_message_fiss_not_working", "FISS is not working"))
        else
            ; reset spell study list
            while (ControlScript.spell_fifo_pop() != none)
            EndWhile
            
            Debug.MessageBox(__l("mcm_message_fiss_wait", "Please wait until the next message box. Do not quit this MCM menu yet."))
            fiss.beginLoad("SpellLearning.xml")
            Spell sp
            int iSpellcount = fiss.loadInt("SpellCount")
            int i = 0
            while (i < iSpellCount)
                sp = Game.GetFormFromFile(fiss.loadInt("SpellID"+i), fiss.loadString("SpellMod"+i)) as Spell
                if (sp != none)
                    ControlScript.spell_fifo_push(sp)
                EndIf
                i += 1
            EndWhile
            fiss.endLoad()
            Debug.MessageBox(__l("mcm_message_fiss_done", "Done. You are free to leave this MCM menu."))
        EndIf
    EndIf

endEvent

Event OnOptionHighlight(int option)
    If (Option == minChanceStudyOID)
        SetInfoText(__l("hint_minChanceStudy", "Minimum chance per night to learn a spell from books you've read or spells you've discovered. Defaults to 20%."))
    ElseIf (Option == maxChanceStudyOID)
        SetInfoText(__l("hint_maxChanceStudy", "Maximum chance per night to learn a spell from books you've read or spells you've discovered. Defaults to 80%."))
    ElseIf (Option == minChanceDiscoverOID)
        SetInfoText(__l("hint_minChanceDiscover", "Minimum chance per night to discover a new spell, adding it to the study list without the need for a book. Defaults to 0%.")) 
    ElseIf (Option == maxChanceDiscoverOID)
        SetInfoText(__l("hint_maxChanceDiscover", "Maximum chance per night to discover a new spell, adding it to the study list without the need for a book. Defaults to 10%."))
    ElseIf (Option == maxConsecutiveFailuresOID)
        SetInfoText(__l("hint_maxConsecutiveFailures", "Maximum consecutive failures before automatically succeeding. Set to 0 for unlimited failures. Defaults to 3."))
    ElseIf (Option == autoNoviceLearningOID)
        SetInfoText(__l("hint_autoNoviceLearning", "Required skill difference to always succeed when learning spells. At 25, a difference of one skill tier is required - e.g. 50 in Destruction means you'll never fail at learning Novice or Apprentice level Destruction spells. Lowering this makes things easier overall. Defaults to 30."))
	ElseIf (Option == noviceLearningEnabledOID)
		SetInfoText(__l("hint_noviceLearningEnabled", "When enabled, the difference between your skill in a school and the level of the spell you're trying to learn can result in an automatic success. The required difference to ensure this success is configurable below. Defaults to on."))
	ElseIf (Option == autoSuccessBypassesLimitOID)
		SetInfoText(__l("hint_autoSuccessBypassesLimit", "Spells learned via the above option do not count towards the daily limit and all eligible spells will be learned on rest. Defaults to on."))
	ElseIf (Option == dreadstareLethalityOID)
        SetInfoText(__l("hint_dreadstareLethality", "Base chance to overdose when consuming Dreadmilk. Defaults to 10%. Increased by your bloodstream toxicity."))
	ElseIf (Option == parallelLearningOID)
        SetInfoText(__l("hint_parallelLearning", "Choose how many spells from the top of your list you will try to learn on each attempt. Keep in mind that when combined with drugs and a high max learning chance, this can be overpowered. It is recommended to turn off learning failure notifications when learning lots of spells to prevent failure message spam. 1 is default."))
	ElseIf (Option == harderParallelOID)
        SetInfoText(__l("hint_harderParallel", "When learning multiple spells at once, divide the chance to learn by the amount of spells being learned to help preserve a similar speed. Recommended, defaults to on."))
    ElseIf (Option == bonusScaleOID)
        SetInfoText(__l("hint_bonusScale", "Multiplier applied to the roleplaying bonus to chance of learning/discovering. This means casting spells relevant to your study, hoarding relevant spell notes, sleeping or studying at the College and temples, consuming nootropics, etc. Default is 1.0. Raising this can make it unreasonably easy to learn spells."))
    ElseIf (Option == infoStudyOID)
        SetInfoText(__l("hint_infoStudy", "Current chance to learn the next spell on your list on an eligible rest. Cast spells of the same school, use potions, or collect more notes to improve. If your study list is empty, this will show 0%."))
    ElseIf (Option == infoDiscoverOID)
        SetInfoText(__l("hint_infoDiscover", "Current chance to discover a new spell and add it to the study list on an eligible rest. Cast spells of your current school of interest, use potions, or collect more notes to improve."))
    ElseIf (Option == infoSchoolOID)
        SetInfoText(__l("hint_infoSchool", "Current magical school of interest."))
    ElseIf (Option == collectOID)
        SetInfoText(__l("hint_collectNotes", "Whether or not to deconstruct removed or insta-learned books into notes. Keeping a large collection of spell notes improves the chances of learning and discovery. The number of notes generated depends on your skill in relation to the spell, with the maximum amount generated being equal in value to the base value of the book. Default is enabled."))
    ElseIf (Option == removeOID)
        SetInfoText(__l("hint_removeBooks", "Whether or not to remove spell books from inventory when added, to prevent vanilla 'insta-learn'. Default is enabled. Only turn this off if you are also disabling the mod's Spell Learning functions above!")) 
    ElseIf (Option == forceSchoolOID)
        SetInfoText(__l("hint_preferedSchool", "Set this to the school of magic you want to discover spells from. Default is Automatic, which uses your most cast school from that day."))
    ElseIf (Option == effortScalingOID)
        SetInfoText(__l("hint_effortScaling", "The way effort scales when rolling for successful learning. Default is Tough Start, which is harsher to those with poorer magical skills and less overall bonus from things like notes."))
	ElseIf (Option == fissExportOID)
        SetInfoText(__l("hint_export", "Export/backup spell study list to FISS XML."))
    ElseIf (Option == fissImportOID)
        SetInfoText(__l("hint_import", "Import/restore spell study list from FISS XML."))
    ElseIf (Option == CustomLocationOID)
        setInfoText(__l("hint_customLocation", "Click to mark the current location as your personal study. It will provide a learning bonus similar to temples, but not as much as the College. Click again to unset. This can also be set with the Attunement spell."))
    ElseIf (Option == studyIntervalOID)
        setInfoText(__l("hint_studyInterval", "How many days must pass between learning and discovery attempts. Default is 0.65."))
	ElseIf (Option == tooDifficultDeltaOID)
        setInfoText(__l("hint_tooDifficultDiff", "The difference in skill required to automatically fail learning. Lowering this makes things harder overall. Default is 30 - at or below Destruction 20, you will fail to learn Destruction 50+ spells."))
	ElseIf (Option == tooDifficultEnabledOID)
        setInfoText(__l("hint_tooDiffEnabled", "When enabled, you can automatically fail to learn a spell if it's significantly above your current skill level. In this case you will automatically move to the next possible spell without penalty."))
    ElseIf (Option == isEnabledOption)
		setInfoText(__l("hint_deletionWarning", "WARNING: Disabling mod will clear your spell research list, remove known mod spells and purge *ALL* non-permanent spell effects from your character! Use FISS backups to save your research list!"))
	ElseIf (Option == potionBypassOID)
		setInfoText(__l("hint_potionBypass", "When enabled, Dreadmilk will bypass enabled skill requirements. For example, with Dreadmilk a novice can attempt to learn a master spell even when they would otherwise be prevented from doing so. Defaults to on."))
	ElseIf (Option == intervalCDRenabledOID)
		setInfoText(__l("hint_cdrEnabled", "When enabled, casting up to 100 spells will reduce the cooldown between learning and discovery attempts. Defaults to on."))
	ElseIf (Option == intervalCdrOID)
		setInfoText(__l("hint_cdr", "The maximum percentage by which the cooldown can be reduced through practice. Defaults to 25%."))
	ElseIf (Option == maxFailsAutoSucceedsOID)
		setInfoText(__l("hint_maxFailsSucceeds", "When enabled, reaching the maximum failure limit will cause you to succeed as long as it isn't prevented by something like the skill difference option. When off, the spell will be moved to the bottom of your list instead. Defaults to on."))
	ElseIf (Option == dynamicDiffOID)
		setInfoText(__l("hint_dynamicDiff", "When enabled, the chance to learn a spell also depends on its own difficulty relative to your skill. Makes learning spells twice your magical skill level about twice as hard, or half your skill level about two times easier. Defaults to on."))
	ElseIf (Option == nootropicStatusOID)
		setInfoText(__l("hint_drug_status", "Your current level of toxicity from consuming Dreadmilk and Shadowmilk. As it increases, so does the chance of overdose on consumption. Decreases over time with rest."))
	ElseIf (Option == tutorStatusOID)
		setInfoText(__l("hint_tutor_status", "Whether or not you have successfully recieved the bonus from the Summon Daedric Tutor spell for this learning period."))
	ElseIf (Option == attunementStatusOID)
		setInfoText(__l("hint_attunement_status", "Amount of spell learning attempts left before you can change your custom study location with the Attunement spell."))
	ElseIf (Option == studyIsRestOID)
		setInfoText(__l("hint_study_is_rest", "Whether to use the Study power as a once-per-interval bonus or as a way to learn/discover. Defaults to no bonus, which uses it to learn/discover."))
	ElseIf (Option == studyRequiresNotesOID)
		setInfoText(__l("hint_study_requires_notes", "Whether or not using the 'Study' power requires having notes in the inventory. Defaults to on."))
	ElseIf (Option == removeSpellsOID)
		setInfoText(__l("hint_remove_spells", "Removes Attunement and Summon Daedric Tutor from your spells (if known)."))
	ElseIf (Option == removePowerOID)
		setInfoText(__l("hint_remove_power", "Removes the 'Study' power from your character."))
	ElseIf (Option == removeStatusEffectsOID)
		setInfoText(__l("hint_remove_status", "Removes all mod-related status effects, including the tracking effect and potion effects. Also removes the 'Spell Learning' tracking status effect."))
	ElseIf (Option == addPowerOID)
		setInfoText(__l("hint_add_power", "Adds the 'Study' power to your character, which can be assigned like a dragon shout to enable learning and discovery without sleeping."))
	ElseIf (Option == addStatusTrackerOID)
		setInfoText(__l("hint_add_tracker_effect", "Adds the 'Spell Learning' tracking effect to your character, which records spell casts, automatically removes spellbooks, and generates notes."))
    ElseIf (Option == learnOnStudyOID)
		setInfoText(__l("hint_learn_on_study", "When enabled, using the 'Study' power will cause you to attempt to learn new spells off your spell list. Defaults to on."))
    ElseIf (Option == discoverOnStudyOID)
        setInfoText(__l("hint_discover_on_study", "When enabled, using the 'Study' power will cause you to attempt to discover a new spell, adding it to the study list without the need for a book. Defaults to on."))
    ElseIf (Option == learnOnSleepOID)
        setInfoText(__l("hint_learn_on_sleep", "When enabled, sleeping in a bed will cause you to attempt to learn new spells off your spell list. Defaults to on."))
    ElseIf (Option == discoverOnSleepOID)
		setInfoText(__l("hint_discover_on_sleep", "When enabled, sleeping in a bed will cause you to attempt to discover a new spell, adding it to the study list without the need for a book. Defaults to on. "))
    ElseIf (Option == alreadyStudiedOID)
        setInfoText(__l("hint_already_studied", "Whether or not you have already recieved the bonus from using the 'Study' power this cycle."))
    ElseIf (Option == maxNotesBonusOID)
        setInfoText(__l("hint_max_notes_bonus", "The highest possible total chance provided by school-specific notes in your inventory. If the study power is not used for learning or discovery, it will provide a bonus maxed at half of this value. Default is 33%."))
    ElseIf (Option == maxNotesOID)
        setInfoText(__l("hint_max_notes", "The value of school-specific notes required to reach the above maximum bonus chance. If the study power is not used for learning or discovery, it will require 5 times this number of any notes to give its max modifier. Defaults to 750g."))
    ElseIf (Option == addToListOID)
        setInfoText(__l("hint_add_to_list", "Whether or not unknown spells are added to the research list when a spell tome enters your inventory. Its tome will also be removed when this occurs to prevent vanilla 'insta-learning' from it. If you only want to use this mod's spell discovery features, turn this off. Defaults to on."))
    ElseIf (Option == returnTomesOID)
        setInfoText(__l("hint_return_tomes", "Whether or not spell tomes are returned to your inventory after you learn their spells. Can only return tomes that were removed while this option was enabled. Defaults to off."))
    ElseIf (Option == removeUnknownOnlyOID)
        setInfoText(__l("hint_remove_only_unknown", "When on, tomes for spells you already know will never be removed and won't generate any spell notes. Defaults to off.  If you are using the return tomes option, this must be turned on."))
    EndIf
EndEvent

; ====================================================================================
; === Some Custom UI functions
function InternalSetOptionTextValue(Int a_index, String a_strValue, Bool a_noUpdate = false)
	String menu = "Journal Menu"
	String root = "_root.ConfigPanelFader.configPanel"
	ui.SetInt(menu, root + ".optionCursorIndex", a_index)
	ui.SetString(menu, root + ".optionCursor.text", a_strValue)
	if !a_noUpdate
		ui.Invoke(menu, root + ".invalidateOptionData")
	endIf
endFunction 

function CustomSetOptionText(Int a_option, String a_value, Bool a_noUpdate = false)
	Int index = a_option % 256
    InternalSetOptionTextValue(index, a_value, a_noUpdate)
endFunction

function CustomUpdateTextOption(Int a_option, String a_header, string a_strValue, Bool a_noUpdate = false)
	Int index = a_option % 256
	String menu = "Journal Menu"
	String root = "_root.ConfigPanelFader.configPanel"
	ui.SetInt(menu, root + ".optionCursorIndex", index)
	ui.SetString(menu, root + ".optionCursor.text", a_header)
	ui.SetString(menu, root + ".optionCursor.strValue", a_strValue)
	if !a_noUpdate
		ui.Invoke(menu, root + ".invalidateOptionData")
	endIf
endFunction

; === Spell List Management
function InitializeSpellList()
    if isSpellListInitialized
        return
    endIf
    spellsInPage = new Form[10]
    spellOidList = new int[10]
    spellListStates = new int[6]
    int count = ControlScript.spell_fifo_get_count()
    spellListStates[SPELLS_COUNT] = count
    int pageCount = count / 10
    if (count % 10) != 0
        pageCount += 1
    endIf
    spellListStates[SPELLS_PAGECOUNT] = pageCount
    if count > 0
        spellListStates[SPELLS_PAGE_ITEMINDEX] = 0
        spellListStates[SPELLS_CURRENT_PAGEINDEX] = 0
    else
        spellListStates[SPELLS_PAGE_ITEMINDEX] = -1
    endIf

    spellCommandsMenu = new string[3]
    spellCommandsMenu[SPELL_COMMAND_NONE] = __l("mcm_spell_command_none", "No Operation")
    spellCommandsMenu[SPELL_COMMAND_REMOVE] = __l("mcm_spell_command_remove", "Remove")
    spellCommandsMenu[SPELL_COMMAND_LEARN] = __l("mcm_spell_command_learn", "Learn (Instantly)")

    isSpellListInitialized = true
endFunction

bool function SelectSpellItem(int option)
    return SelectSpellItemByIndex(spellOidList.Find(option))
endFunction

bool function SelectSpellItemByIndex(int itemIndex)
    if itemIndex < 0
        return false
    endIf
    int pageItemCount = spellListStates[SPELLS_PAGE_ITEMCOUNT]
    if itemIndex >= pageItemCount
        return false
    endIf
    int currentIndex = spellListStates[SPELLS_PAGE_ITEMINDEX]
    if currentIndex == itemIndex
        return false
    endIf
    spellListStates[SPELLS_PAGE_ITEMINDEX] = itemIndex
    int pageIndex = spellListStates[SPELLS_CURRENT_PAGEINDEX]
    int startIndex = pageIndex * 10

    UpdateMoveSpellButtons(pageIndex, itemIndex)

    SetSliderOptionValueST(1 + startIndex + itemIndex, "{0}", true, "MoveToIndex")
    SetTextOptionValue(spellOidList[currentIndex], 1 + startIndex + currentIndex, true)
    SetTextOptionValue(spellOidList[itemIndex], "[" + (1 + startIndex + itemIndex) + "]", false)

    return true
endFunction

function UpdateMoveSpellButtons(int pageIndex, int itemIndex)
    int totalCount = spellListStates[SPELLS_COUNT]
    int startIndex = pageIndex * 10

    int flag1 = GetEnabledOptionFlag(totalCount > 0)
    SetOptionFlagsST(flag1, true, "SpellCommand")
    SetOptionFlagsST(flag1, true, "MoveToIndex")
    flag1 = GetEnabledOptionFlag(pageIndex > 0 || itemIndex > 0)
    SetOptionFlagsST(flag1, true, "MoveFirst")
    SetOptionFlagsST(flag1, true, "MoveUp")
    flag1 = GetEnabledOptionFlag((totalCount > 0) && ((startIndex + itemIndex) < (totalCount - 1)))
    SetOptionFlagsST(flag1, true, "MoveDown")
    SetOptionFlagsST(flag1, true, "MoveBottom")
endFunction

function GotoSpellPage(int pageIndex, int selectedItemIndex = 0)
    int pageCount = spellListStates[SPELLS_PAGECOUNT]
    spellListStates[SPELLS_CURRENT_PAGEINDEX] = pageIndex
    spellListStates[SPELLS_PAGE_ITEMINDEX] = selectedItemIndex

    int flag1 = GetEnabledOptionFlag(pageIndex > 0)
    SetOptionFlagsST(flag1, true, "FirstPage")
    SetOptionFlagsST(flag1, true, "PreviousPage")
    flag1 = GetEnabledOptionFlag(pageIndex < (pageCount - 1))
    SetOptionFlagsST(flag1, true, "NextPage")
    SetOptionFlagsST(flag1, true, "LastPage")
    SetSliderOptionValueST(pageIndex + 1, "{0}/" + pageCount, true, "CurrentPage")

    int startIndex = pageIndex * 10
    int count = ControlScript.CopySpells(spellsInPage, startIndex, 10)
    if selectedItemIndex < 0 
        selectedItemIndex = count - 1
        spellListStates[SPELLS_PAGE_ITEMINDEX] = selectedItemIndex
    endIf

    int currentSpellIndex = selectedItemIndex
    UpdateMoveSpellButtons(pageIndex, currentSpellIndex)

    spellListStates[SPELLS_PAGE_ITEMCOUNT] = count
    int i = 0
    string numText

    String menu = "Journal Menu"
    String root = "_root.ConfigPanelFader.configPanel"
    string indexPath = root + ".optionCursorIndex"
    string textPath = root + ".optionCursor.text"
    string valuePath = root + ".optionCursor.strValue"
    while i < count
        if i == currentSpellIndex
            numText = "[" + (i + 1 + startIndex) + "]"
            ;numText = "*"
        else
            numText = (i + 1 + startIndex)
            ;numText = ""
        endIf
        ui.SetInt(menu, indexPath, spellOidList[i] % 256)
        ui.SetString(menu, textPath, spellsInPage[i].GetName())
        ui.SetString(menu, valuePath, numText)
        i += 1
    endWhile
    while i < 10
        ui.SetInt(menu, indexPath, spellOidList[i] % 256)
        ui.SetString(menu, textPath, "")
        ui.SetString(menu, valuePath, "")
        i += 1
    endWhile
    SetSliderOptionValueST(1 + startIndex + currentSpellIndex, "{0}", false, "MoveToIndex")
endFunction

function MoveSpellItem(int activeIndex, int toIndex)
    Form activeSpell = spellsInPage[activeIndex]
    Form otherSpell = spellsInPage[toIndex]
    spellsInPage[activeIndex] = otherSpell
    spellsInPage[toIndex] = activeSpell

    spellListStates[SPELLS_PAGE_ITEMINDEX] = toIndex

    int pageIndex = spellListStates[SPELLS_CURRENT_PAGEINDEX]
    int startIndex = pageIndex * 10

    CustomUpdateTextOption(spellOidList[activeIndex], otherSpell.GetName(), 1 + startIndex + activeIndex, true)
    CustomUpdateTextOption(spellOidList[toIndex], activeSpell.GetName(), "[" + (1 + startIndex + toIndex) + "]", true)

    UpdateMoveSpellButtons(pageIndex, toIndex)

    SetSliderOptionValueST(1 + startIndex + toIndex, "{0}", false, "MoveToIndex")
    ;SelectSpellItemByIndex(toIndex)
endFunction

; === Selected Spell Commands
function UpdateListAfterSpellRemoved(int realIndex)
    int newCount = ControlScript.spell_fifo_get_count()
    spellListStates[SPELLS_COUNT] = newCount
    int pageCount = newCount / 10
    if (newCount % 10) != 0
        pageCount += 1
    endIf
    spellListStates[SPELLS_PAGECOUNT] = pageCount

    int newIndex = realIndex
    if newIndex >= newCount
        newIndex = newCount - 1
    endIf
    
    int toPageIndex = newIndex / 10
    int toItemIndex = newIndex % 10

    ; item is removed we should refresh page
    GotoSpellPage(toPageIndex, toItemIndex)
endFunction

function RemoveSelectedSpell()
    int realIndex = GetSelectedSpellRealIndex()
    if realIndex < 0
        return
    endIf
    ControlScript.spell_list_removeAt(realIndex)
    UpdateListAfterSpellRemoved(realIndex)
endFunction

function LearnSelectedSpell()
    int realIndex = GetSelectedSpellRealIndex()
    if realIndex < 0
        return
    endIf
    ControlScript.forceLearnSpellAt(realIndex, true)
    UpdateListAfterSpellRemoved(realIndex)
endFunction

int function GetSelectedSpellRealIndex()
    int itemIndex = spellListStates[SPELLS_PAGE_ITEMINDEX]
    if itemIndex < 0 
        return -1
    endIf
    int pageIndex = spellListStates[SPELLS_CURRENT_PAGEINDEX]
    return (pageIndex * 10 ) + itemIndex
endFunction

state CurrentPage
    event OnSliderOpenST()
        SetSliderDialogStartValue(spellListStates[SPELLS_CURRENT_PAGEINDEX] + 1)
        SetSliderDialogDefaultValue(1)
        SetSliderDialogRange(1, spellListStates[SPELLS_PAGECOUNT])
        SetSliderDialogInterval(1)
    endEvent

    event OnSliderAcceptST(float value)
        GotoSpellPage((value as Int) - 1)
    endEvent

    event OnDefaultST()
        GotoSpellPage(0)
    endEvent

    event OnHighlightST()
    endEvent
endState

state FirstPage
    event OnSelectST()
        GotoSpellPage(0)
    endEvent
endState

state PreviousPage
    event OnSelectST()
        GotoSpellPage(spellListStates[SPELLS_CURRENT_PAGEINDEX] - 1)
    endEvent
endState

state NextPage
    event OnSelectST()
        GotoSpellPage(spellListStates[SPELLS_CURRENT_PAGEINDEX] + 1)
    endEvent
endState

state LastPage
    event OnSelectST()
        GotoSpellPage(spellListStates[SPELLS_PAGECOUNT] - 1)
    endEvent
endState

state MoveFirst
    event OnSelectST()
        int itemIndex = spellListStates[SPELLS_PAGE_ITEMINDEX]
        if itemIndex < 0 
            return
        endIf

        int pageIndex = spellListStates[SPELLS_CURRENT_PAGEINDEX]
        
        if ControlScript.MoveSpellToTop((pageIndex * 10 ) + itemIndex)
            if pageIndex == 0 && itemIndex == 1
                MoveSpellItem(itemIndex, 0)
            else
                GotoSpellPage(0, 0)
            endif
        endif
    endEvent
	event OnHighlightST()
        setInfoText(__l("hint_moveto_top", "Moves the selected spell to the top of the list."))
	endEvent
endState

state MoveUp
    event OnSelectST()
        int itemIndex = spellListStates[SPELLS_PAGE_ITEMINDEX]
        if itemIndex < 0 
            return
        endIf
        int pageIndex = spellListStates[SPELLS_CURRENT_PAGEINDEX]
        if ControlScript.MoveSpellUp((pageIndex * 10) + itemIndex)
            if itemIndex == 0
                GotoSpellPage(pageIndex - 1, 9)
            else
                MoveSpellItem(itemIndex, itemIndex - 1)
            endIf
        endIf
    endEvent
	event OnHighlightST()
        setInfoText(__l("hint_move_up", "Moves up the selected spell."))
	endEvent
endState

state MoveDown
    event OnSelectST()
        int itemIndex = spellListStates[SPELLS_PAGE_ITEMINDEX]
        if itemIndex < 0 
            return
        endIf
        int pageIndex = spellListStates[SPELLS_CURRENT_PAGEINDEX]
        int pageItemCount = spellListStates[SPELLS_PAGE_ITEMCOUNT]
        if ControlScript.MoveSpellDown((pageIndex * 10) + itemIndex)
            if itemIndex == (pageItemCount - 1)
                GotoSpellPage(pageIndex + 1, 0)
            else
                MoveSpellItem(itemIndex, itemIndex + 1)
            endIf
        endIf
    endEvent
	event OnHighlightST()
        setInfoText(__l("hint_move_down", "Moves down the selected spell."))
	endEvent
endState

state MoveBottom
    event OnSelectST()
        int itemIndex = spellListStates[SPELLS_PAGE_ITEMINDEX]
        if itemIndex < 0 
            return
        endIf
        int pageIndex = spellListStates[SPELLS_CURRENT_PAGEINDEX]
        if ControlScript.MoveSpellToBottom((pageIndex * 10 ) + itemIndex)
            GotoSpellPage(spellListStates[SPELLS_PAGECOUNT] - 1, -1)
        endif
    endEvent
	event OnHighlightST()
        setInfoText(__l("hint_moveto_bottom", "Moves the selected spell to the bottom of the list."))
	endEvent
endState

state MoveToIndex
    event OnSliderOpenST()
        int realOrder = GetSelectedSpellRealIndex() + 1
        SetSliderDialogStartValue(realOrder)
        SetSliderDialogDefaultValue(realOrder)
        SetSliderDialogRange(1, spellListStates[SPELLS_COUNT])
        SetSliderDialogInterval(1)
    endEvent

	event OnSliderAcceptST(float value)
        int targetIndex = (value as int) - 1
        if targetIndex < 0
            return
        endIf
        if ControlScript.MoveSpellToIndex(GetSelectedSpellRealIndex(), targetIndex)
            int newPage = targetIndex / 10
            int newItemPageIndex = targetIndex % 10
            GotoSpellPage(newPage, newItemPageIndex)
        endIf
	endEvent

	event OnDefaultST()
        ;do nothing
	endEvent

	event OnHighlightST()
        setInfoText(__l("hint_moveto_index", "You can move the selected spell to any index that you choose."))
	endEvent
endState

state SpellCommand
	event OnMenuOpenST()
		SetMenuDialogOptions(spellCommandsMenu)
		SetMenuDialogStartIndex(0)
		SetMenuDialogDefaultIndex(0)
	endEvent

	event OnMenuAcceptST(int index)
        if index == SPELL_COMMAND_REMOVE
            RemoveSelectedSpell()
        elseIf index == SPELL_COMMAND_LEARN
            LearnSelectedSpell()
        endIf
	endEvent

	event OnDefaultST()
	endEvent

	event OnHighlightST()
        setInfoText(__l("hint_spell_commands", "Select a command from list to execute on selected spell. Please don't misclick. These commands are not reversible."))
	endEvent    
endState

; === Helper functions to clean up code for button presses
state ShowRemoveBookNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_REMOVE_BOOK))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_REMOVE_BOOK, false))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_remove_book", "Vanilla item removal notification when mod automatically removes spellbook. Defaults to off."))
	endEvent    
endState

state ShowAddSpellNoteNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_ADD_SPELL_NOTE))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_ADD_SPELL_NOTE, false))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_add_note", "Vanilla item add notification when adding notes to inventory. Disabled by default."))
	endEvent    
endState

state ShowAddSpellListNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_ADD_SPELL_LIST))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_ADD_SPELL_LIST, true))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_add_spell", "Notifications when a new spell is added to the list by deconstructing a tome. Includes information about note addition if vanilla notification is off. Defaults to on."))
	endEvent    
endState

state ShowFailAddSpellListNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_ADD_SPELL_LIST_FAIL))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_ADD_SPELL_LIST_FAIL, true))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_add_spell_fail", "Notifications when a spell cannot be added to the research list because you already know it or are already studying it. When enabled, includes information about note addition if the vanilla notification is off. Defaults to on."))
    endEvent    
endState

state ShowLearnSpellNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_LEARN_SPELL))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_LEARN_SPELL, true))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_learn", "Notifications when your character successfully learns a spell. Defaults to on."))
	endEvent    
endState

state ShowFailLearnSpellNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_LEARN_FAIL))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_LEARN_FAIL, true))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_learn_fail", "Notifications when your character fails at learning a spell. Defaults to on."))
	endEvent    
endState

state ShowDiscoverNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_DISCOVERY))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_DISCOVERY, true))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_discover", "Notifications when a new spell has been added to your list via the discovery system. Defaults to on."))
	endEvent    
endState

state ShowSkipNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_MOVING_ON))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_MOVING_ON, true))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_moving_on", "Notifications when your character skips a spell due to impossibility or reaching the maximum amount of failures. Defaults to on."))
	endEvent    
endState

state ShowTooSoonNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_TOO_SOON))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_TOO_SOON, true))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_too_soon", "Notifications when you performed an action (e.g. sleeping or studying) too soon and couldn't use it to learn or discover new spells. Defaults to on."))
	endEvent    
endState

state ShowDreamNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_DREAM))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_DREAM, true))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_dream", "Notifications if you have a dream when sleeping. Defaults to on. Turning off the notifications will not turn off the system."))
	endEvent    
endState

state ShowStudyNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_STUDY))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_STUDY, true))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_study", "Post-study notification. Note that this does not affect spell learning or discovery notifications. Defaults to on."))
	endEvent    
endState

state ShowDreadmilkNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_DREADMILK))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_DREADMILK, true))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_dreadmilk", "Notifications regarding Dreadmilk, Shadowmilk, addiction, your blood toxicity, or overdose. Defaults to on."))
	endEvent    
endState

state ShowTutorNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_SPIRIT_TUTOR))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_SPIRIT_TUTOR, true))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_tutor", "Notifications hinting at the effects of the Daedric Tutor spell. Defaults to on."))
	endEvent    
endState

state ShowErrorNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_ERROR))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_ERROR, true))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_error", "Error messages. You shouldn't ever see these unless mods are misbehaving or have been removed. Defaults to on."))
	endEvent    
endState

state ShowAddSpellNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_VANILLA_ADD_SPELL))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_VANILLA_ADD_SPELL, false))
	endEvent

    event OnHighlightST()
        SetInfoText(__l("hint_notification_vanilla_add_spell", "The game's default 'X added' notification when the character learns a new spell. Defaults to off."))
	endEvent    
endState

Bool Function toggleRemove()
    if (_LEARN_RemoveSpellBooks.GetValue())
        _LEARN_RemoveSpellBooks.SetValue(0)
        return false
    endif
    _LEARN_RemoveSpellBooks.SetValue(1)
    return True
EndFunction

Bool Function toggleCollect()
    if (_LEARN_CollectNotes.GetValue())
        _LEARN_CollectNotes.SetValue(0)
        return false
    endif
    _LEARN_CollectNotes.SetValue(1)
    return True
EndFunction

Bool Function toggleHarderParallel()
    if (_LEARN_HarderParallel.GetValue())
        _LEARN_HarderParallel.SetValue(0)
        return false
    endif
    _LEARN_HarderParallel.SetValue(1)
    return True
EndFunction

Bool Function toggleAutoSuccessBypassesLimit()
    if (_LEARN_AutoSuccessBypassesLimit.GetValue())
        _LEARN_AutoSuccessBypassesLimit.SetValue(0)
        return false
    endif
    _LEARN_AutoSuccessBypassesLimit.SetValue(1)
    return True
EndFunction

Bool Function toggleNoviceLearningEnabled()
    if (_LEARN_AutoNoviceLearningEnabled.GetValue())
        _LEARN_AutoNoviceLearningEnabled.SetValue(0)
        return false
    endif
    _LEARN_AutoNoviceLearningEnabled.SetValue(1)
    return True
EndFunction

bool function toggleTooDifficultEnabled()
    if (_LEARN_TooDifficultEnabled.GetValue())
        _LEARN_TooDifficultEnabled.SetValue(0)
        return false
    endif
    _LEARN_TooDifficultEnabled.SetValue(1)
    return True
EndFunction

bool function togglePotionBypass()
    if (_LEARN_PotionBypass.GetValue())
        _LEARN_PotionBypass.SetValue(0)
        return false
    endif
    _LEARN_PotionBypass.SetValue(1)
    return True
EndFunction

bool function toggleIntervalCDREnabled()
    if (_LEARN_IntervalCDREnabled.GetValue())
        _LEARN_IntervalCDREnabled.SetValue(0)
        return false
    endif
    _LEARN_IntervalCDREnabled.SetValue(1)
    return True
EndFunction

bool function toggleDynamicDifficulty()
    if (_LEARN_DynamicDifficulty.GetValue())
        _LEARN_DynamicDifficulty.SetValue(0)
        return false
    endif
    _LEARN_DynamicDifficulty.SetValue(1)
    return True
EndFunction

bool function toggleMaxFailsAutoSucceeds()
    if (_LEARN_MaxFailsAutoSucceeds.GetValue())
        _LEARN_MaxFailsAutoSucceeds.SetValue(0)
        return false
    endif
    _LEARN_MaxFailsAutoSucceeds.SetValue(1)
    return True
EndFunction

bool function toggleStudyIsRest()
    if (_LEARN_StudyIsRest.GetValue())
        _LEARN_StudyIsRest.SetValue(0)
        return false
    endif
    _LEARN_StudyIsRest.SetValue(1)
    return True
EndFunction

bool function toggleStudyRequiresNotes()
    if (_LEARN_StudyRequiresNotes.GetValue())
        _LEARN_StudyRequiresNotes.SetValue(0)
        return false
    endif
    _LEARN_StudyRequiresNotes.SetValue(1)
    return True
EndFunction

bool function toggleLearnOnStudy()
    if (_LEARN_LearnOnStudy.GetValue())
        _LEARN_LearnOnStudy.SetValue(0)
        return false
    endif
    _LEARN_LearnOnStudy.SetValue(1)
    return True
EndFunction

bool function toggleDiscoverOnStudy()
    if (_LEARN_DiscoverOnStudy.GetValue())
        _LEARN_DiscoverOnStudy.SetValue(0)
        return false
    endif
    _LEARN_DiscoverOnStudy.SetValue(1)
    return True
EndFunction

bool function toggleLearnOnSleep()
    if (_LEARN_LearnOnSleep.GetValue())
        _LEARN_LearnOnSleep.SetValue(0)
        return false
    endif
    _LEARN_LearnOnSleep.SetValue(1)
    return True
EndFunction

bool function toggleDiscoverOnSleep()
    if (_LEARN_DiscoverOnSleep.GetValue())
        _LEARN_DiscoverOnSleep.SetValue(0)
        return false
    endif
    _LEARN_DiscoverOnSleep.SetValue(1)
    return True
EndFunction

bool function toggleAddToList()
    if (_LEARN_ResearchSpells.GetValue())
        _LEARN_ResearchSpells.SetValue(0)
        return false
    endif
    _LEARN_ResearchSpells.SetValue(1)
    return True
EndFunction

bool function toggleReturnTomes()
    if (_LEARN_ReturnTomes.GetValue())
        _LEARN_ReturnTomes.SetValue(0)
        return false
    endif
    _LEARN_ReturnTomes.SetValue(1)
    return True
EndFunction

bool function toggleRemoveUnknownOnly()
    if (_LEARN_RemoveUnknownOnly.GetValue())
        _LEARN_RemoveUnknownOnly.SetValue(0)
        return false
    endif
    _LEARN_RemoveUnknownOnly.SetValue(1)
    return True
EndFunction

; === Helper functions for other scripts
bool function modIsEnabled()
	return isEnabled
endFunction
