//=============================================================================
// KFWeap_Edged_AbominationAxe
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Edged_Scythe extends KFWeap_MeleeBase;

var const array<MeleeHitBoxInfo> HitboxChainFolded;
var const array<MeleeHitBoxInfo> HitboxChainUnfolded;

var const int MaxHitRangeFolded;
var const int MaxHitRangeUnfolded;

var const int FoldedDamage;
var const int FoldedDamageAlt;

var const int UnfoldedDamage;
var const int UnfoldedDamageAlt;

var const class<DamageType> FoldedDT;
var const class<DamageType> FoldedDTAlt;

var const class<DamageType> UnfoldedDT;
var const class<DamageType> UnfoldedDTAlt;

var const float UnfoldBlendingDuration;

var const float FoldedAttackAnimRate;

var const vector PlayerViewOffsetUnfolded;

var transient vector OriginalPlayerViewOffset;
var transient bool bIsFolded;

var AnimNodeBlendPerBone FoldBlendNode;

var const ParticleSystem BloodParticles;

const BloodParticlesSocket = 'BlockEffect';

var ParticleSystem FoldedTrailParticleSystem;
var ParticleSystem UnfoldedTrailParticleSystem;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();

    OriginalPlayerViewOffset = PlayerViewOffset;
}

event PostBeginPlay()
{
    Super.PostBeginPlay();

    ChangeMode(true, false);

    SetFoldedBladeBlendTarget(1.0f, 0.0f);
}

/////////////////////////////////////////////////////////////////////////////

/** The SkeletalMeshComponents Animations are being instanced from AnimTreeTemplate
* 	before PostInitAnimTree. Be sure to never set the Mesh's animations directly through
*	the package */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	FoldBlendNode = AnimNodeBlendPerBone(SkelComp.FindAnimNode('FoldBlendNode'));

    SetFoldedBladeBlendTarget(1.0f, 0.0f);
}

/////////////////////////////////////////////////////////////////////////////

/** Returns true if weapon can potentially be reloaded */
simulated function bool CanReload(optional byte FireModeNum)
{
	return true;
}

