using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class TipJar : MonoBehaviour {

	public float WaterValue;
	public float explosionValue;
	public ParticleSystem particleSystem;

	public GameObject Water;

	public bool exploding;

	public MeshRenderer[] renderers;
	public AudioSource audio;
	public AudioClip bubblingClip;
	public AudioClip tadaClip;

	private bool finalEnding = false;
	ParticleSystem.EmissionModule em;

	private bool BallInside = false;


	private float ballInsideValue;
	private float ballDissovlingValue;
	private float ballDeathValue;
	// Use this for initialization
	void Start () {

		em = particleSystem.emission;
		
	}
	
	void Update () {

		Water.transform.position = (1 + WaterValue ) * Vector3.up;
		for( int i = 0; i < renderers.Length; i++ ){
			renderers[i].sharedMaterial.SetFloat("_WaterValue" , WaterValue );
			renderers[i].sharedMaterial.SetVector("_WaterPosition" , Water.transform.position );
			renderers[i].sharedMaterial.SetFloat("_ExplosionValue" , explosionValue );

			if( BallInside == false ){
				renderers[i].sharedMaterial.SetVector("_BallPosition" , Vector3.up * -1000  );
				renderers[i].sharedMaterial.SetFloat("_DissolvingValue", 0);
				renderers[i].sharedMaterial.SetFloat("_Inside", 0 );
				renderers[i].sharedMaterial.SetFloat("_BottomHit", 0 );
				renderers[i].sharedMaterial.SetFloat("_DeathValue" , 0 );
			}

		}

		if( exploding == true ){
			explosionValue += .008f;
		}else{
			explosionValue -= .004f;
		}


		explosionValue = Mathf.Clamp( explosionValue , 0 , 1 );

		if( finalEnding == true ){

			//particleSystem.emissionRate = 100 * explosionValue;
			em.rate = 100 * explosionValue*explosionValue;
			if( explosionValue == 0 ){
				finalEnding = false;
				particleSystem.Stop();
				BallInside = false;
			}

		}

		if( explosionValue == 1 ){
			TriggerFinalExplosion();
		}


	}

	public void TriggerExplosion(){
		exploding = true;
		audio.clip = bubblingClip;
		audio.Play();
	}

	public void TriggerFinalExplosion(){
		exploding = false;
		finalEnding = true;
		em.rate = 100;
		particleSystem.Play(); 
		audio.clip = tadaClip;
		audio.Play();
		WaterValue += .2f;
	}

	public void TriggerBallInside(){
		BallInside = true;
	}

}
