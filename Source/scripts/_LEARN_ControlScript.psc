ScriptName _LEARN_ControlScript extends Quest ; conditional

globalvariable property _LEARN_CountAlteration auto
globalvariable property _LEARN_CountConjuration auto
globalvariable property _LEARN_CountDestruction auto
globalvariable property _LEARN_CountIllusion auto
globalvariable property _LEARN_CountRestoration auto
globalvariable property _LEARN_CountBonus auto
globalvariable property _LEARN_MinChanceStudy auto
globalvariable property _LEARN_MaxChanceStudy auto
globalvariable property _LEARN_MinChanceDiscover auto
globalvariable property _LEARN_MaxChanceDiscover auto
globalvariable property _LEARN_BonusScale auto
globalvariable property _LEARN_MaxFailsBeforeCycle auto
globalvariable property _LEARN_RemoveSpellBooks auto
globalvariable property _LEARN_CollectNotes auto
globalvariable property _LEARN_ForceDiscoverSchool auto
globalvariable property _LEARN_StudyInterval auto

keyword property LocTypeTemple auto
location property WinterholdCollegeLocation auto
location property customLocation auto

actor property PlayerRef auto
Book property _LEARN_SpellNotesAlteration auto
Book property _LEARN_SpellNotesConjuration auto
Book property _LEARN_SpellNotesDestruction auto
Book property _LEARN_SpellNotesIllusion auto
Book property _LEARN_SpellNotesRestoration auto
MagicEffect Property AlchDreadmilkEffect Auto
MagicEffect Property AlchShadowmilkEffect Auto
Spell Property Dreadstare Auto
Spell property dreadstareJustAdded auto
Book Property _LEARN_SpiritTutorSpell Auto

leveleditem property LitemSpellTomes00Alteration Auto
leveleditem property LitemSpellTomes00Conjuration Auto
leveleditem property LitemSpellTomes00Destruction Auto
leveleditem property LitemSpellTomes00Illusion Auto
leveleditem property LitemSpellTomes00Restoration Auto
leveleditem property LitemSpellTomes25Alteration Auto
leveleditem property LitemSpellTomes25Conjuration Auto
leveleditem property LitemSpellTomes25Destruction Auto
leveleditem property LitemSpellTomes25Illusion Auto
leveleditem property LitemSpellTomes25Restoration Auto
leveleditem property LitemSpellTomes50Alteration Auto
leveleditem property LitemSpellTomes50Conjuration Auto
leveleditem property LitemSpellTomes50Destruction Auto
leveleditem property LitemSpellTomes50Illusion Auto
leveleditem property LitemSpellTomes50Restoration Auto
leveleditem property LitemSpellTomes75Alteration Auto
leveleditem property LitemSpellTomes75Conjuration Auto
leveleditem property LitemSpellTomes75Destruction Auto
leveleditem property LitemSpellTomes75Illusion Auto
leveleditem property LitemSpellTomes75Restoration Auto


Float LastSleepTime
FormList AlterationSpells
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

bool property CanUseLocalizationLib = false Auto;
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

int function GetVersion()
    return 172; v 1.7.2
endFunction

function UpgradeVersion()
    if (currentVersion < 172)
        VisibleNotifications = new int[2]
        VisibleNotifications[NOTIFICATION_REMOVE_BOOK] = 0 
        VisibleNotifications[NOTIFICATION_ADD_SPELL_NOTE] = 1
        UpgradeSpellList()
        string msg = "[Spell Learning] " + formatString1(__l("version_upgrade", "Installed version {0}"), "1.7.2")
        Debug.Notification(msg)
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
    aSchools[0] = __l("Automatic"); added here for mid-game localization support
    _canSetBookAsRead = SKSE.GetPluginVersion("BookExtension") != -1
    UpgradeVersion()
endFunction

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


int function spell_fifo_get_count()
    return iCount
EndFunction

bool function spell_fifo_has_ref(Spell sp)
    return iCount > 0 && _spells.Find(sp as Form) >= 0
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

