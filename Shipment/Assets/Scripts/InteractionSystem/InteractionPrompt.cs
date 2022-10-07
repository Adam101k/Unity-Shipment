//do not use this script, going to merge these scripts with PickUpObject.cs
//keeping this script for reference on interactionPrompt

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class InteractionPrompt : MonoBehaviour
{
    private Camera _mainCamera;
    [SerializeField] private GameObject _promptField;
    [SerializeField] private TextMeshProUGUI _promptText;
    private void Start()
    {
        _mainCamera = Camera.main;
        _promptField.SetActive(false);
    }
    public bool isPromptOn = false;
    public void setUp(string promptText) 
    {
        _promptText.text = promptText;
        _promptField.SetActive(true);
        isPromptOn = true;
    }
    public void Close()
    {
        _promptField.SetActive(false);
        isPromptOn = false;
    }
}
