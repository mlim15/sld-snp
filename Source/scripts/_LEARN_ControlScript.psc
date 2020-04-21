ScriptName _LEARN_ControlScript extends Quest ; conditional

GlobalVariable property _LEARN_CountAlteration auto
GlobalVariable property _LEARN_CountConjuration auto
GlobalVariable property _LEARN_CountDestruction auto
GlobalVariable property _LEARN_CountIllusion auto
GlobalVariable property _LEARN_CountRestoration auto
GlobalVariable property _LEARN_CountBonus auto
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
GlobalVariable property _LEARN_LastSetHome auto
GlobalVariable property _LEARN_StudiedToday auto
GlobalVariable property _LEARN_AlreadyUsedTutor auto
GlobalVariable property _LEARN_StudyIsRest auto
GlobalVariable property _LEARN_StudyRequiresNotes auto
String[] effortLabels

Keyword property LocTypeTemple auto
Location property WinterholdCollegeLocation auto
Keyword property LocTypePlayerHouse auto
Keyword property LocTypeInn auto
Location property customLocation auto

Actor property PlayerRef auto
GlobalVariable property GameHour auto
GlobalVariable property GameDaysPassed auto
Book property _LEARN_SpellNotesAlteration auto
Book property _LEARN_SpellNotesConjuration auto
Book property _LEARN_SpellNotesDestruction auto
Book property _LEARN_SpellNotesIllusion auto
Book property _LEARN_SpellNotesRestoration auto
MagicEffect Property AlchDreadmilkEffect auto
MagicEffect Property AlchShadowmilkEffect auto
MagicEffect Property _LEARN_PracticeEffect auto
Spell Property _LEARN_DiseaseDreadmilk auto
Spell property _LEARN_PracticeAbility auto
Spell property _LEARN_SummonSpiritTutor auto
Spell property _LEARN_SetHomeSp auto
Spell property _LEARN_StudyPower auto
Book property _LEARN_SpellTomeSummonSpiritTutor auto

LeveledItem property LitemSpellTomes00Alteration auto
LeveledItem property LitemSpellTomes00Conjuration auto
LeveledItem property LitemSpellTomes00Destruction auto
LeveledItem property LitemSpellTomes00Illusion auto
LeveledItem property LitemSpellTomes00Restoration auto
LeveledItem property LitemSpellTomes25Alteration auto
LeveledItem property LitemSpellTomes25Conjuration auto
LeveledItem property LitemSpellTomes25Destruction auto
LeveledItem property LitemSpellTomes25Illusion auto
LeveledItem property LitemSpellTomes25Restoration auto
LeveledItem property LitemSpellTomes50Alteration auto
LeveledItem property LitemSpellTomes50Conjuration auto
LeveledItem property LitemSpellTomes50Destruction auto
LeveledItem property LitemSpellTomes50Illusion auto
LeveledItem property LitemSpellTomes50Restoration auto
LeveledItem property LitemSpellTomes75Alteration auto
LeveledItem property LitemSpellTomes75Conjuration auto
LeveledItem property LitemSpellTomes75Destruction auto
LeveledItem property LitemSpellTomes75Illusion auto
LeveledItem property LitemSpellTomes75Restoration auto

Float LastSleepTime
int iFailuresToLearn
String[] aSchools

LeveledItem[] aAlterationLL
LeveledItem[] aConjurationLL
LeveledItem[] aDestructionLL
LeveledItem[] aIllusionLL
LeveledItem[] aRestorationLL
LeveledItem[] aInventSpellsPtr

Spell[] aSpells
int iHead
int iTail = -1
int iMaxSize
int iCount
Form[] _spells
int currentVersion; save active version

bool property CanUseLocalizationLib = false auto;
int property LIST_HEAD_SPARE_COUNT = 8 autoReadOnly
int property LIST_PURGE_AFTER = 31 autoReadOnly
string property SPELL_SCHOOL_ALTERATION = "Alteration" autoReadOnly
string property SPELL_SCHOOL_CONJURATION = "Conjuration" autoReadOnly
string property SPELL_SCHOOL_DESTRUCTION = "Destruction" autoReadOnly
string property SPELL_SCHOOL_ILLUSION = "Illusion" autoReadOnly
string property SPELL_SCHOOL_RESTORATION = "Restoration" autoReadOnly

int property NOTIFICATION_REMOVE_BOOK = 0 autoReadOnly
int property NOTIFICATION_ADD_SPELL_NOTE = 1 autoReadOnly
int[] property VisibleNotifications Auto Hidden
bool _canSetBookAsRead

; === MCM helper functions
String[] function getEffortLabels()
	return effortLabels
endFunction

String[] function getSchools()
    return aSchools
EndFunction

bool function ToggleNotification(int id)
    if id < 0 || id > VisibleNotifications.Length
        return false
    endIf
    int v = 0;
    if VisibleNotifications[id] == 0
        v = 1
    endIf

    VisibleNotifications[id] = v
    return v as bool
endFunction

bool function EnableNotification(int id, bool v)
    if id < 0 || id > VisibleNotifications.Length
        return false
    endIf

    VisibleNotifications[id] = v as int
    return v
endFunction

; === Version and upgrade management
int function GetVersion()
    return 173; v 1.7.3
endFunction

function UpgradeVersion()
	bool displayedUpgradeNotice = false
	if (currentVersion < 173)
		string msg = "[Spell Learning] " + formatString1(__l("notification_version_upgrade", "Installed version {0}"), "1.7.3")
		if (!displayedUpgradeNotice)
			; don't display multiple upgrade messages
			Debug.Notification(msg)
			displayedUpgradeNotice = true
		endIf
		Debug.Trace(msg)
		; Set up new list of scaling options
		effortLabels = new String[3]
		effortLabels[0] = "Tough Start"
		effortLabels[1] = "Diminishing Returns"
		effortLabels[2] = "Linear"
		; If user is upgrading from an older version, disable new options to not disrupt
		; existing functionality for users
		if (currentVersion > 0)
			_LEARN_DynamicDifficulty.SetValue(0)
			_LEARN_IntervalCDREnabled.SetValue(0)
			_LEARN_AutoNoviceLearningEnabled.SetValue(0)
			_LEARN_MaxFailsAutoSucceeds.SetValue(0)
			_LEARN_TooDifficultEnabled.SetValue(0)
		endIf
		; Add study power?
	endIf
    if (currentVersion < 172)
        VisibleNotifications = new int[2]
        VisibleNotifications[NOTIFICATION_REMOVE_BOOK] = 0 
        VisibleNotifications[NOTIFICATION_ADD_SPELL_NOTE] = 1
        UpgradeSpellList()
		string msg = "[Spell Learning] " + formatString1(__l("notification_version_upgrade", "Installed version {0}"), "1.7.2")
		if (!displayedUpgradeNotice)
			; don't display multiple upgrade messages
			Debug.Notification(msg)
			displayedUpgradeNotice = true
		endIf
		Debug.Trace(msg)
    endIf
    currentVersion = GetVersion()
