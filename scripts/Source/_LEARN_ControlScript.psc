ScriptName _LEARN_ControlScript extends Quest ; conditional

;-- Properties --------------------------------------
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

keyword property LocTypeTemple auto
location property WinterholdCollegeLocation auto

actor property PlayerRef auto
Book property _LEARN_SpellNotesAlteration auto
Book property _LEARN_SpellNotesConjuration auto
Book property _LEARN_SpellNotesDestruction auto
Book property _LEARN_SpellNotesIllusion auto
Book property _LEARN_SpellNotesRestoration auto
MagicEffect Property AlchDreadmilkEffect Auto
MagicEffect Property AlchShadowmilkEffect Auto
Spell Property _LEARN_SpiritTutorSpell Auto

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

;-- Variables ---------------------------------------
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
int iTail
int iMaxSize
int iCount

;-- Functions ---------------------------------------

Spell function spell_fifo_peek(int idx = 0)
    if (iCount <= idx)
        return None
    endif
    return aSpells[(iHead + idx) % iMaxSize]
EndFunction

Spell function spell_fifo_push(Spell s)
    ; Debug.Notification("Fifo_Push " + s.GetName())
    if (iCount < iMaxSize)
        aSpells[iTail] = s
        iTail = iTail + 1
        iCount = iCount + 1
        if (iTail == iMaxSize)
            iTail = 0
        EndIf
        return s
    EndIf
    return None
EndFunction

Spell function spell_fifo_pop()
    Spell tmp
    if (iCount > 0)
        tmp = aSpells[iHead]
        aSpells[iHead] = None
        iHead = iHead + 1
        iCount = iCount - 1
        if (iHead == iMaxSize)
            iHead = 0
        EndIf
        return tmp
    EndIf
    return None
EndFunction


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


function OnInit()
    
    GlobalVariable GameHour = Game.GetForm(0x00000038) as GlobalVariable
    aSpells = new Spell[128]
    iHead = 0
    iTail = 0
    iMaxSize = 128
    iCount = 0
    LastSleepTime = 0
    iFailuresToLearn = 0
    
    LitemSpellTomes00Conjuration.addform(_LEARN_SpiritTutorSpell, 1, 1)
    
    aSchools = new String[6]
    aSchools[0] = "Automatic"
    aSchools[1] = "Alteration"
    aSchools[2] = "Conjuration"
    aSchools[3] = "Destruction"
    aSchools[4] = "Illusion"
    aSchools[5] = "Restoration"
    
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

    float myskill = 0 ; out of 100
    int i = 1
    ; Calculate the mean skill over all magic schools
    while (i <= 5)
        myskill += PlayerRef.GetAV(aSchools[i]) / 5
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
    mybonus += (1 - (1 / (notes/1000 + 1)))
    ; Check for alchemical drugs
    if (PlayerRef.HasMagicEffect(AlchDreadmilkEffect)) ; dreadmilk
        mybonus += 65
    elseif (PlayerRef.HasMagicEffect(AlchShadowmilkEffect)) ; shadowmilk
        mybonus += 35
    endif
    ; Check for inspiring location
    Location locationX = PlayerRef.GetCurrentLocation()
    ; Cell myCell = PlayerRef.GetParentCell()
    if (locationX.haskeyword(LocTypeTemple))
        mybonus += 55
    elseif (locationX == WinterholdCollegeLocation)
        mybonus += 85
    endif
    ; put a ceiling on that groovy bonus
    if (mybonus > 100)
        mybonus = 100
    endif
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
    fskill = PlayerRef.GetAv(magicSchool)
    if magicSchool == aSchools[1]
        fcasts = _LEARN_CountAlteration.GetValue()
        fnotes = PlayerRef.GetItemCount(_LEARN_SpellNotesAlteration)
    elseIf magicSchool == aSchools[2]
        fcasts = _LEARN_CountConjuration.GetValue()
        fnotes = PlayerRef.GetItemCount(_LEARN_SpellNotesConjuration)
    elseIf magicSchool == aSchools[3]
        fcasts = _LEARN_CountDestruction.GetValue()
        fnotes = PlayerRef.GetItemCount(_LEARN_SpellNotesDestruction)
    elseIf magicSchool == aSchools[4]
        fcasts = _LEARN_CountIllusion.GetValue()
        fnotes = PlayerRef.GetItemCount(_LEARN_SpellNotesIllusion)
    elseIf magicSchool == aSchools[5]
        fcasts = _LEARN_CountRestoration.GetValue()
        fnotes = PlayerRef.GetItemCount(_LEARN_SpellNotesRestoration)
    endIf    
    fChance = scurve(capFormula(fskill, fcasts, fnotes), minchance / 100, maxchance / 100)
    ; Debug.Notification("baseChance = " + fChance)
    return fChance
