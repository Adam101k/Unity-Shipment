using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShipController : MonoBehaviour
{
    Collider[] distanceCollider;
    public Transform playerSeat;
    public LayerMask checkLayers;
    public float rideRange;
    public bool riding;
    public ShipMovement p;
    void Start()
    {
        if (!riding) {
            p.enabled = false;
        }
        if (riding) {
            p.enabled = true;
        }
    }

    // Update is called once per frame
    void Update()
    {
        distanceCollider = Physics.OverlapSphere(transform.position, rideRange, checkLayers);
        if(distanceCollider.Length == 0) {

        } else {
            if(!riding && Input.GetKeyDown(KeyCode.E)) {
                PlayerRide();
                p.enabled = true;
            }
        }
        if (riding && Input.GetKeyDown(KeyCode.F) ) {
            PlayerDismount();
            p.enabled = false;
        }
    }

    void PlayerRide() {
        riding = true;
        distanceCollider[0].gameObject.transform.SetParent(playerSeat);
        distanceCollider[0].gameObject.transform.localPosition = Vector3.zero;
        distanceCollider[0].gameObject.transform.localRotation = Quaternion.Euler(Vector3.zero);
        distanceCollider[0].gameObject.GetComponent<Rigidbody>().isKinematic = true;
        distanceCollider[0].gameObject.GetComponent<IsoPlayerMovement>().enabled = false;
    }
    void PlayerDismount() {
        riding = false;
        distanceCollider[0].gameObject.transform.SetParent(null);
        distanceCollider[0].gameObject.GetComponent<Rigidbody>().isKinematic = false;
        distanceCollider[0].gameObject.GetComponent<IsoPlayerMovement>().enabled = true;
    }
    private void OnDrawGizmos() {
        Gizmos.DrawWireSphere(transform.position, rideRange);
    }
}
