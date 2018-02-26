using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace DeferredNPR
{

[CreateAssetMenu(menuName=("xoio/NPR/Color Profile List"))]
public class NPRColorProfileList : ScriptableObject {

	public List<NPRColorProfile> items = new List<NPRColorProfile>();

	public void AddNew()
	{
		NPRColorProfile p = ScriptableObject.CreateInstance(typeof(NPRColorProfile)) as NPRColorProfile;
		p.name = "New Color Profile";

		AssetDatabase.AddObjectToAsset(p, this);
		AssetDatabase.SaveAssets();
		AssetDatabase.Refresh();
		items.Add(p);
		
	}

	public void Remove(NPRColorProfile p)
	{
		if(items.Contains(p))
			items.Remove(p);

		DestroyImmediate(p, true);
		AssetDatabase.SaveAssets();
		AssetDatabase.Refresh();
	}

}

}
