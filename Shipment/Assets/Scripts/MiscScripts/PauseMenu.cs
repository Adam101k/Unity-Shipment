using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PauseMenu : MonoBehaviour
{
    public static bool GamePaused = false;

    public GameObject pauseMenuUI;


    // Update is called once per frame
    public void Resume()
    {
        pauseMenuUI.SetActive(false);
        GamePaused = false;
        Time.timeScale = 1;
    }
    public void Pause()
    {
        pauseMenuUI.SetActive(true);
        GamePaused = true;
        Time.timeScale = 0;
    }
}
