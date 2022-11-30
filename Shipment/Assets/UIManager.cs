using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using TMPro;

public class UIManager : MonoBehaviour
{
    private static UIManager _instance;
    // This is making sure that there is only one UIManager that can exist at once
    public static UIManager Instance {
        get {
            if (_instance == null) {
                Debug.LogError("UI Manager is Null!!!");
            }
            return _instance;
        }
    }

    public PauseMenu PM;
    private Fade OMF;
    public GameObject gameOverMenuUI;
    public TextMeshProUGUI objectiveText;
    private GameManager GM;
    public void Start() {
        PM = this.GetComponent<PauseMenu>();
        OMF = this.GetComponent<Fade>();
        GM = this.GetComponent<GameManager>();
    }

    public void Update() {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if (PauseMenu.GamePaused)
            {
                PM.Resume();
            }
            else 
            {
                PM.Pause();
            }
        }
        if (Input.GetKeyDown(KeyCode.Tab)) 
        {
            OMF.Fader();
        }
    }

    public void DisplayGameOver()
    {
        gameOverMenuUI.SetActive(true);
        Debug.Log("Game Over!");
    }
    public void Quit()
    {
        SceneManager.LoadScene("MainMenu");
    }

    public void ExitGame() {
        Application.Quit();
    }

    public void RestartLevel() {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
    public void DisplayObjective1() {
        objectiveText.SetText(GM.scrapCollected + "/5 Scrap Metal Collected");
    }
}
