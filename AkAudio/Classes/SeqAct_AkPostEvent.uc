class SeqAct_AkPostEvent extends SeqAct_Latent
	native;

var transient int Signal;		// signal (event) used for EndOfEvent
`if(`__TW_WWISE_)
/** If TRUE, will use PlayAkEvent() instead of the audio device to trigger the AkEvent on clients */
var() bool bReplicateToClients;
`endif
cpptext
{
	virtual void FinishDestroy();

	void Activated();
	UBOOL UpdateOp(FLOAT deltaTime);
private:
	void PlayEventOnTargets();
};

/** Event to post on the targeted actor(s) */
var() AkEvent Event;

defaultproperties
{
	ObjName="AkPostEvent"
	ObjCategory="AkAudio"

	OutputLinks.Empty

	InputLinks(0)=(LinkDesc="Post")

	OutputLinks(0)=(LinkDesc="Finished")
}
