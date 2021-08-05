using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//•K—v‚È‚à‚Ì‚ð“ü‚ê‚é
[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]

public class WaveSurfaceRenderManager : MonoBehaviour
{
    static WaveSurfaceRenderManager waveSurfaceRenderManager;

    public static WaveSurfaceRenderManager Instance
    {
        get 
        {
            if (waveSurfaceRenderManager != null)
            {
                return waveSurfaceRenderManager;
            }
            else
            {
                waveSurfaceRenderManager = GameObject.Find("waterSurfaceRenderer").GetComponent<WaveSurfaceRenderManager>();
                return waveSurfaceRenderManager;
            }
        }
    }

    public LayerMask reflectLayer = -1;

    public Material surfaceMaterrial;
    public Material waveEqMaterial;

    Vector4 reflect = new Vector4(0.0f, 1.0f, 0.0f, 0.0f);

    MeshFilter meshFilter;

    Transform centerPos;

    Color BaseColor;




    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