Spell function spell_fifo_squeeze(Spell s)
{Obsolete}
    ; insert to the top. we don't use it. if implementation needed just add and movetotop
    return None
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

bool function TryLearnSpellAt(int index)
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

String[] function getSchools()
    return aSchools
EndFunction


function AddSpellsToLists()
    Book x
    int i = LitemSpellTomes00Conjuration.GetNumForms()
    While (i > 0)
        x = LitemSpellTomes00Conjuration.GetNthForm(i) as Book
        if (x == _LEARN_SpiritTutorSpell)
            Return
        EndIf
        i = i - 1
    EndWhile
    
    LitemSpellTomes00Conjuration.addform(_LEARN_SpiritTutorSpell, 1, 1)
    
EndFunction


function OnInit()
    
    GlobalVariable GameHour = Game.GetForm(0x00000038) as GlobalVariable
    ;customLocation = None
    ;dreadstareJustAdded = None
    ;aSpells = new Spell[128]
    ;iHead = 0
    ;iTail = 0
    ;iMaxSize = 128
    ;iCount = 0
    ;LastSleepTime = 0
    ;iFailuresToLearn = 0
    
    AddSpellsToLists()
    
    aSchools = new String[6]
    aSchools[0] = __l("Automatic")
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

float function scurve(float x, float minchance, float maxchance)
    ; returns a nice s-shaped learning curve between x = y = 1
    ; https://www.desmos.com/calculator
    ; \left(1-\frac{1}{\left(\left(2x\right)^3+1\right)}\right)\cdot 0.98+0.01
    float y = (minchance + (maxchance - minchance) * (1 - (1 / (1 + (8*x*x*x)))))
    if (y < minchance)
        return minchance
    ElseIf (y > maxchance)
        return maxchance
    Else
        return y
    EndIf 
EndFunction

float function capFormula(float skill, float casts, float notes)
    float result

    ; so normalize the accumulated learning notes
    ; some mods alter the spell tome values. Let's try to be consistent across load orders
    Book refCandleLight = Game.GetForm(0x0009E2A7) as Book
    float priceFactor = refCandleLight.GetGoldValue() / 44
    notes = notes / pricefactor

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

    float mycasts = casts ; maximum 100
    if (mycasts > 100)
        mycasts = 100
    endif
 
    float mybonus = 0 ; out of 100
    ; Count in the bonus added by other scripts
    mybonus += _LEARN_CountBonus.GetValue()
    
    ; Amount of spell learning notes in inventory provide bonus (diminishing returns)
    float bnot
    bnot = Math.sqrt(notes)
    if (bnot > 30)
        bnot = 30
    EndIf
    mybonus += bnot
    
    ; Check for alchemical drugs
    if (PlayerRef.HasMagicEffect(AlchDreadmilkEffect)) ; dreadmilk
        mybonus += 105
    elseif (PlayerRef.HasMagicEffect(AlchShadowmilkEffect)) ; shadowmilk
        mybonus += 70
    endif
    
    ; Check for inspiring location
    Location locationX = PlayerRef.GetCurrentLocation()
    ; Cell myCell = PlayerRef.GetParentCell()
    if (locationX)
        if (locationX.haskeyword(LocTypeTemple) || (customLocation && locationX.isSameLocation(customLocation)))
            mybonus += 55
        elseif (locationX.isSameLocation(WinterholdCollegeLocation) || WinterholdCollegeLocation.ischild(locationX))
            mybonus += 85
        endif
    endIf
    ; Failing to learn also counts as progress, but only if some role playing effort is being made
    if (mybonus >= 10)
        mybonus += iFailuresToLearn * 5
    endif
    ; put a ceiling on that groovy bonus
    ; update: gameplay testing shows a cap is counter intuitive and unfriendly
    ;if (mybonus > 100)
    ;    mybonus = 100
    ;endif
    mybonus = mybonus * _LEARN_BonusScale.GetValue()
    
    
    result = ((myskill - 15) + mycasts + mybonus) / 300
    if (result < 0)
        result = 0
    EndIf
    return result
