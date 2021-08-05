using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    [SerializeField] float moveSpeed;
    Vector3 move;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        float inputValueHori = 0.0f;
        float inputValueVart = 0.0f;
        if (Input.GetKey(KeyCode.E))
        {
            inputValueHori += 1;
        }
        else if (Input.GetKey(KeyCode.Q))
        {
            inputValueHori -= 1;
        }
        if (Input.GetKey(KeyCode.UpArrow))
        {
            inputValueVart += 1;
        }
        else if (Input.GetKey(KeyCode.DownArrow))
        {
            inputValueVart -= 1;
        }
        move = new Vector3(0, inputValueVart * moveSpeed, moveSpeed);
        if (inputValueVart != 0.0)
        {
            transform.localPosition += move * Time.deltaTime;
        }
        else
        {
            transform.localPosition += new Vector3(0, 0 ,moveSpeed) * Time.deltaTime;
        }
        if (inputValueHori != 0)
        {
            transform.Rotate(new Vector3(0, inputValueHori, 0));
        }
    }
}
