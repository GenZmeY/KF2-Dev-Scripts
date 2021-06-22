class KFWeeklyOutbreakInformation extends Object
	PerObjectConfig
    Config(Game)
    native(UI);

//Item ID reward
var config array<int> RewardIDs;

//Map index for lookup
var config int Index;

//Icon for the weekly mode
var config string IconPath;

//Array of icon paths, one per listed modifier
var config array<string> ModifierIconPaths;

//Friendly Name of the mode
var localized string FriendlyName;

//List of any description info that we need (typically difficulty and a short description)
var localized array<string> DescriptionStrings;

//List of any modifer information we need specific to the mode
var localized array<string> ModifierDescriptions;

cpptext
{
	/** Num of Weekly events available */
    static const int NumWeeklyEvents = 12; 
}
DefaultProperties
{

}