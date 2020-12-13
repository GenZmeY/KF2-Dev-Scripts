//=============================================================================
// KFGFxPopup_Gamma
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 1/10/2014
//=============================================================================

class KFGFxPopup_Gamma extends KFGFxObject_Popup;

//@HSL_MOD_BEGIN - amiller 5/25/2016 - Adding support to save extra data into profile settings
`include(KFProfileSettings.uci);
//@HSL_MOD_END
var GFxObject GammaSlider;
var string GammaImagePath;

function InitializePopup( KFGFxMoviePlayer_Manager InManager )
{
	local float GammaMult;

    Super.InitializePopup(InManager);

	GammaSlider = GetObject("mainSlider");
	if(Manager.CachedProfile != none)
	{
		Manager.CachedProfile.GetProfileSettingValueFloat(KFID_GammaMultiplier, GammaMult);  
	}
`if (`notdefined(FINAL_RELEASE))
	else if(class'WorldInfo'.static.IsPlayInEditor())
	{
		GammaMult = class'KFGameEngine'.default.DefaultGammaMult;
	}
`endif

	// Multiplying by 100 so we can go 0-100 with a snapInterval of 1 for consistency. HSL_BB
	GammaSlider.SetFloat("value", GammaMult*100);
	SetString("imagePath", "img://"$GammaImagePath);

 	Manager.bEnableGammaCorrection = true;
 	Manager.RefreshViewportFlags();
}

event OnClosed()
{
    Super.OnClosed();
    Manager.bEnableGammaCorrection = false;
    Manager.RefreshViewportFlags();
	Manager.SaveConfig();
}

function SetGamma( float GammaValue )
{
	local KFGameEngine KFGE;

	KFGE = KFGameEngine(Class'Engine'.static.GetEngine());
	KFGE.GammaMultiplier = GammaValue;
	KFGE.SaveConfig();

	class'KFGameEngine'.static.SetGamma( GammaValue );
	//class'KFGameEngine'.default.GammaMultiplier = GammaValue;
	Manager.CachedProfile.SetProfileSettingValueFloat(KFID_GammaMultiplier, GammaValue);
	Manager.CachedProfile.SetProfileSettingValueInt(KFID_SetGamma, 1);

	class'KFGameEngine'.static.StaticSaveConfig();
}

function ResetGamma()
{
	local float DefaultGamma;
	local KFGameEngine KFGE;
	//@HSL_MOD_BEGIN - amiller 5/25/2016 - Adding support to save extra data into profile settings
	DefaultGamma = Manager.CachedProfile.GetDefaultFloat(KFID_GammaMultiplier);

	// Multiplying by 100 so we can go 0-100 with a snapInterval of 1 for consistency. HSL_BB
	GammaSlider.SetFloat("value", DefaultGamma*100);
	`log("RESET GAMME: DefaultGamma-" @DefaultGamma @"Slider Value -" @(DefaultGamma * 100));
	KFGE = KFGameEngine(Class'Engine'.static.GetEngine());
	KFGE.GammaMultiplier = DefaultGamma;
	KFGE.SaveConfig();

	Manager.CachedProfile.SetProfileSettingValueFloat(KFID_GammaMultiplier, DefaultGamma);
    class'KFGameEngine'.static.SetGamma( DefaultGamma );
	//class'KFGameEngine'.default.GammaMultiplier = DefaultGamma;
//@HSL_MOD_END
	class'KFGameEngine'.static.StaticSaveConfig();
}


function Callback_ClosedPopup()
{
	Manager.bSetGamma = true;
	Manager.CachedProfile.Save( GetLP().ControllerId );
//@SABER_EGS_BEGIN 
	ClosePopUp();
//@SABER_EGS_END
}

function Callback_GammaChanged( float NewGamma )
{
	// Dividing by 100 so we can go 0-100 with a snapInterval of 1 for consistency. HSL_BB
	SetGamma( NewGamma/100 );
}

function Callback_DefaultGamma()
{
	ResetGamma();
}

defaultproperties
{
	GammaImagePath="UI_GammaPopup_TEX.KF2_Brightess_Calibration"
}