endFunction

function UpgradeSpellList()
    if aSpells || aSpells.Length > 1
        int i = 0
        int newCapacity = NihSldUtil.CalculateNextCapacity(iCount)
        _spells = Utility.CreateFormArray(newCapacity)
        while i < iCount
            _spells[i] = aSpells[(iHead + i) % iMaxSize]
            i += 1
        EndWhile
        iHead = 0
        iTail = iCount - 1
        iMaxSize = newCapacity
        aSpells = new Spell[1]; assigning None causes casting error
    endIf
endFunction

function InternalPrepare()
{Maintainence function}
    aSchools[0] = __l("mcm_automatic", "Automatic"); added here for mid-game localization support
    _canSetBookAsRead = SKSE.GetPluginVersion("BookExtension") != -1
    UpgradeVersion()
endFunction

; === Localization
string function __l(string keyName, string defaultValue = "")
    if CanUseLocalizationLib
        return _LEARN_Strings.__l(keyName, defaultValue);
    endIf
    if (defaultValue == "")
        return keyName;
    endIf
    return defaultValue 
endFunction

string function formatString1(string source, string p1)
    return _LEARN_Strings.StringReplaceAll(source, "{0}", p1)
endFunction

int function GetMenuLangId()
    if CanUseLocalizationLib
        return _LEARN_Strings.GetMenuLangId()
    else
        return 0
    endIf
endFunction

; === Spell list management
function SpellListEnsureCapacity(int capacity)
    if capacity > iMaxSize
        int newSize = NihSldUtil.CalculateNextCapacity(capacity)
        if _spells
            _spells = Utility.ResizeFormArray(_spells, newSize)
        else
            _spells = Utility.CreateFormArray(newSize)
            iTail = -1
            iHead = 0
        endIf
        ;Debug.Trace(_LEARN_Strings.FormatString2("[Spell Learning] Spell capacity increased from {0} to {1}", iMaxSize, newSize))
        iMaxSize = newSize
    endIf
endFunction

int function CopySpells(Form[] targetList, int startIndex, int count)
{to get spells for paging faster. returns copied spell count}
    if startIndex < 0 || startIndex >= iCount
        return 0
    endIf
    if count + startIndex > iCount
        count = iCount - startIndex
    endIf
    int i = 0
    int delta = iHead + startIndex
    while i < count
        targetList[i] = _spells[delta + i]
        i += 1
    EndWhile
    return count
endFunction

int function spell_fifo_get_count()
    return iCount
EndFunction

bool function spell_fifo_has_ref(Spell sp)
    return iCount > 0 && _spells.Find(sp as Form) >= 0
EndFunction

int function spell_fifo_get_ref(Spell sp)
	if (iCount > 0 && _spells.Find(sp as Form) >= 0)
		return _spells.Find(sp as Form)
	Else
		return 0
	EndIf
EndFunction

Spell function spell_fifo_peek(int idx = 0)
    if idx < 0 || iCount <= idx
        return None
    endIf
    return _spells[iHead + idx] as Spell
EndFunction

Bool function spell_fifo_poke(int idx, Spell spx)
    if idx < 0 || iCount <= idx
        return false
    endIf
    _spells[iHead + idx] = spx
EndFunction

Spell function spell_fifo_remove_last()
    if iCount == 0
        return None
    endIf
    Spell tmp = _spells[iTail] as Spell
    _spells[iTail] = None
    iCount -= 1
    iTail -= 1
    return tmp
EndFunction

Spell function spell_fifo_push(Spell s) 
    ; add
    SpellListEnsureCapacity(iTail + 2)
    iTail += 1
    _spells[iTail] = s
    iCount += 1
    return s
EndFunction

Spell function spell_fifo_pop()
    ; remove first item and return it
    if iCount == 0
        return None
    endIf
    Spell tmp = _spells[iHead] as Spell
    _spells[iHead] = None
    iHead += 1
    iCount -= 1
    if iHead > LIST_PURGE_AFTER ; we check here to avoid framing
        PurgeSpellList()
    endIf
    return tmp
EndFunction

Spell function spell_list_removeAt(int index)
    if index < 0 || index >= iCount
        return None
    endIf
    int realIndex = index + iHead
    Spell tmp = _spells[realIndex] as Spell
    bool checkPurge = false

    if realIndex == iHead
        _spells[iHead] = None
        iHead += 1
        iCount -= 1
        checkPurge = true
    elseIf realIndex == iTail
        _spells[iTail] = None
        iCount -= 1
        iTail -= 1
    elseIf (realIndex - iHead) < (iTail - realIndex) ; we move items from start of the list
        int i = realIndex
        while i > iHead
            _spells[i] = _spells[i - 1]
            i -= 1
        EndWhile
        _spells[iHead] = None
        iHead += 1
        iCount -= 1
        checkPurge = true
    else ; we move items from end of the list
        int i = realIndex
        while i < iTail
            _spells[i] = _spells[i + 1]
            i += 1
        EndWhile
        _spells[iTail] = None
        iTail -= 1
        iCount -= 1
    endIf
    if checkPurge && iHead > LIST_PURGE_AFTER
        PurgeSpellList()
    endIf
    return tmp
endFunction

bool function forceLearnSpellAt(int index)
    Spell spellToLearn = spell_list_removeAt(index)
    if spellToLearn
        if !PlayerRef.HasSpell(spellToLearn)
            PlayerRef.AddSpell(spellToLearn)
            return true
        endIf
    endIf
    return false
endFunction

