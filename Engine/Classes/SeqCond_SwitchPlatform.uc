/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
class SeqCond_SwitchPlatform extends SequenceCondition
	native(Sequence);

cpptext
{
	virtual void Activated();
};


defaultproperties
{
	ObjName="Platform"
	ObjCategory="Switch Platform"

	OutputLinks(0)=(LinkDesc="Default")
	OutputLinks(1)=(LinkDesc="Desktop")
	OutputLinks(2)=(LinkDesc="Console (non-mobile)")
	OutputLinks(3)=(LinkDesc="Mobile")
	OutputLinks(4)=(LinkDesc="Windows")
	OutputLinks(5)=(LinkDesc="Xbox360")
	OutputLinks(6)=(LinkDesc="PS3")
	OutputLinks(7)=(LinkDesc="iPhone")
	OutputLinks(8)=(LinkDesc="Tegra2")
	OutputLinks(9)=(LinkDesc="Linux")
	OutputLinks(10)=(LinkDesc="MacOS")
	OutputLinks(11)=(LinkDesc="NGP")
	OutputLinks(12)=(LinkDesc="WiiU")
	OutputLinks(13)=(LinkDesc="Flash")
//@HSL_BEGIN_PS4
	OutputLinks(14)=(LinkDesc="Orbis")
//@HSL_END_PS4
//@HSL_BEGIN_XBOX
    OutputLinks(15)=(LinkDesc="Xbox One")
//@HSL_END_XBOX

	VariableLinks.Empty
}
