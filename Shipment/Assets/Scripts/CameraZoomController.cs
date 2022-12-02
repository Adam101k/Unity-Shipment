using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
public class CameraZoomController : MonoBehaviour
{
public float zoomSpeed = 1;
public float targetOrtho;
public float smoothSpeed = 2.0f;
public float minOrtho = 1.0f;
public float maxOrtho = 20.0f;
public CinemachineVirtualCamera vcam;

void Start()
    {
        targetOrtho = vcam.m_Lens.OrthographicSize;
    }

void Update() {
            
        float scroll = Input.GetAxis("Mouse ScrollWheel");
        if (scroll != 0.0f)
        {
            targetOrtho -= scroll * zoomSpeed;
            targetOrtho = Mathf.Clamp(targetOrtho, minOrtho, maxOrtho);
        }
        vcam.m_Lens.OrthographicSize = Mathf.MoveTowards(vcam.m_Lens.OrthographicSize, targetOrtho, smoothSpeed * Time.deltaTime);

    }
}