using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ship : MonoBehaviour
{
    [SerializeField]
    GameObject gameManager;
    [SerializeField]
    float movePower;
    [SerializeField]
    float shipLength;
    [SerializeField]
    float turnPower;
    [SerializeField]
    float stopPower;
    Rigidbody rb;
    [SerializeField]
    GameObject water;
    [SerializeField]
    float buoyancy;
    [SerializeField]
    float floatpow;
    Shader shader;
    [SerializeField]
    GameObject ship;
    DataSendToShader dataSendToShader;
    /// <summary>
    /// 乗車プレハブ
    /// </summary>
    public static GameObject rider;

    float time = 0;

    // Start is called before the first frame update
    void Start()
    {
        shader = water.GetComponent<Shader>();
        rb = GetComponent<Rigidbody>();
        //dataSendToShader = gameManager.GetComponent<DataSendToShader>();
    }

    // Update is called once per frame
    void Update()
    {
        time  += Time.deltaTime;
        float y = Mathf.Sin(time)/4 + 1;
        float x = ship.transform.position.x;
        float z = ship.transform.position.z;
        ship.transform.position = new Vector3(x, y, z);
        //Debug.Log(y);
        //  常に波の動きの影響を受けるようにシェーダーの力と方向を受け取るerror
        if (Input.GetKey(KeyCode.W))
        {
            acceleration();
        }
        else if (Input.GetKey(KeyCode.S))
        {
            Decelerate();
        }
        //ぶつかっている面積を取得してマネージャーに送る→マネージャーがその力を計算してシェーダーに送る。
        if (this.gameObject.transform.position.y < 0.8f)
        {
            rb.AddForce(Vector3.up * floatpow * Time.deltaTime);
        }
    }

    void acceleration()
    {
        Vector3 moveVector = new Vector3(0, 0, movePower);
        rb.transform.position += moveVector * Time.deltaTime;
    }

    void Decelerate()
    {
        Vector3 vector = new Vector3(0, 0, -stopPower);
    }

    private void OnCollisionStay(Collision collision)
    {
        //ぶつかっている面積を取得したい
        if (collision.gameObject.tag == "water")
        {
            //rb.AddForce(0, buoyancy, 0, ForceMode.Acceleration);
        }
    }
}