EndFunction

float function baseChanceBySchool(string magicSchool, float minchance, float maxchance)
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
    fChance = scurve(capFormula(fskill, fcasts, fnotes), minchance / 100, maxchance / 100)
    ; Debug.Notification("baseChance = " + fChance)
    return fChance
EndFunction


float Function baseChanceToStudy(string magicSchool = "")
    if (magicSchool == "")
        if iCount == 0
            return 0
        endif
        Spell sp = spell_fifo_peek()
        if (sp == None)
            return 1
        endif
        Magiceffect me = sp.GetNthEffectMagicEffect(0)
        if (me == None)
            return 1
        endif
        magicSchool = me.GetAssociatedSkill()
        if (magicSchool == "")
            return 1
        endif
    endif
    return baseChanceBySchool(magicSchool, _LEARN_MinChanceStudy.GetValue(), _LEARN_MaxChanceStudy.GetValue()) 
EndFunction


float Function baseChanceToDiscover(string magicSchool = "")
    if (magicSchool == "")
        magicSchool = topSchoolToday()
    EndIf
    return baseChanceBySchool(magicSchool, _LEARN_MinChanceDiscover.GetValue(), _LEARN_MaxChanceDiscover.GetValue()) 
EndFunction


float Function hours_before_next_ok_to_learn()
    GlobalVariable GameDaysPassed = Game.GetForm(0x00000039) as GlobalVariable

    float now = GameDaysPassed.GetValue()
    float nextOK = LastSleepTime + _LEARN_StudyInterval.GetValue();
    ; default is 0.65
    
    if now >= nextOK
        return 0
    Else
        return ((nextOK - now) * 24)
    endif
EndFunction

Event OnSleepStop(Bool abInterrupted)
    
    ; Do nothing if was already called too recently. 
    if (hours_before_next_ok_to_learn() > 0)
        Return
    EndIf


    if (abInterrupted)
        Debug.Notification(__l("notification_spell learning interrupted", "Interrupted spell learning"))
        Return
    endif

    GlobalVariable GameDaysPassed = Game.GetForm(0x00000039) as GlobalVariable
    LastSleepTime = GameDaysPassed.GetValue()


    
    AddSpellsToLists()
    

    Float fRand
    float fChance
    Spell sp
    MagicEffect eff
    
    if (iCount > 0)
        ; Try to learn the player's first "todo list" spell
        sp = spell_fifo_peek()
        if (! sp)
            Debug.MessageBox(__l("message_spell learning bad reference", "[Spell learning] Bad reference in spell list, dropped"))
            spell_fifo_pop() ; TODO something better to handle spell mod disappearance ?
            return
        endif
        Debug.Notification(formatString1(__l("notification_studying spell", "Studying {0}..."), sp.GetName()))
        String magicSchool = SPELL_SCHOOL_DESTRUCTION
        eff = sp.GetNthEffectMagicEffect(0) 
        if (!eff)
            Debug.Notification(__l("notification_unknown spell", "Strange spell in learning list, assuming Destruction school"))
        else
            magicSchool = eff.GetAssociatedSkill()  
        endif
        fChance = baseChanceToStudy(magicSchool)
        fRand = Utility.RandomFloat(0.0, 1.0) 
        if ((fRand < fChance) || PlayerRef.HasSpell(sp)) 
            ; Spell learning success ! 
            PlayerRef.AddSpell(sp) 
            spell_fifo_pop() 
            iFailuresToLearn = 0 
        Else 
            iFailuresToLearn = iFailuresToLearn + 1

            ; rotate the spell to learn not to be stuck on a failure 
            ; (later) I'm removing this "feature" that is confusing and unnecessary since the implementation of
            ; a complete and user-controlled toto list management system in the MCM
            ; if (iFailuresToLearn >= _LEARN_MaxFailsBeforeCycle.GetValue())
            ;     Debug.Notification("Learning " + sp.GetName() + " is too difficult")
            ;     sp = spell_fifo_pop() 
            ;     spell_fifo_push(sp)
            ;     sp = spell_fifo_peek()
            ;     Debug.Notification("Let's try " + sp.GetName())
            ; EndIf 
        EndIf     
    EndIf
    
    ; self discovery of spells
    if (True)
        tryInventSpell()
    endif
    
    
    ; reset counters for the day
    if (True)
        _LEARN_CountAlteration.SetValue(0.0)
        _LEARN_CountConjuration.SetValue(0.0)
        _LEARN_CountDestruction.SetValue(0.0)
        _LEARN_CountIllusion.SetValue(0.0)
        _LEARN_CountRestoration.SetValue(0.0)
        _LEARN_CountBonus.SetValue(0.0)
    endif

    ; dreams
    if (true)
        fRand = Utility.RandomFloat(0.0, 1.0)
        if (fRand < 0.01)
            Debug.Notification(__l("notification_dreamt Julianos", "Dreamt that Julianos was watching me."))
            _LEARN_CountBonus.SetValue(100)
        ElseIf (fRand < 0.02)
            Debug.Notification(__l("notification_dreamt flying", "Dreamt that I was flying over the landscape."))
            _LEARN_CountBonus.SetValue(30)
        ElseIf (fRand < 0.03)
            Debug.Notification(__l("notification_dreamt exam", "Dreamt of an exam at the College of Winterhold."))
            _LEARN_CountBonus.SetValue(-40)
        endif
    endif
    
    ; low chance to heal Dreadstare disease
    if (PlayerRef.HasSpell(Dreadstare))
        if (dreadstareJustAdded != None)
            dreadstareJustAdded = None
        else
            fRand = Utility.RandomFloat(0.0, 1.0)
            if (fRand > 0.9)
                Debug.Notification(__l("notification_no more dreadmik addiction", "I no longer feel a Dreadmilk addiction"))
                PlayerRef.RemoveSpell(Dreadstare)
            else
                Debug.Notification(__l("notification_need a sip of dreadmilk", "I need a sip of Dreadmilk"))
            endif
        endif
    endif

