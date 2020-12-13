class RazerLEDInterface extends PlatformInterfaceBase
	native(PlatformInterface);

var int Red;
var int Green;
var int Blue;

	/**
* Perform any initialization
*/
native event Init();

native event bool SetColor(byte RedPercent, byte GreenPercent, byte BluePercent, float Brightness = 1.0f);

native event bool LEDSetFlashingRBG(byte redPercentage, byte greenPercentage, byte bluePercentage,
int milliSecondsDuration, int milliSecondsInterval);

native event bool LEDPulseLighting(byte redPercentage, byte greenPercentage, byte bluePercentage, int
milliSecondsDuration, int milliSecondsInterval);

native event bool LedRestoreLighting();
native event bool LedStopEffects();
