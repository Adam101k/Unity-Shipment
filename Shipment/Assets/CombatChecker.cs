using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CombatChecker : MonoBehaviour
{
    // Start is called before the first frame update

    public float AgroCheckerRange;
    public LayerMask checkLayers;
    Collider[] AgroColliders;
    private GameManager GM;
    public GameObject GameManager;
    void Start()
    {
        GM = GameManager.GetComponent<GameManager>();
    }

    private void Update() {
        AgroColliders = Physics.OverlapSphere(transform.position, AgroCheckerRange, checkLayers);
        if(AgroColliders.Length == 0) {
            GM.PlayerInCombat = false;
        } else {
            GM.PlayerInCombat = true;
        }
    }
}
