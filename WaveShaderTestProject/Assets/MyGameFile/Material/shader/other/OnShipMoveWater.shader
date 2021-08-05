Shader "Custom/OnShipMoveWater"
{
    Properties
    {
        _S2("PhaseVelocity^2", Range(0.0, 0.5)) = 0.2
        _Attenuation("Attenuation", Range(0.0, 1.0)) = 0.999
        _DeltaUV("Delta UV", Range(0.0, 0.5)) = 0.1
        _Displacement("Displacement", Range(1.0, 5.0)) = 3.0
    }

    CGINCLUDE
    #include "UnityCustomRenderTexture.cginc"

    half _S2;
    half _Attenuation;
    float _DeltaUV;
    float _Displacement;
    float _height;
    sampler2D _MainTex;

    //�g�����������v�Z����t���O�����g�V�F�[�_�[
    float4 frag(v2f_customrendertexture i) : SV_Target
    {
        float2 uv = i.globalTexcoord;

        // 1px������̒P�ʂ��v�Z����
        float du = 1.0 / _CustomRenderTextureWidth;
        float dv = 1.0 / _CustomRenderTextureHeight;
        float2 duv = float2(du, dv) * _DeltaUV; //_DeltaUV�͌W�� �傫������قǍL�����������

        // ���݂̈ʒu�̃e�N�Z�����t�F�b�`
        float2 c = tex2D(_SelfTexture2D, uv);

        //�g��������
        //h(t + 1) = 2h + c(h(x + 1) + h(x - 1) + h(y + 1) + h(y - 1) - 4h) - h(t - 1)
        //����Ah(t + 1)�͎��̃t���[���ł̔g�̍�����\��
        //R,G�����ꂼ�ꍂ���Ƃ��Ďg�p
        float k = (2.0 * c.r) - c.g; //2h - h(t - 1) ���Ɍv�Z
        float p = (k + _S2 * ( //_S2�͌W�� �ʑ��̕ω����鑬�x
                tex2D(_SelfTexture2D, uv + duv.x).r +
                tex2D(_SelfTexture2D, uv - duv.x).r +
                tex2D(_SelfTexture2D, uv + duv.y).r +
                tex2D(_SelfTexture2D, uv - duv.y).r - 4.0 * c.r)
        ) * _Attenuation; //�����W��

        // ���݂̏�Ԃ��e�N�X�`����R�����ɁA�ЂƂO�́i�ߋ��́j��Ԃ�G�����ɏ������ށB
        return float4(p, c.r, 0, 0);
    }

    //�N���b�N�����Ƃ��ɗ��p�����t���O�����g�V�F�[�_�[
    float4 frag_left_click(v2f_customrendertexture i) : SV_Target
    {
        return float4(_Displacement, 0, 0, 0);
    }
    
    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        //�f�t�H���g�ŗ��p�����Pass
        Pass
        {
            Name "Update"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            ENDCG
        }

        //�N���b�N�����Ƃ��ɗ��p�����Pass
        Pass
        {
            Name "LeftClick"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag_left_click
            ENDCG
        }
    }
}