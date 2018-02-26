using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace DeferredNPR
{

[CustomEditor (typeof (NPRColorProfileList) ) ]
public class NPRColorProfileListEditor : Editor {

	const int 	boxHeight = 20, boxWdith = 200, heightPadding = 10, startHeightOffset = 80,
				nameWidth = 100, colorWidth = 50, widthBuffer = 5;
	NPRColorProfileList _list;

	public override void OnInspectorGUI()
	{
		if(_list == null)	
			_list = ((NPRColorProfileList)target);

		if(GUILayout.Button("Add New"))
		{
			_list.AddNew();
		}

		//base.OnInspectorGUI();
		float widthOffset = 10;
		Rect nameBox = new Rect(widthOffset, startHeightOffset, nameWidth, boxHeight);
		widthOffset += nameWidth + widthBuffer;
		Rect c1Box = new Rect(widthOffset, startHeightOffset, colorWidth, boxHeight);
		widthOffset += colorWidth + widthBuffer;
		Rect c2Box = new Rect(widthOffset, startHeightOffset, colorWidth, boxHeight);
		widthOffset += colorWidth +  widthBuffer;
		Rect xBox = new Rect(widthOffset, startHeightOffset, boxHeight + 5, boxHeight);

		EditorGUI.BeginChangeCheck();
		for(int i = 0; i < _list.items.Count; i++)
		{
			nameBox.y = c1Box.y = c2Box.y = xBox.y = startHeightOffset + (boxHeight + heightPadding) * i;

			//EditorGUI.PropertyField(itemBox, _list.items[i].name)
			_list.items[i].name = EditorGUI.TextField(nameBox, _list.items[i].name);
			_list.items[i].colorLight = EditorGUI.ColorField(
											c1Box, GUIContent.none, 
											_list.items[i].colorLight, 
											false, false, false, null
											);

			_list.items[i].colorDark = EditorGUI.ColorField(
											c2Box, GUIContent.none, 
											_list.items[i].colorDark, 
											false, false, false, null
											);
			if(GUI.Button(xBox, "x"))
			{
				_list.Remove(_list.items[i]);
			}

			
		}

		if(EditorGUI.EndChangeCheck())
		{
			foreach(NPRColorProfile p in _list.items)
			{
				p.Set();
			}
		}


	}
}

}