//=============================================================================
// KFSM_Evade_Fear
//=============================================================================
// Handles playing fear variant evades.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
 
class KFSM_Evade_Fear extends KFSM_Evade;

DefaultProperties
{
	Handle=KFSM_Evade_Fear

	// ---------------------------------------------
	// Animations
	EvadeAnims(DIR_Forward)=(Anims=(EvadeFear_F_V1, EvadeFear_F_V2))
	EvadeAnims(DIR_Backward)=(Anims=(EvadeFear_B_V1, EvadeFear_B_V2))
	EvadeAnims(DIR_Left)=(Anims=(EvadeFear_L_V1, EvadeFear_L_V2))
	EvadeAnims(DIR_Right)=(Anims=(EvadeFear_R_V1, EvadeFear_R_V2))
	EvadeAnims(DIR_ForwardLeft)=(Anims=(EvadeFear_FL_V1, EvadeFear_FL_V2))
	EvadeAnims(DIR_ForwardRight)=(Anims=(EvadeFear_FR_V1, EvadeFear_FR_V2))
	EvadeAnims(DIR_BackwardLeft)=(Anims=(EvadeFear_BL_V1, EvadeFear_BL_V2))
	EvadeAnims(DIR_BackwardRight)=(Anims=(EvadeFear_BR_V1, EvadeFear_BR_V2))
}