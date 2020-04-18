scriptname _LEARN_MCMConfigQuest extends SKI_ConfigBase

import FISSFactory
FISSInterface fiss

;Access the main script to update the variables directly upon update
_LEARN_ControlScript property ControlScript auto

String ModName = "Spell Learning"


Bool isEnabled
Bool wasDisabled = False
Int isEnabledOption
Int showDebugOutputOption ;Toggle for showing debug output messages

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
int fissExportOID
int fissImportOID
int restartModOID
int RotateSpellOID
int AbandonSpellOID
int SwapSpellOID
int PushBackSpellOID
int BringSpellOID
int CustomLocationOID
int StudyIntervalOID

int[] spellListStates; 0=count,1=pageCount;2=currentPageIndex,3=pageItemIndex
int[] spellOidList
Form[] spellsInPage
String[] spellCommandsMenu
int Property SPELLS_COUNT = 0 autoReadOnly
int Property SPELLS_PAGECOUNT = 1 autoReadOnly
int Property SPELLS_CURRENT_PAGEINDEX = 2 autoReadOnly
int Property SPELLS_PAGE_ITEMINDEX = 3 autoReadOnly
int Property SPELLS_CURRENTPAGE_OID = 4 autoReadOnly
int Property SPELLS_PAGE_ITEMCOUNT = 5 autoReadOnly
bool isSpellListInitialized

int Property SPELL_COMMAND_NONE = 0 autoReadOnly
int Property SPELL_COMMAND_REMOVE = 1 autoReadOnly
int Property SPELL_COMMAND_LEARN = 2 autoReadOnly
bool _useLocalizationLib

;Called when the menu is first registered, grab the values as the first-run data
Event OnConfigInit()
    Debug.Trace(_LEARN_Strings.formatString2("[Spell Learning] MCM Configuring... Menu version is {0}.{1} ...", 10, ControlScript.GetMenuLangId()))
    InternalPrepare()

    if (!ControlScript.isRunning())
        ControlScript.Start()
    endif
    
    IsEnabled = True
EndEvent

function InternalPrepare()
    if (!Pages || Pages.Length < 3)
        Pages = new string[3]
    endIf
    _useLocalizationLib = ControlScript.CanUseLocalizationLib
    Pages[0] = __l("Status")
    Pages[1] = __l("Config")
    Pages[2] = __l("page_spells", "Spells")
endFunction

event OnGameReload()
	parent.OnGameReload() 
	
	InternalPrepare()
endEvent

string function __l(string keyName, string defaultValue = "")
; since menu uses this function alot while resetting page I inlined it here for better performance
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

int function GetVersion()
    ; menu version will be multiplies of 10 for allowing user to change language 9 more times
    return 20 + ControlScript.GetMenuLangId();
endFunction

event OnVersionUpdate(int a_version)
    if (a_version > 1)
        InternalPrepare()
    endIf
endEvent

;Called every time the menu is closed (actually saves the data)
Event OnConfigClose()
    ;This is where I would call the disable mod function from inside the quest to remove the Spell

    If(!isEnabled && !wasDisabled)
        ;Debug.Notification("This is where we would remove the spell etc.")
        wasDisabled = True
        
        ;e_dynamicStealthQuest.DisableMod()
        
    EndIf
    
    ;======== RESET ========
    ;Basically reset; If they disable, close the menu, open, enable, close again, this will turn it back on
    If(isEnabled && wasDisabled)
        ;Debug.Notification("Re-activating Dynamic Stealth")
        ;e_dynamicStealthQuest.EnableMod()
        wasDisabled = False
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
    spellCommandsMenu[SPELL_COMMAND_NONE] = __l("spell_command_none", "No Operation")
    spellCommandsMenu[SPELL_COMMAND_REMOVE] = __l("spell_command_remove", "Remove")
    spellCommandsMenu[SPELL_COMMAND_LEARN] = __l("spell_command_learn", "Learn (Instantly)")

    isSpellListInitialized = true
endFunction

