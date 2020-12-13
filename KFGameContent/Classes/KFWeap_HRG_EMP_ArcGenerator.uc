//=============================================================================
// KFWeap_HRG_EMP_ArcGenerator 
//=============================================================================
// A gun that zaps zeds
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// FFerrando @ saber3d
//=============================================================================
/*
	Default firemode:
	-max number of secondary arcs
	-secondary arcs max range
	-main beam max range
	-aiming speed reduction

	Alt firemode:
	-projectile speed
	-projectile max range
	-zapTick (time between zaps)
	-max number of Zeds zapped
	-zap max range
 */
class KFWeap_HRG_EMP_ArcGenerator extends KFWeap_FlameBase;

Replication
{
	if(role == role_authority && bNetDirty)
		oZedCurrentlyBeingSprayed, MaxNumberOfZedsZapped, MaxDistanceToBeZapped, ZapInterval, ChainDamage;
}
/** Shoot animation to play when shooting secondary fire */
var(Animations) const editconst	name	FireHeavyAnim;

/** Shoot animation to play when shooting secondary fire last shot */
var(Animations) const editconst	name	FireLastHeavyAnim;

/** Shoot animation to play when shooting secondary fire last shot when aiming */
var(Animations) const editconst	name	FireLastHeavySightedAnim;

/** Alt-fire explosion template */
var() GameExplosion 		ExplosionTemplate;



/**************************** HRG SPRAY STUFF*/ 


struct BeamAttachedToActor
{
	var ParticleSystemComponent oBeam;
	var KFPawn_Monster oAttachedZed;
};

var array<DamagedActorInfo> vRecentlyZappedActors;
var array<DamagedActorInfo> vAuxDeletionArrayChainedActors;

var array<BeamAttachedToActor> vActiveBeamEffects;
var array<BeamAttachedToActor> vAuxDeletionArray;


var repnotify KFPawn_Monster oZedCurrentlyBeingSprayed;


var ParticleSystem BeamPSCTemplate;

var string EmitterPoolClassPath;
var EmitterPool vBeamEffects;

var int 	MaxNumberOfZedsZapped;
var int 	MaxDistanceToBeZapped;
var float 	ZapInterval;
var int 	ChainDamage;


/*********************** */

/** Handle one-hand fire anims */
simulated function name GetWeaponFireAnim(byte FireModeNum)
{
	local bool bPlayFireLast;

    bPlayFireLast = ShouldPlayFireLast(FireModeNum);

	if ( bUsingSights )
	{
		if( bPlayFireLast )
        {
        	if ( FireModeNum == ALTFIRE_FIREMODE )
        	{
                return FireLastHeavySightedAnim;
        	}
        	else
        	{
                return FireLastSightedAnim;
            }
        }
        else
        {
            return FireSightedAnims[FireModeNum];
        }

	}
	else
	{
		if( bPlayFireLast )
        {
        	if ( FireModeNum == ALTFIRE_FIREMODE )
        	{
                return FireLastHeavyAnim;
        	}
        	else
        	{
                return FireLastAnim;
            }
        }
        else
        {
        	if ( FireModeNum == ALTFIRE_FIREMODE )
        	{
                return FireHeavyAnim;
        	}
        	else
        	{
                return FireAnim;
            }
        }
	}
}



/**
 * Instead of a toggle, just immediately fire alternate fire.
 */
simulated function AltFireMode()
{
	// LocalPlayer Only
	if ( !Instigator.IsLocallyControlled()  )
	{
		return;
	}

	StartFire(ALTFIRE_FIREMODE);
}

/** Disable auto-reload for alt-fire */
simulated function bool ShouldAutoReload(byte FireModeNum)
{
	local bool bRequestReload;

    bRequestReload = Super.ShouldAutoReload(FireModeNum);

    // Must be completely empty for auto-reload or auto-switch
    if ( FireModeNum == ALTFIRE_FIREMODE && AmmoCount[0] > 0 )
    {
   		bPendingAutoSwitchOnDryFire = false;
   		return false;
    }

    return bRequestReload;
}

static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Electric;
}


