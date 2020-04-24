ScriptName _LEARN_enthirChestAlias extends ReferenceAlias

_LEARN_ControlScript property ControlScript auto
GlobalVariable property _LEARN_SpawnItems auto
GlobalVariable property _LEARN_EnthirSells auto
ObjectReference property MerchantWCollegeEnthirChest auto
;GlobalVariable property GameDaysPassed auto

Ingredient property MoonSugar auto
Potion property RestoreHealth03 auto
Ingredient property Mushroom03 auto
Ingredient property Nightshade auto
Potion property RestoreMagicka01 auto
Potion property _LEARN_Dreadmilk auto
Potion property _LEARN_Shadowmilk auto
Book property _LEARN_DreadmilkRecipeBook auto
Book property _LEARN_ShadowmilkRecipeBook auto
Book property _LEARN_SpellTomeSummonSpiritTutor auto

ObjectReference chest

Event OnInit()
    chest = MerchantWCollegeEnthirChest
    if (_LEARN_EnthirSells.GetValue() == 1)
        if (chest.GetItemCount(_LEARN_DreadmilkRecipeBook) == 0)
            chest.AddItem(_LEARN_DreadmilkRecipeBook, 1, true)
        endIf
        if (chest.GetItemCount(_LEARN_ShadowmilkRecipeBook) == 0)
            chest.AddItem(_LEARN_ShadowmilkRecipeBook, 1, true)
        endIf
        if (chest.GetItemCount(_LEARN_SpellTomeSummonSpiritTutor) == 0)
            chest.AddItem(_LEARN_SpellTomeSummonSpiritTutor, 1, true)
        endIf
    endIf
    OnUpdateGameTime()
endEvent

Event OnUpdateGameTime()
    chest = MerchantWCollegeEnthirChest
    ; Only if SpawnItems setting is enabled
    if (_LEARN_EnthirSells.GetValue() == 1)
        ; If sold some shadowmilk/dreadmilk, replenish by 1 per day
        if (chest.GetItemCount(_LEARN_Dreadmilk) < 3)
            chest.AddItem(_LEARN_Dreadmilk, 1, true)
        endIf
        if (chest.GetItemCount(_LEARN_Shadowmilk) < 3)
            chest.AddItem(_LEARN_Shadowmilk, 1, true)
        endIf
        ; Replenish ingredients
        if (chest.GetItemCount(MoonSugar) < 12)
            chest.AddItem(MoonSugar, 1, true)
        endIf
        if (chest.GetItemCount(RestoreHealth03) < 6)
            chest.AddItem(RestoreHealth03, 1, true)
        endIf
        if (chest.GetItemCount(Mushroom03) < 12)
            chest.AddItem(Mushroom03, 2, true)
        endIf
        if (chest.GetItemCount(Nightshade) < 12)
            chest.AddItem(Nightshade, 2, true)
        endIf
        if (chest.GetItemCount(RestoreMagicka01) < 6)
            chest.AddItem(RestoreMagicka01, 1, true)
        endIf
    else
        RemoveItems()
    endIf

    RegisterForSingleUpdateGameTime(24)
endEvent

function RemoveItems()
    chest = MerchantWCollegeEnthirChest
    ; Remove any items we might have added
    chest.RemoveItem(_LEARN_Dreadmilk, chest.GetItemCount(_LEARN_Dreadmilk), true)
    chest.RemoveItem(_LEARN_Shadowmilk, chest.GetItemCount(_LEARN_Shadowmilk), true)
    chest.RemoveItem(_LEARN_DreadmilkRecipeBook, chest.GetItemCount(_LEARN_DreadmilkRecipeBook), true)
    chest.RemoveItem(_LEARN_ShadowmilkRecipeBook, chest.GetItemCount(_LEARN_ShadowmilkRecipeBook), true)
    chest.RemoveItem(_LEARN_SpellTomeSummonSpiritTutor, chest.GetItemCount(_LEARN_SpellTomeSummonSpiritTutor), true)
endFunction

Event OnReset()
    if (_LEARN_EnthirSells.GetValue() == 1)
        OnInit()
    else
        RemoveItems()
    endIf
EndEvent