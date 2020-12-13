//=============================================================================
// KFPickupFactory_ItemDefault
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 4/1/2014
//=============================================================================

class KFPickupFactory_ItemDefault extends KFPickupFactory_Item;

defaultproperties
{
	// These are the default weapons to load into an item pickup factory, more can be added on the object 
	// Weapons in this list are always loaded into memory if this actor exists in the map
    ItemPickups.Add((ItemClass=class'KFInventory_Armor'))
    ItemPickups.Add((ItemClass=class'KFWeap_AssaultRifle_AR15'))
    ItemPickups.Add((ItemClass=class'KFWeap_Shotgun_MB500'))
    ItemPickups.Add((ItemClass=class'KFWeap_Blunt_Crovel'))
	ItemPickups.Add((ItemClass=class'KFWeap_Pistol_9mm'))
	ItemPickups.Add((ItemClass=class'KFWeap_Revolver_Rem1858'))
	ItemPickups.Add((ItemClass=class'KFWeap_Rifle_Winchester1894'))
	ItemPickups.Add((ItemClass=class'KFWeap_Pistol_Medic'))
	ItemPickups.Add((ItemClass=class'KFWeap_SMG_MP7'))
}
