Shader "Unlit/CheakShader"
{
SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
                {
        CGPROGRAM
                    #pragma vertex vert
        #pragma fragment frag
        # include "UnityCG.cginc"

        struct v2f
        {
            float4 vertex : SV_POSITION;
                        float3 worldPos : WORLD_POS;
                    };

        //C#���ł�����ϐ�
        float4 _MousePosition;

        v2f vert(appdata_base v)
        {
            v2f o;
            //3D��ԍ��W���X�N���[�����W�ϊ�
            o.vertex = UnityObjectToClipPos(v.vertex);
            //�`�悵�����s�N�Z���̃��[���h���W���v�Z
            o.worldPos = mul(unity_ObjectToWorld, v.vertex);
            return o;
        }

        fixed4 frag(v2f i) : SV_Target
        {
            //�x�[�X�J���[�@��
            float4 baseColor = (1, 1, 1, 1);

            /*"�}�E�X����o��Ray�ƃI�u�W�F�N�g�̏Փˉӏ�(���[���h���W)"��
     �@        "�`�悵�悤�Ƃ��Ă���s�N�Z���̃��[���h���W"�̋��������߂�*/
            float dist = distance(_MousePosition, i.worldPos);

            //���߂��������C�ӂ̋����ȉ��Ȃ�`�悵�悤�Ƃ��Ă���s�N�Z���̐F��ς���
            if (dist < 0.1)
            {
                //�ԐF��Z���
                baseColor *= float4(1, 0, 0, 0);
            }

            return baseColor;
        }
        ENDCG
        }
    } 
}
