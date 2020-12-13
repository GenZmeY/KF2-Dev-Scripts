/**
 * This class is a helper for downloading an image file via an HTTP URL
 * 
 * Based on
 * John Haynes - War Drum Studios 
 */

class KFHTTPImageDownloader extends Object
	native
	inherits(FTickableObject);

cpptext
{
// FTickableObject interface
	/**
	 * We're always tickable ...
	 */
	virtual UBOOL IsTickable() const 
	{
		return TRUE;
	}

	virtual UBOOL IsTickableWhenPaused() const
	{
		return TRUE;
	}

	/**
	 * Updates our download ...
	 *
	 * @param DeltaTime the amount of time that has passed since the last tick
	 */
	virtual void Tick(FLOAT DeltaTime);

// Helper functions for loading the texture from binary data

	/**
	 * Loads the texture as a PNG from the specified binary data
	 * 
	 * @param Data the array of bytes that represent the downloaded texture data
	 */
	void LoadTexturePNG(TArray<BYTE> & Data);

	/**
	 * Loads the texture as a BMP from the specified binary data
	 * 
	 * @param Data the array of bytes that represent the downloaded texture data
	 */
	void LoadTextureBMP(TArray<BYTE> & Data);
}

/**
 * If set, gets called when the download has completed 
 */
var private delegate<OnDownloadComplete> DownloadCompleteDelegate;

/**
 * The object that handles the actual HTTP download
 */
var private native const pointer HttpDownloader{class FHttpDownloadBinary};

/**
 * The texture that we loaded (don't access this until the DownloadCompleteDelegate has been triggered with success...)
 */
var Texture2D TheTexture;

/**
 * Cached URL for the image
 */
var string ImageURL;

/**
 * Template for the delegate to call when the download has completed
 */
delegate OnDownloadComplete(bool bWasSuccessful);

/**
 * Downloads the image at the specified URL, and calls the specified delegate when the download completes
 * 
 * @param ImgURL the url to download from
 * @param CompleteDelegate the delegate to call when the download completes
 * 
 * @return true if the download has started, false if not
 */
native function bool DownloadImageFromURL(string ImgURL, delegate<OnDownloadComplete> CompleteDelegate);

DefaultProperties
{
	
}
