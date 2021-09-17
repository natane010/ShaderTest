using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowRenderer : MonoBehaviour
{
    /// <summary>
    /// �ΏۃI�u�W�F�N�g�̃����_���[
    /// </summary>
    [SerializeField] private Renderer _renderer;
    [SerializeField] private GameObject targetObj;
    /// <summary>
    /// shader�Œ�`�ς݂̍��W�ϐ���
    /// </summary>
    [SerializeField]private string propName;

    private Material mat;

    /// <summary>
    /// �Ɩ�
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
        Vector3 dir = -(rightObj.transform.position) + targetObj.transform.position;
        Ray shadowRay = new Ray(rightObj.transform.position, dir);
        RaycastHit hitPosition = new RaycastHit();
        bool isHit = Physics.Raycast(shadowRay, out hitPosition);

        if (isHit)
        {
            print(hitPosition.point);
            mat.SetVector(propName, hitPosition.point);
        }
        else
        {
            
        }
    }
}
