using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlamingRandom : MonoBehaviour
{
    float nowDouble;
    float randomNum;
    float setNum;
    Material material;
    [SerializeField]Renderer renderer;
    [SerializeField] float speed;
    [SerializeField] float _Lownum;
    [SerializeField] float _Highnum;
    // Start is called before the first frame update
    void Start()
    {
        material = renderer.material;
        material.SetFloat("_Distortion", 0.3f);
        nowDouble = 0.0f;
        randomNum = 1.0f;
    }

    // Update is called once per frame
    void Update()
    {
        speed = (Random.Range(0, 2) * 0.1f);
        nowDouble = material.GetFloat("_Distortion");
        if (setNum >= _Highnum)
        {
            setNum = nowDouble;
            randomNum = -1;
        }
        else if (setNum <= _Lownum)
        {
            setNum = nowDouble;
            randomNum = 1;
        }
        setNum = Mathf.MoveTowards(setNum, randomNum, Time.deltaTime * speed);
        //setNum = Mathf.Sin(Time.deltaTime) * speed;
        
        material.SetFloat("_Distortion", setNum);
        //print(setNum + " ," + nowDouble);
    }
}
