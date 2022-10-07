//do not use this script, going to merge these scripts with PickUpObject.cs
//keeping this script for reference on interactionPrompt

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Interactor : MonoBehaviour
{
    [SerializeField] private Transform _interactionPoint;
    [SerializeField] private float _interactionPointRadius = 0.5f;
    [SerializeField] private LayerMask _interactableMask;
    [SerializeField] private InteractionPrompt _interactionPrompt;

    private readonly Collider[] _colliders = new Collider[3];
    [SerializeField] private int _numFound;

    private InteractInterface _interactable;

    private void Update()
    {
        _numFound = Physics.OverlapSphereNonAlloc(_interactionPoint.position, _interactionPointRadius, _colliders, _interactableMask);

        if (_numFound > 0)
        {
            _interactable = _colliders[0].GetComponent<InteractInterface>();

            if (_interactable != null)
            {
                if (!_interactionPrompt.isPromptOn) _interactionPrompt.setUp(_interactable.InteractionPrompt);

                if ( Input.GetKeyDown(KeyCode.E) ) _interactable.InteractBool(this);
            }
        }
        else
        {
            if (_interactable != null) _interactable = null;
            if (_interactionPrompt.isPromptOn) _interactionPrompt.Close();
        }
    }
    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(_interactionPoint.position, _interactionPointRadius);
    }
}