event OnPageReset(string page)
{Called when a new page is selected, including the initial empty page}
    if (page == "")
        _useLocalizationLib = ControlScript.CanUseLocalizationLib
        ;StartObjectProfiling()
    endIf
    If(page == "" || page == Pages[0])
        SetCursorFillMode(TOP_TO_BOTTOM) ;starts are 0
               
        AddHeaderOption(__l("Spell Study"), 0)
        
        
        If(isEnabled)   
            
            ; current chance to study
            infoStudyOID = AddSliderOption(__l("Chance to study"), 100 * ControlScript.baseChanceToStudy(), "{2}", OPTION_FLAG_NONE)

            int t = (controlscript.hours_before_next_ok_to_learn() as int)
            if t == 0
                AddTextOption(__l("You can sleep now to try learning"), "", OPTION_FLAG_NONE)
            ElseIf t == 1
                AddTextOption(__f1(__l("You can sleep in 1h to try learning"), t), "", OPTION_FLAG_NONE)
            Else
                AddTextOption(__f1(__l("You can sleep in ?h to try learning", "You can sleep in {0}h to try learning"), t), "", OPTION_FLAG_NONE)
            endif
            
        endif

        AddEmptyOption()
        AddHeaderOption(__l("Notifications"))
        AddToggleOptionST("ShowRemoveBookNotification", __l("notification_remove_book", "Remove spell books"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_REMOVE_BOOK])
        AddToggleOptionST("ShowAddSpellNoteNotification", __l("notification_add_spell_note", "Add spell notes"), ControlScript.VisibleNotifications[ControlScript.NOTIFICATION_ADD_SPELL_NOTE])
        SetCursorPosition(1) ; Move cursor to top right position

        AddHeaderOption(__l("Spell Discovery"), 0)

        If(isEnabled)   
            ; current chance to discover
            infoDiscoverOID = AddSliderOption(__l("Chance to discover"), 100 * ControlScript.baseChanceToDiscover(), "{2}", OPTION_FLAG_NONE)

            ; school of magic
            infoSchoolOID = AddTextOption(__l("Interest"), ControlScript.topSchoolToday(), OPTION_FLAG_NONE) 
                        
        EndIf

    ElseIf(page == Pages[1])
    
        
        SetCursorFillMode(TOP_TO_BOTTOM) ;starts are 0
        
        AddHeaderOption(__l("General"), 0)

        isEnabledOption = AddToggleOption(__l("Mod is enabled"), IsEnabled, 0)
        
        if (isEnabled)
            
            AddEmptyOption()
                
            bonusScaleOID = AddSliderOption(__l("Bonus scale"), ControlScript._LEARN_BonusScale.GetValue(), "{1}", OPTION_FLAG_NONE)
            string n = __l("location_none", "Undefined"); string none causes unexpected behaviors. avoid it
            if ControlScript.customLocation
                n = ControlScript.customLocation.GetName()
            endif
            CustomLocationOID = AddTextOption(__l("Custom study location"), n, OPTION_FLAG_NONE)
            
            AddEmptyOption()
            AddHeaderOption(__l("Maintenance"), 0)
            fissExportOID = AddTextOption(__l("Export to FISS"), __l("Click"), OPTION_FLAG_NONE)
            fissImportOID = AddTextOption(__l("Import from FISS"), __l("Click"), OPTION_FLAG_NONE)

            SetCursorPosition(1) ; Move cursor to top right position

            AddHeaderOption(__l("Spell Study"), 0)

            minChanceStudyOID = AddSliderOption(__l("Min study chance"), ControlScript._LEARN_MinChanceStudy.GetValue(), "{0}", OPTION_FLAG_NONE)
            maxChanceStudyOID = AddSliderOption(__l("Max study chance"), ControlScript._LEARN_MaxChanceStudy.GetValue(), "{0}", OPTION_FLAG_NONE)
            StudyIntervalOID = AddSliderOption(__l("Study interval"), ControlScript._LEARN_StudyInterval.GetValue(), "{2}", OPTION_FLAG_NONE)
            removeOID = AddToggleOption(__l("Remove spell books"), ControlScript._LEARN_RemoveSpellBooks.GetValue(), OPTION_FLAG_NONE)
            collectOID = AddToggleOption(__l("Collect study notes"), ControlScript._LEARN_CollectNotes.GetValue(), OPTION_FLAG_NONE)
            
            AddEmptyOption()
            AddHeaderOption(__l("Spell Research"), 0)
            
            minChanceDiscoverOID = AddSliderOption(__l("Min discover chance"), ControlScript._LEARN_MinChanceDiscover.GetValue(), "{0}", OPTION_FLAG_NONE)
            maxChanceDiscoverOID = AddSliderOption(__l("Max discover chance"), ControlScript._LEARN_MaxChanceDiscover.GetValue(), "{0}", OPTION_FLAG_NONE)
            forceSchoolOID = AddMenuOption(__l("School", "Spell School"), ControlScript.getSchools()[ControlScript._LEARN_ForceDiscoverSchool.GetValueInt()], OPTION_FLAG_NONE)

        EndIf
        
    elseIf page == Pages[2]
        CreatePageSpellList()
    EndIf   
        
