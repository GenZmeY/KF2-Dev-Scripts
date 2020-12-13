//=============================================================================
// AnimationProxy
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class CodeSpeedTestCommandlet extends Commandlet
	native;

var transient object CurrentPackage;

cpptext
{
	/**
	* Commandlet entry point
	*
	* @param	Params	the command line parameters that were passed in.
	*
	* @return	0 if the commandlet succeeded; otherwise, an error code defined by the commandlet.
	*/
	virtual INT Main(const FString& Params);
};
