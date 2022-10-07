//do not use this script, going to merge these scripts with PickUpObject.cs
//keeping this script for reference on interactionPrompt

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Cart : MonoBehaviour, InteractInterface
{
    [SerializeField] private string _prompt;
    public string InteractionPrompt => _prompt;
    public bool InteractBool(Interactor interact)
    {
        Debug.Log("Picked Up Cart");
        return true;
    }
}
