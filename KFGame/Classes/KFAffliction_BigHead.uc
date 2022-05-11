//=============================================================================
// KFAffliction_BigHead
//=============================================================================
// Affliction for cranial popper
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFAffliction_BigHead extends KFAfflictionAdvanced;

var() float EffectAppliedByStack;
var() float ApplyEffectVel;
var() float RemoveEffectVel;
var() array<float> StackDamageExplosion;
var() byte  MaxStack;
var() byte  MaxStackBobbleHead; 

var transient byte CurrentStack;
var transient float CurrentEffectApplied;
var transient bool bIsBobbleHeadMode; 
var transient bool bIsShrunkenHeads;
var transient byte CurrentMaxStack;

function Init(KFPawn P, EAfflictionType Type, KFPerk InstigatorPerk)
{
    local KFGameReplicationInfo KFGRI;
    local int EndlessWeeklyWaveIdx;
    
	Super.Init(P, Type, InstigatorPerk);

    KFGRI = KFGameReplicationInfo(P.WorldInfo.GRI);

    if (KFGRI != none)
    {
        bIsBobbleHeadMode = (KFGRI.bIsWeeklyMode && KFGRI.CurrentWeeklyIndex == 3) || (KFGRI.IsWeeklyWave(EndlessWeeklyWaveIdx) && EndlessWeeklyWaveIdx == 3);
        bIsShrunkenHeads  = KFGRI.bIsWeeklyMode && KFGRI.CurrentWeeklyIndex == 15;

        if (bIsBobbleHeadMode)
        {
            MaxStack = MaxStackBobbleHead;
        }
    }

    CurrentMaxStack = bIsBobbleHeadMode ? MaxStackBobbleHead : MaxStack;
}

function Activate(optional class<KFDamageType> DamageType = none)
{
    if (CurrentStack < CurrentMaxStack)
    {
        Super.Activate();

        if (!bIsBobbleHeadMode && !bIsShrunkenHeads)
        {
            ++CurrentStack;
        }
    }
}

event Tick(float DeltaTime)
{
    local float Target;

    if ( PawnOwner.bPlayedDeath )
    {
        CurrentStrength= 0.0f;
        super.Deactivate();
        return;
    }

    if (bIsBobbleHeadMode || bIsShrunkenHeads)
    {
        return;
    }

    Target = CurrentStack * EffectAppliedByStack;
    
    if (CurrentEffectApplied != Target)
    {
        if (CurrentEffectApplied < Target)
        {
            CurrentEffectApplied = FMin(CurrentEffectApplied + DeltaTime * ApplyEffectVel, Target);
        }
        else
        {
            CurrentEffectApplied = FMax(CurrentEffectApplied - DeltaTime * ApplyEffectVel, 0.0f);
        }

        PawnOwner.IntendedHeadScale = 1 + CurrentEffectApplied;
        PawnOwner.SetHeadScale(1 + CurrentEffectApplied, PawnOwner.CurrentHeadScale);
        PawnOwner.bNetDirty = true;
    }

    if (CurrentStrength <= 0.0f)
    {
        CurrentStack = 0;
        CurrentStrength = 0.1f;

        if (CurrentEffectApplied <= 0.0f)
        {
            CurrentStrength = 0.0f;
            super.Deactivate();
        }
    }
}

/** Accessor to get known affliction Damage modifier */
function float GetDamageModifier()
{
    local float damage;
    
    damage = bIsBobbleHeadMode ? StackDamageExplosion[MaxStackBobbleHead] : StackDamageExplosion[CurrentStack];

    CurrentStack = 0;

    return damage;
}

defaultproperties
{
    DissipationRate=10
    bNeedsTick=true

    MaxStack=3
    MaxStackBobbleHead=1
    EffectAppliedByStack=0.3f
    
    ApplyEffectVel= 1.0f // % per second
    RemoveEffectVel= 1.0f // % per second

    CurrentStack=0
    CurrentEffectApplied=0.0f

    StackDamageExplosion={(0.0f, 150.0f, 300.0f, 500.0f, 0, 0)};
    
}