function PurgeSpellList()
    int spareHead = LIST_HEAD_SPARE_COUNT
    if iHead < spareHead
        return
    endIf
    ;Debug.Trace("[Spell Learning] Purging head=" + iHead + ",count=" + iCount + ",capacity=" + iMaxSize)
    int i = spareHead
    int topIndex = iCount + spareHead
    int delta = iHead - spareHead
    while i < topIndex
        _spells[i] = _spells[i + delta]
        i += 1
    EndWhile
    iTail -= delta
    iHead = spareHead

    ; add shrink functionality
    int requestedCapacity = iCount + (2 * spareHead)
    int calculatedCapacity = NihSldUtil.CalculateNextCapacity(requestedCapacity)
    if iMaxSize > calculatedCapacity
        ;Debug.Trace("[Spell Learning] shrinking from" + iMaxSize + " to " + calculatedCapacity)
        _spells = Utility.ResizeFormArray(_spells, calculatedCapacity)
        iMaxSize = calculatedCapacity
    endIf
    ;Debug.Trace("[Spell Learning] Purge completed head=" + iHead + ",count=" + iCount + ",capacity=" + iMaxSize)
    ;/ TODO: test this later
    if CanUseLocalizationLib ; PapyrusUtil is installed
        _spells = PapyrusUtil.SliceFormArray(_spells, iHead - spareHead, iMaxSize - 1)
        iMaxSize = _spells.Length
        iTail -= (iHead - spareHead)
        iHead = spareHead
    else
        int i = spareHead
        int topIndex = iCount + spareHead
        int delta = iHead - spareHead
        while i < topIndex
            _spells[i] = _spells[i + delta]
            i += 1
        EndWhile
        iTail -= delta
        iHead = spareHead
    endIf
    /;
endFunction

bool function MoveSpellToTop(int spellIndex)
    if spellIndex == 0
        return false
    endIf
    int realIndex = spellIndex + iHead
    Form item = _spells[realIndex]
    int i
    if iHead == 0 ;no free space at beginning
        i = realIndex
        while i
            _spells[i] = _spells[i - 1]
            i -= 1
        endWhile
        _spells[iHead] = item
    else 
        int lenL = realIndex - iHead
        int lenR = iTail - realIndex
        if (lenR < lenL) || (lenR == lenL && iHead > LIST_HEAD_SPARE_COUNT)
            i = realIndex
            while i < iTail
                _spells[i] = _spells[i + 1]
                i += 1
            endWhile
            iTail -= 1
            iHead -= 1
            _spells[iHead] = item
        else
            i = realIndex
            while i > iHead
                _spells[i] = _spells[i - 1]
                i -= 1
            endWhile
            _spells[iHead] = item
        endIf
    endIf
    return true
endFunction

bool function MoveSpellToBottom(int spellIndex)
    if spellIndex >= (iCount - 1)
        return false
    endIf
    int realIndex = spellIndex + iHead
    Form item = _spells[realIndex]
    int i

    int lenL = realIndex - iHead
    int lenR = iTail - realIndex
    
    if (lenL < lenR)
        i = realIndex
        while i > iHead
            _spells[i] = _spells[i - 1]
            i -= 1
        endWhile
        _spells[iHead] = None
        iHead += 1
        SpellListEnsureCapacity(iTail + 2)
        iTail += 1
        _spells[iTail] = item
    else
        i = realIndex
        while i < iTail
            _spells[i] = _spells[i + 1]
            i += 1
        endWhile
        _spells[iTail] = item
    endIf

    return true
endFunction

bool function MoveSpellToIndex(int spellIndex, int targetIndex)
    if spellIndex == targetIndex || spellIndex < 0 || spellIndex >= iCount
        return false
    endIf
    if targetIndex == 0
        return MoveSpellToTop(spellIndex)
    elseIf targetIndex >= (iCount - 1)
        return MoveSpellToBottom(spellIndex)
    endIf

    int realIndex = spellIndex + iHead
    int realTargetIndex = targetIndex + iHead
    Form tmp = _spells[realIndex]
    int displacement
    int leftCount
    int rightCount
    int i
    if (targetIndex < spellIndex) ; going left
        displacement = spellIndex - targetIndex
        leftCount = targetIndex
        rightCount = iCount - spellIndex - 1
        if iHead > 0 && (leftCount + rightCount) < displacement
            i = iHead
            while i < realTargetIndex ; moving left array to left
                _spells[i - 1] = _spells[i]
                i += 1
            endWhile
            iHead -= 1
            _spells[realTargetIndex - 1] = tmp
            i = realIndex
            while i < iTail ; moving right array to left
                _spells[i] = _spells[i + 1]
                i += 1
            endWhile
            _spells[iTail] = None
            iTail -= 1
        else ; move displacement
            i = realIndex
            while i > realTargetIndex
                _spells[i] = _spells[i - 1]
                i -= 1
            endWhile
            _spells[realTargetIndex] = tmp
        endIf
    else ; going right
        displacement = targetIndex - spellIndex
        leftCount = spellIndex
        rightCount = iCount - targetIndex - 1
        if (leftCount + rightCount) < displacement
            SpellListEnsureCapacity(iTail + 2)
            i = iTail
            while i > realTargetIndex ; moving right array to right
                _spells[i + 1] = _spells[i]
                i -= 1
            endWhile
            iTail += 1
            _spells[realTargetIndex + 1] = tmp
            i = realIndex
            while i > iHead ; moving left array to right
                _spells[i] = _spells[i - 1]
                i -= 1
            endWhile
            _spells[iHead] = None
            iHead += 1
        else
            i = realIndex
            while i < realTargetIndex
                _spells[i] = _spells[i + 1]
                i += 1
            endWhile
            _spells[realTargetIndex] = tmp
        endIf
    endIf

    return true
endFunction

bool function MoveSpellUp(int spellIndex)
    if spellIndex == 0
        return false
    endIf
    int realIndex = spellIndex + iHead
    
    Form tmp = _spells[realIndex]
    _spells[realIndex] = _spells[realIndex - 1]
    _spells[realIndex - 1] = tmp
    return true
endFunction

bool function MoveSpellDown(int spellIndex)
    if spellIndex >= (iCount - 1)
        return false
    endIf
    int realIndex = spellIndex + iHead
    
    Form tmp = _spells[realIndex]
    _spells[realIndex] = _spells[realIndex + 1]
    _spells[realIndex + 1] = tmp
    return true
endFunction

function SpawnItemsInWorld(); TODO Fix. Also add the rest of the items.
	if (_LEARN_SpawnItems.GetValue() == 1)
	    Book x
		int i = LitemSpellTomes00Conjuration.GetNumForms()
		While (i > 0)
			x = LitemSpellTomes00Conjuration.GetNthForm(i) as Book
			if (x == _LEARN_SpellTomeSummonSpiritTutor)
				Return
			EndIf
			i = i - 1
		EndWhile
		LitemSpellTomes00Conjuration.addform(_LEARN_SpellTomeSummonSpiritTutor as Form, 1, 1)
	EndIf
