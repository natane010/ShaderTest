using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveMesh : MonoBehaviour
{
    GameObject cameraObj;

    // Start is called before the first frame update
    void Start()
    {
        cameraObj = GameObject.Find("Main Camera");
    }

    // Update is called once per frame
    void Update()
    {
        Quaternion posRotate = new Quaternion(this.gameObject.transform.rotation.x, cameraObj.transform.rotation.y, this.gameObject.transform.rotation.z, this.gameObject.transform.rotation.w);
        this.gameObject.transform.rotation = posRotate;
    }
}
