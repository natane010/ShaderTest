using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    [SerializeField] Rigidbody rb;
    
    [SerializeField] float moveSpeed;
    [SerializeField] float rotationSpeed;
    [SerializeField] KeyCode AttackKey;
    [SerializeField] GameObject bu;
    //[SerializeField] GameObject body;
    int speedRot;
    Vector3 moveVector;//ç≈èIå¸Ç´
    float angleVector;//èc
    float pitchVector;//â°
    Quaternion rotation;
    float yoVec;

    float rayRange = Mathf.Infinity;    //50Ç…ê›íË
    RaycastHit hit;

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

        if (Input.GetKey(AttackKey))
        {
            Vector3 a = this.transform.position;
            a.y = a.y - 10.0f;
            Instantiate(bu, this.transform.position, Quaternion.identity);
        }
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
        yoVec = 0f;
        if (Input.GetKey(KeyCode.D))
        {
            pitchVector++;
        }
        else if (Input.GetKey(KeyCode.A))
        {
            pitchVector--;
        }
        if (Input.GetKey(KeyCode.Z))
        {
            yoVec--;
        }
        else if (Input.GetKey(KeyCode.C))
        {
            yoVec++;
        }
        rotation = Quaternion.Euler(angleVector * rotationSpeed * Time.deltaTime,
                   pitchVector * rotationSpeed * Time.deltaTime , 
                   yoVec * rotationSpeed * Time.deltaTime);
        rotation = rb.rotation * rotation;
        if (Input.GetKeyDown(KeyCode.Q))
        {
            if (speedRot <= 5)
            {
                speedRot++;
            }
        }
        else if (Input.GetKeyDown(KeyCode.E))
        {
            if (speedRot > 0)
            {
                speedRot--;
            }
        }
    }
}
