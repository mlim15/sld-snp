scriptname _LEARN_MCMConfigQuest extends SKI_ConfigBase

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
int bonusScaleOID
int maxFailuresOID
int collectOID
int removeOID
int infoStudyOID
int infoDiscoverOID
int infoSchoolOID
int forceSchoolOID
int forceSchoolIndex = 0

;================ FUNCTIONS ================


;Call this function on Init and Open to load up UI vars
Function LoadSettings()
    ;zoomSpeed = _lookCloserZoomSpeed.GetValue()
    ;zoomHotKey = _lookCloserHotKey.GetValue() as Int
    ;steppedZoomSteps = _lookCloserZoomSteps.GetValue()
    ;steppedZoomFOV = _lookCloserZoomStepFOVIncrement.GetValue()    
EndFunction


;used by the toggle to disable/enable the mod -- for some reason this method does nothing inside of the Init events :|
Function DisableUI()
    ;e SetOptionFlags(StealthModeOID_T, OPTION_FLAG_DISABLED, False)
EndFunction

Function EnableUI()
    ;e SetOptionFlags(StealthModeOID_T, OPTION_FLAG_NONE, False)
EndFunction


;================ EVENTS ========================================================

;Called when the menu is first registered, grab the values as the first-run data
Event OnConfigInit()
    
    Pages = new string[2]
    Pages[0] = "status"
    Pages[1] = "config"

    if (! ControlScript.isRunning())
        ControlScript.Start()
    endif
    
    IsEnabled = True
    
EndEvent

;Called every time the menu is closed (actually saves the data)
Event OnConfigClose()
    ApplySettings()
EndEvent

;Call this function from OnConfigClose() to update everything
function ApplySettings()
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
    
EndFunction

event OnPageReset(string page)
{Called when a new page is selected, including the initial empty page}
    
    If(page == "" || page == "status")
        
        SetCursorFillMode(TOP_TO_BOTTOM) ;starts are 0
               
        AddHeaderOption("Spell study", 0)
        
        
        If(isEnabled)   
            
            ; current chance to study
            infoStudyOID = AddSliderOption("Chance to study", 100 * ControlScript.baseChanceToStudy(), "{2}", OPTION_FLAG_NONE)

            AddHeaderOption("Current study list", 0)
            ; loop through spell study list
            int i = 0
            Spell sp = ControlScript.spell_fifo_peek(i)
            if (sp == None)
                AddTextOption("Nothing", "", OPTION_FLAG_NONE)
            else
                While (sp && (i< 10))
                    i += 1
                    AddTextOption(sp.GetName(), i, OPTION_FLAG_NONE)
                    sp = ControlScript.spell_fifo_peek(i)
                EndWhile
            EndIf
    
        endif

        SetCursorPosition(1) ; Move cursor to top right position

        AddHeaderOption("Spell discovery", 0)

        If(isEnabled)   
            ; current chance to discover
            infoDiscoverOID = AddSliderOption("Chance to discover", 100 * ControlScript.baseChanceToDiscover(), "{2}", OPTION_FLAG_NONE)

            ; school of magic
            infoSchoolOID = AddTextOption("Interest", ControlScript.topSchoolToday(), OPTION_FLAG_NONE) 
                        
        EndIf


    ElseIf(page == "config")
    
        
        SetCursorFillMode(TOP_TO_BOTTOM) ;starts are 0
        
        AddHeaderOption("General", 0)

        isEnabledOption = AddToggleOption("Mod is enabled", IsEnabled, 0)
        
        if (isEnabled)
            
            bonusScaleOID = AddSliderOption("Bonus scale", ControlScript._LEARN_BonusScale.GetValue(), "{1}", OPTION_FLAG_NONE)
            maxFailuresOID = AddSliderOption("Max failures", ControlScript._LEARN_MaxFailsBeforeCycle.GetValue(),"{0}", OPTION_FLAG_NONE)
        
            SetCursorPosition(1) ; Move cursor to top right position

            AddHeaderOption("Spell study", 0)

            minChanceStudyOID = AddSliderOption("Min study chance", ControlScript._LEARN_MinChanceStudy.GetValue(), "{0}", OPTION_FLAG_NONE)
            maxChanceStudyOID = AddSliderOption("Max study chance", ControlScript._LEARN_MaxChanceStudy.GetValue(), "{0}", OPTION_FLAG_NONE)
            removeOID = AddToggleOption("Remove spell books", ControlScript._LEARN_RemoveSpellBooks.GetValue(), OPTION_FLAG_NONE)
            collectOID = AddToggleOption("Collect study notes", ControlScript._LEARN_CollectNotes.GetValue(), OPTION_FLAG_NONE)
            
            AddEmptyOption()
            AddHeaderOption("Spell discovery", 0)
            
            minChanceDiscoverOID = AddSliderOption("Min discover chance", ControlScript._LEARN_MinChanceDiscover.GetValue(), "{0}", OPTION_FLAG_NONE)
            maxChanceDiscoverOID = AddSliderOption("Max discover chance", ControlScript._LEARN_MaxChanceDiscover.GetValue(), "{0}", OPTION_FLAG_NONE)
            forceSchoolOID = AddMenuOption("School", ControlScript.getSchools()[ControlScript._LEARN_ForceDiscoverSchool.GetValueInt()], OPTION_FLAG_NONE)
            
        EndIf
        
    
    EndIf   
        
