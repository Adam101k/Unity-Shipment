using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Cart : MonoBehaviour, InteractInterface
{
    [SerializeField] private string _prompt;
    public string InteractionPrompt => _prompt;
    public bool InteractBool(Interact interact)
    {
        Debug.Log("Picked Up Cart");
        return true;
    }
}
