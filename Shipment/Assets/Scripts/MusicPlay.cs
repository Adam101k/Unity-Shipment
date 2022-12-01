using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.SceneManagement;

public class MusicPlay : MonoBehaviour
{
    public GameObject ObjectMusic;

    private float MusicVolume = 1f;
    public AudioSource AudioSource;
    public AudioClip BattleMusicInitial;
    public AudioClip BattleMusicLoop;
    public AudioClip AtmoMusicInital;
    public AudioClip AtmoMusicLoop;
    public AudioClip MenuMusicInital;
    public AudioClip MenuMusicLoop;
    // Start is called before the first frame update
    private void Start()
    {
        ObjectMusic = GameObject.FindWithTag("GameMusic");
        AudioSource = ObjectMusic.GetComponent<AudioSource>();

        //Set Volume
        MusicVolume = PlayerPrefs.GetFloat("volume");
        AudioSource.volume = MusicVolume;
        /*if(SceneManager.GetActiveScene().name == "MainMenu") {
            AudioSource.PlayOneShot(MenuMusicInital);
        }*/
    }

    // Update is called once per frame
    private void Update()
    {
        AudioSource.PlayOneShot(MenuMusicInital);
        AudioSource.volume = MusicVolume;
        PlayerPrefs.SetFloat("volume", MusicVolume);
    }
    public void VolumeUpdater(float volume) {
        MusicVolume = volume;
    }
    public void MusicReset() {
        PlayerPrefs.DeleteKey("volume");
        AudioSource.volume = 1;
    }
}