EndFunction

function OnInit()

	SpawnItemsInWorld()
    
    aSchools = new String[6]
    aSchools[0] = __l("mcm_automatic", "Automatic")
    aSchools[1] = SPELL_SCHOOL_ALTERATION
    aSchools[2] = SPELL_SCHOOL_CONJURATION
    aSchools[3] = SPELL_SCHOOL_DESTRUCTION
    aSchools[4] = SPELL_SCHOOL_ILLUSION
    aSchools[5] = SPELL_SCHOOL_RESTORATION
    
    aAlterationLL = new LeveledItem[4]
    aAlterationLL[0] = LitemSpellTomes00Alteration
    aAlterationLL[1] = LitemSpellTomes25Alteration
    aAlterationLL[2] = LitemSpellTomes50Alteration
    aAlterationLL[3] = LitemSpellTomes75Alteration
    aConjurationLL = new LeveledItem[4]
    aConjurationLL[0] = LitemSpellTomes00Conjuration
    aConjurationLL[1] = LitemSpellTomes25Conjuration
    aConjurationLL[2] = LitemSpellTomes50Conjuration
    aConjurationLL[3] = LitemSpellTomes75Conjuration
    aDestructionLL = new LeveledItem[4]
    aDestructionLL[0] = LitemSpellTomes00Destruction
    aDestructionLL[1] = LitemSpellTomes25Destruction
    aDestructionLL[2] = LitemSpellTomes50Destruction
    aDestructionLL[3] = LitemSpellTomes75Destruction
    aIllusionLL = new LeveledItem[4]
    aIllusionLL[0] = LitemSpellTomes00Illusion
    aIllusionLL[1] = LitemSpellTomes25Illusion
    aIllusionLL[2] = LitemSpellTomes50Illusion
    aIllusionLL[3] = LitemSpellTomes75Illusion
    aRestorationLL = new LeveledItem[4]
    aRestorationLL[0] = LitemSpellTomes00Restoration
    aRestorationLL[1] = LitemSpellTomes25Restoration
    aRestorationLL[2] = LitemSpellTomes50Restoration
    aRestorationLL[3] = LitemSpellTomes75Restoration
    
    aInventSpellsPtr = aRestorationLL
    
    RegisterForSleep()
    UpgradeVersion()
	
endFunction

; === Chance calculations
float function scaleEffort(float effort, float minchance, float maxchance)
	float scaledEffort
	; This function optionally scales effort to be non-linear. 
	; In the original, an s-curve was used. It has been changed here slightly so that
	; at effort=0 it returns the minimum chance, and at effort=1 (max effort)
	; it returns the maximum chance. Values in between are scaled to 
	; provide a harder start (low total effort is more punished).
	; There are no diminishing returns with effort - above about 60%
	; the relationship between effort in and scaled effort is relatively linear.
    if (_LEARN_EffortScaling.GetValue() == 0) ; If preference set to scurve
		scaledEffort = (minchance + (maxchance - minchance) * (2 - 2 / (1 + (effort*effort*effort))))
	; Alternatively, you can use a square root. This provides the opposite effect.
	; Low effort values are scaled up, while higher values have diminishing returns.
    ElseIf(_LEARN_EffortScaling.GetValue() == 1) ; If preference set to square root
		scaledEffort = ((maxchance - minchance) * Math.sqrt(effort) + minchance)
	; Finally, linear 1:1 is an option. Warning that this often maxes out small discovery
	; chances, as even reaching 5% of the total amount of effort you could generate
	; (which is very easy) will result in a roll of 5%, for example.
    ElseIf(_LEARN_EffortScaling.GetValue() == 2) ; If preference set to linear
		if (effort > maxchance)
			scaledEffort = maxchance
		elseIf (effort < minchance)
			scaledEffort = minchance
		else
			scaledEffort = effort
		endIf
	Else ; This should never happen. But let's at least ensure things are happening if it does.
		return maxchance
	EndIf
    return scaledEffort 
EndFunction

float function calcEffort(float skill, float casts, float notes)
    float effort
	; result is on a scale of 0-1ish.
	; with enough bonus it can go above 1.
	; it's made of three things:
	; myskill (considering magic skill levels)
	; mycasts (spell casts of same school)
	; mybonus (other roleplaying bonus)

	; calculate myskill
    float myskill = 0 ; out of 100
    int i = 1
    ; Calculate the mean skill over all magic schools
    while (i <= 5)
        myskill += PlayerRef.GetActorValue(aSchools[i]) / 5
        i += 1
    EndWhile
    ; That will count for 1/3rd
    myskill /= 3
    ; specific magic school skill will count for 2/3rds
    myskill += skill * 2 / 3

	; cap the passed mycasts at 100 casts.
    float mycasts = casts ; maximum 100
    if (mycasts > 100)
        mycasts = 100
    endif
 
    ; calculate mybonus
    float mybonus = 0 ; no cap. enough bonus can make up for lacking in other two.
	; the CountBonus variable is accessed by other scripts to add more to the bonus.
	; For example, the deprecated dialogue option used this variable.
	; The random "dream" bonus/penalty and the Daedric Tutor also use this value, though I may disable 
	; them by default or make them an optional components for pure lorefriendliness and less debug message spam.
	; It is kept for posterity and can be extended in the future.
    mybonus += _LEARN_CountBonus.GetValue()
    ; Amount of spell learning notes in inventory provide bonus (diminishing returns, 
	; up to asymptote of 33% of 33% of final effort).
	; The number of notes possessed by the player is related to the value of the spells they have read.
	; So this value is normalized by comparing the value of a core spellbook 
	; (in this case Candlelight) to accomodate some mods which alter the spell tome values. 
	; Let's try to be consistent across load orders.
    Book refCandleLight = Game.GetForm(0x0009E2A7) as Book
    float priceFactor = refCandleLight.GetGoldValue() / 44
    notes = notes / pricefactor
    float bnot
    bnot = Math.sqrt(notes)
	; With a cap of 33, the max number of notes that give benefit to the player is 1089 (33 squared).
	; It accounts for a max of 33% of 33% of the final total effort.
	; This value could be configurable in a future update.
    if (bnot > 33)
        bnot = 33
    EndIf
    mybonus += bnot
    ; Check for drug bonus
    if (PlayerRef.HasMagicEffect(AlchDreadmilkEffect)) ; dreadmilk
        mybonus += 300 ; Dreadmilk gives automatic max total effort, and therefore automatic max roll.
    elseif (PlayerRef.HasMagicEffect(AlchShadowmilkEffect)) ; shadowmilk
        mybonus += 100 ; Shadowmilk provides 33% of total effort all by itself. This can help bypass the "tough start" hump.
    endif
    ; Check for good location
    Location locationX = PlayerRef.GetCurrentLocation()
    ; Cell myCell = PlayerRef.GetParentCell()
    if (locationX)
        if (locationX.HasKeyword(LocTypeTemple) || locationX.HasKeyword(LocTypePlayerHouse) || (customLocation && locationX.isSameLocation(customLocation)))
            mybonus += 22
        elseIf (locationX.isSameLocation(WinterholdCollegeLocation) || WinterholdCollegeLocation.isChild(locationX))
            mybonus += 33
		elseIf (locationX.HasKeyword(LocTypeInn))
			mybonus += 11
        endif
    endIf
    ; Failing to learn also counts as progress for rng roll, 
    ; but only if some role playing is already happening
    if (mybonus >= 33)
        mybonus += iFailuresToLearn * 11
    endif
	; scale mybonus using the configurable BonusScale parameter (default 1, max 3)
    mybonus = mybonus * _LEARN_BonusScale.GetValue()
	
    effort = ((myskill + mycasts + mybonus) / 3 / 100)
	; cap effort at 1
	; this ensures the bonus value can only make up for lost effort from myskill and mycast.
	; gives cleaner math for scaling, as effort scales exactly from 0 to 1.
    if (effort < 0)
        effort = 0
	ElseIf (effort > 1)
		effort = 1
    EndIf
    return effort
