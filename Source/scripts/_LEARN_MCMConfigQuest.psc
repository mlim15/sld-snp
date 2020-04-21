scriptname _LEARN_MCMConfigQuest extends SKI_ConfigBase

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
GlobalVariable property _LEARN_SpawnItems auto
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
MagicEffect Property _LEARN_PracticeEffect auto
Spell property _LEARN_DiseaseDreadmilk auto
Spell property _LEARN_PracticeAbility auto
Spell property _LEARN_StudyPower auto
Spell property _LEARN_SummonSpiritTutor auto
Spell property _LEARN_SetHomeSp auto

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
int shutUpOID ; unused
int spawnItemsOID ; unused
int enthirSellsOID ; unused

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
    if (!Pages || Pages.Length < 4)
        Pages = new string[4]
    endIf
    _useLocalizationLib = ControlScript.CanUseLocalizationLib
    Pages[0] = __l("mcm_tab_status", "Current Status")
    Pages[1] = __l("mcm_tab_learning","Learning and Discovery")
	Pages[2] = __l("mcm_tab_spell_list", "Manage Spell List")
	Pages[3] = __l("mcm_tab_items_and_notifications", "Items and Notifications")
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
		; Then stop the quest. This should automatically remove items from enthir (?)
		; as well as stop the script from running on sleep.
		_LEARN_SpellControlQuest.Stop()
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
    if (page == "")
        _useLocalizationLib = ControlScript.CanUseLocalizationLib
        ;StartObjectProfiling()
    endIf
    if(page == "" || page == Pages[0])
        SetCursorFillMode(TOP_TO_BOTTOM) ;starts are 0
        AddHeaderOption(__l("mcm_header_general_settings", "General Settings"), 0)
        isEnabledOption = AddToggleOption(__l("mcm_mod_enabled", "Mod is Enabled: "), IsEnabled, 0)
		AddEmptyOption()
        if(isEnabled)   
            bonusScaleOID = AddSliderOption(__l("mcm_option_roleplaying_bonus", "Roleplaying Bonus Modifier"), _LEARN_BonusScale.GetValue(), "{1}", OPTION_FLAG_NONE)
			effortScalingOID = AddMenuOption(__l("mcm_option_scaling", "Bonus Scaling Type"), ControlScript.getEffortLabels()[_LEARN_effortScaling.GetValueInt()], OPTION_FLAG_NONE)
            string n = __l("mcm_current_location_none", "Undefined"); string none causes unexpected behaviors. avoid it
            if ControlScript.customLocation
                n = ControlScript.customLocation.GetName()
            endif
            CustomLocationOID = AddTextOption(__l("mcm_option_set_home", "Set Custom Study Location"), n, OPTION_FLAG_NONE)
			AddEmptyOption()
			AddHeaderOption(__l("mcm_header_current_learning", "Miscellaneous Status Effects"), 0)
			nootropicStatusOID = AddTextOption(__l("mcm_current_blood_toxicity", "Current Bloodstream Toxicity: "), __f1("{0}%", _LEARN_Strings.SubStringSafe(((_LEARN_ConsecutiveDreadmilk.GetValue() * 10) as String),0,5)), OPTION_FLAG_NONE)
			if (_LEARN_AlreadyUsedTutor.GetValue() == 1)
				tutorStatusOID = AddTextOption(__l("mcm_current_tutor_used", "Already Used Tutor: "), __l("mcm_true", "True"), OPTION_FLAG_NONE)
			else
				tutorStatusOID = AddTextOption(__l("mcm_current_tutor_used", "Already Used Tutor: "), __l("mcm_false", "False"), OPTION_FLAG_NONE)
			endIf
			if ((GameDaysPassed.GetValue() - _LEARN_LastSetHome.GetValue()) >= 7)
				attunementStatusOID = AddTextOption(__l("mcm_current_days_left_attunement_now", "Can Change Attunement: "), __f1(__l("mcm_now", "Now"), "0"), OPTION_FLAG_NONE)
			elseIf ((GameDaysPassed.GetValue() - _LEARN_LastSetHome.GetValue()) == 6)
				attunementStatusOID = AddTextOption(__l("mcm_current_days_left_attunement", "Can Change Attunement in: "), __f1(__l("mcm_x_day", "{0} Day"), "1"), OPTION_FLAG_NONE)
			else
				attunementStatusOID = AddTextOption(__l("mcm_current_days_left_attunement", "Can Change Attunement in: "), __f1(__l("mcm_x_days", "{0} Days"), (((GameDaysPassed.GetValue() - _LEARN_LastSetHome.GetValue()) as int) as String)), OPTION_FLAG_NONE)
			endIf
		endif
        SetCursorPosition(1) ; Move cursor to top right position
		if(isEnabled)
			AddHeaderOption(__l("mcm_header_current_learning", "Current Spell Learning Status"), 0)
			infoStudyOID = AddTextOption(__l("mcm_current_learning_chance", "Chance to Successfully Learn: "), __f1("{0}%", _LEARN_Strings.SubStringSafe(((ControlScript.baseChanceToStudy() * 100) as String),0,5)), OPTION_FLAG_NONE)
			int t = (controlscript.hours_before_next_ok_to_learn() as int)
			if t == 0
				AddTextOption(__l("mcm_current_sleep_now", "You can sleep now to try learning!"), "", OPTION_FLAG_NONE)
			elseIf t == 1
				AddTextOption(__f1(__l("mcm_current_sleep_1h", "You can sleep in 1h to try learning."), t), "", OPTION_FLAG_NONE)
			else
				AddTextOption(__f1(__l("mcm_current_sleep_Xh", "You can sleep in {0}h to try learning."), t), "", OPTION_FLAG_NONE)
			endIf
		endIf
		AddEmptyOption()
        If(isEnabled)   
		    AddHeaderOption(__l("mcm_header_sleep_current_discovery", "Current Spell Discovery Status"), 0)
            infoDiscoverOID = AddTextOption(__l("mcm_current_discovery_chance", "Chance for Discovery: "), __f1("{0}%", _LEARN_Strings.SubStringSafe(((ControlScript.baseChanceToDiscover() * 100) as String),0,5)), OPTION_FLAG_NONE)
            infoSchoolOID = AddTextOption(__l("mcm_current_school", "Current School of Interest: "), ControlScript.topSchoolToday(), OPTION_FLAG_NONE) 
			AddEmptyOption()
			AddHeaderOption(__l("mcm_header_backup_restore", "Backup/Restore Spell List"), 0)
			fissExportOID = AddTextOption(__l("mcm_option_export", "Export to FISS"), __l("mcm_export_fiss", "Click"), OPTION_FLAG_NONE)
			fissImportOID = AddTextOption(__l("mcm_option_import", "Import from FISS"), __l("mcm_import_fiss", "Click"), OPTION_FLAG_NONE)
        endIf
    elseIf (page == Pages[1])
        SetCursorFillMode(TOP_TO_BOTTOM) ;starts are 0
        AddHeaderOption(__l("mcm_header_spell_learning_options", "Spell Learning Options"), 0)
		if (isEnabled)
			minChanceStudyOID = AddSliderOption(__l("mcm_option_min_learn_chance", "Min Learn Chance"), _LEARN_MinChanceStudy.GetValue(), "{0}%", OPTION_FLAG_NONE)
            maxChanceStudyOID = AddSliderOption(__l("mcm_option_max_learn_chance", "Max Learn Chance"), _LEARN_MaxChanceStudy.GetValue(), "{0}%", OPTION_FLAG_NONE)
			dynamicDiffOID = AddToggleOption(__l("mcm_option_chance_scales_with_spell_level", "Chance Depends on Spell Level"), _LEARN_DynamicDifficulty.GetValue(), OPTION_FLAG_NONE)
			StudyIntervalOID = AddSliderOption(__l("mcm_option_sleep_interval", "Time Between Learnings"), _LEARN_StudyInterval.GetValue(), __l("mcm_x_day(s)", "{2} Day(s)"), OPTION_FLAG_NONE)
			intervalCDRenabledOID = AddToggleOption(__l("mcm_option_practice_gives_cdr", "Practice Reduces Time"), _LEARN_IntervalCDREnabled.GetValue(), OPTION_FLAG_NONE)
			if (_LEARN_IntervalCDREnabled.GetValue() == 1)
				intervalCdrOID = AddSliderOption(__l("mcm_option_max_cdr", "Maximum Reduction"), _LEARN_IntervalCDR.GetValue(), "{0}%", OPTION_FLAG_NONE)
			else
				AddEmptyOption()
			endIf
		else
			AddTextOption(__l("mcm_current_disabled", "Mod is disabled."), "", OPTION_FLAG_NONE)
		endIf
		if (isEnabled)
			AddHeaderOption(__l("mcm_header_spell_discovery_options", "Spell Discovery Options"), 0)
			minChanceDiscoverOID = AddSliderOption(__l("mcm_option_min_discovery_chance", "Min Discovery Chance"), _LEARN_MinChanceDiscover.GetValue(), "{0}%", OPTION_FLAG_NONE)
            maxChanceDiscoverOID = AddSliderOption(__l("mcm_option_max_discovery_chance", "Max Discovery Chance"), _LEARN_MaxChanceDiscover.GetValue(), "{0}%", OPTION_FLAG_NONE)
            forceSchoolOID = AddMenuOption(__l("mcm_option_spell_school", "Spell School"), ControlScript.getSchools()[_LEARN_ForceDiscoverSchool.GetValueInt()], OPTION_FLAG_NONE)
		endIf		
		SetCursorPosition(1) ; Move cursor to top right position
        if (isEnabled)
			AddHeaderOption(__l("mcm_header_study_options", "Study Power Options"), 0)
			studyIsRestOID = AddToggleOption(__l("mcm_option_study_rest", "Power Acts as Resting"), _LEARN_StudyIsRest.GetValue(), OPTION_FLAG_NONE)
			studyRequiresNotesOID = AddToggleOption(__l("mcm_option_study_notes", "Power Requires Notes"), _LEARN_StudyRequiresNotes.GetValue(), OPTION_FLAG_NONE)
			AddHeaderOption(__l("mcm_header_adv_spell_options", "Advanced Spell Learning Options"), 0)
			parallelLearningOID = AddSliderOption(__l("mcm_option_number_spells", "Daily Learning Limit"), _LEARN_ParallelLearning.GetValue(), __l("mcm_x_spell(s)", "{0} Spell(s)"), OPTION_FLAG_NONE)
			if (_LEARN_ParallelLearning.GetValue() > 1)
				harderParallelOID = AddToggleOption(__l("mcm_option_harder_multiple", "Learning Multiple Spells is Harder"), _LEARN_HarderParallel.GetValue(), OPTION_FLAG_NONE)
			else
				AddEmptyOption()
			endIf
			tooDifficultEnabledOID = AddToggleOption(__l("mcm_option_auto_failure", "Skill-based Automatic Failure"), _LEARN_TooDifficultEnabled.GetValue(), OPTION_FLAG_NONE)
			if (_LEARN_TooDifficultEnabled.GetValue() == 1)
				tooDifficultDeltaOID = AddSliderOption(__l("mcm_option_auto_failure_diff", "Max Skill Difference before Auto Fail"), _LEARN_TooDifficultDelta.GetValue(), "{0}", OPTION_FLAG_NONE)
				potionBypassOID = AddToggleOption(__l("mcm_option_potion_bypass_auto_fail", "Potions Bypass Auto Fail"), _LEARN_PotionBypass.GetValue(), OPTION_FLAG_NONE)
			else
				AddEmptyOption()
				AddEmptyOption()
			endIf
			; We're running out of space to avoid scroll bars, so no spacer :(
			; AddEmptyOption()
			noviceLearningEnabledOID = AddToggleOption(__l("mcm_option_auto_success", "Skill-based Automatic Success"), _LEARN_AutoNoviceLearningEnabled.GetValue(), OPTION_FLAG_NONE)
			if (_LEARN_AutoNoviceLearningEnabled.GetValue() == 1)
				autoNoviceLearningOID = AddSliderOption(__l("mcm_option_auto_success_diff", "Req. Skill Difference for Auto Success"), _LEARN_AutoNoviceLearning.GetValue(), "{0}", OPTION_FLAG_NONE)
				autoSuccessBypassesLimitOID = AddToggleOption(__l("mcm_option_auto_success_bypass", "Auto Success Bypasses Daily Limit"), _LEARN_AutoSuccessBypassesLimit.GetValue(), OPTION_FLAG_NONE)
			else
				AddEmptyOption()
				AddEmptyOption()
			endIf

        endIf		
    elseIf (page == Pages[2])
        CreatePageSpellList()
	elseIf(page == Pages[3])
		SetCursorFillMode(TOP_TO_BOTTOM) ;starts are 0
		if (isEnabled)
			AddHeaderOption(__l("mcm_header_drug_options", "Nootropic Alchemy Options"), 0)
			dreadstareLethalityOID = AddSliderOption(__l("mcm_option_potion_toxicity", "Potion Toxicity"), _LEARN_DreadstareLethality.GetValue(), "{0}%", OPTION_FLAG_NONE)
			AddEmptyOption()
			AddHeaderOption(__l("mcm_header_spell_book_options", "Spell Book Options"), 0)
			removeOID = AddToggleOption(__l("mcm_option_remove_books", "Auto-Remove Spell Books"), _LEARN_RemoveSpellBooks.GetValue(), OPTION_FLAG_NONE)
            collectOID = AddToggleOption(__l("mcm_option_collect_notes", "Create Study Notes from Books"), _LEARN_CollectNotes.GetValue(), OPTION_FLAG_NONE)
			;AddEmptyOption()
			;AddHeaderOption(__l("mcm_header_spell_book_options", "Item Spawning Options"), 0)
			;enthirSellsOID = AddToggleOption(__l("mcm_option_potion_bypass_auto_fail", "Enthir Sells Mod Items"), _LEARN_EnthirSells.GetValue(), OPTION_FLAG_NONE)
			;spawnItemsOID = AddToggleOption(__l("mcm_option_spawn_items_in_world", "Spawn Items Automatically"), _LEARN_SpawnItems.GetValue(), OPTION_FLAG_NONE)
		else
			AddTextOption(__l("mcm_current_disabled", "Mod is disabled."), "", OPTION_FLAG_NONE)
		endIf
		SetCursorPosition(1) ; Move cursor to top right position
		if (isEnabled)
			; These options seem to be broken so we'll leave them for now.
			; Can investigate when putting together quiet mode.
			;AddHeaderOption(__l("mcm_header_notifications", "Notifications"))
			;AddToggleOptionST("ShowRemoveBookNotification", __l("mcm_notification_remove_book", "When Consuming Spell Books"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_REMOVE_BOOK])
			;AddToggleOptionST("ShowAddSpellNoteNotification", __l("mcm_notification_add_spell_note", "When Adding Spell Notes"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_ADD_SPELL_NOTE])
			;AddToggleOptionST("QuietMode", __l("mcm_shut_up_notifications", "Quiet Mode"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATIONS_ALL])
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
	PlayerRef.AddSpell(_LEARN_SummonSpiritTutor, true)
	PlayerRef.AddSpell(_LEARN_SetHomeSp, true)
	; above only for debug purposes
	PlayerRef.AddSpell(_LEARN_PracticeAbility, true)
	PlayerRef.AddSpell(_LEARN_StudyPower, true)
