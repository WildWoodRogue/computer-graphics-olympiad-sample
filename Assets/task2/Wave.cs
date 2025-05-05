using UnityEngine;

public class Wave : MonoBehaviour
{
    struct Vertex
    {
        public Vector3 position;
    }

    public ComputeShader computeShader;

    private Mesh mesh;
    private ComputeBuffer vertexBuffer;
    private int kernel;
    private Vertex[] vertexArray;

    public float amplitude = 0.5f;
    public float frequency = 1.0f;
    public float speed = 1.0f;

    void Start()
    {
        mesh = GetComponent<MeshFilter>().mesh;
        Vector3[] verts = mesh.vertices;
        vertexArray = new Vertex[verts.Length];

        for (int i = 0; i < verts.Length; i++)
            vertexArray[i].position = verts[i];

        vertexBuffer = new ComputeBuffer(verts.Length, sizeof(float) * 3);
        vertexBuffer.SetData(vertexArray);

        kernel = computeShader.FindKernel("CSMain");
        computeShader.SetBuffer(kernel, "vertices", vertexBuffer);
    }

    void Update()
    {
        computeShader.SetFloat("time", Time.time);
        computeShader.SetFloat("amplitude", amplitude);
        computeShader.SetFloat("frequency", frequency);
        computeShader.SetFloat("speed", speed);

        computeShader.Dispatch(kernel, vertexArray.Length / 64 + 1, 1, 1);

        vertexBuffer.GetData(vertexArray);
        Vector3[] verts = new Vector3[vertexArray.Length];
        for (int i = 0; i < verts.Length; i++)
            verts[i] = vertexArray[i].position;

        mesh.vertices = verts;
        mesh.RecalculateNormals(); // необязательно, если не нужен свет
    }

    void OnDestroy()
    {
        if (vertexBuffer != null)
            vertexBuffer.Release();
    }
}
