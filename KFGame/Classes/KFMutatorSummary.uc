//=============================================================================
// KFMutatorSummary
//=============================================================================
// Provides meta data for mutators.
//
// A mutator needs to be registered in the .ini file as follows:
// [MutatorName KFMutatorSummary]
// ClassName=MyPackage.MyMutator
//
// And in the localization file as:
// [MutatorName KFMutatorSummary]
// FriendlyName="My Mutator"
// Description="Description of my mutator"
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================
class KFMutatorSummary extends UIResourceDataProvider
	PerObjectConfig
	Config(Game);

/**
 * Fully qualified classname (package.class) of the mutator.
 */
var config string ClassName;
/**
 * Fully qualified classname of gametypes which this mutator supports.
 * Leave empty if all gametypes are supported.
 */
var config array<string> SupportedGameTypes;
/**
 * Only one mutator belonging to the same group can be active at the same
 * time.
 */
var config array<string> GroupNames;

var	localized string FriendlyName;
var	localized string Description;

/**
 * Disabled items will not be shown in the UI.
 */
var	config bool bIsDisabled;