simulated function StartPilotSound()
{
	if( Instigator != none && Instigator.IsLocallyControlled() && Instigator.IsFirstPerson() )
	{
        //PostAkEventOnBone(PilotLightPlayEvent, PilotLightSocketName, true, true);
    }
}

/**
 * Stops playing looping Pilot light sound
 */
simulated function StopPilotSound()
{
    //PostAkEventOnBone(PilotLightStopEvent, PilotLightSocketName, true, true);
}

/**********************************************************************




*********************************************************************** */


simulated function ReplicatedEvent(name VarName)
{
	if(VarName == nameof(oZedCurrentlyBeingSprayed))
	{
		if(role != role_authority || WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_StandAlone)
		{
			if(oZedCurrentlyBeingSprayed == none)
			{
				SprayEnded();
			}
		}
	}
}

simulated function ChangeMaterial()
{
	// Removed from base class
	/*local int i, Idx;
    if( BarrelHeat != LastBarrelHeat )
    {
    	for( i = 0; i < WeaponMICs.Length; ++i )
    	{
    		if( WeaponMICs[i] != none )
    		{
				WeaponMICs[i].SetScalarParameterValue('Glow_Intensity', BarrelHeat);
			}
		}
    }*/
}

simulated protected function TurnOnPilot()
{
	Super.TurnOnPilot();

	if( FlamePool[0] != None )
	{
		KFSprayActor_ArcGenerator(FlamePool[0]).OwnerWeapon = self;
		MaxNumberOfZedsZapped=KFSprayActor_ArcGenerator(FlamePool[0]).MaxNumberOfZedsZapped;
		MaxDistanceToBeZapped=KFSprayActor_ArcGenerator(FlamePool[0]).MaxDistanceToBeZapped;
		ZapInterval=KFSprayActor_ArcGenerator(FlamePool[0]).ZapInterval;
		ChainDamage=KFSprayActor_ArcGenerator(FlamePool[0]).ChainDamage;
	}
	if( FlamePool[1] != None )
	{
		KFSprayActor_ArcGenerator(FlamePool[1]).OwnerWeapon = self;
	}
}

simulated function float FlameHeatCalc()
{
	//hack in order to make the arc gen always glow
	LastBarrelHeat = 1.0f;
	return 1.0f;
}

simulated event PostBeginPlay()
{
	local class<EmitterPool> PoolClass;
	super.PostBeginPlay();

	PoolClass = class<EmitterPool>(DynamicLoadObject(EmitterPoolClassPath, class'Class'));
	if (PoolClass != None)
	{
		vBeamEffects = Spawn(PoolClass, self,, vect(0,0,0), rot(0,0,0));
	}
}


/***************************************

	PARTICLE SYSTEM POOL AND ATTACHMENT MANAGEMENT

 ***************************************/

/** We so we detach the Component once we are done playing it **/
simulated function OnBeamEffectFinished( ParticleSystemComponent PSC )
{
	PSC.DeactivateSystem();
	EndPSC(PSC);
}

//returns the position of the effect in the array, otherwise, -1
simulated function int SpawnBeam(Actor _OriginActor, Actor _DestinationActor)
{	
	local ParticleSystemComponent BeamPSC;

	local BeamAttachedToActor BeamAttachedInfo;
	local int i;

	//if actor is dupped in active beams, not chain again this to another beam

	for(i = 0; i < vActiveBeamEffects.Length; i++)
	{
		if(vActiveBeamEffects[i].oAttachedZed == _DestinationActor)
		{
			return -1;
		}
	}
	BeamPSC = vBeamEffects.SpawnEmitterCustomLifetime(BeamPSCTemplate);
	if(BeamPSC != none)
	{
		BeamPSC.SetBeamSourcePoint(0, _OriginActor.Location, 0);
		BeamPSC.SetBeamTargetPoint(0, _DestinationActor.Location, 0);
		BeamPSC.SetKillOnDeactivate(0, true);
		BeamPSC.SetAbsolute(false, false, false);
		BeamPSC.bUpdateComponentInTick = true;

		BeamAttachedInfo.oBeam = BeamPSC;
		BeamAttachedInfo.oAttachedZed = KFPawn_Monster(_DestinationActor);

		if(role != role_authority || WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_StandAlone)
		{
			BeamPSC.SetActive(true);
			AttachComponent(BeamPSC);
		}

		BeamAttachedInfo.oBeam.SetActive(true);
		vActiveBeamEffects.AddItem(BeamAttachedInfo);
		return vActiveBeamEffects.Length - 1;
	}
	else
	{
	}
	return -1;
}

