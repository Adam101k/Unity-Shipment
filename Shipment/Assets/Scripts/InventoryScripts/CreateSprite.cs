//using System.Collections;
//using System.Collections.Generic;
//using UnityEngine;

//public class CreateSprite : MonoBehaviour
//{
//    public static void CaptureScreenshot(string filename)
//    {

//    }
//    private void OnMouseDown()
//    {
//        ScreenCapture.CaptureScreenshot("GasCan.png");
//    }
//    public List<GameObject> sceneObjects;
//    public List<InventoryItemData> dataObjects;
//    private void Awake()
//    {
//        camera = GetComponent<Camera>();
//    }
//    [ContextMenu("Screenshot")]
//    private void ProcessScreenshots()
//    {
//        StartCoroutine(Screenshot());
//    }

//    private IEnumerator Screenshot()
//    {
//        for (int i = 0; i < sceneObjects.Count; i++)
//        {
//            GameObject obj = sceneObjects[i];
//            InventoryItemData data = dataObjects[i];
//            obj.gameObject.SetActive(true);

//            yield return null;

//            TakeScreenshot($"{Application.dataPath}/{pathFolder}/{data.id}_Icon.png");
//        }
//    }


//    Camera camera;
//    public string Prefix;
//    public string Path
//    void TakeScreenshot(string fullpath)
//    {
//        if (camera == null)
//        {
//            camera = GetComponent<Camera>();
//        }
//        RenderTexture rt = new RenderTexture(256, 256, 24);
//        camera.targetTexture = rt;
//        Texture2D screenShot = new Texture2D(256, 256, TextureFormat.RGBA32, false);
//        camera.Render();
//        RenderTexture.active = rt;
//        screenShot.ReadPixels(new Rect(0, 0, 256, 256), 0, 0);
//        camera.targetTexture = null;
//        RenderTexture.active = null;

//        if (Application.isEditor)
//        {
//            DestroyImmediate(rt);
//        }
//        else
//        {
//            Destroy(rt);
//        }
//        byte[] bytes = screenShot.EncodeToPNG();
//        System.IO.File.WriteAllBytes(fullpath, bytes);

//    }
//}
