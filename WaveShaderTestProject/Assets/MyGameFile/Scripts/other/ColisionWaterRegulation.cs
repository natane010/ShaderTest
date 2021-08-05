using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColisionWaterRegulation : MonoBehaviour
{
    public class ClickRipple : MonoBehaviour
    {
        [SerializeField] private CustomRenderTexture _customRenderTexture;
        [SerializeField, Range(0.01f, 0.05f)] private float _ripppleSize = 0.01f;
        [SerializeField] private int iterationPerFrame = 5;

        private CustomRenderTextureUpdateZone _defaultZone;

        private void Start()
        {
            //������
            _customRenderTexture.Initialize();

            //�g���������̃V�~�����[�g�p��UpdateZone
            //�S�̂̍X�V�p
            _defaultZone = new CustomRenderTextureUpdateZone
            {
                needSwap = true,
                passIndex = 0,
                rotation = 0f,
                updateZoneCenter = new Vector2(0.5f, 0.5f),
                updateZoneSize = new Vector2(1f, 1f)
            };
        }

        private void Update()
        {
            //�N���b�N����UpdateZone���N���b�N����K�����ꂽ��ԂɂȂ�Ȃ��悤�Ɉ�x��������
            _customRenderTexture.ClearUpdateZones();
            UpdateZonesClickArea();
            //�X�V�������t���[�������w�肵�čX�V
            _customRenderTexture.Update(iterationPerFrame);
        }

        /// <summary>
        /// �N���b�N�����ӏ����N�_�ɓ���̗̈�̂ݎw�肵���p�X�ŃV�~�����[�g������
        /// </summary>
        private void UpdateZonesClickArea()
        {
            bool leftClick = Input.GetMouseButton(0);
            if (!leftClick) return;

            var ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out var hit))
            {
                //�N���b�N���Ɏg�p����UpdateZone
                //�N���b�N�����ӏ����X�V�̌��_�Ƃ���
                //�g�p����p�X���N���b�N�p�ɕύX
                var clickZone = new CustomRenderTextureUpdateZone
                {
                    needSwap = true,
                    passIndex = 1,
                    rotation = 0f,
                    updateZoneCenter = new Vector2(hit.textureCoord.x, 1f - hit.textureCoord.y),
                    updateZoneSize = new Vector2(_ripppleSize, _ripppleSize)
                };

                _customRenderTexture.SetUpdateZones(new CustomRenderTextureUpdateZone[] { _defaultZone, clickZone });
            }
        }
    }
}
