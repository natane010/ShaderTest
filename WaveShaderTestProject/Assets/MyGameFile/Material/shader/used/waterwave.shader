Shader "waterwave"
{
   Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("Base color", Color ) = (1.0, 1.0, 1.0, 1.0 )
        _S2("PhaseVelocity^2", Range(0.0, 0.5)) = 0.2
        _Atten("Attenuation", Range(0.0, 1.0)) = 0.999
        _DeltaUV("Delta UV", Float) = 3
    }
    SubShader
    {
        Tags {
            "RenderType"="Opaque"
            "LightMode"="UniversalForward"
        }
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
                float4 vertexW : TEXCOORD2;
                float3 normalW : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BaseColor;
            float4 _PlayerPosition;
            half _S2;
            half _Atten;
            float _DeltaUV;

            // �Q���X�g�i�[�g
            void gerstnerWave(in float3 localVtx, float t, float waveLen, float Q, float R, float2 browDir,inout float3 localVtxPos,inout float3 localNormal ) {

                browDir = normalize( browDir );
                const float pi = 3.1415926535f;
                const float grav = 9.8f;
                float A = waveLen / 14.0f;
                float _2pi_per_L = 2.0f * pi / waveLen;
                float d = dot( browDir, localVtx.xz );
                float th = _2pi_per_L * d + sqrt( grav / _2pi_per_L ) * t;

                float3 pos = float3( 0.0, R * A * sin( th ), 0.0 );
                pos.xz = Q * A * browDir * cos( th );

                // �Q���X�g�i�[�g�̖@��
                float3 normal = float3( 0.0, 1.0, 0.0 );
                normal.xz = -browDir * R * cos( th ) / ( 7.0f / pi - Q * browDir * browDir * sin( th ) );

                localVtxPos += pos;
                localNormal += normalize( normal );
            }

            v2f vert (appdata v)
            {
                v2f o;

                o.vertexW = mul( unity_ObjectToWorld, v.vertex );

                float3 oPosW = float3( 0.0, 0.0, 0.0 );
                float3 oNormalW = float3( 0.0, 0.0, 0.0 );
                float t = _Time.y;
                gerstnerWave( o.vertexW, t + 2.0, 0.8, 0.7, 0.3, float2( 0.2, 0.3 ), oPosW, oNormalW );
                gerstnerWave( o.vertexW, t, 1.2, 0.3, 0.5, float2( -0.4, 0.7 ), oPosW, oNormalW );
                gerstnerWave( o.vertexW, t + 3.0, 1.8, 0.3, 0.5, float2( 0.4, 0.4 ), oPosW, oNormalW );
                gerstnerWave( o.vertexW, t, 2.2, 0.4, 0.4, float2( -0.3, 0.6 ), oPosW, oNormalW );
                o.vertexW.xyz += oPosW;

                // ���W�ϊ�
                o.vertex = mul( UNITY_MATRIX_VP, o.vertexW );
                o.uv = TRANSFORM_TEX( v.uv, _MainTex );
                o.normalW = normalize( oNormalW );
                UNITY_TRANSFER_FOG( o, o.vertex );

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 normalW = normalize( i.normalW );

                // �f�B�t���[�Y
                float3 toLightDirW = normalize( _WorldSpaceLightPos0.xyz );
                float diffusePower = dot( normalW, toLightDirW );
                col.rgb = max( 0.0, diffusePower ) * _BaseColor.rgb * col.xyz;

                // �X�y�L����
                float3 vertexToCameraW = normalize( _WorldSpaceCameraPos - i.vertexW.xyz );
                float3 specularColor = pow( max( 0.0, dot( reflect( -toLightDirW, normalW ), vertexToCameraW ) ), 4.0f );
                col.rgb += specularColor * 0.5f;

                UNITY_APPLY_FOG( i.fogCoord, col );

                return col;
            }
            ENDCG
        }
    }
}
