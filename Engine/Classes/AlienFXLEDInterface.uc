class AlienFXLEDInterface extends PlatformInterfaceBase
	native(PlatformInterface);

var int Red;
var int Green;
var int Blue;

	/**
* Perform any initialization
*/
native event Init();
native event Activate();
native event bool SetColor(byte RedPercent, byte GreenPercent, byte BluePercent, byte Brightness = 255);

native event bool LedRestoreLighting();
native event bool LedStopEffects();
native function UpdateAlienFX();
//Depreciated dont use
native event bool LEDSetFlashingRBG(byte redPercentage, byte greenPercentage, byte bluePercentage,
int milliSecondsDuration, int milliSecondsInterval);
//Depreciated dont use
native event bool LEDPulseLighting(byte redPercentage, byte greenPercentage, byte bluePercentage, int
milliSecondsDuration, int milliSecondsInterval);


