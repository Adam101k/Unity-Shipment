using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Minimap : MonoBehaviour
{
    public Transform player;
    public float distance;

    void LateUpdate() {
        transform.position = player.position;
    }
}
