using UnityEngine;

namespace DeferredNPR 
{

[System.Serializable]
[CreateAssetMenu(menuName=("xoio/NPR/Color Profile"))]
public class NPRColorProfile : ScriptableObject {

	public Color 	colorLight = new Color (0.8f,0.7f,0.75f,1),
					colorDark  = new Color (0.2f,0.3f,0.5f,1);

	[HideInInspector]public DeferredNPREffect_ColorProfiles _effect;

	void OnValidate()
	{
		Set();
	}

	void OnDisable()
	{
		_effect = null;
	}

	public void Set()
	{
		if(_effect != null && !_effect.Set(this))
		{
			_effect = null;
		}
	}
}

}