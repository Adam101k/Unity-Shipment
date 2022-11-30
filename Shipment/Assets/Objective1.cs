using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Objective1 : MonoBehaviour
{
    public AudioSource objSFX;
    public GameObject ObjectiveUI;
    public GameObject trigger;
    public GameObject theText;
    private void OnTriggerEnter(Collider other) {
        if(other.tag == "Player") {
            StartCoroutine(StartMissionObj());
        }
    }

    private IEnumerator StartMissionObj() {
        theText.GetComponent<Text>().text = "Collect 5 Scrap Metal";
        yield return new WaitForSeconds(5.3f);
        trigger.SetActive(false);
    }
}
