//=============================================================================
// AIDebugGoal.uc
//=============================================================================
// Actor that can be used to test AI pathing. Place one in a level and
// use the AIPathTo <goalname> cheat
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AIDebugGoal extends Actor
	placeable;

/** This is the name you input when using the AIPathTo cheat (i.e, "AIPathTo GoalName") - use something easy to remember. */
var() name  GoalName;

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'ENG_EditorResources_TEX.AI.KF_StorySquads_Ico'
		HiddenGame=false
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		Scale=0.2f
	End Object
	Components.Add(Sprite)
	GoalName=GoalName
}
