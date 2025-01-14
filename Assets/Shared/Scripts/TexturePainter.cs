﻿using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
using UnityEngine.Rendering;

public class TexturePainter : MonoBehaviour {

	public ShaderRunner shaderRunner;
	[ColorUsage(false,true,-10,10,-10,10)]
	public Color color;
	public int radius;
	public Pattern pattern;
	public EventSystem eventSystem;
	public Texture2D cursor;
	public PainterMode mode;
	public PainterMode altMode;
	public enum PainterMode {
		add,
		subtract,
		equals
	}


	private Material mat;

	public enum Pattern {
		Linear,
		Circular,
		Square
	}

	void Awake () {
		if( eventSystem == null ){
			eventSystem = GameObject.FindObjectOfType<EventSystem>();
		}
		mat = new Material(Shader.Find("Hidden/BrushAdd"));

	}
	
	void Update () {

		RaycastHit hit;
		bool isOverUI = false;
		if( eventSystem != null ){
			isOverUI = eventSystem.IsPointerOverGameObject();
		}

		if( isOverUI ){
			return;
		}

		if( Input.GetMouseButton(0) ){
			
			if( Physics.Raycast( Camera.main.ScreenPointToRay( Input.mousePosition ), out hit )){
				//Debug.Log(hit.textureCoord);
				Paint(hit.textureCoord, Input.GetKey(KeyCode.LeftShift));

			}
		}

	}

	public void Paint(Vector2 pos, bool useAltMode = false){
		PainterMode modeToUse = useAltMode ? altMode : mode;
		mat.SetVector("_Pos", new Vector4(pos.x, pos.y,0,0));
		mat.SetColor("_Color", modeToUse==PainterMode.subtract ? color*-1 : color);
		mat.SetFloat("_Radius", radius);
		mat.SetInt("_DstMode", (int) ( mode==PainterMode.equals ? BlendMode.OneMinusSrcAlpha : BlendMode.One ));
		mat.SetInt("_Pattern",(int) pattern);

		Graphics.Blit(
			shaderRunner.CurrentBuffer,
			shaderRunner.CurrentBuffer,
			mat 
		);
	}

	public void Clear(){
		shaderRunner.Clear();
	}
}
