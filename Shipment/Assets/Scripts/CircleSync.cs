using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CircleSync : MonoBehaviour
{
    public static int PosID = Shader.PropertyToID("_Position");
    public static int SizeID = Shader.PropertyToID("_Size");


    public Material WallMaterial;
    public Camera Camera;
    public LayerMask Mask;

    
    float hitDistance;
    // Update is called once per frame
    void Update()
    {
        Plane camPlane = new Plane(Camera.transform.forward, Camera.transform.position);
        Ray rayToCam = new Ray(transform.position, -Camera.transform.forward);
        
        if (camPlane.Raycast(rayToCam, out hitDistance)) {
            Vector3 startPoint = rayToCam.GetPoint(hitDistance);
            Ray ray = new Ray(startPoint, Camera.transform.forward); 
            // From here on out, put the logic you already have
            if (Physics.Raycast(rayToCam, 3000, Mask)) {
            WallMaterial.SetFloat(SizeID, 1);
            } else {
            WallMaterial.SetFloat(SizeID, 0);
            }
        }

        var view = Camera.WorldToViewportPoint(transform.position);
        WallMaterial.SetVector(PosID, view);
        
    }
}
