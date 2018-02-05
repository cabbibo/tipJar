using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ForceUp : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	void OnTriggerEnter( Collider c ){
		if( c.gameObject.GetComponent<TipBall>() != null ){
			c.gameObject.GetComponent<TipBall>().OnInside();
		}
	}

	void OnTriggerExit( Collider c ){
		if( c.gameObject.GetComponent<TipBall>() != null ){
			c.gameObject.GetComponent<TipBall>().OnOutside();
		}
	}
}
