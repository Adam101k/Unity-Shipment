using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FuelTank : MonoBehaviour, InteractInterface
{
    [SerializeField] private string _prompt;
    public string InteractionPrompt => _prompt;
    public bool InteractBool(Interact interact)
    {
        Debug.Log("Press E To Pick Up Fuel Tank");
        return true;
    }
}
