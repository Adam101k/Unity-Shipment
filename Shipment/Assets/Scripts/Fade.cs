using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class Fade : MonoBehaviour
{
    public CanvasGroup fadingCanvasGroup;

    public bool isFaded = true;

    public void Fader() {
        isFaded = !isFaded;

        if(isFaded) {
            fadingCanvasGroup.DOFade(1, 2);
        } else {
            fadingCanvasGroup.DOFade(0, 2);
        }
    }
}
