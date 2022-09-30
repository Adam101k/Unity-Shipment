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
    private void LateUpdate()
    {
        var rotation = _mainCamera.transform.rotation;
        transform.LookAt(transform.position + rotation * Vector3.forward, rotation * Vector3.up);
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
