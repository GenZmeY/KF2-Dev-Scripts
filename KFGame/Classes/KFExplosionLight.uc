//=============================================================================
// KFExplosionLight
//=============================================================================
// Template class for KFExplosionLightComponent
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFExplosionLight extends Object
	native(Effect)
	hidecategories(Object);

struct native LightValues
{
	var() float StartTime;
	var() float Radius;
	var() float Brightness;
	var() color LightColor;
	
	structdefaultproperties
	{
		LightColor=(R=255,G=255,B=255,A=255)
	}
};

/** Specifies brightness, radius, and color of light at various points in its lifespan */
var() array<LightValues> TimeShift;

defaultproperties
{
	TimeShift(0)={(
		StartTime=0.0,
		Radius=128,
		Brightness=8,
		LightColor=(B=224,G=254,R=255,A=255)
		)}
	TimeShift(1)={(
		StartTime=0.2,
		Radius=64,
		Brightness=8,
		LightColor=(B=0,G=211,R=252,A=255)
		)}
	TimeShift(2)={(
		StartTime=0.25,
		Radius=64,
		Brightness=0,
		LightColor=(B=0,G=123,R=253,A=255)
		)}
}