EndFunction


float Function baseChanceToStudy(string magicSchool = "")
    if (magicSchool == "")
        Spell sp = spell_fifo_peek()
        if (sp == None)
            return 0
        endif
        Magiceffect me = sp.GetNthEffectMagicEffect(0)
        if (me == None)
            return 0
        endif
        magicSchool = me.GetAssociatedSkill()
        if (magicSchool == "")
            return 0
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


Event OnSleepStop(Bool abInterrupted)
    if (abInterrupted)
        Debug.Notification("Interrupted spell learning")
        Return
    endif
    GlobalVariable GameDaysPassed = Game.GetForm(0x00000039) as GlobalVariable
    ; Do nothing if was already called too recently. 
    ; Study intervals need to be in the vicinity of 1 day
    if (GameDaysPassed.GetValue() < LastSleepTime + 0.90)
        ;Return
    EndIf
    
    Float fRand
    float fChance
    Spell sp
    MagicEffect eff
    
    if (iCount > 0)
        ; Try to learn the player's first "todo list" spell
        sp = spell_fifo_peek()
        if (! sp)
            Debug.MessageBox("[Spell learning] Bad reference in spell list, dropped")
            spell_fifo_pop() ; TODO something better to handle spell mod disappearance ?
            return
        endif
        Debug.Notification("Studying " + sp.GetName() + "...")
        String magicSchool = aSchools[3]
        eff = sp.GetNthEffectMagicEffect(0) 
        if (!eff)
            Debug.Notification("Strange spell in learning list, assuming Destruction school")
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
            ; rotate the spell to learn not to be stuck on a failure 
            if (iFailuresToLearn >= _LEARN_MaxFailsBeforeCycle.GetValue())
                Debug.Notification("Learning " + sp.GetName() + " is too difficult")
                sp = spell_fifo_pop() 
                spell_fifo_push(sp)
                sp = spell_fifo_peek()
                Debug.Notification("Let's try " + sp.GetName())
            EndIf 
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
            Debug.Notification("Dreamt that Julianos was watching me.")
            _LEARN_CountBonus.SetValue(100)
        ElseIf (fRand < 0.02)
            Debug.Notification("Dreamt that I was flying over the landscape.")
            _LEARN_CountBonus.SetValue(30)
        ElseIf (fRand < 0.03)
            Debug.Notification("Dreamt of an exam at the College of Winterhold.")
            _LEARN_CountBonus.SetValue(-40)
        endif
    endif
    
    LastSleepTime = GameDaysPassed.GetValue()
EndEvent


String function topSchoolToday()
    string magicSchool
    if (_LEARN_ForceDiscoverSchool.GetValue() != 0)
        magicSchool = aSchools[_LEARN_ForceDiscoverSchool.GetValueInt()]
    else
        ; Determine the school PC most used today
        magicSchool = aSchools[5] ; default to Restoration just because.
        float fTopCount = _LEARN_CountRestoration.getvalue()
        aInventSpellsPtr = aRestorationLL
        if (_LEARN_CountDestruction.GetValue() > fTopCount)
            magicSchool = aSchools[3]
        EndIf
        if (_LEARN_CountConjuration.GetValue() > fTopCount)
            magicSchool = aSchools[2]
        EndIf
        if (_LEARN_CountAlteration.GetValue() > fTopCount)
            magicSchool = aSchools[1]
        EndIf
        if (_LEARN_CountIllusion.GetValue() > fTopCount)
            magicSchool = aSchools[4]
        EndIf
    endif

    if magicSchool == aSchools[1]
        aInventSpellsPtr = aRestorationLL
    elseIf magicSchool == aSchools[2] 
        aInventSpellsPtr = aConjurationLL
    elseIf magicSchool == aSchools[3] 
        aInventSpellsPtr = aDestructionLL
    elseIf magicSchool == aSchools[4]
        aInventSpellsPtr = aIllusionLL
    elseIf magicSchool == aSchools[5] 
        aInventSpellsPtr = aRestorationLL
    endIf
    
    return magicSchool
EndFunction


Spell function tryInventSpell()
        String sSchool = topSchoolToday()
        float fSkill = PlayerRef.GetAV(sSchool)
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

        Spell inventedsp = ll.GetNthForm(spidx) as Spell
        while (inventedsp && PlayerRef.HasSpell(inventedsp) && limit > 0)
            spidx = (spidx + 1) % llcount
            inventedsp = ll.GetNthForm(spidx) as Spell
            limit -=1
        EndWhile
        
        if (inventedsp && (! PlayerRef.HasSpell(inventedsp)))
            Debug.Notification("Discovered a new spell")
            PlayerRef.AddSpell(inventedsp)
        EndIf
        
EndFunction
