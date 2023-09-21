//=============================================================================
// KFPawn_ZedClot
//=============================================================================
// Base pawn class for Clots
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFPawn_ZedClot extends KFPawn_Monster
	abstract;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree( SkelComp );

	if( bCanHeadTrack )
	{
		IK_Look_Head		= SkelControlLookAt(Mesh.FindSkelControl('HeadLook'));
		//IK_Look_Spine       = SkelControlLookAt(Mesh.FindSkelControl('SpineLook'));
	}
}

/** Returns (hardcoded) dialog event ID for when players spots this zed type */
function int GetSpotterDialogID()
{
	local int EmergeType;

	if( IsDoingSpecialMove(SM_Emerge) )
    {
        EmergeType = SpecialMoveFlags & 0x0f;
        switch( EmergeType )
        {
        case EMERGE_Floor:
            return 142;//SPOTZ_EmergeFloor

        case EMERGE_Wall248UU:
        case EMERGE_WallHigh:
            return 140;//SPOTZ_EmergeVent

        case EMERGE_Ceiling:
            return 141;//SPOTZ_EmergeCeiling
        };
    }

	return 125;//SPOTZ_Generic
}

DefaultProperties
{
	Begin Object Name=KFPawnSkeletalMeshComponent
		bPerBoneMotionBlur=false
	End Object

	bIsClotClass=true
	// ---------------------------------------------
	// Content
	MonsterArchPath="ZED_ARCH.ZED_Clot_UnDev_Archetype"

	// ---------------------------------------------
	// Gameplay
	bCanGrabAttack=true
	Begin Object Name=MeleeHelper_0
		BaseDamage=6.f
		MaxHitRange=172.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_ZedWeak'
	End Object

	Health=100 // 67% KF1 scale
	DoshValue=7.0
	Mass=65.f //
	KnockedDownBySonicWaveOdds=0.23f
	bKnockdownWhenJumpedOn=true

	// ---------------------------------------------
	// Movement / Physics
	GroundSpeed=190.f
	SprintSpeed=400.f

	// ---------------------------------------------
	// Special Moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_GrappleAttack)=class'KFGame.KFSM_GrappleCombined'
		SpecialMoveClasses(SM_Taunt)=class'KFGame.KFSM_Zed_Taunt'
		SpecialMoveClasses(SM_Emerge)=class'KFSM_Emerge'
		SpecialMoveClasses(SM_Evade)=class'KFSM_Evade'
		SpecialMoveClasses(SM_Evade_Fear)=class'KFSM_Evade_Fear'
		SpecialMoveClasses(SM_GorgeZedVictim)=class'KFGameContent.KFSM_GorgeVictim'
	End Object

	IncapSettings(AF_Stun)=		(Vulnerability=(2), Cooldown=3.0)
	IncapSettings(AF_Knockdown)=(Vulnerability=(2), Cooldown=8.0)
	IncapSettings(AF_Stumble)=	(Vulnerability=(2), Cooldown=1.0)
	IncapSettings(AF_GunHit)=	(Vulnerability=(2), Cooldown=1.0)
	IncapSettings(AF_MeleeHit)= (Vulnerability=(2), Cooldown=1.0)

    DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', DamageScale=(0.5))

	// ---------------------------------------------
	// AI / Navigation
	//DebugRange_Melee_Material=Material'ENG_EditorResources_MAT.Debug_Radius_M'
	RotationRate=(Pitch=50000,Yaw=30000,Roll=50000)

	// Only used in Volter Castle for now when the spawn volume has bForceUseMapReplacePawn set to true
	// If we need to reuse it more we'll have to connect map to zed here
	MapReplacePawnClass.Add(class'KFPawn_ZedHansClot')
}