simulated function MarkBeamToDeactivate(BeamAttachedToActor _BeamData)
{
	vAuxDeletionArray.AddItem(_BeamData);
}

simulated function MarkZedToUnchain(DamagedActorInfo _DamageActorInfo)
{
	vAuxDeletionArrayChainedActors.AddItem(_DamageActorInfo);
}

simulated function BeamAttachedToActor GetBeamFromActor(Actor _Actor)
{
	local int i;

	for(i = 0; i < vActiveBeamEffects.Length; i++)
	{
		if(vActiveBeamEffects[i].oAttachedZed == _Actor)
		{
			return vActiveBeamEffects[i];
		}
	}
}

simulated function DeactivateBeam(Actor _ChainedActor)
{
	local int i;
	for(i = 0; i < vActiveBeamEffects.Length; i++)
	{
		if(vActiveBeamEffects[i].oAttachedZed == _ChainedActor)
		{
			OnBeamEffectFinished(vActiveBeamEffects[i].oBeam);
			vActiveBeamEffects.RemoveItem(vActiveBeamEffects[i]);
			break;
		}
	}

}

simulated function EndPSC(ParticleSystemComponent _Value)
{
	/*if(vCachedBeamEffects.Length < MaxNumberOfZedsZapped)
	{
		vCachedBeamEffects.AddItem(_Value);
	}*/
	_Value.KillParticlesForced();
	vBeamEffects.OnParticleSystemFinished(_Value);
	DetachComponent(_Value);
}


/***************************************

	END PARTICLE SYSTEM POOL AND ATTACHMENT MANAGEMENT

 ***************************************/



/***************************************

	CHAIN LOGIC FUNCTIONS

 ***************************************/
 
simulated function SetCurrentSprayedZed(KFPawn_Monster _Monster)
{
	if(role == role_authority || WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_StandAlone)
	{
		oZedCurrentlyBeingSprayed = _Monster;
		bNetDirty=true;
	}
}

 //returns true if it has successfully chained the zed, false otherwise (ex: dupe zed in the array)
function bool ChainZed(Actor _ZedToChain)
{
	local DamagedActorInfo NewActorInfo;
	local int i;
	
	for (i = vRecentlyZappedActors.Length - 1; i >= 0; i--)
	{
		//remove everything if pawn died or interval is greater than the time its supposed to be in here; 
		if(vRecentlyZappedActors[i].HitActor == _ZedToChain)
		{
			return false;
		}
	}

	NewActorInfo.HitActor = _ZedToChain;
	NewActorInfo.HitTime = WorldInfo.TimeSeconds;
	vRecentlyZappedActors.AddItem(NewActorInfo);
	return true;
}

function UnchainZed(DamagedActorInfo _ZedToUnchain)
{
	vRecentlyZappedActors.RemoveItem(_ZedToUnchain);
}

function bool CheckRecentlyZapped(Actor _ActorToCheck)
{
	local int i;
	local bool bZapedRecently;
	bZapedRecently = false;

	for (i = vRecentlyZappedActors.Length - 1; i >= 0; i--)
	{
		if (vRecentlyZappedActors[i].HitActor == _ActorToCheck)
		{
			//`Warn("FOUND ACTOR. WorldInfo.TimeSeconds = " $(WorldInfo.TimeSeconds)$ "");
			//`Warn("FOUND ACTOR. vRecentlyZappedActors[i].HitTime = " $(vRecentlyZappedActors[i].HitTime)$ "");
			//`Warn("FOUND ACTOR. INTERVAL = " $(WorldInfo.TimeSeconds - vRecentlyZappedActors[i].HitTime)$ "");
			// Only damage at a specified rate, so return if it's too soon
			if ((WorldInfo.TimeSeconds - vRecentlyZappedActors[i].HitTime) < ZapInterval)
			{
				bZapedRecently = true;
			}
			break;
		}
	}

	return bZapedRecently;
}

