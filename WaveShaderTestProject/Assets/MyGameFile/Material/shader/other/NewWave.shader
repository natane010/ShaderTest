Shader "NewWave"
{
    Properties
    {
        _Speed("Speed ",Range(0, 100)) = 1
        _Frequency("Frequency ", Range(0, 3)) = 1
        _Amplitude("Amplitude", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag
            
           #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };
            
            float _Speed;
            float _Frequency;
            float _Amplitude;

            v2f vert (appdata v)
            {
                v2f o;
                
                // ŽžŠÔ‚É‚æ‚Á‚Ä”g‚ªˆÚ“®‚·‚é‚æ‚¤‚É
                float time     = _Time * _Speed;
                float offsetY  = sin(time + v.vertex.x * _Frequency) + sin(time + v.vertex.z * _Frequency);
                offsetY         *= _Amplitude;
                v.vertex.y      += offsetY;
                o.vertex        = UnityObjectToClipPos(v.vertex);

                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = 1;
                return col;
            }
            ENDCG
        }
    }
}
