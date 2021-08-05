using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class _Test_Raytracing_PostEffect : MonoBehaviour
{
    [SerializeField] Shader _testShader = default;

    private Material _testMaterial;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_testShader != null)
        {
            if (_testMaterial == null)
            {
                _testMaterial = new Material(_testShader);
            }
            Graphics.Blit(source, destination, _testMaterial);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