EndFunction

float function baseChanceBySchool(string magicSchool, float minchance, float maxchance, MagicEffect eff, bool discovering)
    float fskill
    float fcasts
    float fnotes
    float fChance
    ; Debug.Notification(magicSchool) 
    fskill = PlayerRef.GetActorValue(magicSchool)
    if magicSchool == SPELL_SCHOOL_ALTERATION
        fcasts = _LEARN_CountAlteration.GetValue()
        fnotes = PlayerRef.GetItemCount(_LEARN_SpellNotesAlteration)
    elseIf magicSchool == SPELL_SCHOOL_CONJURATION
        fcasts = _LEARN_CountConjuration.GetValue()
        fnotes = PlayerRef.GetItemCount(_LEARN_SpellNotesConjuration)
    elseIf magicSchool == SPELL_SCHOOL_DESTRUCTION
        fcasts = _LEARN_CountDestruction.GetValue()
        fnotes = PlayerRef.GetItemCount(_LEARN_SpellNotesDestruction)
    elseIf magicSchool == SPELL_SCHOOL_ILLUSION
        fcasts = _LEARN_CountIllusion.GetValue()
        fnotes = PlayerRef.GetItemCount(_LEARN_SpellNotesIllusion)
    elseIf magicSchool == SPELL_SCHOOL_RESTORATION
        fcasts = _LEARN_CountRestoration.GetValue()
        fnotes = PlayerRef.GetItemCount(_LEARN_SpellNotesRestoration)
    endIf    
	; Check to see if dynamic difficulty is enabled.
	; If it is, then adjust the fChance accordingly to make it more/less likely to learn the spell.
	if (_LEARN_DynamicDifficulty.GetValue() == 1 && !discovering)
		int magicLevel = 0
		magicLevel = eff.GetSkillLevel()
		if (magicLevel == 0)
			; so that we don't crash the game with novice spells by dividing by zero
			magicLevel = 1
		endIf
		fskill = PlayerRef.GetActorValue(magicSchool)
		float skillDiff = 0
		skillDiff = fskill/magicLevel
		if (skillDiff == 0)
			; this won't (shouldn't?) happen but it's not a good situation so let's fix that
			fChance = fChance/0.01
		else
			; divide fChance by skillDiff.
			; when your skill is higher than spell level, skillDiff is >1 so division increases the number, making learning easier
			; when your skill is lower, skillDiff is <1 so division decreases the number, making learning harder
			fChance = fChance/skillDiff
		endIf
	endIf
    fChance = scaleEffort(calcEffort(fskill, fcasts, fnotes), minchance / 100, maxchance / 100)
    ; Debug.Notification("baseChance = " + fChance)
    return fChance
EndFunction

float Function baseChanceToStudy(string magicSchool = "")
    Magiceffect me
	if (magicSchool == "")
        if iCount == 0
            return 0
        endif
        Spell sp = spell_fifo_peek()
        if (sp == None)
            return 1
        endif
        me = sp.GetNthEffectMagicEffect(0)
        if (me == None)
            return 1
        endif
        magicSchool = me.GetAssociatedSkill()
        if (magicSchool == "")
            return 1
        endif
    endif
    return baseChanceBySchool(magicSchool, _LEARN_MinChanceStudy.GetValue(), _LEARN_MaxChanceStudy.GetValue(), me, false) 
EndFunction

float Function baseChanceToDiscover(string magicSchool = "")
	if (magicSchool == "")
        magicSchool = topSchoolToday()
    EndIf
	; Pass an arbitrary magiceffect. It won't be used thanks to the boolean.
    return baseChanceBySchool(magicSchool, _LEARN_MinChanceDiscover.GetValue(), _LEARN_MaxChanceDiscover.GetValue(), _LEARN_PracticeEffect, true) 
EndFunction

float function getTotalCasts()
	return (_LEARN_CountAlteration.GetValue() + _LEARN_CountDestruction.GetValue() + _LEARN_CountConjuration.GetValue() + _LEARN_CountRestoration.GetValue() + _LEARN_CountIllusion.GetValue())
endFunction

float function getTotalNotes()
	return (PlayerRef.GetItemCount(_LEARN_SpellNotesAlteration) + PlayerRef.GetItemCount(_LEARN_SpellNotesConjuration) + PlayerRef.GetItemCount(_LEARN_SpellNotesDestruction) + PlayerRef.GetItemCount(_LEARN_SpellNotesIllusion) + PlayerRef.GetItemCount(_LEARN_SpellNotesRestoration))
endFunction

