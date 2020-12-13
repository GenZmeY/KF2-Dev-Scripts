/**
 * This object is responsible for the enumeration of downloadable content bundles on Dingo
 */
class DownloadableContentEnumeratorDingo extends DownloadableContentEnumerator
	native;

/**
 * Uses the OnlineContentInterface to populate the DLC data for all signed in users
 */
function FindDLC()
{
	local OnlineSubsystem OnlineSub;
	local array<OnlineContent> FoundBundles;

	DLCBundles.Length = 0;
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None && OnlineSub.ContentInterface != None)
	{
		// Start the read - NOTE this is synchronous and LocalUserNum is ignored on Dingo
		if (OnlineSub.ContentInterface.ReadDownloadableContentList(-1))
		{
			FoundBundles.Length = 0;

			OnlineSub.ContentInterface.GetDownloadableContentList(-1, FoundBundles);

			// Skip the call if the array is empty
			if (FoundBundles.Length > 0)
			{
				AppendDLC(FoundBundles);
			}
		}
	}

	TriggerFindDLCDelegates();
}

/**
 * Appends the specified array to the DLCBundles array
 *
 * @param Bundles the array to append
 */
native function AppendDLC(const out array<OnlineContent> Bundles);

/**
 * Can't work, so ignore the call
 *
 * @param DLCName the name of the DLC bundle to delete
 */
function DeleteDLC(string DLCName)
{
	// Purposefully empty and doesn't call super
}
