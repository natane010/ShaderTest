Shader "CustomPicture/Phantom_Star"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AddTime ("AddTime", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"
               "LightMode" = "SRPDefaultUnlit"
             }
        LOD 300

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
                        // make fog work
            #pragma multi_compile_fog
            #pragma target 4.6

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #define PI 3.141592

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
            float _AddTime;


            float2x2 rot(float a)
            {
                float c = cos(a), s = sin(a);
                return float2x2(c, s, -s, c);
            }

            static const float pi = PI;
            static const float pi2 = PI * 2.0;

            float2 pmod(float2 p, float r)
            {
                float a = atan2(p.x, p.y) + pi / r;
                float n = pi2 / r;
                a = floor(a / n) * n;
                //float2 a1 = p * rot(-a);
                float2 a1 = mul(p, rot(-a));
                return a1;
            }

            float box(float3 p, float3 b)
            {
                float3 d = abs(p) - b;
                return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
            }

            float ifsBox(float3 p)
            {
                for (int i = 0; i < 5; i++)
                {
                    p = abs(p) - 1.0;
                    float2 a1 = mul(p.xy, rot(_Time * 0.3));//p.xy *= rot(_Time * 0.3);
                    p.xy = a1;
                    float2 a2 = mul(p.xz, rot(_Time * 0.1));//p.xz *= rot(_Time * 0.1);
                    p.xz = a2;
                }
                float2 a3 = mul(p.xz, rot(_Time));//p.xz *= rot(_Time.y);
                p.xz = a3;
                
                return box(p, float3(0.4, 0.8, 0.3));
            }

            float map(float3 p, float3 cPos)
            {
                float3 p1 = p;
                p1.x = fmod(p1.x - 5., 10.) - 5.;
                p1.y = fmod(p1.y - 5., 10.) - 5.;
                p1.z = fmod(p1.z, 16.) - 8.;
                p1.xy = pmod(p1.xy, 5.0);
                return ifsBox(p1);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float time = _Time * _AddTime;
                float timeX = _Time.x * _AddTime;
                float timeY = _Time.y * _AddTime;
                float timeZ = _Time.z * _AddTime;

                float2 p = (i.uv * _ScreenParams.xy * 2.0 - _ScreenParams.xy) / min(_ScreenParams.x, _ScreenParams.y);
                float cp = -3.0 * time;
                //float3 cPos = float3(0.0, 0.0, cp);
                float3 cPos = float3(0.3f*sin(0.8f*timeX), 0.4f*cos(timeY*0.3f), -6.0f * timeZ);
                float3 cDir = normalize(float3(0.0, 0.0, -1.0));
                float cu = sin(time); 
                float3 cUp = float3(cu, 1.0, 0.0);
                float3 cSide = cross(cDir, cUp);

                float3 ray = normalize(cSide * p.x + cUp * p.y + cDir);

                float acc = 0.0f;
                float acc2 = 0.0;
                float t = 0.0;
                for (int i = 0; i < 99; i++)
                {
                    float3 pos = cPos + ray * t;
                    float dist = map(pos, cPos);
                    dist = max(abs(dist), 0.02);
                    float a = exp(-dist * 3.0);
                    float ifmod = fmod(length(pos) + 24.0 * time, 30.0);
                    if (ifmod < 3.0f)
                    {
                        a *= 2.0;
                        acc2 += a;
                    }
                    acc += a;
                    t += dist * 0.5;
                }

                float3 col = float3(acc, acc * 1.1 + acc2 * 0.8, acc * 1.2 + acc2 * 0.5);
                float4 fragColor = float4(col, 1.0 - t * 0.03);
                return fragColor;
            }
            ENDCG
        }
    }
}