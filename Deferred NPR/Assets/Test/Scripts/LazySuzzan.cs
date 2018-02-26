using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LazySuzzan : MonoBehaviour {

	public AnimationCurve _curve;
	public float duration = 1, dir = 1;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
		transform.eulerAngles = Vector3.up * 360 * dir * _curve.Evaluate((Time.time % duration) / duration);
	}
}
