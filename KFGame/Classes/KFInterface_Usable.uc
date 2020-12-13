/**
 * Interface for actors that can Speak
 * 
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
interface KFInterface_Usable;

/** Checks if this actor is presently usable */
simulated function bool GetIsUsable( Pawn User );
/** Return the index for our interaction message. */
function int GetInteractionIndex( Pawn User );
