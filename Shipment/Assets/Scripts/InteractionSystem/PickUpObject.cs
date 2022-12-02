using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PickUpObject : MonoBehaviour
{
    public FuelTank gasScript;
    public Rigidbody rb;
    public BoxCollider coll;
    public Transform player, gasContainer;

    public Items item;

    public float pickUpRange;
    public float dropForwardForce, dropUpwardForce;

    public bool equipped;
    public static bool carryingItem;

    private void Start()
    {
        //set up
        if (!equipped) 
        {
            gasScript.enabled = false;
            rb.isKinematic = false;
            coll.isTrigger = false;
        }
        if (equipped)
        {
            gasScript.enabled = true;
            rb.isKinematic = true;
            coll.isTrigger = true;
            carryingItem = true;
        }
    }
    private void Update()
    {
        Vector3 distanceToPlayer = player.position - transform.position;
        if (!equipped && distanceToPlayer.magnitude <= pickUpRange && Input.GetKeyDown(KeyCode.E) && !carryingItem) PickUpItem();

        if (equipped && Input.GetKeyDown(KeyCode.Q) ) DropItem();
    }
    private void PickUpItem() 
    {
        transform.SetParent(gasContainer);
        transform.localPosition = Vector3.zero;
        transform.localRotation = Quaternion.Euler(Vector3.zero);
        //transform.localScale = Vector3.one;

        InventoryManager.Instance.Add(item);

        equipped = true;
        carryingItem = true;

        rb.isKinematic = true;
        coll.isTrigger = true;

        gasScript.enabled = true;
    }
    private void DropItem() 
    {
        equipped = false;
        carryingItem = false;

        transform.SetParent(null);

        rb.isKinematic = false;
        coll.isTrigger = false;
        
        //add random rotation
        float random = Random.Range(-1f, 1f);
        rb.AddTorque(new Vector3(random, random, random) * 10);
        gasScript.enabled = false;
    }
}
