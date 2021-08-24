Shader "Custom/SurfaceWaveShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _PlaneHeight("PlaneHeight", float) = 1.0
        _WaveLength("WaveLength", float) = 14.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        //#pragma surface surf Standard fullforwardshadows
        #pragma surface surf Standard addshadow vertex:vert
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 4.6

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float4 vertexWave;
            float4 pos;
            float3 normalWave;
        };

        half _Glossiness;
        half _Metallic;
        float4 _MainTex_ST;
        fixed4 _Color;
        float _PlaneHeight;
        float _WaveLength;

        void gerstnerWave(in float3 localVtx, float t, float waveLength, float Q, float R, float2 browDir, inout float3 localVtxPos, inout float3 localNormal, Input o)
        {

            browDir = normalize(browDir);
            const float pi = 3.1415926535f;
            const float grav = 9.8f;
            float A = waveLength / _WaveLength;
            float _2pi_per_L = 2.0f * pi / waveLength;
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

        //// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        //// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        //// #pragma instancing_options assumeuniformscaling
        //UNITY_INSTANCING_BUFFER_START(Props)
        //    // put more per-instance properties here
        //UNITY_INSTANCING_BUFFER_END(Props)

        void vert(inout appdata_full v, out Input o)
        {
            float3 forward = -UNITY_MATRIX_V._m20_m21_m22;
            float3 campos = _WorldSpaceCameraPos;
            float center_distance = abs(_ProjectionParams.z - _ProjectionParams.y) * 0.5;
            float3 center = campos + forward * (center_distance + abs(_ProjectionParams.y));
            float3 pos1 = float3(v.vertex.x * center_distance * 0.5 + center.x * 0.2,
                                _PlaneHeight,
                                v.vertex.z * center_distance * 0.5 + center.z * 0.2);

            o.vertexWave = mul(unity_ObjectToWorld, v.vertex);

            float3 oPosWave = float3(0.0, 0.0, 0.0);
            float3 oNormalWave = float3(0.0, 0.0, 0.0);
            float3 oPosR = float3(0.0, 0.0, 0.0);
            float t = _Time.y;
            gerstnerWave(o.vertexWave, t + 2.0, 0.8, 0.7, 0.3, float2(0.2, 0.3), oPosWave, oNormalWave, o);
            gerstnerWave(o.vertexWave, t, 1.2, 0.3, 0.5, float2(-0.4, 0.7), oPosWave, oNormalWave, o);
            gerstnerWave(o.vertexWave, t + 3.0, 1.8, 0.3, 0.5, float2(0.4, 0.4), oPosWave, oNormalWave, o);
            gerstnerWave(o.vertexWave, t, 2.2, 0.4, 0.4, float2(-0.3, 0.6), oPosWave, oNormalWave, o);
            o.vertexWave.xyz += oPosWave;
            o.vertexWave.xyz = o.vertexWave.xyz + pos1;

            // 座標変換
            o.pos = mul(UNITY_MATRIX_VP, o.vertexWave);
            o.uv_MainTex = TRANSFORM_TEX(pos1.xz * float2(1.0 / 16.0, 1.0 / 16.0),_MainTex);
            o.normalWave = normalize(oNormalWave);
            UNITY_TRANSFER_FOG(o, o.vertexWave);

            UNITY_INITIALIZE_OUTPUT(Input, o);

            v.vertex.xyz += o.vertexWave.xyz;
        }

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
    FallBack "Diffuse"
}
