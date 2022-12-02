using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public class PMeleeWeapons : MonoBehaviour
{
    
    public float damageTimeout = 1f;
    public bool canDealDamage;
    public float damage = 1;
    private bool equipped;
    public LayerMask checkLayers;
    UnitHealth eHealth;
    public float UnitDamageRange; 
    Collider[] DamageColliders;
    public GameObject hitEffect;
    Animator anim;
    public WeaponInteraction weaponI;
    private GameObject ObjectMusic;
    private AudioSource AudioSource;
    private MusicPlay MP;
    void Start()
    {
        anim = gameObject.GetComponent<Animator>();
        canDealDamage = true;
        ObjectMusic = GameObject.FindWithTag("GameMusic");
        MP = ObjectMusic.GetComponent<MusicPlay>();
        AudioSource = ObjectMusic.GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        DamageColliders = Physics.OverlapSphere(transform.position, UnitDamageRange, checkLayers);
        if(canDealDamage == true && weaponI.equipped && Input.GetMouseButtonDown(0)) {
            anim.SetTrigger("Attack");
            DealDamage();
            AudioSource.PlayOneShot(MP.PlayerAttack);
            StartCoroutine(damageTimer());
        }
    }

    public void DealDamage() {
        Debug.Log("Player is attacking");
        GameObject.Instantiate(hitEffect, DamageColliders[0].transform.position, DamageColliders[0].transform.rotation);
        eHealth = DamageColliders[0].gameObject.GetComponent<UnitHealth>();
        eHealth.AdjustCurrentHealth(damage);
        
    }
    private IEnumerator damageTimer() {
        canDealDamage = false;
        yield return new WaitForSeconds(damageTimeout);
        canDealDamage = true;
    }
}
