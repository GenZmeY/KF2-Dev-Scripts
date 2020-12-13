/**
 * This is the post process label renderer
 *
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
class PostProcessLabelRenderer extends ThumbnailLabelRenderer
	native;

cpptext
{
protected:
	/**
	 * Adds the name of the object and anim set
	 *
	 * @param Object the object to build the labels for
	 * @param OutLabels the array that is added to
	 */
	void BuildLabelList(UObject* Object, const ThumbnailOptions& InOptions, TArray<FString>& OutLabels);
}