function UpdateLastHitTimeForActor(Actor _ActorToCheck)
{
	local int i;
	for (i = vRecentlyZappedActors.Length - 1; i >= 0; i--)
	{
		if (vRecentlyZappedActors[i].HitActor == _ActorToCheck)
		{
			//`Warn("SETTING TIME: " $WorldInfo.TimeSeconds$ "");
			vRecentlyZappedActors[i].HitTime = WorldInfo.TimeSeconds;
			break;
		}
	}
}

simulated function ChainNearZeds(Actor _TouchActor)
{
	local KFPawn_Monster oMonsterPawn;

	//`Warn("ChainNearZeds(Actor _TouchActor)");
	//we get all pawns from the world to check them
	foreach WorldInfo.AllPawns( class'KFPawn_Monster', oMonsterPawn )
	{
		//if its alive and its not the main sprayed monster
		if( oMonsterPawn.IsAliveAndWell() && oMonsterPawn != _TouchActor)
		{
			//if its close enough to be zapped
			if( VSizeSQ(oMonsterPawn.Location - _TouchActor.Location) < Square(MaxDistanceToBeZapped) )
			{
				if(vActiveBeamEffects.Length < MaxNumberOfZedsZapped)
				{
					//if we have nothing in between
					if(FastTrace(_TouchActor.Location, oMonsterPawn.Location, vect(0,0,0)) == false)
					{
						continue;
					}
					if(_TouchActor.IsA('KFPawn_Monster'))
					{
						if(role == role_authority || WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_StandAlone)
						{
							ChainZed(oMonsterPawn);
						}
						SpawnBeam(_TouchActor, oMonsterPawn);
					}
				}
				else
				{
					break;
				}
			}
		}
	}
}

/***************************************

	CHAIN LOGIC FUNCTIONS END

 ***************************************/

