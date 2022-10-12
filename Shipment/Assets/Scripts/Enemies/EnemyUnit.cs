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
    public float walkSpeed;
    public float chaseSpeed;
    public bool enemyAgro;

    private Vector3 walkPoint;
    public float walkPointRange;

    public float damageTimeout = 1f;

    public float wonderTimeout = 1f;
    public bool canTakeDamage = true;
    public bool canWander = true;

    public GameObject BloodHitEffect;
    public float damage = 1;

    // Start is called before the first frame update
    void Start() {
        myAgent = GetComponent<NavMeshAgent>();
    }
    // Update is called once per frame
    private void Update() {
        AgroColliders = Physics.OverlapSphere(transform.position, UnitAgroRange, checkLayers);
        if(AgroColliders.Length == 0)
        {
            //wandering code
            if(canWander == true) {
            myAgent.speed = walkSpeed;
            myAgent.SetDestination(Wander());
            StartCoroutine(wanderTimer());
        }
        } else {
        
            myAgent.SetDestination(AgroColliders[0].transform.position);
            myAgent.stoppingDistance=(UnitDamageRange);
            myAgent.speed = chaseSpeed;
        }


        DamageColliders = Physics.OverlapSphere(transform.position, UnitDamageRange, checkLayers);
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

    public void DealDamage() {
        GameObject.Instantiate(BloodHitEffect, AgroColliders[0].transform.position, AgroColliders[0].transform.rotation);
        UnitHealth eHealth = DamageColliders[0].gameObject.GetComponent<UnitHealth>();
        eHealth.AdjustCurrentHealth(damage);
    }

    private IEnumerator damageTimer() {
        canTakeDamage = false;
        yield return new WaitForSeconds(damageTimeout);
        canTakeDamage = true;
    }

    private void OnDrawGizmos() {
        Gizmos.DrawWireSphere(transform.position, UnitAgroRange);
        Gizmos.DrawWireSphere(transform.position, UnitDamageRange);
        Gizmos.DrawWireSphere(transform.position, walkPointRange);
        Gizmos.DrawSphere(walkPoint, 3);
    }

    public Vector3 Wander() {
        float randomZ = Random.Range(-walkPointRange, walkPointRange);
        float randomX = Random.Range(-walkPointRange, walkPointRange);
        walkPoint = new Vector3(transform.position.x + randomX, transform.position.y, transform.position.z + randomZ);
        return walkPoint;
    }
    
    private IEnumerator wanderTimer() {
        canWander = false;
        yield return new WaitForSeconds(wonderTimeout);
        canWander = true;
    }

}
