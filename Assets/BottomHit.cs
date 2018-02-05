using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BottomHit : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	void OnCollisionEnter( Collision c ){
		if( c.gameObject.GetComponent<TipBall>() != null ){
			c.gameObject.GetComponent<TipBall>().OnBottomHit();
		}
	}
}
