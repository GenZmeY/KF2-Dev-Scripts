//=============================================================================
// KFGoreChunkAttachmentInfo
//=============================================================================
// Gore Attachment info when a bone is dismembered
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 5/29/2014
//=============================================================================

class KFGoreChunkAttachmentInfo extends Object
	hidecategories(Object)
	editinlinenew;

/** The static mesh gore chunk to be attached */
var() Staticmesh StaticMesh;
/** Name of the socket the chunk is attached to */
var() name SocketName;
/** List of bones that when dismembered should spawn this attachment */
var() array<name> DismemberedBoneList;

/** Whether the gore chunk should be attached */
simulated function bool ShouldAttachGoreChunk(KFPawn_Monster InPawn)
{
	return true;
}

/** Whether the gore chunk should be detached */
simulated function bool ShouldDetachGoreChunk(KFPawn_Monster InPawn)
{
	return false;
}

