using System.Collections;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Audio;

public class EnemyUnit : MonoBehaviour
{

    NavMeshAgent myAgent;
    Collider[] AgroColliders;

    Collider[] DamageColliders;
    public LayerMask checkLayers;
    public float UnitAgroRange; //How Close the unit has to be to start moving
    public float UnitDamageRange; //How Close the unit has to be to deal damage
    public float walkPointRange; //Radius value for where the enemy can wonder
    public float walkSpeed; //How fast the enemy moves when wondering
    public float chaseSpeed; //How fast the enemy moves when agro
    public bool enemyAgro;
    PlayerHealth eHealth;
    public float damageTimeout = 1f;
    public float wonderTimeout = 1f;
    public float damage = 1;
    public bool canTakeDamage = true;
    public bool canWander = true;

    public GameObject BloodHitEffect;
    private Vector3 walkPoint;
    private GameObject ObjectMusic;
    private AudioSource AudioSource;
    private MusicPlay MP;

    // Start is called before the first frame update
    void Start() {
        myAgent = GetComponent<NavMeshAgent>();
        ObjectMusic = GameObject.FindWithTag("GameMusic");
        MP = ObjectMusic.GetComponent<MusicPlay>();
        AudioSource = ObjectMusic.GetComponent<AudioSource>();
    }
    // Update is called once per frame
    private void Update() {
        AgroColliders = Physics.OverlapSphere(transform.position, UnitAgroRange, checkLayers);
        if(AgroColliders.Length == 0)   {
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
            AudioSource.PlayOneShot(MP.EnemyAttack);
            StartCoroutine(damageTimer());
            myAgent.ResetPath();
        }
    }

    public void DealDamage() {
        Debug.Log("Damage is being called");
        GameObject.Instantiate(BloodHitEffect, AgroColliders[0].transform.position, AgroColliders[0].transform.rotation);
        eHealth = DamageColliders[0].gameObject.GetComponent<PlayerHealth>();
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
        Gizmos.DrawSphere(walkPoint, 1);
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
