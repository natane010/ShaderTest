using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HomingObj : MonoBehaviour
{
    [SerializeField] protected Vector3 accele;
    [SerializeField] protected float limitAccele;
    [SerializeField] protected GameObject target;
    protected Transform targetPos;
    [SerializeField] protected float land;
    [SerializeField] protected float fewTime;
    [SerializeField] protected float limitNear;
    // Start is called before the first frame update
    void Start()
    {
        SStart();
    }

    // Update is called once per frame
    void Update()
    {
        SUpdate();
    }
    private void FixedUpdate()
    {
        FixSUpdate();
    }
    protected virtual void SStart() { }
    protected virtual void SUpdate() { }
    protected virtual void FixSUpdate() { }
}
