Shader "ShaderSketches/NewShader2"
{
   Properties
   {
        _MainTex ("MainTex", 2D) = "white" {}
   }
    
   CGINCLUDE
   #include "UnityCG.cginc"
   
   float4 heart(float2 st)
   {
       st = (st - float2(0.5, 0.38)) * float2(2.1,2.8);
       return pow(st.x, 2) + pow(st.y - sqrt(abs(st.x)),2);
   }

   float4 frag1(v2f_img i):SV_Target
   {
        float d = heart(i.uv);
        return step(d,abs(sin(d * 8 - _Time.w * 2)));
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
