//=============================================================================
// KFPersistentBloodActor
//=============================================================================
// Placeable actor that sprays persistent blood on level load
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 4/7/2014
//=============================================================================

class KFPersistentBloodActor extends Actor
	native(Effect)
	placeable;

/** CONST values */
var const float ConeSpreadRadius;
var const  float MaxConeSpreadDegrees;

/** Activate/Deactivate the persistent blood actor */
var() bool bEnabled;
/** Scalar for amount of blood */
var() float BloodScale<UIMin=0.0|UIMax=1.0|ClampMin=0.0|ClampMax=1.0>;
/** Used to specify whether to spawn the blood in a specific direction (0) or a cone effect (>0) */
var() float BloodSpread<UIMin=0.0|UIMax=1.0|ClampMin=0.0|ClampMax=1.0>;

/** Used to visualize the blood spread */
var const DrawConeComponent PreviewCone;

cpptext
{
#if WITH_EDITOR
	/** Process change of property value for the light */
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
#endif
}

simulated function TryAddBloodSplats()
{
	if( bEnabled && BloodScale > 0.f )
	{
		LeaveBloodSplats();
	}
}

simulated function LeaveBloodSplats()
{
	local KFGoreManager GoreManager;
	local vector FaceDir, UpDir, RightDir;
	local vector ConeRimCenter, SamplePoint, TraceDir;
	local int NumConeSegmentTraces, Y, Z, Trace;
	local float ConeRimRadius, UpDistance, RightDistance;

	// Grab the gore manager
	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
	if( GoreManager != none )
	{
		GetAxes(Rotation, FaceDir, RightDir, UpDir);

		if( BloodSpread == 0.f )
		{
			// Leave a splat on level geometry along the direction being shot at
			TraceDir = FaceDir;
			GoreManager.LeaveAPersistentBloodSplat(Location, TraceDir,BloodScale, false, true);
		}
		else
		{
			NumConeSegmentTraces = FCeil(25*BloodSpread);
        	ConeRimCenter = Location + ConeSpreadRadius*FaceDir;
        	ConeRimRadius = Tan(MaxConeSpreadDegrees * BloodSpread * PI / 180.f) * ConeSpreadRadius;

			for( Y=-1; Y<=1; Y+=2 )
			{
				for(Z=-1; Z<=1; Z+=2 )
				{
					for( Trace = 0; Trace < NumConeSegmentTraces; Trace++ )
					{
						RightDistance = FRand() * ConeRimRadius;
						UpDistance = FRand() * ConeRimRadius;
						SamplePoint = ConeRimCenter + Y * RightDir * RightDistance + Z * UpDir * UpDistance;
						TraceDir = Normal(SamplePoint - Location);
						GoreManager.LeaveAPersistentBloodSplat(Location, TraceDir,BloodScale, false, true);

						// START DEBUG
						// DrawDebugLine(Location, Location + 500*TraceDir, 255, 255, 255, true);
						// DrawDebugStar(Location + 500*TraceDir, 5, 255, 0, 0, true);
						// END DEBUG
					}
				}
			}
		}
	}
}

simulated event PreBeginPlay()
{
	TryAddBloodSplats();
}

simulated function Reset()
{
	TryAddBloodSplats();
}

defaultproperties
{
	// Const values
	ConeSpreadRadius=500.f
	MaxConeSpreadDegrees=60.f

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'ENG_EditorResources_TEX.Gore.S_PersistentBloodActor'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="PersistentBlood"
	End Object
	Components.Add(Sprite)

	Begin Object Class=ArrowComponent Name=Arrow
		ArrowColor=(R=150,G=200,B=255)
		ArrowSize=1
		bTreatAsASprite=True
		HiddenGame=true
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Arrow)

	Begin Object Class=DrawConeComponent Name=SpreadCone
		ConeColor=(R=150,G=200,B=255)
		ConeRadius=500.0
		ConeAngle=44.0
		HiddenGame=true
		HiddenEditor=true
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(SpreadCone)
	PreviewCone=SpreadCone

	// Actor properties
    bStatic=true
	bMovable=false
	bCollideActors=false
	bBlockActors=false

	bEnabled=TRUE
	BloodScale=1.f
	BloodSpread=0.f
}
