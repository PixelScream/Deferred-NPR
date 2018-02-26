using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace DeferredNPR
{
public class DeferredNPREffect_ColorProfiles : DeferredNPREffectBase {

	[SerializeField] protected NPRColorProfile _profile;

	protected override void Init()
	{
		base.Init();
	}

	protected override void Set()
	{
		base.Set();
		Shader.SetGlobalColor("_ColorLight", _profile != null ? _profile.colorLight : colorLight);
		Shader.SetGlobalColor("_ColorDark", _profile != null ? _profile.colorDark : colorDark);
	}

	public bool Set(NPRColorProfile p)
	{
		LinkToProfile();

		bool b = p == _profile;
		Debug.Log(b, p);
		if(b)
			Set();

		return b;
	}

	void LinkToProfile()
	{
		if(_profile != null && _profile._effect != this)
			_profile._effect = this;
	}


}
}