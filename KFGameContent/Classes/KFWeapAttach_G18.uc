//=============================================================================
// KFWeapAttach_G18
//=============================================================================
// Custom 3rd person weapon attachment for the Glock 18 and Riot Shield
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_G18 extends KFWeapAttach_DualBase;

function bool ChooseActiveWeapon(byte FlashCount)
{
	bPlayFXOnSecondWeapon = false;
	return bPlayFXOnSecondWeapon;
}