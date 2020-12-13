class KFGFxStartContainer_NewsImageHolder extends KFGFxObject_Container;

var string NewsImageLink;
var KFHTTPImageDownloader ImageDownLoader;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	Super.Initialize(NewParentMenu);
	//DownloadNewsImage();
	LocalizeContainer();
}

function LocalizeContainer()
{
	local GFxObject LocalizedObject;

	LocalizedObject = CreateObject("Object");
	LocalizedObject.SetString("newsTitle", class'KFGFxMenu_StartGame'.default.NewsPageString);
	LocalizedObject.SetString("closeButton", class'KFCommon_LocalizedStrings'.default.BackString);	
	LocalizedObject.SetString("failedToLoad", Localize("StartMenuHelperText", "FailedToLoadNewsString", "KFGame"));

	SetObject("localizedText", LocalizedObject);
}

function DownloadNewsImage()
{
	if(NewsImageLink != "")
	{
		ImageDownloader = new(Outer) class'KFHTTPImageDownloader';
		ImageDownloader.DownloadImageFromURL(NewsImageLink, ImageDownloadComplete);
	}
}

function ImageDownloadComplete(bool bWasSuccessful)
{
	if(bWasSuccessful) {
		SetString("newsImage", "Img://" $PathName(ImageDownloader.TheTexture));
	} else {
		`log("Failed to load image.  May be unsupported format");
	}
}

defaultproperties
{
	NewsImageLink="http://media.tripwirecdn.com/kf2news/currentnewsimage.jpg"
}