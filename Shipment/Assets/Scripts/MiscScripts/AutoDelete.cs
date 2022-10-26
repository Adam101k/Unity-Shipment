using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoDelete : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(DeleteTimer());
    }

    IEnumerator DeleteTimer()
    {
        yield return new WaitForSeconds(2f);
        Destroy(gameObject);
    }

}