float function calcCDReffort()
	;float mybonus = 0
	;mybonus += _LEARN_CountBonus.GetValue() ; Get value from script counter - e.g. demonic tutor, dreams.
	;mybonus = mybonus
	; cap at 100
	;if (mybonus > 100)
	;	mybonus = 100
	;endIf
	float mycasts = getTotalCasts()
	; mycasts max of 500 - 100 of each school counted.
	; we will cap it at 100 because 500 spell casts per rest is not realistic?
	if (mycasts > 100)
		mycasts = 100
	endIf
	; weighting is here and not configurable atm.
	return ((mycasts)/100*_LEARN_BonusScale.GetValue()) 
endFunction

bool function rollToLearn(float fChance, Spell sp)
	Float fRand
	; ...check to see if HarderParallel is enabled. If it is, divide chance by number of spells being learned.
	if (_LEARN_HarderParallel.GetValue() != 0) 
		fRand = Utility.RandomFloat(0.0, 1.0)
		fRand = fRand * _LEARN_ParallelLearning.GetValue()
	Else ; Otherwise, roll as normal.
		fRand = Utility.RandomFloat(0.0, 1.0)
	EndIf
	
	; Once you have the roll, compare it to the chance. If it passes, return a True boolean.
	if (fRand < fChance)
		return True
	Else
		return False
	EndIf
EndFunction

bool function debugCheck(Spell sp, int fifoindex)
	MagicEffect eff
	; Debug checks - make sure spell and spell effect exists, get spell school
	if (! sp)
		Debug.MessageBox(__l("message_spell_learning_bad_reference", "[Spell Learning] Error learning spell, removing entry from list."))
		spell_list_removeAt(fifoindex) ; TODO something better to handle spell mod disappearance ?
		return false
	endif
	eff = sp.GetNthEffectMagicEffect(0)
	if (!eff)
		Debug.Notification(__l("notification_unknown_spell", "[Spell Learning] Unknown spell in learning list - other spell mod removed?"))
		return false
	else
		return true
	endIf
endFunction

bool function canAutoLearn(Spell sp, int fifoindex)
    ; Initialize variables
	MagicEffect eff
	String magicSchool = SPELL_SCHOOL_DESTRUCTION
	int magicLevel = 100
	float fskill = 0
	float pskill = 0
	; debug check to ensure everything still exists
	if (!debugCheck(sp, fifoindex))
		return False
	endif
	; If debug checks are passed, compare spell's level to player's skill and auto learn if eligible.
	; initialize more variables now that we know they really exist
	eff = sp.GetNthEffectMagicEffect(0)
	magicSchool = eff.GetAssociatedSkill()
	magicLevel = eff.GetSkillLevel()
	fskill = PlayerRef.GetActorValue(magicSchool)
	if ((pskill - _LEARN_AutoNoviceLearning.GetValue()) >= magicLevel)
		return True
	Else
		return False
	EndIf
EndFunction

bool function cannotLearn(Spell sp, int fifoindex)
	; First things first: if configured to allow dreadmilk to bypass autofail,
	; and under the effects of dreadmilk, then just return False.
	if ((PlayerRef.HasMagicEffect(AlchDreadmilkEffect)) && _LEARN_PotionBypass.GetValue() == 1)
		return False
	EndIf
    ; Initialize variables
	MagicEffect eff
	String magicSchool = SPELL_SCHOOL_DESTRUCTION
	int magicLevel = 100
	float fskill = 0
	float pskill = 0
	; debug check to ensure everything still exists
	if (!debugCheck(sp, fifoindex))
		return True
	endif
	; If debug checks are passed, compare spell's level to player's skill and auto learn if eligible.
	; initialize more variables now that we know they really exist
	eff = sp.GetNthEffectMagicEffect(0)
	magicSchool = eff.GetAssociatedSkill()
	magicLevel = (eff.GetSkillLevel())
	fskill = PlayerRef.GetActorValue(magicSchool)
	if (pskill > (_LEARN_TooDifficultDelta.GetValue() - magicLevel))
		return True
	Else
		return False
	EndIf
EndFunction

; === Spell Learning
float Function hours_before_next_ok_to_learn()
    float now = GameDaysPassed.GetValue()
	float nextOK = LastSleepTime + 1
	; If cooldown reduction is enabled, then reduce the required wait time accordingly.
	if (_LEARN_IntervalCDREnabled.GetValue() == 1)
		float actualCDR = 0
		actualCDR = scaleEffort(calcCDReffort(), 0, (_LEARN_IntervalCDR.GetValue() / 100))
		nextOK = LastSleepTime + _LEARN_StudyInterval.GetValue()*(1-actualCDR)
	Else
		nextOK = LastSleepTime + _LEARN_StudyInterval.GetValue() ; default is 0.65
	EndIf

    if now >= nextOK
        return 0
    Else
        return ((nextOK - now) * 24)
    endif
EndFunction

function tryLearnSpell(Spell sp, int fifoIndex, bool forceSuccess)
    ; Initialize variables
	float fChance
	MagicEffect eff
	String magicSchool = SPELL_SCHOOL_DESTRUCTION
	; debug check to ensure everything still exists
	if (!debugCheck(sp, fifoindex))
		return ; break if debug check fails
	else
		eff = sp.GetNthEffectMagicEffect(0)
		magicSchool = eff.GetAssociatedSkill()
	endif

	; if passed bool forceSuccess is true, just succeed
	if (forceSuccess)
		Debug.Notification(formatString1(__l("notification_effortless_learn", "{0} came effortlessly to you."), sp.GetName()))
		forceLearnSpellAt(fifoindex)
		iFailuresToLearn = 0
		return
	EndIf
	
	; Otherwise, roll to learn the spell
	if ((rollToLearn(baseChanceToStudy(magicSchool),sp) || PlayerRef.HasSpell(sp))) 
		Debug.Notification(formatString1(__l("notification_learn_spell", "It all makes sense now! Learned {0}."), sp.GetName()))
		forceLearnSpellAt(fifoindex)
		iFailuresToLearn = 0 
	Else 
		iFailuresToLearn = iFailuresToLearn + 1
		Debug.Notification(formatString1(__l("notification_fail_spell", "{0} still makes no sense..."), sp.GetName()))
	EndIf
EndFunction