simulated event Tick(float DeltaTime)
{
	local int i;
	local vector BeamStartPoint, BeamEndPoint;

	Super.Tick(DeltaTime);

	if(oZedCurrentlyBeingSprayed != none)
	{
			//if we have space for one more zed to chain, we try to chain one zed
			if(vActiveBeamEffects.Length < MaxNumberOfZedsZapped && !CheckRecentlyZapped(oZedCurrentlyBeingSprayed))
			{
				ChainNearZeds(oZedCurrentlyBeingSprayed);
			}
			//`Warn(vActiveBeamEffects.Length);
			//check current beams
			for (i = vActiveBeamEffects.Length - 1; i >= 0; i--)
			{
				//if a current beam has gone out of sight (we have a wall in between for example), remove the beam and continue to next beam
				if(FastTrace(vActiveBeamEffects[i].oAttachedZed.Location, oZedCurrentlyBeingSprayed.Location, vect(0,0,0)) == false)
				{
					//OnBeamEffectFinished(vActiveBeamEffects[i].oBeam);
					MarkBeamToDeactivate(GetBeamFromActor(vRecentlyZappedActors[i].HitActor));
					continue;
				}

				//if its not near enough to stay zapped, we break the chain
				if (VSizeSQ(vActiveBeamEffects[i].oAttachedZed.Location - oZedCurrentlyBeingSprayed.Location) < Square(MaxDistanceToBeZapped))
				{
					//if has been recently damaged, do not take damage again until the fire rate tells us
					if( !CheckRecentlyZapped(vActiveBeamEffects[i].oAttachedZed))
					{
						//take damage
						if(vActiveBeamEffects[i].oAttachedZed.IsAliveAndWell())
						{		
							if(role == role_authority || WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_StandAlone)
							{ 
								ChainedZapDamageFunction(vActiveBeamEffects[i].oAttachedZed, oZedCurrentlyBeingSprayed);
								UpdateLastHitTimeForActor(vActiveBeamEffects[i].oAttachedZed);
							}
							 
							if(role != role_authority || WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_StandAlone)
							{
								//`warn(vActiveBeamEffects[i].oAttachedZed.Location);
								BeamStartPoint = oZedCurrentlyBeingSprayed.Mesh.GetBoneLocation('Spine1');
								BeamEndPoint = vActiveBeamEffects[i].oAttachedZed.Mesh.GetBoneLocation('Spine1');

								if(BeamStartPoint == vect(0,0,0)) BeamStartPoint = oZedCurrentlyBeingSprayed.Location;
								if(BeamEndPoint == vect(0,0,0)) BeamEndPoint = vActiveBeamEffects[i].oAttachedZed.Location;

								vActiveBeamEffects[i].oBeam.SetBeamSourcePoint(0, BeamStartPoint, 0);
								vActiveBeamEffects[i].oBeam.SetBeamTargetPoint(0, BeamEndPoint, 0);
							}
							

							if(!vActiveBeamEffects[i].oAttachedZed.IsAliveAndWell())
							{
								//OnBeamEffectFinished(vActiveBeamEffects[i].oBeam);
								MarkBeamToDeactivate(GetBeamFromActor(vActiveBeamEffects[i].oAttachedZed));
							}
						}
					}
				}
				else
				{
					//OnBeamEffectFinished(vActiveBeamEffects[i].oBeam);
					if(role != role_authority || WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_StandAlone)
						MarkBeamToDeactivate(GetBeamFromActor(vActiveBeamEffects[i].oAttachedZed));
				}
			}
	}


	if(oZedCurrentlyBeingSprayed == none && (role != role_authority || WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_StandAlone))
	{
		for(i = 0; i < vActiveBeamEffects.Length; i++)
		{
			OnBeamEffectFinished(vActiveBeamEffects[i].oBeam);
		}
		vActiveBeamEffects.Remove(0, vActiveBeamEffects.Length);
	}
	else if(oZedCurrentlyBeingSprayed != none && (role != role_authority || WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_StandAlone))
	{
		`log(vActiveBeamEffects.Length);
		for(i = 0; i < vActiveBeamEffects.Length; i++)
		{

			if(!vActiveBeamEffects[i].oAttachedZed.IsAliveAndWell())
			{
				//OnBeamEffectFinished(vActiveBeamEffects[i].oBeam);
				MarkBeamToDeactivate(GetBeamFromActor(vActiveBeamEffects[i].oAttachedZed));
			}
		}

		for(i = 0; i < vAuxDeletionArray.Length; i++)
		{
			OnBeamEffectFinished(vAuxDeletionArray[i].oBeam);
			vAuxDeletionArray.RemoveItem(vAuxDeletionArray[i]);

		}
	}

	if(role == role_authority || WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_StandAlone)
	{
		for (i = vRecentlyZappedActors.Length - 1; i >= 0; i--)
		{
			//remove everything if pawn died 
			if(vRecentlyZappedActors[i].HitActor == none )
			{
				DeactivateBeam(vRecentlyZappedActors[i].HitActor);
				//UnchainZed(vRecentlyZappedActors[i]);
				MarkZedToUnchain(vRecentlyZappedActors[i]);
			}
			//remove everything if pawn died 
			if(!KFPawn_Monster(vRecentlyZappedActors[i].HitActor).IsAliveAndWell())
			{
				DeactivateBeam(vRecentlyZappedActors[i].HitActor);
				//UnchainZed(vRecentlyZappedActors[i]);
				MarkZedToUnchain(vRecentlyZappedActors[i]);
			}
			//remove if interval is greater than the time its supposed to be in here; 
			if(((WorldInfo.TimeSeconds - vRecentlyZappedActors[i].HitTime) > 1.f))
			{
				DeactivateBeam(vRecentlyZappedActors[i].HitActor);
				//UnchainZed(vRecentlyZappedActors[i]);
				MarkZedToUnchain(vRecentlyZappedActors[i]);
			}
		}
		for(i = 0; i < vAuxDeletionArrayChainedActors.Length; i++)
		{
			UnchainZed(vAuxDeletionArrayChainedActors[i]);
		}
		vAuxDeletionArrayChainedActors.Remove(0, vAuxDeletionArrayChainedActors.Length);

	}
	
	/*if(role != role_authority || WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_StandAlone)
	{
		for (i = vRecentlyZappedActors.Length - 1; i >= 0; i--)
		{
			//remove everything if pawn died 
			if(vRecentlyZappedActors[i].HitActor == none )
			{
				DeactivateBeam(vRecentlyZappedActors[i].HitActor);
				MarkZedToUnchain(vRecentlyZappedActors[i]);

			}
			//remove everything if pawn died 
			if(!KFPawn_Monster(vRecentlyZappedActors[i].HitActor).IsAliveAndWell())
			{
				DeactivateBeam(vRecentlyZappedActors[i].HitActor);
				MarkZedToUnchain(vRecentlyZappedActors[i]);

			}
			//remove if interval is greater than the time its supposed to be in here; 
			if(((WorldInfo.TimeSeconds - vRecentlyZappedActors[i].HitTime) > 1.f))
			{
				DeactivateBeam(vRecentlyZappedActors[i].HitActor);
				MarkZedToUnchain(vRecentlyZappedActors[i]);
			}
		}	
	}*/

}


/** Notification that a direct impact has occurred. */
event ProcessDirectImpact()
{
    if( KFPlayer != none )
    {
        KFPlayer.AddShotsHit(1);
    }
}

function ChainedZapDamageFunction(Actor _TouchActor, Actor _OriginActor)
{
	local vector Momentum;
	local TraceHitInfo HitInfo;
	local Pawn TouchPawn;
	local int TotalDamage;
 
	if (_OriginActor != none)
	{
		Momentum = _TouchActor.Location - _OriginActor.Location;
	}

	//Momentum *= (MomentumScale / DistToHitActor);
	if (ChainDamage > 0)
	{
		TouchPawn = Pawn(_TouchActor);

		// Let script know that we hit something
		if (TouchPawn != none)
		{
			ProcessDirectImpact();
		}
		//`Warn("["$WorldInfo.TimeSeconds$"] Damaging "$_TouchActor.Name$" for "$ChainDamage$", Dist: "$VSize(_TouchActor.Location - _OriginActor.Location));
		
		TotalDamage = ChainDamage * GetUpgradeDamageMod();
		_TouchActor.TakeDamage(TotalDamage, KFPlayer, _TouchActor.Location, Momentum, class'KFDT_EMP_ArcGenerator_DefaultFiremodeZapDamage', HitInfo, self);
	}
}

