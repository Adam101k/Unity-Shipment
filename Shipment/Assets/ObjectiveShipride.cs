using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;
using TMPro;

public class ObjectiveShipride : MonoBehaviour
{
    private UIManager UM;
    public TextMeshProUGUI theText;
    public AudioClip ObjectiveUpdateSFX;
    private MusicPlay MP;
    private ShipController SC;
    public GameObject ObjectMusic;
    private AudioSource AudioSource;
    private GameObject playerShip;
    // Start is called before the first frame update
    void Start()
    {
        UM = this.GetComponent<UIManager>();
        ObjectMusic = GameObject.FindWithTag("GameMusic");
        AudioSource = ObjectMusic.GetComponent<AudioSource>();
        MP = ObjectMusic.GetComponent<MusicPlay>();
        playerShip = GameObject.FindWithTag("Ship");
        SC = playerShip.GetComponent<ShipController>();
    }

    // Update is called once per frame
    private void OnTriggerEnter(Collider other) {
        if(other.tag == "Player" && SC.riding) {
            StartCoroutine(EscapeRight());
        }
    }
    private IEnumerator EscapeRight() {
        AudioSource.PlayOneShot(ObjectiveUpdateSFX);
        theText.SetText("Escape to the Right");
        yield return new WaitForSeconds(3f);
        Destroy(gameObject);
    }

}