simulated state WeaponUpkeep
{
    simulated function BeginState(name PreviousStateName)
	{
		local name AnimName;
		local float Duration;

        AnimName = CleanNonBloodyAnim;

		Duration = MySkelMesh.GetAnimLength(AnimName);
		if ( Duration > 0.f )
		{
			if ( Instigator.IsFirstPerson() )
			{
				PlayAnimation(AnimName);
                SetTimer(Duration, FALSE, nameof(SwapComplete));
			}
    	}
		else
		{
			`warn("Duration is zero!!!"@AnimName);
			SetTimer(0.001, FALSE, nameof(SwapComplete));
		}

		NotifyBeginState();
	}

	simulated function BeginFire(byte FireModeNum)
	{
		
	}

	simulated event EndState(Name NextStateName)
	{
		ClearTimer(nameof(SwapComplete));
        Super.EndState(NextStateName);
        NotifyEndState();
	}
    
    simulated function SwapComplete()
    {
        if (Role == ROLE_Authority)
        {
            GotoState('Active');
        }
        else
        {
            GotoState('Active');
            ServerSwapComplete();
        }
    }
}

server reliable function ServerSwapComplete()
{
    GotoState('Active');
}

simulated function ChangeMode(bool IsFolded, bool bApplyBlend = true)
{
    if (MeleeAttackHelper == none)
        return;

    if (IsFolded)
    {
        MeleeAttackHelper.SetMeleeRange(MaxHitRangeFolded);
        MeleeAttackHelper.SetHitBoxChain(HitboxChainFolded);

        InstantHitDamage[DEFAULT_FIREMODE] = FoldedDamage;
        InstantHitDamage[HEAVY_ATK_FIREMODE] = FoldedDamageAlt;

        InstantHitDamageTypes[DEFAULT_FIREMODE] = FoldedDT;
        InstantHitDamageTypes[HEAVY_ATK_FIREMODE] = FoldedDTAlt;

        PlayerViewOffset = OriginalPlayerViewOffset;

        InstantHitDamageTypes[BASH_FIREMODE]=class'KFDT_Piercing_ScytheStabFolded';
	    InstantHitMomentum[BASH_FIREMODE]=100000.f;
        InstantHitDamage[BASH_FIREMODE]=40;
    }
    else 
    {
        MeleeAttackHelper.SetMeleeRange(MaxHitRangeUnfolded);
        MeleeAttackHelper.SetHitBoxChain(HitboxChainUnfolded);

        InstantHitDamage[DEFAULT_FIREMODE] = UnfoldedDamage;
        InstantHitDamage[HEAVY_ATK_FIREMODE] = UnfoldedDamageAlt;

        InstantHitDamageTypes[DEFAULT_FIREMODE] = UnfoldedDT;
        InstantHitDamageTypes[HEAVY_ATK_FIREMODE] = UnfoldedDTAlt;
    
        PlayerViewOffset = PlayerViewOffsetUnfolded;

        InstantHitDamageTypes[BASH_FIREMODE]=class'KFDT_Piercing_ScytheStab';
	    InstantHitMomentum[BASH_FIREMODE]=100000.f;
        InstantHitDamage[BASH_FIREMODE]=60;
    }

    NotifyServerMode(bIsFolded);

    if (bApplyBlend)
    {   
        SetFoldedBladeBlendTarget(bIsFolded ? 1.0f : 0.0f, UnfoldBlendingDuration);
    }
}

simulated function SetFoldedBladeBlendTarget(float Value, float BlendTime)
{
    if ( FoldBlendNode != None )
    {
        FoldBlendNode.SetBlendTarget(Value, BlendTime);
    }
}

simulated function StartFire(byte FireModeNum)
{
    if (StartFireDisabled && FireModeNum == BLOCK_FIREMODE)
    {
        StartFireDisabled = false;
        return;
    }

    if (FireModeNum == DEFAULT_FIREMODE || FireModeNum == HEAVY_ATK_FIREMODE)
    {
        DistortTrailParticle = bIsFolded ? FoldedTrailParticleSystem : UnfoldedTrailParticleSystem;
    }
    else if (FireModeNum == BASH_FIREMODE)
    {
        DistortTrailParticle = none;
    }

	super.StartFire(FireModeNum);
}

static simulated function float CalculateTraderWeaponStatDamage()
{
    // How is this calculated for this weapon?
    return default.UnfoldedDamage;
}

simulated function PlayAnimation(name Sequence, optional float fDesiredDuration, optional bool bLoop, optional float BlendInTime=0.1, optional float BlendOutTime=0.0)
{
    local string NewAnimName;

    if (Sequence == 'Idle' ||
        Sequence == 'Guncheck_V1' ||
        Sequence == 'Guncheck_V2' ||
        Sequence == 'Guncheck_V3')
    {
        NewAnimName = string(Sequence);
        NewAnimName $= ((bIsFolded) ? "_Folded" : "_Unfolded");
        Super.PlayAnimation(name(NewAnimName), fDesiredDuration, bLoop, BlendInTime, BlendOutTime);
    }
    else
    {
        Super.PlayAnimation(Sequence, fDesiredDuration, bLoop, BlendInTime, BlendOutTime);
    }
}

simulated function ModifyMeleeAttackSpeed(out float InSpeed, optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE, optional KFPerk CurrentPerk)
{
    Super.ModifyMeleeAttackSpeed(InSpeed, FireMode, UpgradeIndex, CurrentPerk);

    if (bIsFolded)
    {
        InSpeed *= FoldedAttackAnimRate;
    }
}

/** 
  * Overriden to apply fold/unfold logic
  */
simulated function ANIMNOTIFY_LockBolt()
{
    bIsFolded = !bIsFolded;
	ChangeMode(bIsFolded);
}

/** Unused */
simulated function ANIMNOTIFY_UnLockBolt()
{

}

/** Play blood VFX as we only use one anim. */
simulated function ANIMNOTIFY_CleanBlood()
{
    if (!bIsBloody)
    {
        return;
    }

    if (WorldInfo.NetMode != NM_DedicatedServer && BloodParticles != none)
    {
        WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BloodParticles, MySkelMesh, BloodParticlesSocket, true);
    }

	Super.ANIMNOTIFY_CleanBlood();
}

simulated state WeaponEquipping
{
	/** Initialize the weapon as being active and ready to go. */
	simulated event BeginState(Name PreviousStateName)
	{
        Super.BeginState(PreviousStateName);

	    if (WorldInfo.NetMode != NM_Client)
        {
            NotifyInitialState(bIsFolded);
        }
    }
}

/**
	Should replicate to 3P to show the shield effects
 */
simulated function NotifyInitialState(bool bFolded)
{
	local KFPawn KFP;

	if (WorldInfo.NetMode != NM_Client)
	{
        `Log("NotifyInitialState: " $bFolded);

		KFP = KFPawn(Instigator);
		KFP.OnWeaponSpecialAction(bFolded ? 0 : 1);
	}
}

reliable server function NotifyServerMode(bool bFolded)
{
    bIsFolded = bFolded;
}

defaultproperties
{
	// Zooming/Position
	PlayerViewOffset=(X=10,Y=0,Z=-10) // (X=2,Y=0,Z=0)
    PlayerViewOffsetUnfolded=(X=12,Y=0,Z=-7)

	// Content
	PackageKey="Scythe"
	FirstPersonMeshName="WEP_1P_Scythe_MESH.Wep_1stP_Scythe_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Scythe_ANIM.Wep_1st_Scythe_Anim"
    FirstPersonAnimTree="WEP_1P_Scythe_ANIM.1P_Scythe_Animtree"
	PickupMeshName="wep_3p_scythe_mesh.Wep_3rdP_Scythe_Pickup"
	AttachmentArchetypeName="WEP_Scythe_ARCH.Wep_Scythe_3P"

    // Short Range Mode Params
    MaxHitRangeFolded=220
    FoldedDamage = 70
    FoldedDamageAlt = 120
    FoldedDT=class'KFDT_Slashing_ScytheShort'
    FoldedDTAlt=class'KFDT_Slashing_ScytheShortAlt'
    HitboxChainFolded = {(
        (BoneOffset=(X=+3,Z=190)),
        (BoneOffset=(X=-3,Z=170)),
        (BoneOffset=(X=+3,Z=150)),
        (BoneOffset=(X=-3,Z=130)),
        (BoneOffset=(X=+3,Z=110)),
        (BoneOffset=(X=-3,Z=90)),
        (BoneOffset=(X=+3,Z=70)),
        (BoneOffset=(X=-3,Z=50)),
        (BoneOffset=(X=+3,Z=30)),
        (BoneOffset=(Z=10))
    )}

    // Long Range Mode Params
    MaxHitRangeUnfolded=300
    UnfoldedDamage=140
    UnfoldedDamageAlt=190
    UnfoldedDT=class'KFDT_Slashing_ScytheLong'
    UnfoldedDTAlt=class'KFDT_Slashing_ScytheLongAlt'
    HitboxChainUnfolded = {(
        (BoneOffset=(X=-3,Z=290)),
        (BoneOffset=(X=-3,Z=270)),
        (BoneOffset=(X=-3,Z=250)),
        (BoneOffset=(X=+3,Z=230)),
        (BoneOffset=(X=-3,Z=210)),
        (BoneOffset=(X=+3,Z=190)),
        (BoneOffset=(X=-3,Z=170)),
        (BoneOffset=(X=+3,Z=150)),
        (BoneOffset=(X=-3,Z=130)),
        (BoneOffset=(X=+3,Z=110)),
        (BoneOffset=(X=-3,Z=90)),
        (BoneOffset=(X=+3,Z=70)),
        (BoneOffset=(X=-3,Z=50)),
        (BoneOffset=(X=+3,Z=30)),
        (BoneOffset=(Z=10))
    )}

	Begin Object Name=MeleeHelper_0
		WorldImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Bladed_melee_impact'
		MeleeImpactCamShakeScale=0.04f //0.5
		// modified combo sequences
		ChainSequence_F=(DIR_ForwardRight, DIR_ForwardLeft, DIR_ForwardRight, DIR_ForwardLeft)
		ChainSequence_B=(DIR_BackwardLeft, DIR_BackwardRight, DIR_BackwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right, DIR_Left)
		ChainSequence_L=(DIR_Right, DIR_Left)
		ChainSequence_R=(DIR_Left, DIR_Right, DIR_ForwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right)
	End Object

	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing_ScytheShort'
	InstantHitMomentum(DEFAULT_FIREMODE)=30000.f

	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Slashing_ScytheShortAlt'
    FiringStatesArray(HEAVY_ATK_FIREMODE)=MeleeHeavyAttacking
	InstantHitMomentum(HEAVY_ATK_FIREMODE)=30000.f

    // Defined in ChangeMode function
	//InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Piercing_ScytheStab'
	//InstantHitMomentum(BASH_FIREMODE)=100000.f
    //InstantHitDamage(BASH_FIREMODE)=50

	// Inventory
    GroupPriority=50
	InventorySize=7
	WeaponSelectTexture=Texture2D'WEP_UI_Scythe_TEX.UI_WeaponSelect_Scythe'
	

	AssociatedPerkClasses(0)=class'KFPerk_Berserker'

	// Block Sounds
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Katana'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Metal'

	ParryDamageMitigationPercent=0.4
	BlockDamageMitigation=0.5
	ParryStrength=5

    bIsFolded=true

	BonesToLockOnEmpty.Empty()

    UnfoldBlendingDuration=0.05f

    FoldedAttackAnimRate=0.65f

    // IdleFidgetAnims=(Guncheck_v1, Guncheck_v2, Guncheck_v3)

	// Weapon Upgrade stat boosts
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))

    DistortTrailParticle = none
    WhiteTrailParticle = none
    // BlueTrailParticle = none
    // RedTrailParticle = none
	
    FoldedTrailParticleSystem=ParticleSystem'WEP_Scythe_EMIT.FX_Scythe_Custom_R_01'
    UnfoldedTrailParticleSystem=ParticleSystem'WEP_Scythe_EMIT.FX_Scythe_Custom_Unfold_01';

    BloodParticles = ParticleSystem'WEP_1P_KATANA_EMIT.FX_katana_blood_flick_01'
}
