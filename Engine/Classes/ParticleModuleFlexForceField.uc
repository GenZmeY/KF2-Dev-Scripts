/**
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleFlexForceField extends ParticleModuleForceFieldBase
	native(Particle)
	hidecategories(ForceFieldComponent);

var(FlexForceField) FlexForceFieldComponent FlexForceField;

event FlexForceFieldComponent GetFlexForceFieldInstance(vector Location)
{
	local FlexForceFieldComponent FF;

	FF = new FlexForceField.Class(FlexForceField);
	FF.SetTickGroup(TG_PreAsyncWork);

	// the FF needs to be colocated with the particle system component (Location), in case its offset
	FF.SetTranslation(Location + FF.Translation);
	
	return FF;
}

defaultproperties
{
	Begin Object Class=FlexForceFieldComponent Name=FF
	End Object
	FlexForceField = FF
}
