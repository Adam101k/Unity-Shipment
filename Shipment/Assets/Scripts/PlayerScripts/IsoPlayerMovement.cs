using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class IsoPlayerMovement : MonoBehaviour
{
    private InputHandler _input;

    [SerializeField]
    public VisualEffect runParticle; 

    [SerializeField]
    private float moveSpeed;
    public float runSpeed;
    [Header("Ground Check")]
    public float playerHeight;
    public LayerMask whatIsGround;
    bool grounded;

    private float speed;

    [SerializeField]
    public Camera cam;

    [SerializeField]
    private bool rotateTowardsMouse;

    [SerializeField]
    private float rotateSpeed;

    private Rigidbody rb;
    
    private void Awake()
    {
        _input = GetComponent<InputHandler>();
        rb = GetComponent<Rigidbody>();
    }

    void FixedUpdate()
    {
        var targetVector = new Vector3(_input.InputVector.x, 0, _input.InputVector.y);

        //Move in the direction we are aiming
        var movementVector = MoveTowardTarget(targetVector);

        if(Input.GetKey("left shift")) {
            speed = runSpeed * Time.deltaTime;
        } else {
            speed = moveSpeed * Time.deltaTime;
        }
        if(Input.GetKey("left shift") && movementVector.magnitude > 0) {
            CreateDust();
        }
        //Rotate in the direction we are traveling
        RotateTowardMovementVector(movementVector);
        if(!rotateTowardsMouse)
            RotateTowardMovementVector(movementVector);
        else
            RotateTowardsMouseVector();
    }

    //This is so the player rotates towards the mouse position
    private void RotateTowardsMouseVector()
    {
        Ray ray = cam.ScreenPointToRay(_input.MousePosition);

        if(Physics.Raycast(ray, out RaycastHit hitInfo, maxDistance: 300f))
        {
            var target = hitInfo.point;
            target.y = transform.position.y; //making sure that he doesn't look up or down, this could be used with a model for head movement?
            transform.LookAt(target);
        }
    }

    //This is so the player faces the direction they're moving
    private void RotateTowardMovementVector(Vector3 movementVector)
    {
        if(movementVector.magnitude == 0) { return; }
        var rotation = Quaternion.LookRotation(movementVector);
        transform.rotation = Quaternion.RotateTowards(transform.rotation, rotation, rotateSpeed);
    }

    private Vector3 MoveTowardTarget(Vector3 targetVector)
    {   
        targetVector = Quaternion.Euler(0, cam.gameObject.transform.eulerAngles.y, 0) * targetVector;
        var targetPosition = transform.position + targetVector * speed;
        targetVector = Vector3.Normalize(targetVector);
        transform.position = targetPosition;
        return targetVector;
    }

    void CreateDust() {
        runParticle.Play();
    }
}