simulated function SprayEnded()
{
	local int i;

	/*for (i = 0; i < vActiveBeamEffects.Length - 1; i++)
	{
		DeactivateBeam(vActiveBeamEffects[i].oAttachedZed);
	}*/
    //`Warn(vActiveBeamEffects.Length);
	for(i = 0; i < vActiveBeamEffects.Length; i++)
	{
		OnBeamEffectFinished(vActiveBeamEffects[i].oBeam);
	}

	vActiveBeamEffects.Remove(0, vActiveBeamEffects.Length);

}

/**********************************************************************************




 */


defaultproperties
{
	FlameSprayArchetype=KFSprayActor_ArcGenerator'WEP_HRG_ArcGenerator_ARCH.WEP_HRG_ArcGenerator_Spray'

	// Shooting Animations
	bHasFireLastAnims=true
	FireSightedAnims[0]=Shoot
	FireSightedAnims[1]=Shoot_Heavy_Iron
	FireLastHeavySightedAnim=Shoot_Heavy_Iron_Last
    FireHeavyAnim=Shoot_Heavy
    FireLastHeavyAnim=Shoot_Heavy_Last

    // FOV
	MeshIronSightFOV=52
    PlayerIronSightFOV=80

	// Zooming/Position
	IronSightPosition=(X=3,Y=0,Z=0)
	PlayerViewOffset=(X=5.0,Y=9,Z=-3)

	// Depth of field
	DOF_FG_FocalRadius=150
	DOF_FG_MaxNearBlurSize=1

	// Content
	PackageKey="HRG_ArcGenerator"
	FirstPersonMeshName="WEP_1P_HRG_ArcGenerator_MESH.Wep_1stP_HRG_ArcGenerator_Rig"
	FirstPersonAnimSetNames(0)="WEP_1p_HRG_ArcGenerator_ANIM.WEP_1p_HRG_ArcGenerator_ANIM"
	PickupMeshName="WEP_3P_HRG_ArcGenerator_MESH.Wep_HRG_ArcGenerator_Pickup"
	AttachmentArchetypeName="WEP_HRG_ArcGenerator_ARCH.HRG_ArcGenerator_3P"
	MuzzleFlashTemplateName="WEP_HRG_ArcGenerator_ARCH.Wep_HRG_ArcGenerator_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=90 //100
	SpareAmmoCapacity[0]=450 //500
	InitialSpareMags[0]=0
	AmmoPickupScale[0]=0.5
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=150
	minRecoilPitch=115
	maxRecoilYaw=115
	minRecoilYaw=-115
	RecoilRate=0.085
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65034
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	RecoilViewRotationScale=0.25
	IronSightMeshFOVCompensationScale=1.5
    HippedRecoilModifier=1.5

    // Inventory
	InventorySize=9 //10
	GroupPriority=100
	WeaponSelectTexture=Texture2D'WEP_UI_HRG_ArcGenerator_TEX.UI_WeaponSelect_HRG_ArcGenerator'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'
	FiringStatesArray(DEFAULT_FIREMODE)=SprayingFire
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Custom
	FireInterval(DEFAULT_FIREMODE)=+0.1//+0.07 // 850 RPM
	MinAmmoConsumed=2 //3
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALT_FIREMODE
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	Spread(ALTFIRE_FIREMODE) = 0.0085
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
    WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_ArcGeneratorSphereBlast'
	FireInterval(ALTFIRE_FIREMODE)=+1.0 //+0.223 //269 RPMs
	AmmoCost(ALTFIRE_FIREMODE)=15
	PenetrationPower(ALTFIRE_FIREMODE)=40.0 //10.0
	InstantHitDamage(ALTFIRE_FIREMODE)=220 //180 //185 //200
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_EMP_ArcGeneratorSphereImpact'


	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_ArcGenerator'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_ArcGenerator.Play_HRG_ArcGenerator_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_HRG_ArcGenerator.Play_HRG_ArcGenerator_Fire_1P_Loop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_ArcGenerator.Play_HRG_ArcGenerator_AltFire_3P', FirstPersonCue=AkEvent'WW_WEP_HRG_ArcGenerator.Play_HRG_ArcGenerator_AltFire_1P')
    WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_ArcGenerator.Play_HRG_ArcGenerator_Fire_3P_LoopEnd', FirstPersonCue=AkEvent'WW_WEP_HRG_ArcGenerator.Play_HRG_ArcGenerator_Fire_1P_LoopEnd')

	//@todo: add akevents when we have them
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_Microwave_Gun.Play_SA_MicrowaveGun_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_Microwave_Gun.Play_SA_MicrowaveGun_DryFire'
	PilotLightPlayEvent=AkEvent'WW_WEP_HRG_ArcGenerator.Play_HRG_ArcGenerator_PilotLight_Loop'
	PilotLightStopEvent=AkEvent'WW_WEP_HRG_ArcGenerator.Stop_HRG_ArcGenerator_PilotLight_Loop'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	SingleFireSoundIndex=FIREMODE_NONE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

   	AssociatedPerkClasses(0)=class'KFPerk_Survivalist'

   	BonesToLockOnEmpty=(RW_Handle1, RW_BatteryCylinder1, RW_BatteryCylinder2, RW_LeftArmSpinner, RW_RightArmSpinner, RW_LockEngager2, RW_LockEngager1)

 	// AI Warning
 	bWarnAIWhenFiring=true
    MaxAIWarningDistSQ=2250000

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.15f,IncrementWeight=1)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))

	BeamPSCTemplate = ParticleSystem'WEP_HRG_ArcGenerator_EMIT.FX_Beam_Test'
	EmitterPoolClassPath="Engine.EmitterPool"
	oZedCurrentlyBeingSprayed=none;

	MaxNumberOfZedsZapped=3
	MaxDistanceToBeZapped=2500
	ZapInterval=0.07
	ChainDamage=5;
	bAlwaysRelevant = true
	bOnlyRelevantToOwner = false
}