Event OnSleepStop(Bool abInterrupted)
	; initialize variables
	Spell sp
	bool emergencyBreaks = false
	int alreadyLearnedSpells = 0
	
	; Do nothing if sleep was interrupted. 
	if (abInterrupted)
        Debug.Notification(__l("notification_sleep_interrupted", "Your sleep was interrupted."))
        return
    endIf

	; First things first: If auto-successes bypass the daily limit, then process them all first.
	if (_LEARN_AutoNoviceLearningEnabled.GetValue() == 1 && _LEARN_AutoSuccessBypassesLimit.GetValue() == 1)
		int currentSpell = 0
		while (currentSpell < spell_fifo_get_count())
			sp = spell_fifo_peek(currentSpell)
			if(canAutoLearn(sp, currentSpell))
				tryLearnSpell(sp, currentSpell, true)
			endIf
			currentSpell = currentSpell + 1
		endWhile
	endIf
   
    ; Do not roll for any spells if was already called too recently. 
    if (hours_before_next_ok_to_learn() > 0)
        Debug.Notification(__l("notification_slept_too_soon", "It seems your mind isn't settled enough yet to learn any spells..."))
		return
    endIf

    LastSleepTime = GameDaysPassed.GetValue()	
    
    SpawnItemsInWorld()
	
	; Before the main spell learning cycle, if we've reached the max amount of failures, we'll handle that here first.
	; As long as the setting is enabled, obviously.
	if (iFailuresToLearn >= _LEARN_MaxFailsBeforeCycle.GetValue() && _LEARN_MaxFailsBeforeCycle.GetValue() != 0)
		sp = spell_fifo_peek()
		if (_LEARN_MaxFailsAutoSucceeds.GetValue() == 1 && (_LEARN_TooDifficultEnabled.GetValue() == 0 || !cannotLearn(sp, 0))) 
		; If reaching the max amount of fails is supposed to make you auto succeed and it's not an automatic failure for some other reason...
			; ...then automatically learn the spell.
			Debug.Notification(formatString1(__l("notification_fail_upwards", "It's finally coming together! Learned {0}."), sp.GetName()))
			forceLearnSpellAt(0)
			iFailuresToLearn = 0
			alreadyLearnedSpells = alreadyLearnedSpells + 1
		else ; Otherwise it's supposed to just move the spell to the bottom of the list.
			MoveSpellToBottom(0)
			iFailuresToLearn = 0
			Debug.Notification(formatString1(__l("notification_moving_on", "Not making any progress on {0}... trying other spells."), sp.GetName()))
		endIf
	endIf
	
	; main spell learning loop
	if (true)
		; initialize variables only used in this loop
		int currentSpell = 0
		float spellLimit = 1
		; set the spell limit
		if (_LEARN_AutoSuccessBypassesLimit.GetValue() == 1 && _LEARN_MaxFailsAutoSucceeds.GetValue() == 0)
			; if all the ways spells could be learned before are off or are set
			; to not count towards the limit, then the limit is just the amount of spells per
			; day to learn
			spellLimit = _LEARN_ParallelLearning.GetValue()
		else
			; otherwise, subtract the already learned spells counter from the amount of available spells to learn
			spellLimit = _LEARN_ParallelLearning.GetValue()-alreadyLearnedSpells
		endIf
		; while below max daily limit AND not yet at end of list, iterate through and try to learn
		while (currentSpell < spellLimit && currentSpell < spell_fifo_get_count() && !emergencyBreaks) 
			; get the current spell
			sp = spell_fifo_peek(currentSpell)
			; initialize some variables here.
			; they are only used in the loop below.
			; if we initialize them in that loop they'll reset,
			; so we do it here.
			bool unbroken = true
			int insideCount = 0
			; Loop to repeatedly check to see if top spell is unlearnable.
			; If it is, move it to the bottom of the list and keep checking
			; until it is learnable or we have exhausted the list.
			While (unbroken)
				bool foundLearnableSpell = false
				sp = spell_fifo_peek(currentSpell)
				if(cannotLearn(sp, currentSpell) && _LEARN_TooDifficultEnabled.GetValue() == 1)
					MoveSpellToBottom(currentSpell)
					Debug.Notification(formatString1(__l("notification_impossible_spell", "{0} is too difficult. Trying other spells first."), sp.GetName()))
					insideCount = insideCount + 1
					; test to see if we've iterated through the whole list, meaning all spells are too hard.
					if ((currentSpell+insideCount) >= spell_fifo_get_count())
						; if we have, then break the loop to prevent an endless loop.
						unbroken = false
					endIf
				else
					; If we find one that is learnable, learn it and break the loop.
					unbroken = false
					foundLearnableSpell = true
				endIf
				if (!foundLearnableSpell && ((currentSpell+insideCount) >= spell_fifo_get_count()))
					; if we didn't find a learnable spell in the entire list,
					; put on the emergency breaks to prevent outer loop from going again
					; which would spam failure messages exponentially
					emergencyBreaks = true
				elseIf(foundLearnableSpell)
					tryLearnSpell(sp, currentSpell, false)
				endIf
			endWhile
			currentSpell = currentSpell + 1
		endWhile
    endIf
    
	; random discovery
    if (True)
        tryInventSpell()
    endif
    
    ; reset counters and limits for the day
    if (True)
        _LEARN_CountAlteration.SetValue(0.0)
        _LEARN_CountConjuration.SetValue(0.0)
        _LEARN_CountDestruction.SetValue(0.0)
        _LEARN_CountIllusion.SetValue(0.0)
        _LEARN_CountRestoration.SetValue(0.0)
        _LEARN_CountBonus.SetValue(0.0)
		_LEARN_AlreadyUsedTutor.SetValue(0)
    endif

    ; dreams
    if (true)
		float fRand = 1
        fRand = Utility.RandomFloat(0.0, 1.0)
        if (fRand < 0.01)
            Debug.Notification(__l("notification_dreamt_Julianos", "You dreamt that Julianos was watching over you."))
            _LEARN_CountBonus.SetValue(100)
        ElseIf (fRand < 0.02)
            Debug.Notification(__l("notification_dreamt_flying", "You dreamt that you were flying over Solstheim."))
            _LEARN_CountBonus.SetValue(30)
        ElseIf (fRand < 0.03)
            Debug.Notification(__l("notification_dreamt_exam", "You had a nightmare about being lost forever in a plane of Oblivion."))
            _LEARN_CountBonus.SetValue(-40)
        endif
    endif
    
	; chance to heal Dreadstare disease
    if (PlayerRef.HasSpell(_LEARN_DiseaseDreadmilk))
		float fRand = 0
		fRand = Utility.RandomFloat(0.0, 1.0)
		if (fRand > (0.2 - 0.1*_LEARN_consecutiveDreadmilk.GetValue()))
			Debug.Notification(__l("notification_no_more_dreadmilk_addiction", "You're finally starting to feel your dreadmilk craving wane."))
			PlayerRef.RemoveSpell(_LEARN_DiseaseDreadmilk)
		endif
    endif
	
