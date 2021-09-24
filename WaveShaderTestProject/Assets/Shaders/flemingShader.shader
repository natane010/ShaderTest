Shader "Unlit/flemingShader"
{
Properties
	{
		_Color("Color", Color) = (1, 1, 1, 1)
		_BumpTex("BumpTexture", 2D) = "white" { }
		_Distortion("Distortion", Range(-0.3, 0.3)) = 0
		_WaveLength("WaveLength", float) = 14.0
		_Flat("_Flat", Range(0, 1)) = 1
	}
	SubShader
	{
	Tags { "RenderType" = "Transparent" "Queue" = "Transparent"}

	//GrabPass{ "_GrabTex" }

	Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			# include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 grabPos : TEXCOORD1;
				float4 scrPos : TEXCOORD2;
				float4 vertexW : TEXCOORD3;
			};
			sampler2D _BumpTex;
			float4 _BumpTex_ST;

			sampler2D _CameraOpaqueTexture;
			float4 _GrabTex_ST;
			float4 _GrabTex_TexelSize;

			sampler2D _CameraDepthTexture;
			float2 _CameraDepthTexture_ST;
			float4 _CameraDepthTexture_TexelSize;

			float4 _Color;
			float _Distortion;

			float _WaveLength;
            float _Flat;

			void gerstnerWave(in float3 localVtx, float t, float waveLen, float Q, float R, float2 browDir, inout float3 localVtxPos, inout float3 localNormal )
            {

                browDir = normalize(browDir);
                const float pi = 3.1415926535f;
                const float grav = 9.8f;
                
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

			v2f vert(appdata v)
			{
				v2f o;

				o.vertexW = mul(unity_ObjectToWorld, v.vertex);

                float3 oPosW = float3(0.0, 0.0, 0.0);
                float3 oNormalW = float3(0.0, 0.0, 0.0);
                float t = _Time.y;
                gerstnerWave(o.vertexW, t + 2.0, 0.8, 0.7, 0.3, float2(0.2, -1.0), oPosW, oNormalW);
                gerstnerWave(o.vertexW, t, 1.2, 0.3, 0.5, float2(-0.4, 0.3), oPosW, oNormalW);
                gerstnerWave(o.vertexW, t + 3.0, 1.8, 0.3, 0.5, float2(0.4, -0.4), oPosW, oNormalW);
                gerstnerWave(o.vertexW, t, 2.2, 0.4, 0.4, float2(0, 0.3), oPosW, oNormalW);
                o.vertexW.xyz += oPosW;

				//float3 perNormalWave = float3(0, rand(v.uv), 0);
                //o.vertexW.xyz += perNormalWave / 1000;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _BumpTex);
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				o.scrPos = ComputeScreenPos(o.vertex);
				//o.normalW = normalize(oNormalW);
				return o;
			}

			float2 AlignWithGrabTexel(float2 uv)
			{
				return (floor(uv * _CameraDepthTexture_TexelSize.zw) + 0.5) * abs(_CameraDepthTexture_TexelSize.xy);
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 bump = UnpackNormal(tex2D(_BumpTex, i.uv));
				float4 depthUV = i.grabPos;
				depthUV.xy = i.grabPos.xy + (bump.xy * _Distortion);

				float surfDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.scrPos.z);
				float refFix = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(depthUV))));
				float depthDiff = saturate(refFix - surfDepth);

				float2 uvoffset = bump.xy * _Distortion;
				float2 grabUV;
				grabUV = AlignWithGrabTexel((i.grabPos.xy + uvoffset * depthDiff) / i.grabPos.w);

				float4 col = tex2D(_CameraOpaqueTexture, grabUV) * _Color;
				//col = tex2D(_GrabTex, grabUV) * depthDiff * _Color;
				return col;
			}
			ENDCG
		}
	}
}
