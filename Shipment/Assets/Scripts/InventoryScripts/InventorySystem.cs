//using System.Collections;
//using System.Collections.Generic;
//using UnityEngine;

//public class InventorySystem : MonoBehaviour
//{
//    private Dictionary<InventoryItemData, InventoryItem> m_itemDict;
//    public List<InventoryItem> inventory { get; private set; }

//    private void Awake()
//    {
//        inventory = new List<InventoryItem>();
//        m_itemDict = new Dictionary<InventoryItemData, InventoryItem>();
//    }
//    public InventoryItem Get(InventoryItemData referenceData)
//    {
//        if (m_itemDict.TryGetValue(referenceData, out InventoryItem value))
//        {
//            return value;
//        }
//        return null;
//    }

//    public void Add(InventoryItemData referenceData)
//    {
//        if (m_itemDict.TryGetValue(referenceData, out InventoryItem value))
//        {
//            value.AddToStack();
//        }
//        else
//        {
//            InventoryItem newItem = new InventoryItem(referenceData);
//            inventory.Add(newItem);
//            m_itemDict.Add(referenceData, newItem);
//        }
//    }

//    public void Remove(InventoryItemData referenceData)
//    {
//        if (m_itemDict.TryGetValue(referenceData, out InventoryItem value))
//        {
//            value.RemoveFromStack();

//            if (value.stackSize == 0)
//            {
//                inventory.Remove(value);
//                m_itemDict.Remove(referenceData);
//            }
//        }
//    }
//}

//public class InventoryItem
//{
//    public InventoryItemData data {get; private set;}
//    public int stackSize { get; private set;}

//    public InventoryItem(InventoryItemData source)
//    {
//        data = source;
//        AddToStack();
//    }

//    public void AddToStack()
//    {
//        stackSize++;
//    }

//    public void RemoveFromStack()
//    {
//        stackSize--;
//    }
//}
