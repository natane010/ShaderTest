Shader "Custom/ColisionWater"
{

    Properties
    {
        _Color("Color", color) = (1, 1, 1, 0)
        _MainTex("Base (RGB)", 2D) = "white" {}
        _DispTex("Disp Texture", 2D) = "gray" {}
        _MinDist("Min Distance", Range(0.1, 50)) = 10
        _MaxDist("Max Distance", Range(0.1, 50)) = 25
        _TessFactor("Tessellation", Range(1, 50)) = 10 //�������x��
        _Displacement("Displacement", Range(0, 1.0)) = 0.3 //�ψ�
    }

    SubShader
    {

        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert //vert�����_�V�F�[�_�[�ł��邱�Ƃ�GPU�ɓ`����
            #pragma fragment frag //frag���t���O�����g�V�F�[�_�[�ł��邱�Ƃ�GPU�ɓ`����
            #pragma hull hull //hull���n���V�F�[�_�[�ł��邱�Ƃ�GPU�ɓ`����
            #pragma domain domain //domain���h���C���V�F�[�_�[�ł��邱�Ƃ�GPU�ɓ`����

            #include "Tessellation.cginc"
            #include "UnityCG.cginc"

            //�萔���`
            #define INPUT_PATCH_SIZE 3
            #define OUTPUT_PATCH_SIZE 3

            float _TessFactor;
            float _Displacement;
            float _MinDist;
            float _MaxDist;
            sampler2D _DispTex;
            sampler2D _MainTex;
            fixed4 _Color;

            //GPU���璸�_�V�F�[�_�[�ɓn���\����
            struct appdata
            {
                float3 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            //���_�V�F�[�_�[����n���V�F�[�_�[�ɓn���\����
            struct HsInput
            {
                float4 position : POS;
                float3 normal : NORMAL;
                float2 texCoord : TEXCOORD;
            };

            //�n���V�F�[�_�[����e�b�Z���[�^�[�o�R�Ńh���C���V�F�[�_�[�ɓn���\����
            struct HsControlPointOutput
            {
                float3 position : POS;
                float3 normal : NORMAL;
                float2 texCoord : TEXCOORD;
            };

            //Patch-Constant-Function����e�b�Z���[�^�[�o�R�Ńh���C���V�F�[�_�[�ɓn���\����
            struct HsConstantOutput
            {
                float tessFactor[3] : SV_TessFactor;
                float insideTessFactor : SV_InsideTessFactor;
            };

            //�h���C���V�F�[�_�[����t���O�����g�V�F�[�_�[�ɓn���\����
            struct DsOutput
            {
                float4 position : SV_Position;
                float2 texCoord : TEXCOORD0;
            };

            //���_�V�F�[�_�[
            HsInput vert(appdata i)
            {
                HsInput o;
                o.position = float4(i.vertex, 1.0);
                o.normal = i.normal;
                o.texCoord = i.texcoord;
                return o;
            }

            //=======================�y�p��z==================================
            // �R���g���[���|�C���g�F���_�����Ŏg������_
            // �p�b�`�F�|���S�������������s���ۂɎg�p����R���g���[���|�C���g�̏W��
            //================================================================
            
            //�n���V�F�[�_�[
            //�p�b�`�ɑ΂��ăR���g���[���|�C���g�����蓖�Ăďo�͂���
            //�R���g���[���|�C���g���Ƃ�1����s
            [domain("tri")] //�����ɗ��p����`����w��@"tri" "quad" "isoline"����I��
            [partitioning("integer")] //�������@ "integer" "fractional_eve" "fractional_odd" "pow2"����I��
            [outputtopology("triangle_cw")] //�o�͂��ꂽ���_���`������g�|���W�[(�`��)�@"point" "line" "triangle_cw" "triangle_ccw" ����I��
            [patchconstantfunc("hullConst")] //Patch-Constant-Function�̎w��
            [outputcontrolpoints(OUTPUT_PATCH_SIZE)] //�o�͂����R���g���[���|�C���g�̏W���̐�
            HsControlPointOutput hull(InputPatch<HsInput, INPUT_PATCH_SIZE> i, uint id : SV_OutputControlPointID)
            {
                HsControlPointOutput o = (HsControlPointOutput)0;
                //���_�V�F�[�_�[�ɑ΂��ăR���g���[���|�C���g�����蓖��
                o.position = i[id].position.xyz;
                o.normal = i[id].normal;
                o.texCoord = i[id].texCoord;
                return o;
            }

            //Patch-Constant-Function
            //�ǂ̒��x���_�𕪊����邩�����߂�W�����l�ߍ���Ńe�b�Z���[�^�[�ɓn��
            //�p�b�`���ƂɈ����s�����
            HsConstantOutput hullConst(InputPatch<HsInput, INPUT_PATCH_SIZE> i)
            {
                HsConstantOutput o = (HsConstantOutput)0;

                float4 p0 = i[0].position;
                float4 p1 = i[1].position;
                float4 p2 = i[2].position;
                //���_����J�����܂ł̋������v�Z���e�b�Z���[�V�����W���������ɉ����Čv�Z���Ȃ����@LOD�I�ȁH
                float4 tessFactor = UnityDistanceBasedTess(p0, p1, p2, _MinDist, _MaxDist, _TessFactor);

                o.tessFactor[0] = tessFactor.x;
                o.tessFactor[1] = tessFactor.y;
                o.tessFactor[2] = tessFactor.z;
                o.insideTessFactor = tessFactor.w;

                return o;
            }

            //�h���C���V�F�[�_�[
            //�e�b�Z���[�^�[����o�Ă��������ʒu�Œ��_���v�Z���o�͂���̂��d��
            [domain("tri")] //�����ɗ��p����`����w��@"tri" "quad" "isoline"����I��
            DsOutput domain(
                HsConstantOutput hsConst,
                const OutputPatch<HsControlPointOutput, INPUT_PATCH_SIZE> i,
                float3 bary : SV_DomainLocation)
            {
                DsOutput o = (DsOutput)0;

                //�V�����o�͂���e���_�̍��W���v�Z
                float3 f3Position =
                    bary.x * i[0].position +
                    bary.y * i[1].position +
                    bary.z * i[2].position;

                //�V�����o�͂���e���_�̖@�����v�Z
                float3 f3Normal = normalize(
                    bary.x * i[0].normal +
                    bary.y * i[1].normal +
                    bary.z * i[2].normal);

                //�V�����o�͂���e���_��UV���W���v�Z
                o.texCoord =
                    bary.x * i[0].texCoord +
                    bary.y * i[1].texCoord +
                    bary.z * i[2].texCoord;

                //tex2Dlod�̓t���O�����g�V�F�[�_�[�ȊO�̉ӏ��ł��e�N�X�`�����T���v�����O�ł���֐�
                //������r�������p���邱�ƂŔg��̍����ɉ����Ē��_�̕ψʂ𑀍�ł���I�������I
                float disp = tex2Dlod(_DispTex, float4(o.texCoord, 0, 0)).r * _Displacement;
                f3Position.xyz += f3Normal * disp;

                o.position = UnityObjectToClipPos(float4(f3Position.xyz, 1.0));

                return o;
            }

            //�t���O�����g�V�F�[�_�[
            fixed4 frag(DsOutput i) : SV_Target
            {
                return tex2D(_MainTex, i.texCoord) * _Color;
            }
            ENDCG
        }
    }

    Fallback "Unlit/Texture"

}