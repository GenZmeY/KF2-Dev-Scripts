//=============================================================================
// AIPlugin
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class AIPlugin extends PluginBase within BaseAIController
	native(Plugin)
	abstract;

var const protected{protected} BaseAIController MyBaseAIController;
var const protected{private} bool bCustomSetupController;

cpptext
{
	virtual UBOOL SetupController(class ABaseAIController* Owner);
	// Called if bCustomSetupController == true
	virtual UBOOL SetupControllerImpl(class ABaseAIController* Owner) PURE_VIRTUAL(UPluginBase::SetupConrollerImpl, return TRUE;);

	UBOOL HasCustomControllerSetup() const
	{
		return bCustomSetupController;
	}

	FORCEINLINE const ABaseAIController* GetController() const
	{
		return MyBaseAIController;
	}

	FORCEINLINE ABaseAIController* GetController()
	{
		return MyBaseAIController;
	}
};

event ScriptSetUp()
{

}

/**
 * ===========
 * DEBUG STATES
 * ===========
 */
state DEBUGSTATE
{
	function BeginState( Name PreviousStateName )
	{
		//debug
		`AILog( "BEGINSTATE"@PreviousStateName, 'State' );
	}

	function EndState( Name NextStateName )
	{
		//debug
		`AILog( "ENDSTATE"@NextStateName, 'State' );
	}

	function PushedState()
	{
		//debug
		`AILog( "PUSHED", 'State' );
	}

	function PoppedState()
	{
		//debug
		`AILog( "POPPED", 'State' );
	}

	function ContinuedState()
	{
		//debug
		`AILog( "CONTINUED", 'State' );
	}

	function PausedState()
	{
		//debug
		`AILog( "PAUSED", 'State' );
	}
}

defaultproperties
{
	bCustomSetupController=false
}
