using System;
using System.Collections;
using UnityEngine;
using UnityEngine.AI;


public class EnemyUnit : MonoBehaviour
{

    NavMeshAgent myAgent;
    Collider[] AgroColliders;

    Collider[] DamageColliders;
    public LayerMask checkLayers;
    public float UnitAgroRange; //How Close the unit has to be to start moving
    public float UnitDamageRange; //How Close the unit has to be to deal damage
    public bool enemyAgro;

    public float damageTimeout = 1f;
    public bool canTakeDamage = true;

    public GameObject BloodHitEffect;
    public float damage = 1;

    // Start is called before the first frame update
    void Start()
    {
        myAgent = GetComponent<NavMeshAgent>();
    }
    // Update is called once per frame
    private void Update()
    {
        AgroColliders = Physics.OverlapSphere(transform.position, UnitAgroRange, checkLayers);
        Array.Sort(AgroColliders, new DistanceComparer(transform));
        if(AgroColliders.Length == 0)
        {
            
        } else {
        
        myAgent.SetDestination(AgroColliders[0].transform.position);
        myAgent.stoppingDistance=(UnitDamageRange);
        }


        DamageColliders = Physics.OverlapSphere(transform.position, UnitDamageRange, checkLayers);
        Array.Sort(AgroColliders, new DistanceComparer(transform));

        if(DamageColliders.Length == 0)
        {
            enemyAgro = false;
        } else {
            enemyAgro = true;
        }
        if(canTakeDamage == true && enemyAgro == true && DamageColliders[0].gameObject.tag == "Player")
        {
            DealDamage();
            StartCoroutine(damageTimer());
            myAgent.ResetPath();
        }
    }

    public void DealDamage()
    {
        GameObject.Instantiate(BloodHitEffect, AgroColliders[0].transform.position, AgroColliders[0].transform.rotation);
        UnitHealth eHealth = DamageColliders[0].gameObject.GetComponent<UnitHealth>();
        eHealth.AdjustCurrentHealth(damage);
    }

    private IEnumerator damageTimer()
    {
        canTakeDamage = false;
        yield return new WaitForSeconds(damageTimeout);
        canTakeDamage = true;
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, UnitAgroRange);
        Gizmos.DrawWireSphere(transform.position, UnitDamageRange);
    }
}
