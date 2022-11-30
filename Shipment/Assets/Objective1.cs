using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Objective1 : MonoBehaviour
{
    public GameObject ObjectiveUI;
    public GameObject trigger;
    
    private void OnTriggerEnter(Collider other) {
        if(Collider.tag == "player") {
            StartCourutine(missionObj());
        }
    }

    private IEnumerator missionObj() {
        ObjectiveUI.getComponenent<Text>().text = "Collect 5 Scrap Metal";
    }
}
