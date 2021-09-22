Shader "Unlit/normalnotinfinitywave"
{
	Properties
    {
        _MainTex("Texture", 2D) = "white" { }
        _BaseColor("Base color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Color("Color", Color) = (1, 1, 1, 1)
        _Spec("Specula", Color) = (0.5, 0.5, 0.5)
        _Alpha("alpha", Range(0, 1)) = 0.5
        _WaveLength("WaveLength", float) = 14.0
        _Flat("_Flat", Range(0, 1)) = 1
        _ReflectTex("RenderTex", 2D) = "white"{ }
        _ReflectAlpha("ReflectAlpha", Range(0, 1)) = 0.5
        _Radius("Radius", Range(0.0, 1.0)) = 0.3
        _MaybeHight("MaybeHight", float) = 1.0
    }
    SubShader
    {
        Tags 
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
            "LightMode" = "SRPDefaultUnlit"
        }
        LOD 200

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
                        //#pragma surface surf Standard fullforwardshadows
            #pragma target 4.6
                        //#pragma fragmentoption ARB_precision_hint_nicest
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            # include "UnityCG.cginc"
            # include "Lighting.cginc"
            # include "UnityLightingCommon.cginc"
            # include "AutoLight.cginc"

            float3 lightDir = float3(1.0, 1.0, 1.0);

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BaseColor;
            float4 _Color;
            float4 _Specula;
            float _Alpha;
            float _WaveLength;
            float _Flat;
            float _MaybeHight;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct Input
            {
                float2 uv_MainTex;
            };

            struct v2g
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION;
                float4 vertexW : TEXCOORD2;
                float3 normalW : TEXCOORD3;
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                float3 normalW : TEXCOORD0;
                float4 diff : COLOR0;
            };

            void gerstnerWave(in float3 localVtx, float t, float waveLen, float Q, float R, float2 browDir, inout float3 localVtxPos, inout float3 localNormal )
            {

                browDir = normalize(browDir);
                const float pi = 3.1415926535f;
                const float grav = 9.8f;
                //float A = _MaybeHight / _WaveLength;
                //float _2pi_per_L = 2.0f * pi / _MaybeHight;
                float A = waveLen / _WaveLength;
                float _2pi_per_L = 2.0f * pi / waveLen;
                float d = dot(browDir, localVtx.xz);
                float th = _2pi_per_L * d + sqrt(grav / _2pi_per_L) * t;

                float3 pos = float3(0.0, R * A * sin(th), 0.0);
                pos.xz = Q * A * browDir * cos(th);

                // ゲルストナー波の法線
                float3 normal = float3(0.0, 5.0, 0.0);
                normal.xz = -browDir * R * cos(th) / (7.0f / pi - Q * browDir * browDir * sin(th));

                localVtxPos += pos;
                localNormal += normalize(normal);
            }
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453 * (_Time / 1000));
            }

            fixed2 random2(fixed2 st)
            {
                st = fixed2( dot(st,fixed2(127.1,311.7)), dot(st,fixed2(269.5,183.3)) );
                return -1.0 + 2.0*frac(sin(st)*43758.5453123);
            }

            float perlinNoise(fixed2 st) 
            {
                fixed2 p = floor(st);
                fixed2 f = frac(st);
                fixed2 u = f*f*(3.0-2.0*f);

                float v00 = random2(p+fixed2(0,0));
                float v10 = random2(p+fixed2(1,0));
                float v01 = random2(p+fixed2(0,1));
                float v11 = random2(p+fixed2(1,1));

                return lerp( lerp( dot( v00, f - fixed2(0,0) ), dot( v10, f - fixed2(1,0) ), u.x ),
                             lerp( dot( v01, f - fixed2(0,1) ), dot( v11, f - fixed2(1,1) ), u.x ), 
                             u.y)+0.5f;
            }
            float fresnel(in float3 toCameraDirWave, in float3 normalWave, in float n1, in float n2)
            {
                float A = n1 / n2;
                float B = dot(toCameraDirWave, normalWave);
                float C = sqrt(1.0 - A * A * (1.0 - B * B));
                float V1 = (A * B - C) / (A * B + C);
                float V2 = (A * C - B) / (A * C + B);
                return (V1 * V1 + V2 * V2) * 0.5;
            }
            float SurgeWave(float2 uvPos, float DeltaUV)
            {
                float duv = uvPos * DeltaUV;

            }

            v2g vert(appdata v)
            {

                v2g o;

                o.vertexW = mul(unity_ObjectToWorld, v.vertex);

                float3 oPosW = float3(0.0, 0.0, 0.0);
                float3 oNormalW = float3(0.0, 0.0, 0.0);
                float t = _Time.y;
                gerstnerWave(o.vertexW, t + 2.0, 0.8, 0.7, 0.3, float2(0.2, -1.0) , oPosW, oNormalW);
                gerstnerWave(o.vertexW, t, 1.2, 0.3, 0.5, float2(-0.4, 0.3), oPosW, oNormalW);
                gerstnerWave(o.vertexW, t + 3.0, 1.8, 0.3, 0.5, float2(0.4, -0.4), oPosW, oNormalW);
                gerstnerWave(o.vertexW, t, 2.2, 0.4, 0.4, float2(0, 0.3), oPosW, oNormalW);
                o.vertexW.xyz += oPosW;
                float3 perNormalWave = float3(0, rand(v.uv), 0);
                o.vertexW.xyz += perNormalWave/ 1000;

                // 座標変換
                o.pos = mul(UNITY_MATRIX_VP, o.vertexW);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //o.uv = TRANSFORM_TEX(pos1.xz * float2(1.0 / 16.0, 1.0 / 16.0), _MainTex);
                o.normalW = normalize(oNormalW);
                UNITY_TRANSFER_FOG(o, o.pos);

                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> outStream)
            {
                float3 wp0 = input[0].vertexW.xyz;
                float3 wp1 = input[1].vertexW.xyz;
                float3 wp2 = input[2].vertexW.xyz;
                float3 normalWave = normalize(cross(wp1 - wp0, wp2 - wp1));

                g2f output0;
                output0.pos = input[0].pos;
                output0.normalW = lerp(input[0].normalW, normalWave, _Flat);
                output0.diff = max(0, dot(output0.normalW, _WorldSpaceLightPos0.xyz)) * _LightColor0;

                g2f output1;
                output1.pos = input[1].pos;
                output1.normalW = lerp(input[1].normalW, normalWave, _Flat);
                output1.diff = max(0, dot(output1.normalW, _WorldSpaceLightPos0.xyz)) * _LightColor0;

                g2f output2;
                output2.pos = input[2].pos;
                output2.normalW = lerp(input[2].normalW, normalWave, _Flat);
                output2.diff = max(0, dot(output2.normalW, _WorldSpaceLightPos0.xyz)) * _LightColor0;

                outStream.Append(output0);
                outStream.Append(output1);
                outStream.Append(output2);
            }

            fixed4 frag(g2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col = _BaseColor;
                float3 normalW = normalize(i.normalW);

                // フレネル反射率算出
                // 頂点座標からカメラへのレイと法線
                float3 fromVtxToCameraWave = normalize(_WorldSpaceCameraPos - i.normalW.xyz);
                float R = fresnel(fromVtxToCameraWave, normalW, 1.000292, 1.3334);

                // ディフューズ
                float3 toLightDirW = normalize(_WorldSpaceLightPos0.xyz);
                float diffusePower = dot(normalW, toLightDirW);
                //col.rgb = max(0.0, diffusePower) * _BaseColor.rgb * col.xyz;
                float3 diffuseColor = (diffusePower) * R;

                // スペキュラ
                //float3 vertexToCameraW = normalize(_WorldSpaceCameraPos - i.vertexW.xyz);

                //float3 specularColor = pow(max(0.0, dot(reflect(-toLightDirW, normalW), vertexToCameraW)), 4.0f);

                float3 vert2CameraWave = normalize(toLightDirW - fromVtxToCameraWave);
                float3 specularColor = pow(max(0.0, dot(reflect(-toLightDirW, normalW), vert2CameraWave)), 30.0f);
                col.rgb += (diffuseColor + (specularColor)) * _BaseColor * R;
                col.rgb += specularColor;
                float2 perNRandom = random2(i.normalW.xy);

                col *= perlinNoise(normalW.xy * 8.0f) / 30;
                col *= perlinNoise(perNRandom) * 20;
                UNITY_APPLY_FOG(i.fogCoord, col);
                col.a = _Alpha;
                return col;
            }
            ENDCG
        }
    }
}