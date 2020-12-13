//=============================================================================
// KFGoreChunkAttachment_Skull
//=============================================================================
// Gore chunk attachment with special attachment detachment logic for the skull
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 6/4/2014
//=============================================================================

class KFGoreChunkAttachment_Skull extends KFGoreChunkAttachmentInfo
	hidecategories(Object)
	editinlinenew;

/** The skull gore chunk is used only when one or two head chunks are removed */
simulated function bool ShouldAttachGoreChunk(KFPawn_Monster InPawn)
{
	return InPawn.NumHeadChunksRemoved < 3;
}

/** If attached, the skull gore chunk is detached when more than 2 head chunks are removed */
simulated function bool ShouldDetachGoreChunk(KFPawn_Monster InPawn)
{
	return InPawn.NumHeadChunksRemoved >= 3 && (InPawn.bPlayedDeath || InPawn.bIsHeadless);
}


