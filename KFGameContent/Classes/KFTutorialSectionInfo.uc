//=============================================================================
// KFTutorialSectionInfo
//=============================================================================
// archetype inside GP_Tutorial_ARCH for kfgameinfo_tutorial
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 4/21/2016
//=============================================================================

class KFTutorialSectionInfo extends Object
	hidecategories(Object);

struct STutorialSlide
{
	var() string TitleKey;
	var() string DescriptionKey;
	var() Texture2D UIImage;
	/** Key binds to locate and merge with description text */
	var() array<string> KeyGBAs;

	/** If >= 0, replace this slide from the GamepadSlides array */
	var() int GamepadSlideIndex;

	StructDefaultProperties
	{
		GamepadSlideIndex=INDEX_NONE
	}
};


struct SControllerTutorialSlide
{
	/** Image to use for PS4 builds */
	var() Texture2D PS4Image;
	/** Image to use for xbox one builds */
	var() Texture2D XboxOneImage;
	/** Image to use for xbox 360 builds or on PC with controller */
	var() Texture2D PCImage;

	var() string TitleKey;
	var() string DescriptionKey;

	/** Key binds to locate and merge with description text */
	var() array<string> KeyGBAs;
};


/** Default slides */
var() private array <STutorialSlide> TutorialSlides;
/** DEPRECATED - Override slides used only for gamepad */
var() private array<STutorialSlide> GamepadReplacementSlides;

/** Override slides for use on controller or with consoles */
var() private array<SControllerTutorialSlide> ControllerReplacementSlides;

var() AKEvent VoiceOverOpenEvent;
var() AKEvent VoiceOverCloseEvent;

/** Delay before this screen opens */
var() float OpenDelay;

function array<STutorialSlide> GetSlides(PlayerController PC)
{
    local array<STutorialSlide> MergedSlides;
    local STutorialSlide NextSlide, NewSlide;
   
	if ( GamepadReplacementSlides.Length > 0 )
	{
		 if ( PC.PlayerInput.bUsingGamepad )
		 {
		 	foreach TutorialSlides(NextSlide)
		 	{
				// ControllerReplacementSlides supports multiple platforms
				if( NextSlide.GamepadSlideIndex >= 0 && 
					NextSlide.GamepadSlideIndex < ControllerReplacementSlides.Length )
				{
					NewSlide.TitleKey = ControllerReplacementSlides[NextSlide.GamepadSlideIndex].TitleKey;
					NewSlide.DescriptionKey = ControllerReplacementSlides[NextSlide.GamepadSlideIndex].DescriptionKey;
					NewSlide.KeyGBAs = ControllerReplacementSlides[NextSlide.GamepadSlideIndex].KeyGBAs;
					
					if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Orbis ) )
					{
						NewSlide.UIImage = ControllerReplacementSlides[NextSlide.GamepadSlideIndex].PS4Image;
					}
					else if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Durango ) )
					{
						NewSlide.UIImage = ControllerReplacementSlides[NextSlide.GamepadSlideIndex].XboxOneImage;
					}
					else
					{
						NewSlide.UIImage = ControllerReplacementSlides[NextSlide.GamepadSlideIndex].PCImage;
					}

					MergedSlides.AddItem( NewSlide );
				}
				// DEPRECRATED! Remove this block once ControllerReplacementSlides is fully utilized
		 		else if ( NextSlide.GamepadSlideIndex >= 0 
		 			&& NextSlide.GamepadSlideIndex < GamepadReplacementSlides.Length )
		 		{
		 			MergedSlides.AddItem(GamepadReplacementSlides[NextSlide.GamepadSlideIndex]);
		 		}
		 		else
		 		{
		 			MergedSlides.AddItem(NextSlide);
		 		}
		 	}

		 	return MergedSlides;
		 }
	}

	return TutorialSlides;
}

/** Called from GI when tutorial is requested */
function OpenDelayTimer()
{
	local KFGameInfo_Tutorial GI;

	GI = KFGameInfo_Tutorial(class'WorldInfo'.static.GetWorldInfo().Game);
	if ( GI != None )
	{
		// Don't play this if load screen is still up
		if( class'KFGameEngine'.static.IsFullScreenMoviePlaying() )
		{
			GI.SetTimer( 0.05, false, nameof(OpenDelayTimer), self );
		}
		else
		{
			GI.CreateTutorialHUD(self, true);
		}
	}
}