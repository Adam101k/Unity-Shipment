using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PickUpObject : MonoBehaviour
{
    public FuelTank gasScript;
    public Rigidbody rb;
    public BoxCollider coll;
    public Transform player, fpsCam;

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
        if (!equipped && distanceToPlayer.magnitude <= pickUpRange && Keyboard.current.eKey.wasPressedThisFrame && !carryingItem) PickUpItem();

        if (equipped && Keyboard.current.qKey.wasPressedThisFrame) DropItem();
    }
    private void PickUpItem() 
    {
        transform.SetParent(player);
        transform.localPosition = Vector3.zero;
        transform.localRotation = Quaternion.Euler(Vector3.zero);
        transform.localScale = Vector3.one;

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
        
        //matches velocity of player
        rb.velocity = player.GetComponent<Rigidbody>().velocity;

        //add force
        rb.AddForce(fpsCam.forward * dropForwardForce, ForceMode.Impulse);
        rb.AddForce(fpsCam.up * dropUpwardForce, ForceMode.Impulse);

        //add random rotation
        float random = Random.Range(-1f, 1f);
        rb.AddTorque(new Vector3(random, random, random) * 10);
        gasScript.enabled = false;
    }
}
