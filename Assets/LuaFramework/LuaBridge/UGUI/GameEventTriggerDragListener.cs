﻿/*****************************************************
 * 作者: 龙涛
 * 创建时间：2015-10-23
 * 版本：1.0.0
 * 描述：与EventTriggerListener不同点在于,响应不会被阻塞
 ****************************************************/

using System;
using UnityEngine;
using System.Collections;
using UGUIExtend;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class GameEventTriggerDragListener : MonoBehaviour,IBeginDragHandler,IEndDragHandler, IDragHandler
{
    public ScrollRect scroll;
    public GameEventCollector gameEventCollector;
    public GameModule gameModule;

    public void OnBeginDrag(PointerEventData eventData)
    {
        if(scroll != null) 
        {
            scroll.OnBeginDrag(eventData);
        }
        if (gameEventCollector != null)
        {
            gameEventCollector.OnBeginDrag(eventData);
        }
        if (gameModule != null)
        {
            gameModule.OnBeginDrag(eventData);
        }
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        if(scroll != null) 
        {
            scroll.OnEndDrag(eventData);
        }
        if (gameEventCollector != null)
        {
            gameEventCollector.OnEndDrag(eventData);
        }
        if (gameModule != null)
        {
            gameModule.OnBeginDrag(eventData);
        }
    }    

    public void OnDrag(PointerEventData eventData)
    {
        if(scroll != null) 
        {
            scroll.OnDrag(eventData);
        }
        if (gameEventCollector)
        {
            gameEventCollector.OnDrag(eventData);
        }
        if (gameModule != null)
        {
            gameModule.OnBeginDrag(eventData);
        }
    }
}