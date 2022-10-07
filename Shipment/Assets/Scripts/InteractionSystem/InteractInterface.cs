//do not use this script, going to merge these scripts with PickUpObject.cs
//keeping this script for reference on interactionPrompt

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface InteractInterface
{
    public string InteractionPrompt { get; }
    public bool InteractBool(Interactor interact);
}
