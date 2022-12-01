using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.Audio;

public class Objective1 : MonoBehaviour
{
    public AudioSource objSFX;
    public GameObject ObjectiveUI;
    public GameObject trigger;
    public TextMeshProUGUI theText;
    private GameManager GM;
    public GameObject GameManager;
    private GameObject ObjectMusic;
    private void OnTriggerEnter(Collider other) {
        if(other.tag == "Player") {
            StartCoroutine(StartMissionObj());
        }
    }
    public void Start() {
        GM = GameManager.GetComponent<GameManager>();
        ObjectMusic = GameObject.FindWithTag("GameMusic");
        objSFX = ObjectMusic.GetComponent<AudioSource>();
    }

    private IEnumerator StartMissionObj() {
        objSFX.PlayOneShot(GM.ObjectiveUpdateSFX);
        theText.SetText("Collect 5 Scrap Metal");
        yield return new WaitForSeconds(3f);
        GM.Objective1State(true);
        trigger.SetActive(false);
        Destroy(gameObject);
    }
}
