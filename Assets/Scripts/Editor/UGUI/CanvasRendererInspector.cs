﻿using UnityEngine;


#if UNITY_EDITORusing UnityEditor;#endif
using System.Collections;

[CustomEditor(typeof(CanvasRenderer), true)]
public class CanvasRendererInpsctor : Editor
{
    public string current = "0";


    CanvasRenderer mCache;
    void OnEnable() {
        mCache = target as CanvasRenderer;
        current = mCache.transform.GetSiblingIndex().ToString();
    }

    public override void OnInspectorGUI()
    {
        GUILayout.Space(5);
        GUILayout.BeginHorizontal();
        GUILayout.Label("AbsoluteDepth:");
        GUILayout.TextField(mCache.absoluteDepth.ToString());
        GUILayout.EndHorizontal();
        GUILayout.Space(5);
        GUILayout.BeginHorizontal();
        GUILayout.Label("Depth:");
        current = GUILayout.TextField(current.ToString());
        if (GUILayout.Button("SetDepth"))
        {
            int newCurrent = 0;
            if (int.TryParse(current, out newCurrent))
            {
                mCache.transform.SetSiblingIndex(newCurrent);
            }
        }
        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("BringToFront"))
        {
            mCache.transform.SetAsFirstSibling();
            current = string.Format("{0}", mCache.transform.GetSiblingIndex());
        }

        if (GUILayout.Button("BringToBack"))
        {
            mCache.transform.SetAsLastSibling();
            current = string.Format("{0}", mCache.transform.GetSiblingIndex());
        }
        GUILayout.EndHorizontal();
    }

}
