//=============================================================================
// KFProj_Grenade_HRGTeslauncher
//=============================================================================
// EMP Grenade projectile class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
// - Fernando Ferrando @ Saber Interactive
//=============================================================================

class KFProj_Grenade_HRGTeslauncher extends KFProj_EMPGrenade
	hidedropdown;

var array<Actor> ImpactList;

//==============
/*  Touching
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if (Other != Instigator && !Other.bWorldGeometry)
	{
		// Don't hit teammates
		if (Other.GetTeamNum() == GetTeamNum())
		{
			return;
		}
		if (!bHasExploded && !bHasDisintegrated)
		{
			GetExplodeEffectLocation(HitLocation, HitNormal, Other);
			TriggerExplosion(HitLocation, HitNormal, Other);
		}
	}

	super.ProcessTouch(Other, HitLocation, HitNormal);
}*/

//==============
// Touching
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
    //local bool bWantsClientSideDudHit;
	local float TraveledDistance;

    // If we collided with a Siren shield, let the shield code handle touches
    if( Other.IsA('KFTrigger_SirenProjectileShield') )
    {
        return;
    }

	// Don't hit teammates
	if( Other.GetTeamNum() == GetTeamNum() )
	{
        return;
	}

    // Need to do client side dud hits if this is a client
    //if( Instigator != none && Instigator.Role < ROLE_Authority )
	//{
    //    bWantsClientSideDudHit = true;
    //}

	TraveledDistance = (`TimeSince(CreationTime) * Speed);
	TraveledDistance *= TraveledDistance;

	// Process impact hits
    if (Other != Instigator && !Other.bStatic)
    {
		// check/ignore repeat touch events
		if( !CheckRepeatingTouch(Other) && Other.GetTeamNum() != GetTeamNum())
		{
			ProcessBulletTouch(Other, HitLocation, HitNormal);
		}
    }

    if( WorldInfo.NetMode == NM_Standalone ||
        (WorldInfo.NetMode == NM_ListenServer && Instigator != none && Instigator.IsLocallyControlled()) )
    {
        Super.ProcessTouch( Other, HitLocation, HitNormal );
		if (!bHasExploded && !bHasDisintegrated)
		{
			GetExplodeEffectLocation(HitLocation, HitNormal, Other);
			TriggerExplosion(HitLocation, HitNormal, Other);
		}
        return;
    }

    if( Owner != none && KFWeapon( Owner ) != none && Instigator != none )
    {
    	if( Instigator.Role < ROLE_Authority && Instigator.IsLocallyControlled() )
    	{
            KFWeapon(Owner).HandleClientProjectileExplosion(HitLocation, self);
			Super.ProcessTouch( Other, HitLocation, HitNormal );
			if (!bHasExploded && !bHasDisintegrated)
			{
				GetExplodeEffectLocation(HitLocation, HitNormal, Other);
				TriggerExplosion(HitLocation, HitNormal, Other);
			}
            return;
        }
    }

}

/** Handle bullet collision and damage */
simulated function ProcessBulletTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if (ImpactList.Find(Other) != INDEX_NONE)
	{
		return;
	}
	if (Other != none)
	{
		ImpactList.AddItem(Other);
	}

	super.ProcessBulletTouch(Other, HitLocation, HitNormal);
}

/** Blow up on impact */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	if( StaticMeshComponent(WallComp) != none && StaticMeshComponent(WallComp).CanBecomeDynamic() )
	{
		// pass through meshes that can move (like those little coffee tables in biotics)
		return;
	}

	Explode( Location, HitNormal );
}

// for nukes && concussive force
simulated protected function PrepareExplosionTemplate()
{
    class'KFPerk_Berserker'.static.PrepareExplosive( Instigator, self );

	GetRadialDamageValues(ExplosionTemplate.Damage, ExplosionTemplate.DamageRadius, ExplosionTemplate.DamageFalloffExponent);

    //super.PrepareExplosionTemplate();
}


defaultproperties
{
    FuseTime=0.25 //0.5
	Speed=4000
	MaxSpeed=4000
	TerminalVelocity=4000
	TossZ=150

	ProjFlightTemplate = ParticleSystem'WEP_HRG_Teslauncher_EMIT.FX_Medic_GrenadeLauncher_Projectile'
	ProjFlightTemplateZedTime = ParticleSystem'WEP_HRG_Teslauncher_EMIT.FX_Medic_GrenadeLauncher_Projectile_ZEDTIME'
	ExplosionActorClass=class'KFExplosionActor'
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_EMPGrenade'

	bSyncToOriginalLocation=true
	bSyncToThirdPersonMuzzleLocation=true
	bWarnAIWhenFired=true

	// set collision size to 0 so it doesn't cause non-zero extent checks against zeds
	Begin Object Name=CollisionCylinder
		CollisionRadius=0.f
		CollisionHeight=0.f
	End Object

	// Grenade explosion light
	Begin Object Name=ExplosionPointLight
	    LightColor=(R=128,G=200,B=255,A=255)
		Brightness=4.f
		Radius=750.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=True
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=25  //100
		DamageRadius=350   //600
		DamageFalloffExponent=1  //2
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_EMP_TeslauncherEMPGrenade'
		FractureMeshRadius=100
		FracturePartVel=250.0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.EMPGrenade_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_EMP.Play_WEP_EXP_Grenade_EMP_Explosion'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.5
        ExploLightFadeOutTime=0.25
        ExploLightFlickerIntensity=5.f
        ExploLightFlickerInterpSpeed=15.f

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
		CamShakeInnerRadius=100	
		CamShakeOuterRadius=450
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	// Temporary effect (5.14.14)
	ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'

	AssociatedPerkClass=class'KFPerk_Berserker'
}


