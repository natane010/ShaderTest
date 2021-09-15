Shader "Custom/ReflectiveInfinityShader"
{
     Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) =  (1.0, 1.0, 1.0, 1.0)
        _PlaneHeight("PlaneHeight", float) = 1.0
        _Alpha("alpha", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent" 
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "LightMode" = "SRPDefaultUnlit"
        }
        Cull Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog // make fog work

            #include "UnityCG.cginc"

            struct appdata
            {
                fixed4 vertex : POSITION;
                fixed2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD3;
                float3 worldNormal : TEXCOORD1;
                float3 pos : TEXCOORD2;
            };

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            float _PlaneHeight;
            float4 _Color;
            float _Alpha;

            v2f vert(appdata v)
            {
                float3 forward = -UNITY_MATRIX_V._m20_m21_m22;
                float3 campos = _WorldSpaceCameraPos;
                float center_distance = abs(_ProjectionParams.z - _ProjectionParams.y) * 0.5;
                float3 center = campos + forward * (center_distance + abs(_ProjectionParams.y));
                float3 pos = float3(v.vertex.x * center_distance * 0.5 + center.x*0.2,
                                    _PlaneHeight, // ground level
                                    v.vertex.z * center_distance * 0.5 + center.z*0.2);
                v2f o;
                o.vertex = UnityWorldToClipPos(pos);
                o.uv = TRANSFORM_TEX(pos.xz*float2(1.0/16.0, 1.0/16.0), _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //UNITY_TRANSFER_FOG(o, o.vertex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half3 worldViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 reflDir = reflect(-worldViewDir, i.worldNormal);
                float4 col = _Color;
                float2 fuv = frac(i.uv);
                float2 uv = fuv;
                float2 dx = ddx(i.uv);
                float2 dy = ddy(i.uv);
                col *= tex2Dgrad(_MainTex, uv, dx, dy);
                UNITY_APPLY_FOG(i.fogCoord, col);
                //return col;
                // unity_SpecCube0はUnityで定義されているキューブマップ
                half4 refColor = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflDir, 0);

                // Reflection ProbeがHDR設定だった時に必要な処理
                refColor.rgb = DecodeHDR(refColor, unity_SpecCube0_HDR);
                refColor.a = _Alpha;
                return refColor;
            }

            ENDCG
        }
    }
}