endFunction

function disableModEffects()
	if (PlayerRef.HasSpell(_LEARN_DiseaseDreadmilk))
		PlayerRef.RemoveSpell(_LEARN_DiseaseDreadmilk)
	endIf
	if (PlayerRef.HasSpell(_LEARN_PracticeAbility))
		PlayerRef.RemoveSpell(_LEARN_PracticeAbility)
	endIf
	if (PlayerRef.HasSpell(_LEARN_StudyPower))
		PlayerRef.RemoveSpell(_LEARN_StudyPower)
	endIf
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
        SetSliderDialogDefaultValue(3)
        SetSliderDialogRange(0, 10)
        SetSliderDialogInterval(1)
        return
    EndIf
	
    If (a_option == autoNoviceLearningOID)
        SetSliderDialogStartValue(_LEARN_AutoNoviceLearning.GetValue())
        SetSliderDialogDefaultValue(50)
        SetSliderDialogRange(0, 100)
        SetSliderDialogInterval(25)
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
        SetSliderDialogRange(0, 4)
        SetSliderDialogInterval(0.01)
        return
    EndIf
	
	If (a_option == tooDifficultDeltaOID)
        SetSliderDialogStartValue(_LEARN_TooDifficultDelta.GetValue())
        SetSliderDialogDefaultValue(75)
        SetSliderDialogRange(25, 100)
        SetSliderDialogInterval(25)
        return
    EndIf
	
	If (a_option == intervalCdrOID)
        SetSliderDialogStartValue(_LEARN_IntervalCDR.GetValue())
        SetSliderDialogDefaultValue(25)
        SetSliderDialogRange(1, 100)
        SetSliderDialogInterval(1)
        return
    EndIf

