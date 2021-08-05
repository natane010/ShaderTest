using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestSketch : MonoBehaviour
{
    [SerializeField] Material mat;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(null, destination, mat);
    }
}
