class LogitechLEDInterface extends PlatformInterfaceBase
	native(PlatformInterface);

var int Red;
var int Green;
var int Blue;

	/**
* Perform any initialization
*/
native event Init();

native event bool SetColor(int RedPercent, int GreenPercent, int BluePercent, float Brightness = 1.0f);

native event bool LEDSetFlashingRBG(int redPercentage, int greenPercentage, int bluePercentage,
int milliSecondsDuration, int milliSecondsInterval);

native event bool LEDPulseLighting(int redPercentage, int greenPercentage, int bluePercentage, int
milliSecondsDuration, int milliSecondsInterval);

native event bool LedRestoreLighting();
native event bool LedStopEffects();
