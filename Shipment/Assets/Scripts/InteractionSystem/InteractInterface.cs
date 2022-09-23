using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface InteractInterface
{
    public string InteractionPrompt { get; }
    public bool InteractBool(Interact interact);
}
