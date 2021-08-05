Shader "Custom/SurfaceInfinityShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _MainTex("Texture", 2D) = "white"{ }
    }
    SubShader
    {
        Pass
        {
            Tags { "RenderType"="Opaque" }
            LOD 200

            CGPROGRAM
            #pragma surface surf Standard fullforwardshadows
            #pragma vertex vert

            // Use shader model 3.0 target, to get nicer looking lighting
            #pragma target 3.0

            sampler2D _MainTex;

            struct Input
            {
                float2 uv_MainTex;
            };

            void gerstnerWave(in float3 localVtx, float t, float waveLen, float Q, float R, float2 browDir, inout float3 localVtxPos, inout float3 localNormal)
            {

                browDir = normalize(browDir);
                const float pi = 3.1415926535f;
                const float grav = 9.8f;
                float A = waveLen / 14.0f;
                float _2pi_per_L = 2.0f * pi / waveLen;
                float d = dot(browDir, localVtx.xz);
                float th = _2pi_per_L * d + sqrt(grav / _2pi_per_L) * t;

                float3 pos = float3(0.0, R * A * sin(th), 0.0);
                pos.xz = Q * A * browDir * cos(th);

                // ゲルストナー波の法線
                float3 normal = float3(0.0, 1.0, 0.0);
                normal.xz = -browDir * R * cos(th) / (7.0f / pi - Q * browDir * browDir * sin(th));

                localVtxPos += pos * 20;
                localNormal += normalize(normal) * 20;
            }


            half _Glossiness;
            half _Metallic;
            fixed4 _Color;

            // #pragma instancing_options assumeuniformscaling
            UNITY_INSTANCING_BUFFER_START(Props)
                // put more per-instance properties here
            UNITY_INSTANCING_BUFFER_END(Props)

            void surf (Input IN, inout SurfaceOutputStandard o)
            {
                // Albedo comes from a texture tinted by color
                fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb;
                // Metallic and smoothness come from slider variables
                o.Metallic = _Metallic;
                o.Smoothness = _Glossiness;
                o.Alpha = c.a;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