EndEvent

; === Spell Discovery
String function topSchoolToday()
    string magicSchool
    if (_LEARN_ForceDiscoverSchool.GetValue() != 0)
        magicSchool = aSchools[_LEARN_ForceDiscoverSchool.GetValueInt()]
    else
        ; Determine the school PC most used today
        magicSchool = SPELL_SCHOOL_RESTORATION ; default to Restoration just because.
        float fTopCount = _LEARN_CountRestoration.getvalue()
        aInventSpellsPtr = aRestorationLL
        if (_LEARN_CountDestruction.GetValue() > fTopCount)
            magicSchool = SPELL_SCHOOL_DESTRUCTION
        EndIf
        if (_LEARN_CountConjuration.GetValue() > fTopCount)
            magicSchool = SPELL_SCHOOL_CONJURATION
        EndIf
        if (_LEARN_CountAlteration.GetValue() > fTopCount)
            magicSchool = SPELL_SCHOOL_ALTERATION
        EndIf
        if (_LEARN_CountIllusion.GetValue() > fTopCount)
            magicSchool = SPELL_SCHOOL_ILLUSION
        EndIf
    endif

    if magicSchool == SPELL_SCHOOL_ALTERATION
        aInventSpellsPtr = aAlterationLL
    elseIf magicSchool == SPELL_SCHOOL_CONJURATION
        aInventSpellsPtr = aConjurationLL
    elseIf magicSchool == SPELL_SCHOOL_DESTRUCTION
        aInventSpellsPtr = aDestructionLL
    elseIf magicSchool == SPELL_SCHOOL_ILLUSION
        aInventSpellsPtr = aIllusionLL
    elseIf magicSchool == SPELL_SCHOOL_RESTORATION 
        aInventSpellsPtr = aRestorationLL
    endIf
    
    return magicSchool
EndFunction

Spell function tryInventSpell()
        String sSchool = topSchoolToday()
        float fSkill = PlayerRef.GetActorValue(sSchool)
        float baseChance = baseChanceToDiscover(sSchool)
        

        float fRand = Utility.RandomFloat(0.0, 1.0) 
        if (fRand > baseChance) 
            ; Spell discovery failure ! 
            Return None
        EndIf
        
        int llidx
        if (fskill < 25)
            llidx = 0
        elseif (fskill < 50)
            llidx = 1
        elseif (fskill < 75)
            llidx = 2
        Else
            llidx = 3
        EndIf
        LeveledItem ll = aInventSpellsPtr[llidx]
        int llcount = ll.GetNumForms()
        int limit = 10
        int spidx = Utility.RandomInt(0, llcount - 1)

        Book inventedbook = ll.GetNthForm(spidx) as Book
        Spell inventedsp = inventedbook.getspell()
        
        if inventedsp == None
            ;Debug.Notification(__l("notification_spell_invention_bug", "Bug in spell invention, boy"))
            return None
        endif
        
        while (inventedsp && (PlayerRef.HasSpell(inventedsp) || spell_fifo_has_ref(inventedsp)) && limit > 0)
            spidx = (spidx + 1) % llcount
            inventedbook = ll.GetNthForm(spidx) as Book
            inventedsp = inventedbook.getspell()
            limit -=1
        EndWhile
        
        if (inventedsp && (! (PlayerRef.HasSpell(inventedsp) || spell_fifo_has_ref(inventedsp))))
            Debug.Notification(formatString1(__l("notification_new_spell_idea", "An idea for a new spell came to you in a dream: {0}"), inventedsp.GetName()))
            spell_fifo_push(inventedsp)
            Bookextension.setreadWFB(inventedbook, true)
        EndIf
        
EndFunction

; === Spell Book management
function TryAddSpellBook(Book akBook, Spell sp, int aiItemCount)
    ; maybe remove book
    if (_LEARN_RemoveSpellBooks.GetValue() != 0)
        PlayerRef.removeItem(akBook, aiItemCount, !VisibleNotifications[NOTIFICATION_REMOVE_BOOK])
    EndIf
	; maybe add notes
	if (_LEARN_CollectNotes.GetValue() != 0)
		Int value = akBook.GetGoldValue()
		MagicEffect eff = sp.GetNthEffectMagicEffect(0)
		String magicSchool = eff.GetAssociatedSkill() 
		if magicSchool == SPELL_SCHOOL_ALTERATION
			PlayerRef.addItem(_LEARN_SpellNotesAlteration, value, !VisibleNotifications[NOTIFICATION_ADD_SPELL_NOTE]) 
		elseIf magicSchool == SPELL_SCHOOL_CONJURATION
			PlayerRef.addItem(_LEARN_SpellNotesConjuration, value, !VisibleNotifications[NOTIFICATION_ADD_SPELL_NOTE])
		elseIf magicSchool == SPELL_SCHOOL_DESTRUCTION
			PlayerRef.addItem(_LEARN_SpellNotesDestruction, value, !VisibleNotifications[NOTIFICATION_ADD_SPELL_NOTE]) 
		elseIf magicSchool == SPELL_SCHOOL_ILLUSION
			PlayerRef.addItem(_LEARN_SpellNotesIllusion, value, !VisibleNotifications[NOTIFICATION_ADD_SPELL_NOTE])
		elseIf magicSchool == SPELL_SCHOOL_RESTORATION
			PlayerRef.addItem(_LEARN_SpellNotesRestoration, value, !VisibleNotifications[NOTIFICATION_ADD_SPELL_NOTE])
		endIf
	endIf
	
    ; add spell to the todo list if not already known or in list
	if (!PlayerRef.HasSpell(sp) && !spell_fifo_has_ref(sp))
		spell_fifo_push(sp)
		if (canAutoLearn(sp, spell_fifo_get_ref(sp)) && _LEARN_AutoNoviceLearningEnabled.GetValue() == 1)
			; if the spell is eligible for automatic success, move it to the top of the list.
			MoveSpellToTop(spell_fifo_get_ref(sp))
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
