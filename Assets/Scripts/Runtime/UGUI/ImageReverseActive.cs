/*****************************************************
 * 作者: DRed(龙涛) 1036409576@qq.com
 * 创建时间：2016.8.30
 * 版本：1.0.0
 * 描述：反向激活Image,可用于Toggle的状态改变
 ****************************************************/

using UnityEngine;
using System.Collections;
using UnityEngine.UI;

[ExecuteInEditMode]
public class ImageReverseActive : MonoBehaviour {
    private Image mImage;

    void Awake() {
        mImage = GetComponent<Image>();
    }

    public void SetReverseActive(bool toggleState) {
        if (mImage != null) {
            mImage.enabled = !toggleState;
        }
    }
}
