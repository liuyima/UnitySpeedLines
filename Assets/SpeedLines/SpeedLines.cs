using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class SpeedLines : MonoBehaviour
{
    public Shader shader;
    public Texture fbm;
    public Color color = new Color(1,1,1,0.1f);
    [Range(0,1)]
    public float _Width = 0.4f;
    [Range(0, 1)]
    public float _Length = 0.18f;
    [Range(0, 100)]
    public float _LengthSpeed = 17;
    [Range(0, 1)]
    public float _Density = 0.75f;
    Material material;


    int p_Color = Shader.PropertyToID("_Color");
    int p_Width = Shader.PropertyToID("_Width");
    int p_Length = Shader.PropertyToID("_Length");
    int p_LengthSpeed = Shader.PropertyToID("_LengthSpeed");
    int p_Density = Shader.PropertyToID("_Density");
    private void Awake()
    {
        if(!material)
        {
            material = new Material(shader);
            material.SetTexture("_FBM", fbm);
        }
    }

    private void LateUpdate()
    {
        material.SetColor(p_Color, color);
        material.SetFloat(p_Width, _Width);
        material.SetFloat(p_Length, _Length);
        material.SetFloat(p_LengthSpeed, _LengthSpeed);
        material.SetFloat(p_Density, _Density);
    }

    public void OnRenderObject()
    {
        material.SetPass(0);
        GL.PushMatrix();
        GL.LoadOrtho();

        GL.Begin(GL.QUADS);
        GL.TexCoord(new Vector3(0, 0, 0));
        GL.Vertex3(0, 0, 0);
        GL.TexCoord(new Vector3(0, 1, 0));
        GL.Vertex3(0, 1, 0);
        GL.TexCoord(new Vector3(1, 1, 0));
        GL.Vertex3(1, 1, 0);
        GL.TexCoord(new Vector3(1, 0, 0));
        GL.Vertex3(1, 0, 0);
        GL.End();
        GL.PopMatrix();
    }
}
