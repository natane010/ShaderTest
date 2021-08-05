using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveCamera : MonoBehaviour
{
    [SerializeField] GameObject playerObj;
    [SerializeField] float rotateSpeed;
    Vector3 lastPos;
    Vector3 movePos;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        float angle = Input.GetAxis("Horizontal") * rotateSpeed;
        Vector3 pos = playerObj.transform.position;
        transform.RotateAround(pos, Vector3.up, angle);
        if (lastPos != pos)
        {
            movePos = pos - lastPos;
            transform.position += movePos;
            lastPos = pos;
        }
    }
}
