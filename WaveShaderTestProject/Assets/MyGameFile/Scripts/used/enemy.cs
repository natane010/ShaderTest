using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class enemy : MonoBehaviour
{
    [SerializeField] GameObject bu;
    // Start is called before the first frame update
    void Start()
    {
        InvokeRepeating("runch", 1, 1);
    }
    void runch()
    {
        Instantiate(bu, this.transform.position, Quaternion.identity);
    }
}
