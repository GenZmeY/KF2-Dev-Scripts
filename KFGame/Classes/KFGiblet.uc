//=============================================================================
// KFGiblet
//=============================================================================
// Giblets are spawned during obliteration
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 8/13/2014
//=============================================================================

class KFGiblet extends Actor
	notplaceable;

/** The component that will be set to the chosen mesh */
var MeshComponent GibMeshComp;

/** The  giblet's sound group based on the destroyed pawn */
var KFPawnSoundGroup SoundGroup;

/** The time when this gib las collided with something in the world (relative to WorldInfo.TimeSeconds) */
var float LastCollisionTime;

/** Retain gibs as long as the player can see it */
simulated function LifespanTimer()
{
    if( LifeSpan < 3.5f && PlayerCanSeeMe() )
	{
        LifeSpan = 3.5f;
	}

	SetTimer(2.f, false, 'LifespanTimer');
}

/** Intialize the mesh from the passed in GibInfo */
simulated function SetMesh(KFGibletInfo InGibInfo)
{
	local StaticMeshComponent SMC;
	local SkeletalMeshComponent SKMC;

	// do the static mesh version of the gib
	if( InGibInfo.GibStaticMesh != none )
	{
		GibMeshComp = new(self) class'KFGibStaticMeshComponent';
		CollisionComponent = GibMeshComp;

		SMC = StaticMeshComponent(GibMeshComp);
		SMC.SetScale(InGibInfo.DrawScale);
		if( InGibInfo.CullDistance > 0 )
		{
			SMC.SetCullDistance(InGibInfo.CullDistance);
		}

		// NOTE: Need to attach before calling SetStaticMesh, so component is in right place before creating physics
		AttachComponent(GibMeshComp);
		SMC.SetStaticMesh( InGibInfo.GibStaticMesh );
	}
	// do the skeletal mesh version of the gib
	else if( InGibInfo.GibSkelMesh != none &&
			 InGibInfo.GibPhysAsset != none )
	{
		GibMeshComp = new(self) class'KFGibSkeletalMeshComponent';
		CollisionComponent = GibMeshComp;
		SKMC = SkeletalMeshComponent(GibMeshComp);
		SKMC.SetSkeletalMesh( InGibInfo.GibSkelMesh );
		SKMC.SetPhysicsAsset( InGibInfo.GibPhysAsset );
		SKMC.SetScale(InGibInfo.DrawScale);
		if( InGibInfo.CullDistance > 0 )
		{
			SKMC.SetCullDistance(InGibInfo.CullDistance);
		}

		AttachComponent(GibMeshComp);
		SKMC.SetHasPhysicsAssetInstance( TRUE ); // this need to comes after the AttachComponent so component is in right place.
	}
	else
	{
		// No valid mesh specified for the giblet
		Destroy();
	}

	// Rigid body collisions events for giblets such as impact blood splats and sounds
	if( GibMeshComp != none && !WorldInfo.bDropDetail && WorldInfo.GetDetailMode() > DM_Medium )
	{
		GibMeshComp.SetNotifyRigidBodyCollision(true);			
	}
}

simulated event RigidBodyCollision(
	PrimitiveComponent HitComponent,
	PrimitiveComponent OtherComponent,
	const out CollisionImpactData RigidCollisionData,
	int ContactIndex )
{
	local int i;
	local KFGoreManager GoreManager;
	local RigidBodyContactInfo ContactInfo;

	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);

	if( GoreManager != none && `TimeSince(LastCollisionTime) > GoreManager.GetTimeBetweenGibBloodSplats() )
	{
		// Play impact sound
		if( OtherComponent != none && OtherComponent.Owner != none &&
			/* don't play zed-on-zed ragdoll collision sounds */
			!OtherComponent.Owner.IsA('KFPawn_Monster') )
		{
			SoundGroup.PlayGibletCollisionSound( self, RigidCollisionData.ContactInfos[ContactIndex].ContactPosition );

			// Leave blood splats on impact
			for( i=0; i<RigidCollisionData.ContactInfos.length; i++ )
			{
				ContactInfo = RigidCollisionData.ContactInfos[i];
				GoreManager.LeaveAPersistentBloodSplat(ContactInfo.ContactPosition, -ContactInfo.ContactNormal);
				//DrawDebugCoordinateSystem(ContactInfo.ContactPosition, rotator(-ContactInfo.ContactNormal), 10, true);
			}

			// Update last collision time
			LastCollisionTime = WorldInfo.TimeSeconds;
		}
	}
}

defaultproperties
{
	TickGroup=TG_PostAsyncWork
	RemoteRole=ROLE_None
	Physics=PHYS_RigidBody

	bNoEncroachCheck=true
	bDestroyedByInterpActor=TRUE
	bCollideActors=true
	bBlockActors=false
	bWorldGeometry=false
	bCollideWorld=FALSE  // we want the gib to use the rigidbody collision.  Setting this to TRUE means that unreal physics will try to control
	bProjTarget=true
	LifeSpan=10.0
	bGameRelevant=true
}


