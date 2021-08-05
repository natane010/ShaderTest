using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DataSendToShader : MonoBehaviour
{
    public MaterialPropertyBlock gameObjectTransform;
    private Material waterMaterial = null;
    private Renderer waterRenderer = null;

    [SerializeField]
    private GameObject water;

    private void Start()
    {
        gameObjectTransform = new MaterialPropertyBlock();
        waterRenderer = water.GetComponent<Renderer>();
        waterMaterial = waterRenderer.material;
    }
    private void Update()
    {
        
    }
    public void OnWater(GameObject go)
    {
        gameObjectTransform.Clear();
        gameObjectTransform.SetVector("_PlayerPosition", go.transform.position);
        waterRenderer.SetPropertyBlock(gameObjectTransform);
    }
}