endEvent

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

    If (a_option == maxFailuresOID)
        SetSliderDialogStartValue(ControlScript._LEARN_MaxFailsBeforeCycle.GetValue())
        SetSliderDialogDefaultValue(3)
        SetSliderDialogRange(0, 100)
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

    If (a_option == maxFailuresOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        ControlScript._LEARN_MaxFailsBeforeCycle.SetValue(a_value)
        return
    EndIf

    If (a_option == bonusScaleOID)   
        SetSliderOptionValue(a_option, a_value, "{0}", false)
        ControlScript._LEARN_BonusScale.SetValue(a_value)
        return
    EndIf

EndEvent

event OnOptionSelect(int option)

    ;enable and disable the mod (remove the spell from the player but leave the quest running for now)
    If (Option == isEnabledOption)
        IsEnabled = !IsEnabled
        SetToggleOptionValue(option, IsEnabled, False)
        
        If(isEnabled)
            EnableUI()
        Else
            DisableUI()
        EndIf
    ElseIf (Option == removeOID)
        SetToggleOptionValue(option, ControlScript.toggleRemove(), False)
    ElseIf (Option == collectOID)
        SetToggleOptionValue(option, ControlScript.toggleCollect(), False)
    EndIf

endEvent

Event OnOptionHighlight(int option)
    If (Option == minChanceStudyOID)
        SetInfoText("Minimum percent chance per night to learn a spell from books. Default 1.")
    ElseIf (Option == maxChanceStudyOID)
        SetInfoText("Maximum percent chance per night to learn a spell from books. Default 95.") 
    ElseIf (Option == minChanceDiscoverOID)
        SetInfoText("Minimum percent chance per night to discover a new spell by onself. Default 0.") 
    ElseIf (Option == maxChanceDiscoverOID)
        SetInfoText("Maximum percent chance per night to discover a new spell by oneself. Default 20.") 
    ElseIf (Option == maxFailuresOID)
        SetInfoText("Number of failures to learn from a book after which will rotate to next spell in the list (not to stay stuck on a specific spell). Default 3.") 
    ElseIf (Option == bonusScaleOID)
        SetInfoText("Scale of the roleplaying bonus to chance of learning/discovering. Roleplaying is mage dialogue, collecting spell notes, sleeping at the College and temples, consuming shadowmilk, summoning spirit tutors, etc. Default 1.") 
    ElseIf (Option == infoStudyOID)
        SetInfoText("Current percent chance to learn a spell from books (rolled after next night). Cast spells of the same school to improve. (Displays 0 if study list is empty)") 
    ElseIf (Option == infoDiscoverOID)
        SetInfoText("Current percent chance to discover a new spell by oneself (rolled after next night). Cast spells of the same school to improve.") 
    ElseIf (Option == infoSchoolOID)
        SetInfoText("Current magic school of interest - the one that was most used today (defaults to Restoration if no spell was cast so far).") 
    ElseIf (Option == collectOID)
        SetInfoText("Whether or not to collect spell notes when acquiring spell tomes. A large collection of spell notes improves the roleplaying bonus for spell learning chance. Default is enabled.") 
    ElseIf (Option == removeOID)
        SetInfoText("Whether or not to remove unknown spell books from inventory when added, to prevent vanilla 'insta-learn'. Default is enabled.") 
    ElseIf (Option == forceSchoolOID)
        SetInfoText("Set this to the school of magic you want to discover spells from. Default is Automatic.") 
    EndIf
EndEvent

;====================================================================================


