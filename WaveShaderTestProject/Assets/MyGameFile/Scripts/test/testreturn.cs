using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class testreturn : MonoBehaviour
{
    int func(int a)
    {
        if (a >= 100)
        {
            return a;
        }
        return a + func(a + 1);
    }
    private void Start()
    {
        int c = func(1);
        Debug.Log(c);
    }
}
