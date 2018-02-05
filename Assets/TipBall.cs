using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TipBall : MonoBehaviour {

	public TipJar tipJar;
	public bool inside;
	public bool bottomHit;

	public AudioClip splashClip;
	public AudioClip bottomHitClip;
	public AudioClip dissolvingClip;
	public AudioClip yayClip;

	public AudioSource oneHitSource;
	public AudioSource loopSource;

	private Rigidbody rb;

	private float dissolvingValue;
	private float deathValue = 0;
	private bool endingTriggered = false;

	public MeshRenderer[] renderers;

	// Use this for initialization
	void Start () {
		rb = gameObject.GetComponent<Rigidbody>();
	}
	
	// Update is called once per frame
	void Update () {

		if( inside == true ){
			for( int i = 0; i < renderers.Length; i++ ){
				renderers[i].sharedMaterial.SetVector("_BallPosition" , transform.position + deathValue * Vector3.up * -.7f );
				renderers[i].sharedMaterial.SetFloat("_DissolvingValue", dissolvingValue);
				renderers[i].sharedMaterial.SetFloat("_Inside", inside ? 1 : 0 );
				renderers[i].sharedMaterial.SetFloat("_BottomHit", bottomHit ? 1 : 0 );
				renderers[i].sharedMaterial.SetFloat("_DeathValue" , deathValue );
			}
		}
	}

	void FixedUpdate(){
		if( inside == true ){
			
			if( bottomHit == true){
				dissolvingValue -= .04f;
				deathValue += .004f;
			}else{
				dissolvingValue += .01f;
				rb.AddForce( Vector3.up * 9.4f);
			}

			dissolvingValue = Mathf.Clamp( dissolvingValue , 0 , 1 );
			deathValue = Mathf.Clamp( deathValue , 0 , 1 );

			loopSource.volume = dissolvingValue;

			if( deathValue == 1 && endingTriggered == false ){
				TriggerEnd();
			}
		}
	}

	public void OnInside(){
		oneHitSource.clip = splashClip;
		oneHitSource.Play();
		dissolvingValue = 0;
		inside = true;
		loopSource.clip = dissolvingClip;
		loopSource.Play();
		tipJar.TriggerBallInside();
	}

	public void OnOutside(){
		oneHitSource.clip = splashClip;
		oneHitSource.Play();
		inside = false;
		dissolvingValue = 0;
		loopSource.volume = 0;
	}

	public void OnBottomHit(){
		if( bottomHit == false ){
			bottomHit = true;
			oneHitSource.clip = bottomHitClip;
			oneHitSource.time = 1;
			oneHitSource.Play();
		}
	}

	public void TriggerEnd(){
		endingTriggered = true;
		inside = false;
		dissolvingValue = 0;
		bottomHit = false;
		rb.detectCollisions = false;
		gameObject.GetComponent<MeshRenderer>().enabled = false;
		tipJar.TriggerExplosion();
	}
}