endEvent

function CreatePageSpellList()
    InitializeSpellList()
    SetCursorFillMode(TOP_TO_BOTTOM) 
    
    AddHeaderOption(__l("Spell List"))
    int totalCount = spellListStates[SPELLS_COUNT]
    if totalCount == 0
        AddTextOption(__l("nothing", "List is empty"), "")
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
    AddSliderOptionST("CurrentPage", "=== " + __l("footer_page", "Current Page") + " ===", currentPageIndex + 1,  pageFormat)

    SetCursorPosition(1)
    AddHeaderOption(__l("List Actions"))
    int flag1 = GetEnabledOptionFlag(currentPageIndex > 0)
    AddTextOptionST("FirstPage", __l("First Page"), "|(", flag1)
    AddTextOptionST("PreviousPage", __l("Previous Page"), "(", flag1)
    flag1 = GetEnabledOptionFlag(currentPageIndex < (pageCount - 1))
    AddTextOptionST("NextPage", __l("Next Page"), ")", flag1)
    AddTextOptionST("LastPage", __l("Last Page"), ")|", flag1)

    AddHeaderOption(__l("Selected Spell"))
    flag1 = GetEnabledOptionFlag(count > 0)
    AddMenuOptionST("SpellCommand", __l("Execute Command"), __l("choose_command", "Choose"), flag1)
    AddSliderOptionST("MoveToIndex", __l("Move to Location"), startIndex + currentSpellIndex + 1, "{0}", flag1)
    flag1 = GetEnabledOptionFlag(currentPageIndex > 0 || currentSpellIndex > 0)
    AddTextOptionST("MoveFirst", __l("Move to Top"), "", flag1)
    AddTextOptionST("MoveUp", __l("Move Up"), "", flag1)
    flag1 = GetEnabledOptionFlag((count > 0) && ((startIndex + currentSpellIndex) < (totalCount - 1)))
    AddTextOptionST("MoveDown", __l("Move Down"), "", flag1)
    AddTextOptionST("MoveBottom", __l("Move to Bottom"), "", flag1)

endFunction

int function GetEnabledOptionFlag(bool enabled)
    if enabled
        return OPTION_FLAG_NONE
    else
        return OPTION_FLAG_DISABLED
    endIf
endFunction

;====================================================================================

Event OnOptionMenuOpen(int option)
    if (option == forceSchoolOID)
        setMenuDialogOptions(ControlScript.getSchools())
        setMenuDialogStartIndex(forceSchoolIndex)
        setMenuDialogDefaultIndex(1)
        return
    endif
    
EndEvent


event OnOptionMenuAccept(int option, int index)
    if (option == forceSchoolOID)
        forceSchoolIndex = index
        SetMenuOptionValue(option, ControlScript.getSchools()[forceSchoolIndex], false)
        ControlScript._LEARN_ForceDiscoverSchool.SetValue(index)
    endif
EndEvent


