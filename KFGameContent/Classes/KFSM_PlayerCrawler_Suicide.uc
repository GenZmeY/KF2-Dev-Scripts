//=============================================================================
// KFSM_PlayerCrawler_Suicide
//=============================================================================
// Play a suicide attack animation sequence
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerCrawler_Suicide extends KFSM_PlaySingleAnim;

/** Explosion template for suicide gas attack */
var KFGameExplosion SuicideGasExplosionTemplate;

/** Damagetype used on owner pawn when exploding */
var class<KFDamageType> SuicideDamageType;

protected function bool InternalCanDoSpecialMove()
{
    if( KFPOwner.WorldInfo.GRI.bMatchIsOver || KFGameReplicationInfoVersus(KFPOwner.WorldInfo.GRI).bRoundIsOver )
    {
        return false;
    }

	if( KFPOwner.IsHumanControlled() )
	{
		return KFPOwner.IsAliveAndWell();
	}

	return true;
}

simulated function SpecialMoveEnded( name PrevMove, name NextMove )
{
    //if( !bPendingStopFire )
    //{
    	TriggerExplosion( KFPOwner, default.SuicideGasExplosionTemplate );
    //}

	super.SpecialMoveEnded( PrevMove, NextMove );
}

/** Called when crawler suicides */
static function TriggerExplosion( KFPawn CrawlerOwner, KFGameExplosion ExplosionTemplate, optional bool bForceExplosion )
{
	local KFExplosion_PlayerCrawlerSuicide ExploActor;
    local KFPawn_ZedCrawler_Versus CrawlerOwnerV;

	// Only living crawlers can explode
	if( CrawlerOwner != none && (!CrawlerOwner.bPlayedDeath || bForceExplosion) )
	{
        // Cache controller
        CrawlerOwnerV = KFPawn_ZedCrawler_Versus( CrawlerOwner );
        if( CrawlerOwnerV != none )
        {
            KFPawn_ZedCrawler_Versus(CrawlerOwner).OldController = CrawlerOwner.Controller;
        }

    	// Explode using the given template
		ExploActor = CrawlerOwner.Spawn( class'KFExplosion_PlayerCrawlerSuicide', CrawlerOwner,, CrawlerOwner.Location, rotator(vect(0,0,1)) );
		if( ExploActor != none )
		{
            ExploActor.InstigatorController = CrawlerOwner.Controller;
            ExploActor.Instigator = CrawlerOwner;
            ExploActor.Explode( ExplosionTemplate );
		}

		// Make sure we're dead!
		if( CrawlerOwner.Role == ROLE_Authority && !CrawlerOwner.bPlayedDeath && !bForceExplosion ) 
   		{
   			CrawlerOwner.TakeRadiusDamage( none, 10000, default.SuicideGasExplosionTemplate.DamageRadius, default.SuicideDamageType, 1, CrawlerOwner.Location, true, none );
   		}
	}
}

/** Interrupts the special move if the player has released the button */
/*function SpecialMoveFlagsUpdated()
{
    if( !KFPOwner.IsLocallyControlled() && KFPOwner.SpecialMoveFlags == FLAG_SpecialMoveButtonReleased )
    {
        bPendingStopFire = true;
        bCanBeInterrupted = true;

        // End the special move on the server
        if( KFPOwner.Role == ROLE_Authority )
        {
            // Wait 2 frames for the pending stopfire flag to propagate
            KFPOwner.SetTimer( KFPOwner.WorldInfo.DeltaSeconds*2.f, false, nameOf(KFPOwner.EndSpecialMove) );
        }
    }
    else
    {
        super.SpecialMoveFlagsUpdated();
    }
}*/

/** Interrupt the move if the button was released */
/*function SpecialMoveButtonReleased()
{
    bPendingStopFire = true;
    if( KFPOwner.Role < ROLE_Authority && KFPOwner.IsLocallyControlled() )
    {
        KFPOwner.ServerDoSpecialMove( KFPOwner.SpecialMove, true,, FLAG_SpecialMoveButtonReleased );
    }
    KFPOwner.EndSpecialMove();
}*/

defaultproperties
{
	// ---------------------------------------------
	// SpecialMove
	Handle=KFSM_PlayerCrawler_Suicide
	bPawnRotationLocked=true
	bShouldDeferToPostTick=true

	// ---------------------------------------------
	// Animations
	AnimName=Player_Suicide
	AnimStance=EAS_FullBody
	bUseRootMotion=true

	/** Suicide explosion point light */
    /*Begin Object Class=PointLightComponent Name=ExplosionPointLight
        LightColor=(R=200,G=200,B=0,A=255)
        Brightness=4.f
        Radius=500.f
        FalloffExponent=10.f
        CastShadows=False
        CastStaticShadows=FALSE
        CastDynamicShadows=True
        bEnabled=FALSE
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object*/

    /** Used for suicide gas AOE attack "explosion" template */
    Begin Object Class=KFGameExplosion Name=ExploTemplate1
        Damage=10 //10
        DamageRadius=450 //600
        DamageFalloffExponent=0.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Toxic_PlayerCrawlerSuicide'

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=0
        FracturePartVel=0
        ExplosionEffects=KFImpactEffectInfo'ZED_Crawler_ARCH.ToxicGasAoE_Explosion'
        ExplosionSound=AkEvent'WW_WEP_EXP_Dynamite.Play_WEP_EXP_Dynamite_Explosion'
        MomentumTransferScale=100

        // Dynamic Light
        ExploLight=none
        //ExploLight=ExplosionPointLight
        //ExploLightStartFadeOutTime=7.0
        //ExploLightFadeOutTime=1.0
        //ExploLightFlickerIntensity=5.f
        //ExploLightFlickerInterpSpeed=15.f

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=450
        CamShakeOuterRadius=900
        CamShakeFalloff=1.f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    SuicideGasExplosionTemplate=ExploTemplate1

    SuicideDamageType=class'KFDT_Explosive_CrawlerSuicide'
}