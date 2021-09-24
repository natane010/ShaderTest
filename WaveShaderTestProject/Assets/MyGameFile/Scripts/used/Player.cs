using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    [SerializeField] Rigidbody rb;
    
    [SerializeField] float moveSpeed;
    [SerializeField] float rotationSpeed;
    [SerializeField] KeyCode AttackKey;
    //[SerializeField] GameObject body;
    int speedRot;
    Vector3 moveVector;//ç≈èIå¸Ç´
    float angleVector;//èc
    float pitchVector;//â°
    Quaternion rotation;

    // Start is called before the first frame update
    void Start()
    {
        //rb = this.GetComponent<Rigidbody>();
        moveVector = Vector3.zero;
        angleVector = 0f;
        pitchVector = 0f;
        speedRot = 0;
    }

    // Update is called once per frame
    void Update()
    {
        InputCon();
    }
    private void FixedUpdate()
    {
        rb.MoveRotation(rotation);
        transform.Translate(0f, 0f, speedRot * moveSpeed * Time.deltaTime);
    }
    private void InputCon()
    {
        angleVector = Input.GetAxis("Vertical");
        //pitchVector = Input.GetAxis("Horizontal");â°
        pitchVector = 0f;
        if (Input.GetKey(KeyCode.D))
        {
            pitchVector++;
        }
        else if (Input.GetKey(KeyCode.A))
        {
            pitchVector--;
        }
        rotation = Quaternion.Euler(angleVector * rotationSpeed * Time.deltaTime,
                   pitchVector * rotationSpeed * Time.deltaTime , 0);
        rotation = rb.rotation * rotation;
        if (Input.GetKeyDown(KeyCode.Q))
        {
            if (speedRot <= 5)
            {
                speedRot++;
            }
        }
        if (Input.GetKeyDown(KeyCode.E))
        {
            if (speedRot > 0)
            {
                speedRot--;
            }
        }
    }
}