Event OnOptionSliderOpen(Int a_option)    ; SLIDERS

    If (a_option == minChanceStudyOID)
        SetSliderDialogStartValue(ControlScript._LEARN_MinChanceStudy.GetValue())
        SetSliderDialogDefaultValue(1)
        SetSliderDialogRange(0, ControlScript._LEARN_MaxChanceStudy.GetValue())
        SetSliderDialogInterval(1)
        return
    EndIf

    If (a_option == maxChanceStudyOID)
        SetSliderDialogStartValue(ControlScript._LEARN_MaxChanceStudy.GetValue())
        SetSliderDialogDefaultValue(95)
        SetSliderDialogRange(ControlScript._LEARN_MinChanceStudy.GetValue(), 100)
        SetSliderDialogInterval(1)
        return
    EndIf

    If (a_option == minChanceDiscoverOID)
        SetSliderDialogStartValue(ControlScript._LEARN_MinChanceDiscover.GetValue())
        SetSliderDialogDefaultValue(0)
        SetSliderDialogRange(0, ControlScript._LEARN_MaxChanceDiscover.GetValue())
        SetSliderDialogInterval(1)
        return
    EndIf

    If (a_option == maxChanceDiscoverOID)
        SetSliderDialogStartValue(ControlScript._LEARN_MaxChanceDiscover.GetValue())
        SetSliderDialogDefaultValue(20)
        SetSliderDialogRange(ControlScript._LEARN_MinChanceDiscover.GetValue(), 100)
        SetSliderDialogInterval(1)
        return
    EndIf

    If (a_option == bonusScaleOID)
        SetSliderDialogStartValue(ControlScript._LEARN_BonusScale.GetValue())
        SetSliderDialogDefaultValue(1.0)
        SetSliderDialogRange(0, 4)
        SetSliderDialogInterval(0.1)
        return
    EndIf

    If (a_option == studyIntervalOID)
        SetSliderDialogStartValue(ControlScript._LEARN_StudyInterval.GetValue())
        SetSliderDialogDefaultValue(0.65)
        SetSliderDialogRange(0, 4)
        SetSliderDialogInterval(0.01)
        return
    EndIf

EndEvent

