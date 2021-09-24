using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HomingBullet : HomingObj
{
    protected Rigidbody rb;
    protected Vector3 firstDir;
    protected Vector3 position;
    public static bool isHack;
    private float dis;
    Transform pos;
    Quaternion a;
    protected override void SStart()
    {
        firstDir = new Vector3(Random.Range(0f, 5.0f), Random.Range(0f, 5.0f), 0);
        position = transform.position;
        rb = this.GetComponent<Rigidbody>();
        pos = GameObject.FindGameObjectWithTag("Player").transform;
    }
    protected override void SUpdate()
    {
        dis = Vector3.Distance(this.transform.position, pos.position);
        if (isHack && dis <= limitNear)
        {
            StartCoroutine("DestoroyHackBullet");
        }
        else if (!isHack)
        {
            accele = Vector3.zero;

            var diff = pos.position - transform.position;

            accele += (diff - firstDir * land) * 2.0f / (land * land);

            if (accele.magnitude > limitAccele)
            {
                accele = accele.normalized * limitAccele;
            }

            land -= Time.deltaTime;

            firstDir += accele * Time.deltaTime;
        }
        a = Quaternion.LookRotation(firstDir);
    }
    protected override void FixSUpdate()
    {
        rb.MoveRotation(a);
        rb.MovePosition(transform.position + firstDir * Time.deltaTime);
    }
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.transform.tag != "Enemy")
        {
            if (collision.transform.tag == "water")
            {
                Instantiate(sp, transform.position, Quaternion.identity);
            }
            Instantiate(ex, transform.position, Quaternion.identity);
            Destroy(this.gameObject);
        }
        
    }
    IEnumerable DestoroyHackBullet()
    {
        FixSUpdate();
        yield return new WaitForSeconds(fewTime);
        Instantiate(ex, transform.position, Quaternion.identity);
        Destroy(this.gameObject);
    }
}
