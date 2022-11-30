using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class Objective1 : MonoBehaviour
{
    //public AudioSource objSFX;
    public GameObject ObjectiveUI;
    public GameObject trigger;
    public TextMeshProUGUI theText;
    private GameManager GM;
    public GameObject GameManager;
    private void OnTriggerEnter(Collider other) {
        if(other.tag == "Player") {
            StartCoroutine(StartMissionObj());
        }
    }
    public void Start() {
        GM = GameManager.GetComponent<GameManager>();
    }

    private IEnumerator StartMissionObj() {
        //objSFX.Play();
        theText.SetText("Collect 5 Scrap Metal");
        yield return new WaitForSeconds(5f);
        GM.Objective1State(true);
        trigger.SetActive(false);
        Destroy(gameObject);
    }
}
