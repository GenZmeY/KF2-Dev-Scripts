class InterpTrackInstAkEvent extends InterpTrackInst
	native;

cpptext
{
	virtual void InitTrackInst(UInterpTrack* Track);
	virtual void TermTrackInst(UInterpTrack* Track);
}

var	float						LastUpdatePosition; 

defaultproperties
{
}
