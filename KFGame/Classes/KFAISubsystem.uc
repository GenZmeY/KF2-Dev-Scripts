//=============================================================================
// KFAISystem
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAISubsystem extends BaseAISubsystem
	config(Engine)
	native(AI);

// if you want a behavior tree template to get loaded it needs to be in this list
//var array<BTTemplate> BehaviorTreeTemplatesToLoadForThisSystem;

// if you want a Enviromental terain query template to get loaded it needs to be in this list
//var array<ETQTemplate> ETQ_TemplatesToLoadForThisSystem;

/** Used to access the difficulty values from KFGame for BaseAI */
event float GetDifficultyValue(int Index)
{
	return class'KFGameDifficultyInfo'.static.GetDifficultyValue( Index );
}

cpptext
{
};

defaultproperties
{
}