EndEvent

Event OnOptionSliderAccept(Int a_option, Float a_value)

    If (a_option == maxConsecutiveFailuresOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        _LEARN_MaxFailsBeforeCycle.SetValue(a_value)
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
        SetSliderOptionValue(a_option, a_value, "{2}", false)
        _LEARN_TooDifficultDelta.SetValue(a_value)
        return
    EndIf
	
	If (a_option == intervalCdrOID)
        SetSliderOptionValue(a_option, a_value, "{2}", false)
        _LEARN_IntervalCDR.SetValue(a_value)
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
    ElseIf (Option == collectOID)
        SetToggleOptionValue(option, toggleCollect(), False)
	ElseIf (Option == harderParallelOID)
		SetToggleOptionValue(option, toggleHarderParallel(), False)
	ElseIf (Option == autoSuccessBypassesLimitOID)
		SetToggleOptionValue(option, toggleAutoSuccessBypassesLimit(), False)	
	ElseIf (Option == noviceLearningEnabledOID)
		SetToggleOptionValue(option, toggleNoviceLearningEnabled(), False)	
		forcepagereset()
	ElseIf (Option == spawnItemsOID) ; not implemented.
		SetToggleOptionValue(option, toggleSpawnItems(), False)
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
	ElseIf (Option == studyRequiresNotesOID)
		SetToggleOptionValue(option, toggleStudyRequiresNotes(), False)
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
            ControlScript.SpawnItemsInWorld()
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
        SetInfoText(__l("hint_maxConsecutiveFailures", "Maximum consecutive failures before automatically succeeding. Set to 0 for unlimited failures. Not recommended for use with option to learn multiple spells at once - script counts only total failures, not per-spell. Defaults to 3."))
    ElseIf (Option == autoNoviceLearningOID)
        SetInfoText(__l("hint_autoNoviceLearning", "Required skill difference to always succeed when learning spells. At 0, no difference is required - e.g. Apprentice Destruction means you'll never fail at learning Apprentice and Novice spells. At 25, an Apprentice of Destruction will only never fail at learning Novice spells. Defaults to 50."))
	ElseIf (Option == noviceLearningEnabledOID)
		SetInfoText(__l("hint_noviceLearningEnabled", "When enabled, the difference between your skill in a school and the level of the spell you're trying to learn can result in an automatic success. The required difference to ensure this success is configurable below. Defaults to on."))
	ElseIf (Option == autoSuccessBypassesLimitOID)
		SetInfoText(__l("hint_autoSuccessBypassesLimit", "Spells learned via the above option do not count towards the daily limit. Default off. This can result in learning many spells per sleep."))
	ElseIf (Option == dreadstareLethalityOID)
        SetInfoText(__l("hint_dreadstareLethality", "Base chance to overdose when consuming Dreadmilk. Defaults to 10%. Increased by your bloodstream toxicity."))
	ElseIf (Option == parallelLearningOID)
        SetInfoText(__l("hint_parallelLearning", "Choose how many spells from the top of your list you will attempt to learn on each sleep. Keep in mind that when combined with drugs and a high max learning chance, learning multiple per sleep is overpowered. 1 is default."))
	ElseIf (Option == harderParallelOID)
        SetInfoText(__l("hint_harderParallel", "When learning multiple spells at once, divide the chance to learn by the amount of spells being learned to help preserve a similar speed. Recommended, defaults to on."))
    ElseIf (Option == bonusScaleOID)
        SetInfoText(__l("hint_bonusScale", "Multiplier applied to the roleplaying bonus to chance of learning/discovering. This means casting spells relevant to your study, hoarding relevant spell notes, sleeping at the College and temples, consuming shadowmilk, etc. Default is 1.0. Raising this can make it unreasonably easy to learn spells."))
    ElseIf (Option == infoStudyOID)
        SetInfoText(__l("hint_infoStudy", "Current chance to learn the next spell on your list on an eligible rest. Cast spells of the same school, use potions, or collect more notes to improve. If your study list is empty, this will show 0%."))
    ElseIf (Option == infoDiscoverOID)
        SetInfoText(__l("hint_infoDiscover", "Current chance to discover a new spell and add it to the study list on an eligible rest. Cast spells of your current school of interest, use potions, or collect more notes to improve."))
    ElseIf (Option == infoSchoolOID)
        SetInfoText(__l("hint_infoSchool", "Current magical school of interest."))
    ElseIf (Option == collectOID)
        SetInfoText(__l("hint_collectNotes", "Whether or not to deconstruct removed books into scraps. Keeping a large collection of spell notes improves the roleplaying bonus for spell learning chance. Scraps are equal in value to the book. Default is enabled."))
    ElseIf (Option == removeOID)
        SetInfoText(__l("hint_removeBooks", "Whether or not to remove spell books from inventory when added, to prevent vanilla 'insta-learn'. Default is enabled. Disabling this may cause errors if the mod tries to teach you a spell you learn with the vanilla functionality.")) 
    ElseIf (Option == forceSchoolOID)
        SetInfoText(__l("hint_preferedSchool", "Set this to the school of magic you want to discover spells from. Default is Automatic, which uses your most cast school from that day."))
    ElseIf (Option == effortScalingOID)
        SetInfoText(__l("hint_effortScaling", "The way effort scales when rolling for successful learning. Default is Tough Start, which is harsher to those with poorer magical skills and less roleplaying bonus."))
	ElseIf (Option == fissExportOID)
        SetInfoText(__l("hint_export", "Export/backup spell study list to FISS XML."))
    ElseIf (Option == fissImportOID)
        SetInfoText(__l("hint_import", "Import/restore spell study list from FISS XML."))
    ElseIf (Option == CustomLocationOID)
        setInfoText(__l("hint_customLocation", "Click to mark the current location as your personal study. It will provide a learning bonus similar to temples, but not as much as the College. Click again to unset. This can also be set with the Attunement spell."))
    ElseIf (Option == studyIntervalOID)
        setInfoText(__l("hint_studyInterval", "How many days must pass between learning attempts on sleep. Default is 0.65."))
	ElseIf (Option == enthirSellsOID) ; unused
        setInfoText(__l("hint_enthir", "Whether or not Enthir will keep a stock of items related to this mod. Default is yes."))
	ElseIf (Option == spawnItemsOID) ; unused
        setInfoText(__l("hint_studyInterval", "Whether or not items are added to loot lists, causing them to spawn in random merchants and as loot. Defaults to no."))
	ElseIf (Option == tooDifficultDeltaOID)
        setInfoText(__l("hint_tooDifficultDiff", "The difference in skill required to automatically fail learning. Default is 75 - a novice will automatically fail to learn expert+ level spells."))
	ElseIf (Option == tooDifficultEnabledOID)
        setInfoText(__l("hint_tooDiffEnabled", "When enabled, you can automatically fail to learn a spell if it's significantly above your current skill level. In this case you will automatically move to the next possible spell without penalty."))
    ElseIf (Option == isEnabledOption)
		setInfoText(__l("hint_deletionWarning", "WARNING: Disabling mod will clear your spell list! Use backups!"))
	ElseIf (Option == potionBypassOID)
		setInfoText(__l("hint_potionBypass", "When enabled, Dreadmilk will bypass enabled skill requirements. For example, with Dreadmilk a novice can attempt to learn a master spell even when they would otherwise be prevented from doing so. Defaults to on."))
	ElseIf (Option == intervalCDRenabledOID)
		setInfoText(__l("hint_cdrEnabled", "When enabled, casting up to 100 spells will not only increase your chance to learn spells, but will also reduce the cooldown between learnings. Defaults to on."))
	ElseIf (Option == intervalCdrOID)
		setInfoText(__l("hint_cdr", "The maximum percentage by which the cooldown can be reduced through practice. Defaults to 25%."))
	ElseIf (Option == maxFailsAutoSucceedsOID)
		setInfoText(__l("hint_maxFailsSucceeds", "When enabled, reaching the maximum failure limit will cause you to succeed as long as it isn't prevented by something like the skill difference option. When off, the spell will be moved to the bottom of your list instead. Defaults to on."))
	ElseIf (Option == dynamicDiffOID)
		setInfoText(__l("hint_dynamicDiff", "When enabled, the chance to learn a spell also depends on its own difficulty relative to your skill. Defaults to on."))
	ElseIf (Option == nootropicStatusOID)
		setInfoText(__l("hint_drug_status", "Your current level of toxicity from consuming Dreadmilk and Shadowmilk. As it increases, so does the chance of overdose on consumption. Decreases over time with rest."))
	ElseIf (Option == tutorStatusOID)
		setInfoText(__l("hint_tutor_status", "Whether or not you have successfully recieved the bonus from the Summon Daedric Tutor spell for this learning period."))
	ElseIf (Option == attunementStatusOID)
		setInfoText(__l("hint_attunement_status", "Amount of spell learning attempts left before you can change your custom study location with the Attunement spell."))
	ElseIf (Option == studyIsRestOID)
		setInfoText(__l("hint_study_is_rest", "Amount of spell learning attempts left before you can change your custom study location with the Attunement spell."))
	ElseIf (Option == studyRequiresNotesOID)
		setInfoText(__l("hint_study_requires_notes", "Amount of spell learning attempts left before you can change your custom study location with the Attunement spell."))
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
    ControlScript.forceLearnSpellAt(realIndex)
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

;/ ; we don't have enough space to put it as button. replaced by CurrentPage
state GotoPage
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
/;

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
	endEvent    
endState

state ShowAddSpellNoteNotification
	event OnSelectST()
		SetToggleOptionValueST(ControlScript.ToggleNotification(ControlScript.NOTIFICATION_ADD_SPELL_NOTE))
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(ControlScript.EnableNotification(ControlScript.NOTIFICATION_ADD_SPELL_NOTE, true))
	endEvent

	event OnHighlightST()
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

bool function toggleSpawnItems()
    if (_LEARN_SpawnItems.GetValue())
        _LEARN_SpawnItems.SetValue(0)
        return false
    endif
    _LEARN_SpawnItems.SetValue(1)
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
    _LEARN_MaxFailsAutoSucceeds.SetValue(1)
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