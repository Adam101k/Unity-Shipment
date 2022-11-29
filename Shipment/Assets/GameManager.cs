using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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

    public void Start() {
        playerHealth = player.GetComponent<PlayerHealth>();
        UM = this.GetComponent<UIManager>();
    }

    //checks if the player died
    public void Update() {
        if(playerHealth.health <= 0) {
            GameOver(true);
            UM.DisplayGameOver();
            player.SetActive(false);
        }
    }
    public void GameOver(bool gState) {
        _isGameOver = gState;
    }

}
