Shader "ShaderSketches/NewShader1"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
    }
    
    CGINCLUDE
    #include "UnityCG.cginc"

    float4 frag(v2f_img i):SV_TARGET
    {
        return float4(i.uv.x,i.uv.y,0,1);
    }

    float4 frag1(v2f_img i):SV_TARGET
    {
        float dis = distance(float2(0.5,0.5),i.uv);
        dis = dis * 30;
        float area = abs(sin(dis)) * _Time;
        return area;
        //return area;
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
