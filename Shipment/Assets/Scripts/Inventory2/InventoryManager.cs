using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InventoryManager : MonoBehaviour
{
    public static InventoryManager Instance;
    public List<Items> Item = new List<Items>();

    private void Awake()
    {
        Instance = this;
    }

    public void Add(Items items)
    {
        Item.Add(items);
    }

    public void Remove(Items items)
    {
        Item.Remove(items);
    }
}
