using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetPositionInWallMaterials : MonoBehaviour {

	public MeshRenderer[] renderers;
	private Material[] materials;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		for( int i = 0; i < renderers.Length; i++ ){
			renderers[i].material.SetVector("_BallPosition" , transform.position);
		}
		
	}
}
