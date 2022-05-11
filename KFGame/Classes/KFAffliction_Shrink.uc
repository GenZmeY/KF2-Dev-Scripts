//=============================================================================
// KFAffliction_Shrink
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFAffliction_Shrink extends KFAfflictionAdvanced;

var() float ScaleOnMaxEffect;
var() float EffectAppliedByStack;
var() float MaxEffectDamageValue;
var() float ApplyEffectVel;
var() float RemoveEffectVel;
var() float StackDamageModifier;
var() byte  MaxEffect;

var transient float CurrentEffect;
var transient float CurrentEffectApplied;
var transient KFPlayerController Instigator;
var transient bool bIsTinyTerrorMode;

var transient bool AlreadyCached;
var transient float CachedBodyScaleChangePerSecond;
var transient float CachedBodyScale;

function Init(KFPawn P, EAfflictionType Type, KFPerk InstigatorPerk)
{
    local KFGameReplicationInfo KFGRI;

	Super.Init(P, Type, InstigatorPerk);

    if (InstigatorPerk != none)
    {
        Instigator = InstigatorPerk.OwnerPC;
    }

    if (AlreadyCached == false)
    {
        // (see KFPawn_ZedMatriarch.uc)
        // There are some systems directly calling Init again without letting the Affliction Manager know
        // That is a hack, but we can't improve it at this stage, so catch that here only once
        AlreadyCached = true;

        CachedBodyScaleChangePerSecond  = P.BodyScaleChangePerSecond;
        CachedBodyScale                 = P.Mesh.Scale;
    }

    KFGRI = KFGameReplicationInfo(P.WorldInfo.GRI);
    if (KFGRI != none && KFGRI.bIsWeeklyMode)
    {
        bIsTinyTerrorMode = KFGRI.CurrentWeeklyIndex == 2;
    }
}

function Activate(optional class<KFDamageType> DamageType = none)
{
    local float StackModifier;

    if (bIsTinyTerrorMode)
    {
        return;
    }
    
    if (CurrentEffect < MaxEffect)
    {
        Super.Activate();

        StackModifier = 1.0f;

        if (KFPawn_Monster(PawnOwner) != none)
        {
            StackModifier = KFPawn_Monster(PawnOwner).ShrinkEffectModifier;
        }

        // Allow body to shrink visually faster
        if (StackModifier >= 1.0f)
        {
            PawnOwner.BodyScaleChangePerSecond = CachedBodyScaleChangePerSecond * StackModifier;
            PawnOwner.bNetDirty = true;
        }

        CurrentEffect += EffectAppliedByStack * StackModifier;
    }
    
    if (CurrentEffectApplied >= MaxEffect)
    {
        CurrentEffectApplied = MaxEffect;

        KillOwner();
    }
}

event Tick(float DeltaTime)
{
    if ( PawnOwner.bPlayedDeath )
    {
        CurrentStrength= 0.0f;
        super.Deactivate();
        return;
    }

    if (CurrentEffectApplied != CurrentEffect)
    {
        if (CurrentEffectApplied < CurrentEffect)
        {
            CurrentEffectApplied = FMin(CurrentEffectApplied + DeltaTime * ApplyEffectVel * KFPawn_Monster(PawnOwner).ShrinkEffectModifier, CurrentEffect);
        }
        else
        {
            CurrentEffectApplied = CurrentEffectApplied - DeltaTime * RemoveEffectVel;
        }

        CurrentEffectApplied = FMax(CurrentEffectApplied, 0.f);
        CurrentEffectApplied = FMin(CurrentEffectApplied, MaxEffect);

        // It goes from the Cached Body Scale to CachedBodyScale - 0.5 at 100% affliction
        PawnOwner.IntendedBodyScale = CachedBodyScale - ((CurrentEffectApplied/MaxEffect) * (1.0f - ScaleOnMaxEffect));
    }

    if (CurrentStrength <= 0.0f)
    {
        CurrentEffect = 0;
        CurrentStrength = 0.1f;

        if (CurrentEffectApplied <= 0.0f)
        {
            CurrentStrength = 0.0f;
            PawnOwner.BodyScaleChangePerSecond = CachedBodyScaleChangePerSecond;
            PawnOwner.bNetDirty = true;
            super.Deactivate();
        }
    }
}

function float GetDamageTakenModifier()
{
    return MaxEffectDamageValue * (CurrentEffect/MaxEffect);
}

function KillOwner()
{
    local KFPawn_Monster KFPM;

    KFPM = KFPawn_Monster(PawnOwner);

    if (KFPM == none)
    {
        return;
    }
    
    KFPM.BodyScaleChangePerSecond = CachedBodyScaleChangePerSecond;
    KFPM.bNetDirty = true;

    if (!KFPM.bCanBeKilledByShrinking)
    {
        return;
    }
    
    KFPM.bUseExplosiveDeath = true;
    KFPM.TakeDamage(9999, Instigator, KFPM.Location, vect(0,0,0), class'KFDT_ShrinkDeath',, Instigator.Pawn.Weapon);
}

defaultproperties
{
    DissipationRate=10 //20
    bNeedsTick=true

    MaxEffect=10.f;
    ScaleOnMaxEffect=0.5f
    EffectAppliedByStack=1.0f
    
    ApplyEffectVel=100.0f // % per second
    RemoveEffectVel=0.25f // % per second

    CurrentEffect=0.0f
    CurrentEffectApplied=0.0f

    MaxEffectDamageValue=1.0f

    AlreadyCached = false
}