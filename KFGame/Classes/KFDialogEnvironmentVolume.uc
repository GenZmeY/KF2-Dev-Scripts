//=============================================================================
// KFDialogEnvironmentVolume
//=============================================================================
// Volume that triggers dialog based on environment settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDialogEnvironmentVolume extends Volume
	hidecategories(Volume,Collision,Attachment,Physics,Mobile)
	placeable;

`include(KFGameDialog.uci)

enum EDialogEnvironment
{
	DENV_DarkOutside,
	DENV_DarkInside,
	DENV_Raining,
	DENV_ColdInside,
	DENV_ColdOutside,
	DENV_HotInside,
	DENV_HotOutside,
	DENV_Foggy,
	DENV_Snow,
	DENV_Gross,
	DENV_Smelly,
	DENV_HighTech,
	DENV_OldSchoolHighTech,
	DENV_Cloning,
	DENV_Experiments,
	DENV_Torture,
	DENV_BioMatter,
	DENV_Aftermath,
	DENV_Cave,
	DENV_Underground
};

var() EDialogEnvironment Environment;

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local KFPawn_Human KFPH;

	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	KFPH = KFPawn_Human(Other);
	if ( KFPH == none )
	{
		return;
	}

	KFPH.EnvironmentDialogEventID = `SITU_DarkOutside + Environment;
}

event Untouch( Actor Other )
{
	local KFPawn_Human KFPH;

	super.Untouch(Other);

	KFPH = KFPawn_Human(Other);
	if ( KFPH == none )
	{
		return;
	}

	if( KFPH.EnvironmentDialogEventID == `SITU_DarkOutside + Environment )
	{
		KFPH.EnvironmentDialogEventID = 0;
	}
}