EndEvent


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
            Debug.Notification(__l("notification_spell invention bug", "Bug in spell invention, boy"))
            return None
        endif
        
        while (inventedsp && (PlayerRef.HasSpell(inventedsp) || spell_fifo_has_ref(inventedsp)) && limit > 0)
            spidx = (spidx + 1) % llcount
            inventedbook = ll.GetNthForm(spidx) as Book
            inventedsp = inventedbook.getspell()
            limit -=1
        EndWhile
        
        if (inventedsp && (! (PlayerRef.HasSpell(inventedsp) || spell_fifo_has_ref(inventedsp))))
            Debug.Notification(__l("notification_new spell idea", "Had an idea for a new spell"))
            Debug.Notification(inventedsp.GetName())
            spell_fifo_push(inventedsp)
            Bookextension.setreadWFB(inventedbook, true)
        EndIf
        
EndFunction

function TryAddSpellBook(Book akBook, Spell sp, int aiItemCount)
    if spell_fifo_has_ref(sp)
        return
    endIf
    ;bool knowsSpell = PlayerRef.HasSpell(sp) 
    if PlayerRef.HasSpell(sp)
        return
    endIf
    
    bool isRead = akBook.isRead()
    ; maybe remove book
    if (_LEARN_RemoveSpellBooks.GetValue() != 0)
        PlayerRef.removeItem(akBook, aiItemCount, !VisibleNotifications[NOTIFICATION_REMOVE_BOOK])
    EndIf
    
    ; maybe add notes
    if (!isRead && _LEARN_CollectNotes.GetValue() != 0)
        Int value = akBook.GetGoldValue()
        
        MagicEffect eff = sp.GetNthEffectMagicEffect(0)
        String magicSchool = eff.GetAssociatedSkill() 
        ; Debug.Notification(magicSchool) 
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

    ; add spell to the todo list
    spell_fifo_push(sp)
    if _canSetBookAsRead && !isRead
        Bookextension.SetReadWFB(akBook, true)
    endIf

endFunction