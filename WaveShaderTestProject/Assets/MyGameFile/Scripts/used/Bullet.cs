using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    Rigidbody rb;
    [SerializeField]float moveve = 100f;
    [SerializeField] GameObject sp;
    [SerializeField] GameObject ex;
    // Start is called before the first frame update
    void Start()
    {
        rb = this.GetComponent<Rigidbody>();
        Vector3 a = new Vector3(0, 0, moveve);
        rb.MovePosition(a);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.transform.tag != "Player")
        {
            if (collision.transform.tag == "water")
            {
                Instantiate(sp, transform.position, Quaternion.identity);
            }
            Instantiate(ex, transform.position, Quaternion.identity);
            Destroy(this.gameObject);
        }
    }
}
