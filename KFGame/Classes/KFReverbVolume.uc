class KFReverbVolume extends ReverbVolume
    native(Effect)
	placeable
	hidecategories(Advanced, Attachment, Collision, Volume, Toggle, UAudio);

struct native WWiseEnvironmentSettings
{
    var() ReverbPreset  EnvironmentID;
    var() float         EnvironmentValue;
    var() float         FadeTime;

    structdefaultproperties
	{
		EnvironmentID=REVERB_Default
		EnvironmentValue=1.0f
		FadeTime=1.0f
	}
};

struct native WwiseStateSettings
{
    var() name StateGroupName;
    var() name StateName;
};

/** WWise environment (auxiliary bus) settings to use for this volume */
var() editfixedsize array<WWiseEnvironmentSettings> ReverbEnvironments;

var() WwiseStateSettings StateSettings;

/** How much of the calculated audio occlusion value to apply to sounds played witin this volume whose listeners are also within this volume */
var() float IntraVolumeOcclusionScalar<ClampMin = 0.0 | ClampMax = 1.0>;

var array<Name> EnvironmentNames;

/** Array of distances to play eccho sounds at associated with each ReverbPreset */
var array<float> EnvironmentEchoDistances;

cpptext
{
	virtual void SetEnvironmentalEffects();
	virtual FName GetEnvironmentName() { return ReverbEnvironments.Num() > 0 ? EnvironmentNames(ReverbEnvironments(0).EnvironmentID) : NAME_None; }
    virtual float GetIntraVolumeOcclusionScalar(){ return IntraVolumeOcclusionScalar; }
}

/**
 * Get the EchoDistance based on the ReverbPreset of this volume
 *
 * @return The EchoDistance for the ReverbPreset this volume is set to
 */
simulated function float GetEnvironmentEchoDistance()
{
    if( ReverbEnvironments.Length > 0 )
    {
        return EnvironmentEchoDistances[ReverbEnvironments[0].EnvironmentID];
    }

    return 0.0;
}

simulated static function CalculateEchoVolumeAndDistance( WorldInfo WI, vector SourceLocation, out ReverbVolume EchoVolume, out float EchoDistance )
{
    EchoVolume = WI.GetReverbVolume( SourceLocation );

    if( EchoVolume != none )
    {
        EchoDistance = EchoVolume.GetEnvironmentEchoDistance();
    }
    else
    {
        EchoDistance = class'KFReverbVolume'.default.EnvironmentEchoDistances[REVERB_Default];
    }
}

simulated static function CalculateEchoLocationAndDelay( ReverbVolume EchoVolume, vector SourceLoc, vector EchoDir, float EchoDist, out vector EchoLoc, out float EchoDelay )
{
    local vector NewHitLocation, HitNormal;

    // Calculate the EchoDistance (it's delay actually). 34029 UUS/S is the speed
    // of sound at sea level
    if( EchoDist > 0 )
    {
        EchoDelay = FMin((EchoDist/34029.0) * 3,5.0);
    }
    else
    {
        EchoDelay = 0;
    }

    if( EchoVolume != none )
    {
        // Calculate the echo sound locations, but trace twice as far out initially to find the edges of the volume
        EchoLoc = SourceLoc + EchoDir * EchoDist * 2.f;

        // Check to see if this echo location will be outside the volume for the front left echo,
        // and if so pull it back inside the volume
        EchoVolume.TraceComponent(NewHitLocation, HitNormal, EchoVolume.CollisionComponent, SourceLoc, EchoLoc);
        if( NewHitLocation != EchoLoc )
        {
            EchoLoc = NewHitLocation - ((NewHitLocation - SourceLoc) * 0.05);

            // update the delay
            EchoDelay = FMin((VSize(NewHitLocation - SourceLoc)/34029.0) * 3,5.0);
            //`log("AdjustedDelay = "$(VSize(NewHitLocation - SourceLoc)/100.0)$" Meters delay = "$EchoDelay);
            return;
        }
    }

    // default echo location
    EchoLoc = SourceLoc + EchoDir * EchoDist;
}

