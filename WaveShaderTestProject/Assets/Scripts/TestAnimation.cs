using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestAnimation : MonoBehaviour
{
    [SerializeField] Animator serfAnimator;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.UpArrow))
        {
            serfAnimator.SetBool("Run", true);
        }
        else
        {
            serfAnimator.SetBool("Run", false);
        }
    }
}
