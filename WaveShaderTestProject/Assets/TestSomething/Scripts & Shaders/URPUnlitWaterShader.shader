Shader "Unlit/URPUnlitWaterShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _BaseColor("BaseColor", Color) = (1.0, 1.0, 1.0, 1.0)
        _Alpha("alpha", Range(0, 1)) = 0.5
        _Spec("Specula", Color) = (0.5, 0.5, 0.5)
    }
    SubShader
    {
        Tags { "RenderType" = "Geometory" }
        LOD 100


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"



            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                //float3 forward = UNITY_MATRIX_V._m20_m21_m22;
                //float3 cameraPos = _WorldSpaceCameraPos;
                //float centerDistance = abs(_ProjectionParams.z - _ProjectionParams.y) * 0.5f;
                //float3 center = cameraPos + forward * (centerDistance * 0.5 + center.x * 0.2,
                //                0, v.vertex.z * centerDistance * 0.5 + center.z * 0.2);            

                v2f o;
                o.vertex = -UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