Event OnOptionSliderAccept(Int a_option, Float a_value)

    If (a_option == minChanceStudyOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        ControlScript._LEARN_MinChanceStudy.SetValue(a_value)
        return
    EndIf

    If (a_option == maxChanceStudyOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        ControlScript._LEARN_MaxChanceStudy.SetValue(a_value)
        return
    EndIf

    If (a_option == minChanceDiscoverOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        ControlScript._LEARN_MinChanceDiscover.SetValue(a_value)
        return
    EndIf

    If (a_option == maxChanceDiscoverOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        ControlScript._LEARN_MaxChanceDiscover.SetValue(a_value)
        return
    EndIf

    If (a_option == bonusScaleOID)   
        SetSliderOptionValue(a_option, a_value, "{1}", false)
        ControlScript._LEARN_BonusScale.SetValue(a_value)
        return
    EndIf

    If (a_option == studyIntervalOID)   
        SetSliderOptionValue(a_option, a_value, "{2}", false)
        ControlScript._LEARN_studyInterval.SetValue(a_value)
        return
    EndIf

EndEvent

event OnOptionSelect(int option)
    if (option != 0 && CurrentPage == Pages[2] && SelectSpellItem(option))
        return
    endIf
    ;enable and disable the mod (remove the spell from the player but leave the quest running for now)
    If (Option == isEnabledOption)
        IsEnabled = !IsEnabled
        SetToggleOptionValue(option, IsEnabled, False)

        Actor learningme = Game.GetPlayer()
        Spell PracticeSpell = Game.GetFormFromFile(0x00000802, "Spell Learning.esp") as Spell
        if (IsEnabled)
            learningme.addspell(PracticeSpell, true)
            ControlScript.start()
        Else
            learningme.removespell(PracticeSpell)
            ControlScript.stop()
        EndIf
    ElseIf (Option == customLocationOID)
        Location l = Game.GetPlayer().GetCurrentLocation()
        if (ControlScript.customLocation != l)
            ControlScript.customLocation = l
        Else
            ControlScript.customLocation = None
        endif
        forcepagereset()
    ElseIf (Option == removeOID)
        SetToggleOptionValue(option, ControlScript.toggleRemove(), False)
    ElseIf (Option == collectOID)
        SetToggleOptionValue(option, ControlScript.toggleCollect(), False)
    ElseIf (Option == fissExportOID)
        fiss = getFISS()
        if (fiss == None)
            Debug.MessageBox(__l("message_fiss is not working", "FISS is not working"))
        else
            Debug.MessageBox(__l("message_fiss wait", "Please wait until the next message box. Do not quit this MCM menu yet."))
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
            Debug.MessageBox(__l("message_fiss done", "Done. You are free to leave this MCM menu."))
        EndIf
    ElseIf (Option == fissImportOID)
        fiss = getFISS()
        if (fiss == None)
            Debug.MessageBox(__l("message_fiss is not working", "FISS is not working"))
        else
            ControlScript.AddSpellsToLists()
            ; reset spell study list
            while (ControlScript.spell_fifo_pop() != none)
            EndWhile
            
            Debug.MessageBox(__l("message_fiss wait", "Please wait until the next message box. Do not quit this MCM menu yet."))
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
            Debug.MessageBox(__l("message_fiss done", "Done. You are free to leave this MCM menu."))
        EndIf
    EndIf

endEvent

Event OnOptionHighlight(int option)
    If (Option == minChanceStudyOID)
        SetInfoText(__l("hint_minChanceStudy", "Minimum percent chance per night to learn a spell from books. Default 15."))
    ElseIf (Option == maxChanceStudyOID)
        SetInfoText(__l("hint_maxChanceStudy", "Maximum percent chance per night to learn a spell from books. Default 95."))
    ElseIf (Option == minChanceDiscoverOID)
        SetInfoText(__l("hint_minChanceDiscover", "Minimum percent chance per night to discover a new spell by onself. Default 0.")) 
    ElseIf (Option == maxChanceDiscoverOID)
        SetInfoText(__l("hint_maxChanceDiscover", "Maximum percent chance per night to discover a new spell by oneself. Default 20."))
    ElseIf (Option == bonusScaleOID)
        SetInfoText(__l("hint_bonusScale", "Scale of the roleplaying bonus to chance of learning/discovering. Roleplaying is mage dialogue, collecting spell notes, sleeping at the College and temples, consuming shadowmilk, summoning spirit tutors, etc. Default 1.5."))
    ElseIf (Option == infoStudyOID)
        SetInfoText(__l("hint_infoStudy", "Current percent chance to learn a spell from books (rolled after next night). Cast spells of the same school to improve. (Displays 0 if study list is empty)"))
    ElseIf (Option == infoDiscoverOID)
        SetInfoText(__l("hint_infoDiscover", "Current percent chance to discover a new spell by oneself (rolled after next night). Cast spells of the same school to improve."))
    ElseIf (Option == infoSchoolOID)
        SetInfoText(__l("hint_infoSchool", "Current magic school of interest."))
    ElseIf (Option == collectOID)
        SetInfoText(__l("hint_collectNotes", "Whether or not to collect spell notes when acquiring spell tomes. A large collection of spell notes improves the roleplaying bonus for spell learning chance. Default is enabled."))
    ElseIf (Option == removeOID)
        SetInfoText(__l("hint_removeBooks", "Whether or not to remove unknown spell books from inventory when added, to prevent vanilla 'insta-learn'. Default is enabled.")) 
    ElseIf (Option == forceSchoolOID)
        SetInfoText(__l("hint_preferedSchool", "Set this to the school of magic you want to discover spells from. Default is Automatic."))
    ElseIf (Option == fissExportOID)
        SetInfoText(__l("hint_export", "Export/backup spell study list to FISS XML."))
    ElseIf (Option == fissImportOID)
        SetInfoText(__l("hint_import", "Import/restore spell study list from FISS XML."))
    ElseIf (Option == abandonSpellOID)
        setInfoText(__l("hint_abandonSpell", "Manage your spell learning list: Delete the current first spell from your learning list"))
    ElseIf (Option == CustomLocationOID)
        setInfoText(__l("hint_customLocation", "Click to mark the current location as your personal study. It will provide a learning bonus similar to temples, but not as much as the College. Click again to unset."))
    ElseIf (Option == studyIntervalOID)
        setInfoText(__l("hint_studyInterval", "How many days must pass between learning attempts. Smaller values mean faster learning. Default is 0.65."))
    EndIf
EndEvent

;====================================================================================
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
; === End of Custom UI functions
; === Spell List Management
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
    ControlScript.TryLearnSpellAt(realIndex)
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