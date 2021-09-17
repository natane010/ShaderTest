using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CheakCode : MonoBehaviour
{
    /// <summary>
    /// �}�E�X����o��Ray�ƃI�u�W�F�N�g�̏Փˍ��W��Shader�ɓn��
    /// �K���ȃI�u�W�F�N�g�ɃA�^�b�`
    /// </summary>
    public class MouseRayHitPointSendToShader : MonoBehaviour
    {
        /// <summary>
        /// �|�C���^�[���o�������I�u�W�F�N�g�̃����_���[
        /// �O��FShader�͍��W�󂯎��ɑΉ��������̂�K�p
        /// </summary>
        [SerializeField] private Renderer _renderer;

        /// <summary>
        /// Shader���Œ�`�ς݂̍��W���󂯎��ϐ�
        /// </summary>
        private string propName = "_MousePosition";

        private Material mat;

        void Start()
        {
            mat = _renderer.material;
        }

        void Update()
        {
            //�}�E�X�̓���
            if (Input.GetMouseButton(0))
            {
                //Ray�o��
                Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
                RaycastHit hit_info = new RaycastHit();
                float max_distance = 100f;

                bool is_hit = Physics.Raycast(ray, out hit_info, max_distance);

                //Ray�ƃI�u�W�F�N�g���Փ˂����Ƃ��̏���������
                if (is_hit)
                {
                    //�Փ�
                    Debug.Log(hit_info.point);
                    Debug.Log("aa");
                    //Shader�ɍ��W��n��
                    mat.SetVector(propName, hit_info.point);
                }
            }
        }
    }
}