Shader "Custom/_Test_Raytrasing_CrearWaveInfinityShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base color", Color) = (1.0,1.0,1.0,1.0)
        _Color("Color", Color) = (1,1,1,1)
        _Spec ("Specula", Color) = (0.5, 0.5, 0.5)
        _Alpha("alpha", Range(0, 1)) = 0.5
        _WaveLength("WaveLength", float) = 14.0
        _PlaneHeight("PlaneHeight", float) = 1.0
        _Flat("_Flat", Range(0, 1)) = 1
        _ReflectTex("RenderTex", 2D) = "white"{}
        _ReflectAlpha("ReflectAlpha", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { 
               "Queue"="Transparent"
               "RenderType"="Transparent"
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

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc" 

            float3 lightDir = float3(1.0, 1.0, 1.0);

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BaseColor;
            float4 _Color;
            float4 _Specula;
            float _Alpha;
            float _WaveLength;
            float _PlaneHeight;
            float _Flat;
            float3 _Center;
            float _ReflectAlpha;
            sampler2D _ReflectTex;
            

            struct appdata
            {
                fixed4 vertex : POSITION;
                fixed2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Input 
            {
                float2 uv_MainTex;
                float2 uv_ReflectTex;
            };

            struct v2g
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 position : SV_POSITION;
                float4 vertexWave : TEXCOORD1;
                float3 normalWave : TEXCOORD2;
            };

            struct g2f
            {
                float4 vertex : SV_POSITION;
                float3 normalWave : TEXCOORD0;
                float4 diff : COLOR0;
            };

            void gerstnerWave(in float3 localVtx, float t, float waveLength, float Q, float R, float2 browDir, inout float3 localVtxPos, inout float3 localNormal)
            {
                v2g o;

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

            float fresnel( in float3 toCameraDirWave, in float3 normalWave, in float n1, in float n2 ) 
            {
                float A = n1 / n2;
                float B = dot( toCameraDirWave, normalWave );
                float C = sqrt( 1.0 - A * A * ( 1.0 - B * B ) );
                float V1 = ( A * B - C ) / ( A * B + C );
                float V2 = ( A * C - B ) / ( A * C + B );
                return ( V1 * V1 + V2 * V2 ) * 0.5;
            }

            v2g vert(appdata v)
            {
                float3 forward = -UNITY_MATRIX_V._m20_m21_m22;
                float3 campos = _WorldSpaceCameraPos;
                float center_distance = abs(_ProjectionParams.z - _ProjectionParams.y) * 0.5;
                _Center = campos + forward * (center_distance + abs(_ProjectionParams.y));
                float3 pos = float3(v.vertex.x * center_distance * 0.5 + _Center.x * 0.2,
                                    _PlaneHeight,
                                    v.vertex.z * center_distance * 0.5 + _Center.z * 0.2);
                v2g o;

                o.vertexWave = mul(unity_ObjectToWorld, v.vertex);

                float3 oPosWave = float3(0.0, 0.0, 0.0);
                float3 oNormalWave = float3(0.0, 0.0, 0.0);
                float3 oPosR = float3(0.0, 0.0, 0.0);
                float t = _Time.y;
                gerstnerWave(o.vertexWave, t + 2.0, 0.8, 0.7, 0.3, float2(0.2, 0.3), oPosWave, oNormalWave);
                gerstnerWave(o.vertexWave, t, 1.2, 0.3, 0.5, float2(-0.4, 0.7), oPosWave, oNormalWave);
                gerstnerWave(o.vertexWave, t + 3.0, 1.8, 0.3, 0.5, float2(0.4, 0.4), oPosWave, oNormalWave);
                gerstnerWave(o.vertexWave, t, 2.2, 0.4, 0.4, float2(-0.3, 0.6), oPosWave, oNormalWave);
                o.vertexWave.xyz += oPosWave;
                o.vertexWave.xyz = o.vertexWave.xyz + pos;

                // 座標変換
                o.position = mul(UNITY_MATRIX_VP, o.vertexWave);
                o.uv = TRANSFORM_TEX(pos.xz * float2(1.0 / 16.0, 1.0 / 16.0), _MainTex);
                o.normalWave = normalize(oNormalWave);
                UNITY_TRANSFER_FOG(o, o.vertexWave);

                return o;
            }

            [maxvertexcount(3)]
            void geom (triangle v2g input[3], inout TriangleStream<g2f> outStream)
            {
                float3 wp0 = input[0].vertexWave.xyz;
                float3 wp1 = input[1].vertexWave.xyz;
                float3 wp2 = input[2].vertexWave.xyz;
                float3 normalWave = normalize(cross(wp1 - wp0, wp2 - wp1));

                g2f output0;
                output0.vertex = input[0].position;
                output0.normalWave = lerp(input[0].normalWave, normalWave, _Flat);
                output0.diff = max(0, dot(output0.normalWave, _WorldSpaceLightPos0.xyz)) * _LightColor0;  

                g2f output1;
                output1.vertex = input[1].position;
                output1.normalWave = lerp(input[1].normalWave, normalWave, _Flat);
                output1.diff = max(0, dot(output1.normalWave, _WorldSpaceLightPos0.xyz)) * _LightColor0;

                g2f output2;
                output2.vertex = input[2].position;
                output2.normalWave = lerp(input[2].normalWave, normalWave, _Flat); 
                output2.diff = max(0, dot(output2.normalWave, _WorldSpaceLightPos0.xyz)) * _LightColor0;

                outStream.Append(output0);
                outStream.Append(output1);
                outStream.Append(output2);
            }

            fixed4 frag(g2f i) : SV_Target
            {
                fixed4 col = tex2D(_ReflectTex, i.uv);
                fixed4 col *= _BaseColor;
                float3 normalWave = normalize(i.normalWave);
                float3 toLightDirWave = normalize(_WorldSpaceLightPos0.xyz);

                // フレネル反射率算出
                // 頂点座標からカメラへのレイと法線
                float3 fromVtxToCameraWave = normalize( _WorldSpaceCameraPos - i.normalWave.xyz );
                float R = fresnel( fromVtxToCameraWave, normalWave, 1.000292, 1.3334 );

                //カメラマップの反映
                //float4 col2 = tex2D(_ReflectTex, i.normalWave);
                //float3 reflectionDir = reflect(-fromVtxToCameraWave, normalWave);
                //float4 envelopeColor = UNITY_SAMPLE_TEX2DARRAY(_ReflectTex, reflectionDir);

                // ディフューズ
                float3 srcColor = col * (1.0 - R);
                float diffusePower = dot(normalWave, toLightDirWave);
                col.rgb *= (max(0.0, diffusePower * R) * _Color.rgb * col.xyz);
                float3 diffuseColor = (srcColor + diffusePower) * _ReflectAlpha;
               
                // スペキュラ
                //float3 vertexToCameraWave = normalize(_WorldSpaceCameraPos - i.vertexWave.xyz);
                //float3 vertexToCameraWave = normalize(_WorldSpaceCameraPos - normalWave);
                float3 vert2CameraWave = normalize(toLightDirWave - fromVtxToCameraWave);
                float3 specularColor = pow(max(0.0, dot(reflect(-toLightDirWave, normalWave), vert2CameraWave)), 30.0f);
                col.rgb = diffuseColor * (specularColor * 0.75f);
                //col.rgb = color * specularColor * 0.25f;
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                col.a = _Alpha;
                return col;
                 
                //return float4(color, 1.0);
            }

            ENDCG
        }
    }
}