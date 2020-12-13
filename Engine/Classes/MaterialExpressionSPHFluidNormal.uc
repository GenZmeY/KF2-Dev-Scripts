/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionSPHFluidNormal extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

var Texture		DefaultTexture;
var ExpressionInput	DepthMipmapThreshold;

cpptext
{
	virtual INT Compile(FMaterialCompiler* Compiler, INT OutputIndex);
	virtual FString GetCaption() const;

	/**
	 * Replaces references to the passed in expression with references to a different expression or NULL.
	 * @param	OldExpression		Expression to find reference to.
	 * @param	NewExpression		Expression to replace reference with.
	 */
	virtual void SwapReferenceTo(UMaterialExpression* OldExpression,UMaterialExpression* NewExpression = NULL);
}

defaultproperties
{
	DefaultTexture=Texture2D'EngineResources.DefaultTexture'
	MenuCategories(0)="Texture"
}
