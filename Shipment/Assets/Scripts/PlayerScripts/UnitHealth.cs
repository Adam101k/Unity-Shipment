using System;
using UnityEngine;
using UnityEngine.UI;

public class UnitHealth : MonoBehaviour
{
    public float health;
    public float maxHealth;

    public GameObject healthBarUI;
    public GameObject cam;
    public Slider slider;

    void Start()
    {
        health = maxHealth;
        slider.value = CalculateHealth();
    }

    void Update()
    {
        slider.value = CalculateHealth();
        healthBarUI.transform.LookAt(cam.transform);

        if(health < maxHealth)
        {
            healthBarUI.SetActive(true);
        }
        if(health <= 0)
        {
            Destroy(gameObject);
        }
        if(health > maxHealth)
        {
            health = maxHealth;
        }
    }

    public void AdjustCurrentHealth(float adj)
    {
        health -= adj;
    }

    float CalculateHealth()
    {
        return health/maxHealth;
    }
}