defaultproperties
{
    ReverbEnvironments(0)=()

    // by default, use all of the calculated occlusion
    IntraVolumeOcclusionScalar=1.f

    EnvironmentNames(REVERB_Default)="NAME_None"
    EnvironmentNames(REVERB_Bathroom)="NAME_None"
    EnvironmentNames(REVERB_StoneRoom)="NAME_None"
    EnvironmentNames(REVERB_Auditorium)="NAME_None"
    EnvironmentNames(REVERB_ConcertHall)="NAME_None"
    EnvironmentNames(REVERB_Cave)="NAME_None"
    EnvironmentNames(REVERB_Hallway)="NAME_None"
    EnvironmentNames(REVERB_StoneCorridor)="NAME_None"
    EnvironmentNames(REVERB_Alley)="NAME_None"
    EnvironmentNames(REVERB_Forest)="Outdoor_Forest"
    EnvironmentNames(REVERB_City)="Outdoor_City"
    EnvironmentNames(REVERB_Mountains)="Outdoor_Mountain"
    EnvironmentNames(REVERB_Quarry)="NAME_None"
    EnvironmentNames(REVERB_Plain)="NAME_None"
    EnvironmentNames(REVERB_ParkingLot)="NAME_None"
    EnvironmentNames(REVERB_SewerPipe)="NAME_None"
    EnvironmentNames(REVERB_Underwater)="NAME_None"
    EnvironmentNames(REVERB_SmallRoom)="Indoor_Small"
    EnvironmentNames(REVERB_MediumRoom)="Indoor_Medium"
    EnvironmentNames(REVERB_LargeRoom)="Indoor_Large"
    EnvironmentNames(REVERB_MediumHall)="NAME_None"
    EnvironmentNames(REVERB_LargeHall)="NAME_None"
    EnvironmentNames(REVERB_Plate)="NAME_None"

    EnvironmentEchoDistances(REVERB_Default)=200 // 25 meters
    EnvironmentEchoDistances(REVERB_Bathroom)=200 // 10 meters
    EnvironmentEchoDistances(REVERB_StoneRoom)=200 // 10 meters
    EnvironmentEchoDistances(REVERB_Auditorium)=200 // 200 meters
    EnvironmentEchoDistances(REVERB_ConcertHall)=200 // 200 meters
    EnvironmentEchoDistances(REVERB_Cave)=200 // 15 meters
    EnvironmentEchoDistances(REVERB_Hallway)=200 // 5 meters
    EnvironmentEchoDistances(REVERB_StoneCorridor)=200 // 5 meters
    EnvironmentEchoDistances(REVERB_Alley)=200 // 15 meters
    EnvironmentEchoDistances(REVERB_Forest)=200 // 100 meters
    EnvironmentEchoDistances(REVERB_City)=200 // 250 meters
    EnvironmentEchoDistances(REVERB_Mountains)=200 // 500 meters
    EnvironmentEchoDistances(REVERB_Quarry)=200 // 100 meters
    EnvironmentEchoDistances(REVERB_Plain)=200 // 500 meters
    EnvironmentEchoDistances(REVERB_ParkingLot)=200 // 50 meters
    EnvironmentEchoDistances(REVERB_SewerPipe)=200 // 5 meters
    EnvironmentEchoDistances(REVERB_Underwater)=0 // 0 meters
    EnvironmentEchoDistances(REVERB_SmallRoom)=200 // 5 meters
    EnvironmentEchoDistances(REVERB_MediumRoom)=200 // 10 meters
    EnvironmentEchoDistances(REVERB_LargeRoom)=200 // 25 meters
    EnvironmentEchoDistances(REVERB_MediumHall)=200 // 25 meters
    EnvironmentEchoDistances(REVERB_LargeHall)=200 // 50 meters
    EnvironmentEchoDistances(REVERB_Plate)=200 // 25 meters
}

