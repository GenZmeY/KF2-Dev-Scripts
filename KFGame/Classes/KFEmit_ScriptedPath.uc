class KFEmit_ScriptedPath extends KFEmit_TraderPath;

simulated function bool ShouldStopPathing()
{
	return false;
}