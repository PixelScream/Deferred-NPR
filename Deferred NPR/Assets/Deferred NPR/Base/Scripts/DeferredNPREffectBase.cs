using UnityEngine;
using UnityEngine.Rendering;


namespace DeferredNPR
{

[ExecuteInEditMode, ImageEffectAllowedInSceneView, ImageEffectOpaque]
[RequireComponent(typeof(Camera))]
public class DeferredNPREffectBase : MonoBehaviour {

	[SerializeField] protected Shader _compositeShader, _deferredShader;
	[SerializeField] protected Material _mat;

	[SerializeField] protected Color
	colorLight = new Color (0.8f,0.7f,0.75f,1),
	colorDark  = new Color (0.2f,0.3f,0.5f,1);

	[SerializeField] protected Texture2D _lightLUT, _specLUT;

	void OnRenderImage(RenderTexture src, RenderTexture dest) {
		Graphics.Blit(src, dest, _mat);
	}

	void OnEnable()
	{
		Init();
	}

	void OnApplicationQuit()
	{
		Cleanup();
	}

	protected virtual void Init()
	{
		if(_mat == null)
		{
			Debug.Log("Initalizing");
			_mat = new Material(_compositeShader);
		}
		else
		{
			_mat.shader = _compositeShader;
		}
		Set();
	}


	void OnValidate()
	{
		Set();
	}

	protected virtual void Set()
	{
		Shader.SetGlobalTexture("_NPRLUT", _lightLUT);
		Shader.SetGlobalTexture("_NPRLUTSpec", _specLUT);
	}

	protected virtual void Cleanup()
	{
		
		if(_mat != null)
		{
			Debug.Log("Destroying material");
			DestroyImmediate(_mat);
		}
	}

	[ContextMenu("Setup")]
	public void Setup()
	{
		GraphicsSettings.SetShaderMode(BuiltinShaderType.DeferredShading, BuiltinShaderMode.UseCustom);
		GraphicsSettings.SetCustomShader(BuiltinShaderType.DeferredShading, _deferredShader);
		this.enabled = true;
	}
	[ContextMenu("UnSetup")]
	public void UnSetup()
	{
		GraphicsSettings.SetShaderMode(BuiltinShaderType.DeferredShading, BuiltinShaderMode.UseBuiltin);
		this.enabled = false;
	}

}

}