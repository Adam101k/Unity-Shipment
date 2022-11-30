using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShipMovement : MonoBehaviour
{

    private InputHandler _input;
    public float moveSpeed;
    public float runSpeed;
    private float speed;
    [SerializeField]
    public Camera cam;
    
    [SerializeField]
    public float rotateSpeed;

    private void Awake()
    {
        _input = GetComponent<InputHandler>();
    }
    void Update()
    {
        // Handle keyboard control
        var targetVector = new Vector3(_input.InputVector.x, 0, _input.InputVector.y);
    
        //Move in the direction we are aiming
        var movementVector = MoveTowardTarget(targetVector);

        if(Input.GetKey("left shift")) {
            speed = runSpeed * Time.deltaTime;
        } else {
            speed = moveSpeed * Time.deltaTime;
        }
        RotateTowardMovementVector(movementVector);
    }

    private Vector3 MoveTowardTarget(Vector3 targetVector)
    {   
        targetVector = Quaternion.Euler(0, cam.gameObject.transform.eulerAngles.y, 0) * targetVector;
        var targetPosition = transform.position + targetVector * speed;
        targetVector = Vector3.Normalize(targetVector);
        transform.position = targetPosition;
        return targetVector;
    }
    private void RotateTowardMovementVector(Vector3 movementVector)
    {
        if(movementVector.magnitude == 0) { return; }
        var rotation = Quaternion.LookRotation(movementVector);
        transform.rotation = Quaternion.RotateTowards(transform.rotation, rotation, rotateSpeed);
    }
}
