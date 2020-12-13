//=============================================================================
// KFSeqAct_DamageDestructibleActor
//=============================================================================
// Deals damage to a destructible actor
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_DamageDestructibleActor extends SequenceAction;

var() class<DamageType> Type<AllowAbstract>;
var() int Amount;
Var() bool bInstaKillDamage;


event Activated()
{
	local int DamageAmount;
	local KFDestructibleActor DestructibleInput;
	local SeqVar_Object ObjectInput;

	foreach LinkedVariables(class'SeqVar_Object', ObjectInput, "Destructible Actor")
	{
		DestructibleInput = KFDestructibleActor(ObjectInput.GetObjectValue());
		if (DestructibleInput != none)
		{
			if (bInstaKillDamage)
			{
				DamageAmount = DestructibleInput.GetInstaKillDamage();
			}
			else
			{
				DamageAmount = Amount;
			}

			DestructibleInput.TakeDamage(DamageAmount, none, vect(0, 0, 0), vect(0, 0, 0), Type);
		}
	}
}

DefaultProperties
{
	ObjCategory="Killing Floor"
	ObjName="Damage Destructible Actor"

	VariableLinks.Empty()
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object', LinkDesc="Destructible Actor")
}