// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/TIP_1"{
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

  Properties {
    _NumberSteps( "Number Steps", Int ) = 10
    _MaxTraceDistance( "Max Trace Distance" , Float ) = 6.0
    _IntersectionPrecision( "Intersection Precision" , Float ) = 0.0001
	_CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}
	_Color( "Color", COLOR) = (1,1,1,1)
  }

  
  SubShader {
    //Tags { "RenderType"="Transparent" "Queue" = "Transparent" }

    Cull Off
    Tags { "RenderType"="Opaque" "Queue" = "Geometry" }
    LOD 200
    Pass {
      //Blend SrcAlpha OneMinusSrcAlpha // Alpha blending


      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
      // Use shader model 3.0 target, to get nicer looking lighting
      #pragma target 3.0

      #include "UnityCG.cginc"
      #include "Chunks/noise.cginc"
      #include "Chunks/hsv.cginc"
     

      uniform int _NumberSteps;
      uniform float  _IntersectionPrecision;
      uniform float _MaxTraceDistance;

      uniform float _WaterLevel;
      uniform float3 _WaterPosition;

      uniform float3 _BallPosition;
      uniform float _Inside;
      uniform float _BottomHit;
      uniform float _DissolvingValue;
      uniform float _ExplosionValue;
      uniform float _DeathValue;

      uniform samplerCUBE _CubeMap;
      

      float3 origin;

      struct VertexIn
      {
         float4 position  : POSITION; 
         float3 normal    : NORMAL; 
         float4 texcoord  : TEXCOORD0; 
         float4 tangent   : TANGENT;
      };

      struct VertexOut {
          float4 pos    : POSITION; 
          float3 normal : NORMAL; 
          float4 uv     : TEXCOORD0; 
          float3 ro     : TEXCOORD2;
          float3 origin : TEXCOORD1;

          //float3 rd     : TEXCOORD3;
          float3 camPos : TEXCOORD4;
      };
        

      float sdBox( float3 p, float3 b ){

        float3 d = abs(p) - b;

        return min(max(d.x,max(d.y,d.z)),0.0) +
               length(max(d,0.0));

      }

      float sdSphere( float3 p, float s ){
        return length(p)-s;
      }

      float sdCapsule( float3 p, float3 a, float3 b, float r )
      {
          float3 pa = p - a, ba = b - a;
          float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
          return length( pa - ba*h ) - r;
      }

      float2 smoothU( float2 d1, float2 d2, float k)
      {
          float a = d1.x;
          float b = d2.x;
          float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
          return float2( lerp(b, a, h) - k*h*(1.0-h), lerp(d2.y, d1.y, pow(h, 2.0)));
      }

      float3 rotatedBox( float3 p, float4x4 m )
			{
			    float3 q = mul( m , float4( p , 1 )).xyz;
			    return sdBox(q,float3(.2,.2,.2));
			}


      float2 map( in float3 pos ){
        
        float2 res;
        float2 lineF;
        float2 sphere;

        float n  =  .13 * noise( pos * 1 + float3( 0 ,_Time.y , 0 ) ) * 4 + .6 * noise( pos * 3 + float3( 0, _Time.y , 0 ) ) + .5 * noise( pos * 8+ float3( 0,_Time.y,0 ) );

        // Background
        res = float2( -sdBox(pos-float3(0,1.5,0) , float3(.6,3,.6)) , 1);

        res.x += n * .1; // weirdness to BG



        // WATER
        res = smoothU( res ,  float2( sdBox(pos-_WaterPosition+float3(0,1.05,0), float3(3,1,3)) , 1), 0.3 );

        // Ball!
       	res = smoothU( res , float2( sdSphere( pos - _BallPosition , .2) , 2. ) , 0.3 );

        res.x += noise( pos * 10 ) * clamp( (-pos.y+1+ 2 * _ExplosionValue*_ExplosionValue) , 0 , 1);

  	    return res;
  	 
  	  }

      float3 calcNormal( in float3 pos ){

      	float3 eps = float3( 0.001, 0.0, 0.0 );
      	float3 nor = float3(
      	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
      	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
      	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
      	return normalize(nor);

      }
              
         

      float2 calcIntersection( in float3 ro , in float3 rd ){     
            
               
        float h =  _IntersectionPrecision * 2;
        float t = 0.0;
        float res = -1.0;
        float id = -1.0;
        
        for( int i=0; i< 20; i++ ){
            
            if( h < _IntersectionPrecision || t > _MaxTraceDistance ) break;
    
            float3 pos = ro + rd*t;
            float2 m = map( pos );
            
            h = m.x;
            t += h;
            id = m.y;
            
        }
    
    
        if( t <  _MaxTraceDistance ){ res = t; }
        if( t >  _MaxTraceDistance ){ id = -1.0; }
        
        return float2( res , id );
          
      
      }
            
    

      VertexOut vert(VertexIn v) {
        
        VertexOut o;

        o.normal = v.normal;
        
        o.uv = v.texcoord;
  
        // Getting the position for actual position
        o.pos = UnityObjectToClipPos(  v.position );
     
        float3 mPos = mul( unity_ObjectToWorld , v.position );

        o.ro = mPos;//v.position;
        o.origin = mul( unity_ObjectToWorld , float4(0,0,0,1) );
        o.camPos = _WorldSpaceCameraPos; //mul( unity_WorldToObject , float4( _WorldSpaceCameraPos  , 1. )); 

        return o;

      }


     // Fragment Shader
      fixed4 frag(VertexOut i) : COLOR {

        float3 ro = i.ro;
        float3 rd = normalize(ro - i.camPos);
        origin = i.origin;

        float3 col = float3( 0.0 , 0.0 , 0.0 );
    		float2 res = calcIntersection( ro , rd );
    		
    		col= float3( 0. , 0. , 0. );


    		if( res.y > -0.5 ){

    			float3 pos = ro + rd * res.x;
    			float3 nor = calcNormal( pos );
          float3 fRefl = reflect( -rd , nor );
          float3 cubeCol = texCUBE(_CubeMap,-fRefl ).rgb;

          float m = clamp( -dot( nor , rd ),0,1);
    			float3 whiteCol = float3(m,m,m);

          float3 reflCol = fRefl * .5 + .5;

          col = whiteCol;
          if( _Inside > 0 ){
            col = nor * .5 + .5;
          }

          if( _BottomHit > 0 ){
            col = 3 * cubeCol;
          }

         // col = lerp( col , 3* cubeCol * reflCol  , 1 - _BottomHit * 2) _DissolvingValue);



         
         float3 baseCol = whiteCol;
         float3 ballInsideCol = nor * .5 + .5;
         float3 dissolvingCol = cubeCol * 2;
         float3 deathCol = float3(1,1,1) - cubeCol;

         float3 explosionColor = hsv(m,1,1) ;

         col = baseCol;

         col = lerp( col , ballInsideCol , _Inside );
         col = lerp( col , dissolvingCol , _DissolvingValue );
         col = lerp( col , deathCol , _DeathValue );

         col = lerp( col , explosionColor , _ExplosionValue );
    
    			
    		}else{
    			discard;
    		}

        fixed4 color;
        color = fixed4( col , 1. );
        return color;
      }

      ENDCG
    }
  }
  FallBack "Diffuse"
}
