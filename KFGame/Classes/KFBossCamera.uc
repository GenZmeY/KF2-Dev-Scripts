//=============================================================================
// KFBossCamera
//=============================================================================
// Camera for third person
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFBossCamera extends GameCameraBase;

struct CameraOffsets
{
	var vector ViewOffset;
	var vector RotOffset;
	var int	   CameraDistance;
};

var CameraOffsets BaseOffsets;
var CameraOffsets BackupOffsets;
var CameraOffsets DeadOffsets;

var	PointLightComponent PointLightTemplate;
var transient	PointLightComponent PointLight;

var KFInterface_MonsterBoss ViewedBoss;

/** Called when the camera becomes inactive */
function OnBecomeActive( GameCameraBase NewCamera )
{
	if ( PointLight == None && PointLightTemplate != None )
	{
		PointLight = new(self) Class'PointLightComponent' (PointLightTemplate);
		PointLight.SetEnabled(true);
	}
}

/** Called when the camera becomes inactive */
function OnBecomeInActive( GameCameraBase NewCamera )
{
	if( PlayerCamera != none && PlayerCamera.PCOwner != none && PlayerCamera.PCOwner.Pawn != none )
	{
		PlayerCamera.PCOwner.SetViewTarget(PlayerCamera.PCOwner.Pawn);
	}

	if ( PointLight != None )
	{
		if( ViewedBoss != none )
		{
			ViewedBoss.GetMonsterPawn().DetachComponent(PointLight);
		}
		PointLight.SetEnabled(false);
		PointLight = none;
	}

    ViewedBoss = none;
}

/**
* Player Update Camera code
*/
function UpdateCamera(Pawn P, GamePlayerCamera CameraActor, float DeltaTime, out TViewTarget OutVT)
{
	local vector		Loc, X,Y,Z;
	local rotator		Rot;
	local CameraOffsets FinalOffsets;

    if (ViewedBoss == none)
    {
        ViewedBoss = KFInterface_MonsterBoss(P);
    }

	if( P != none && PointLight != none && !PointLight.bAttached )
	{
		if(ViewedBoss != none )
		{
            ViewedBoss.GetMonsterPawn().AttachComponent(PointLight);
		}
		PointLight.SetTranslation( Loc - OutVT.Target.Location );
	}
	
	if(ViewedBoss != none && ViewedBoss.UseAnimatedBossCamera() && ViewedBoss.GetBossCameraSocket() != '' )
	{
        ViewedBoss.GetMonsterPawn().Mesh.GetSocketWorldLocationAndRotation( ViewedBoss.GetBossCameraSocket(), Loc, Rot );
		GetAxes( Rot, X,Y,Z );
		Loc += X * ViewedBoss.GetBossCameraOffset().X + Y * ViewedBoss.GetBossCameraOffset().Y + Z * ViewedBoss.GetBossCameraOffset().Z;
		OutVT.POV.Location = Loc;
		OutVT.POV.Rotation = Rot;

		// Apply our animated camera
		PlayerCamera.ApplyCameraModifiers( DeltaTime, OutVT.POV );
	}
	else
	{
		FinalOffsets = ( P != none && P.IsAliveAndWell() ) ? BaseOffsets : DeadOffsets;
        if( !GetOffsets(OutVT.Target, CameraActor, FinalOffsets, Loc, Rot) )
        {
            GetOffsets(OutVT.Target, CameraActor, BackupOffsets, Loc, Rot);
        }

        OutVT.POV.Location = Loc;
        OutVT.POV.Rotation = Rot;
	}
}

/** Get the necessary offsets for the different possible camera types, return whether there is an actor in the way of our desired location */
function bool GetOffsets( Actor Target, GamePlayerCamera CameraActor, out CameraOffsets InOffsets, out vector InLoc, out rotator InRot)
{
	local vector		Pos, HitLocation, HitNormal;
    local Actor			HitActor;
	
	InLoc = Target.Location;
	InRot = Target.Rotation;

	InRot.Yaw += InOffsets.RotOffset.X;
	InRot.Pitch += InOffsets.RotOffset.Y;

	InLoc += InOffsets.ViewOffset >> InRot;
	Pos = InLoc - Vector(InRot) * InOffsets.CameraDistance;
	
	// Try using the backup offsets if we the camera is in a wall
	HitActor = CameraActor.Trace(HitLocation, HitNormal, Pos, InLoc, FALSE, vect(12,12,12));
	
	InLoc = (HitActor == None) ? Pos : HitLocation;

	return (HitActor == None);
}

defaultproperties
{
	BaseOffsets=(ViewOffset=(X=0,Y=85,Z=90), RotOffset=(X=38000,Y=1200,Z=0), CameraDistance=250)
	DeadOffsets=(ViewOffset=(X=0,Y=0,Z=-50), RotOffset=(X=38000,Y=-1500,Z=0), CameraDistance=200)
	BackupOffsets=(ViewOffset=(X=0,Y=0,Z=65), RotOffset=(X=32768,Y=0,Z=0), CameraDistance=300)

	Begin Object Class=PointLightComponent Name=PointLightTemplate_0
		LightColor=(R=255,G=255,B=255,A=255)
		Brightness=1.f
		Radius=250.f
		FalloffExponent=10.f
		CastShadows=true
		CastStaticShadows=true
		CastDynamicShadows=true
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object
	PointLightTemplate=PointLightTemplate_0
}

