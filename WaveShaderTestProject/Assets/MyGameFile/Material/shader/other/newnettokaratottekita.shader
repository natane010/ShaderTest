Shader "Custom/newnettokaratottekita"
{
    Properties
    {
        _Scale("Scale", float) = 1.5
        _TimeScale("時間のスピード", Vector) = (0, 1, 0, 0)
        _Distortion("歪み具合", float) = 1.0

        _Spec("反射光", Color) = (0.5, 0.5, 0.5)
        _Smooth("滑らかさ", Range(0, 1)) = 1
        _Alpha("透明度", Range(0, 1)) = 0.5


        [MaterialToggle] _IsTex("元のテクスチャを表示", Float) = 0
        _Complex("複雑度", int) = 5
        _Effectivity("影響度", float) = 0.5
    }
        SubShader
    {
        Tags { "RenderType" = "Transparent"
               "Queue" = "Transparent"}
        LOD 200
        Cull Off

        GrabPass{}

        CGPROGRAM

        #pragma  surface surf StandardSpecular alpha:fade
        #pragma  target 3.0

        float _Scale;
        fixed4 _TimeScale;
        float _Distortion;
        

        float3 _Spec;
        half _Smooth;
        float _Alpha;

        int _Complex;
        float _Effectivity;
        float _IsTex;

        sampler2D _GrabTexture;

        struct Input
        {
            float4 screenPos;

            float2 uv_MainTex;
            float3 worldPos;
        };

        fixed2 random2(fixed2 st) {
            st = fixed2(dot(st, fixed2(127.1, 311.7)),
                dot(st, fixed2(269.5, 183.3)));
            return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
        }

        float perlin(fixed2 st) {
            fixed2 p = floor(st);
            fixed2 f = frac(st);
            fixed2 u = f * f * (3.0 - 2.0 * f);

            float v00 = random2(p + fixed2(0, 0));
            float v10 = random2(p + fixed2(1, 0));
            float v01 = random2(p + fixed2(0, 1));
            float v11 = random2(p + fixed2(1, 1));

            return lerp(lerp(dot(v00, f - fixed2(0, 0)), dot(v10, f - fixed2(1, 0)), u.x),
                lerp(dot(v01, f - fixed2(0, 1)), dot(v11, f - fixed2(1, 1)), u.x),
                u.y) + 0.5f;
        }

        float fBm(fixed2 st)
        {
            float f = 0;
            fixed2 q = st;
            for (int i = 1; i <= _Complex; i++) {
                f += pow(_Effectivity, i) * perlin(q);
                q /= _Effectivity;
            }

            return f;
        }

        void surf(Input IN, inout SurfaceOutputStandardSpecular o)
        {
            fixed2 uv = IN.uv_MainTex;
            uv *= _Scale;
            uv += _TimeScale.xy * fixed2(_Time.y, _Time.y);

            float kiten = fBm(uv);

            if (_IsTex == 1) 
            {
                o.Albedo = fixed3(kiten, kiten, kiten);
                o.Alpha = 1;
                //o.Metallic = 0;
                //o.Smoothness = 0;
            }
            else 
            {
                //ノーマルの計算

                //X方向、Y方向について、傾きを求める
                float gradX = fBm(uv + fixed2(1, 0));
                float gradY = fBm(uv + fixed2(0, 1));
                float3 vecX = float3(1, 0, gradX - kiten);
                float3 vecY = float3(0, 1, gradY - kiten);

                //傾きの外積を取り、法線を求める
                float3 norm = cross(vecX, vecY);
                norm = normalize(norm);

                float2 grabUV = (IN.screenPos.xy / IN.screenPos.w);
                grabUV += norm.rg * _Distortion;
                fixed3 grab = tex2D(_GrabTexture, grabUV).rgb;

                o.Albedo = grab;
                o.Normal = norm;
                o.Alpha = _Alpha;
                o.Specular = _Spec.rgb;
                o.Smoothness = _Smooth;
            }

        }


        ENDCG
    }
        FallBack "Diffuse"
}
