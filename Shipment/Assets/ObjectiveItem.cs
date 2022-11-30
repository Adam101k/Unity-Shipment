using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectiveItem : MonoBehaviour
{
    public Transform player;
    public float pickUpRange;
    private GameManager GM;
    public GameObject eventSystem;
    private Outline outline;

    private void Start() {
        GM = eventSystem.GetComponent<GameManager>();
        outline = this.GetComponent<Outline>();
    }
    private void Update()
    {
        Vector3 distanceToPlayer = player.position - transform.position;
        if (distanceToPlayer.magnitude <= pickUpRange && Input.GetKeyDown(KeyCode.E)) {
            CollectObj();
        }
    }
    private void CollectObj() 
    {
        GM.AddObjective1();
        Destroy(gameObject);
    }
}
