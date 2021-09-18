using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowRenderer : MonoBehaviour
{
    /// <summary>
    /// 対象オブジェクトのレンダラー
    /// </summary>
    [SerializeField] private Renderer _renderer;
    [SerializeField] private GameObject targetObj;
    /// <summary>
    /// shaderで定義済みの座標変数名
    /// </summary>
    [SerializeField] private string propName;

    private Material mat;

    /// <summary>
    /// 照明
    /// </summary>
    [SerializeField] private GameObject rightObj;

    // Start is called before the first frame update
    void Start()
    {
        mat = _renderer.material;
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 dir = targetObj.transform.position - (rightObj.transform.position);
        Ray shadowRay = new Ray(rightObj.transform.position, dir * Mathf.Infinity);
        RaycastHit hitPosition = new RaycastHit();
        bool isHit = Physics.Raycast(shadowRay, out hitPosition);
        Debug.DrawRay(shadowRay.origin, shadowRay.direction * Mathf.Infinity, Color.red, Mathf.Infinity, false);

        if (isHit)
        {
            print(hitPosition.point);
            mat.SetVector(propName, hitPosition.point);
        }
    }
}
