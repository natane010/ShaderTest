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
        nowDouble = material.GetFloat("_Distortion");
        if (setNum >= 0.3)
        {
            setNum = nowDouble;
            randomNum = -1;
        }
        else if (setNum <= -0.3)
        {
            setNum = nowDouble;
            randomNum = 1;
        }
        setNum = Mathf.MoveTowards(setNum, randomNum, Time.deltaTime * speed);
        //setNum = Mathf.Sin(Time.deltaTime) * speed;
        
        material.SetFloat("_Distortion", setNum);
        print(setNum + " ," + nowDouble);
    }
}
