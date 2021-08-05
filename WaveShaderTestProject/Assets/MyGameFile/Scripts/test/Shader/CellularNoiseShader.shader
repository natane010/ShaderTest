Shader "ShaderSketches/CellularNoiseShader"
{
    Properties
   {
        _MainTex ("MainTex", 2D) = "white" {}
   }
    
   CGINCLUDE
   #include "UnityCG.cginc"

   float random(float2 st)
   {
          st = float2(dot(st,float2(127.1, 317.7)), 
          dot(st,float2(269.5, 183.3)));
          return - 1.0 + 2.0 * frac(sin(st) * 43758.5453123);
   }

   float4 frag1(v2f_img i):SV_Target
   {
        float2 st = i.uv;
        st = st * 10;
        float2 ist = floor(st);

        float2 fst  = frac(st);

        float distance = 5;

        for(int i = -1; i<=1;i++)
        {
            for(int j = -1; j<=1;j++)
            {
                float2 neightbor = float2(j, i);
                float2 p = 0.5 + 0.5 * sin(_Time.y + 6.2381 * random(ist + neightbor));
                float diff = neightbor + p - fst;
                distance = min(distance, length(diff));
            }
        }
        return distance * 0.5;
   }
   ENDCG

   SubShader
   {
        pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag1
            ENDCG
        }
   }
}
