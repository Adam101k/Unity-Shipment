using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

//https://foxxthom.medium.com/game-manager-one-manager-to-rule-them-all-1c06afa72b23
public class GameManager : MonoBehaviour
{
    private static GameManager _instance;
    // This is making sure that there is only one GameManager that can exist at once
    public static GameManager Instance {
        get {
            if (_instance == null) {
                Debug.LogError("Game Manager is Null!!!");
            }
            return _instance;
        }
    }
    private void Awake() {
        _instance = this;
    }

    bool _isGameOver;
    public GameObject player;
    private PlayerHealth playerHealth;
    private UIManager UM;
    public bool obj1State;
    public int scrapCollected = 0;
    public GameObject ObjectMusic;
    private AudioSource AudioSource;
    public AudioClip ObjectiveUpdateSFX;
    public AudioClip ObjectiveItemSfx;
    public bool PlayerInCombat;
    private MusicPlay MP;
    private AudioClip currentClip;
    private GameObject playerShip;
    private ShipController SC;

    public void Start() {
        playerHealth = player.GetComponent<PlayerHealth>();
        UM = this.GetComponent<UIManager>();
        ObjectMusic = GameObject.FindWithTag("GameMusic");
        AudioSource = ObjectMusic.GetComponent<AudioSource>();
        MP = ObjectMusic.GetComponent<MusicPlay>();
        playerShip = GameObject.FindWithTag("Ship");
        SC = playerShip.GetComponent<ShipController>();
        SC.isRidable = false;
    }

    //checks if the player died
    public void Update() {
        if(playerHealth.health <= 0) {
            GameOver(true);
            UM.DisplayGameOver();
            player.SetActive(false);
        }
        if(PlayerInCombat) {
            PlayMusic(MP.BattleMusicInitial);
            Invoke("PlayMusic(MP.BattleMusicLoop)", 108f);
        } else {
            PlayMusic(MP.AtmoMusicInital);
            Invoke("PlayMusic(MP.AtmoMusicLoop)", 108f);
        }
    }
    
    public void GameOver(bool gState) {
        _isGameOver = gState;
    }
    public void Objective1State(bool t) {
        obj1State = t;
        if(obj1State == true) {
            UM.DisplayObjective1();
            AudioSource.PlayOneShot(ObjectiveUpdateSFX);
            GameObject[] objectiveItems = GameObject.FindGameObjectsWithTag("ObjCollectable");
            foreach(GameObject objItem in objectiveItems) {
                objItem.GetComponent<Outline>().enabled = true;
            }
        }
    }
    
    public void AddObjective1() {
        if (obj1State && scrapCollected < 5) {
            scrapCollected += 1;
            AudioSource.PlayOneShot(ObjectiveItemSfx);
            UM.DisplayObjective1();
        }
        if (obj1State && scrapCollected >= 5) {
            obj1State = false;
            Object1Complete();
        }
    }
    private void Object1Complete() {
        UM.ShipIsNowRideable();
        SC.isRidable = true;
    }
    public void PlayMusic(AudioClip clip) {
        if(currentClip != clip) {
            AudioSource.Stop(); //if not, it stops playback and changes the clip
            currentClip = clip;
            AudioSource.PlayOneShot(currentClip);
        } else {
            if(!AudioSource.isPlaying) {
                AudioSource.PlayOneShot(currentClip);
            }
        }
    }
}
