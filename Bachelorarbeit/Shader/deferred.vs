////////////////////////////////////////////////////////////////////////////////
// Filename: deferred.vs
////////////////////////////////////////////////////////////////////////////////


//////////////////////
// CONSTANT BUFFERS //
//////////////////////
cbuffer MatrixBuffer
{
	matrix worldMatrix;
	matrix viewMatrix;
	matrix projectionMatrix;
};


//////////////
// TYPEDEFS //
//////////////
struct VertexInputType
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
};

struct PixelInputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
	float4 normal : NORMAL;
	float3 viewDirection : TEXCOORD1;
};


////////////////////////////////////////////////////////////////////////////////
// Vertex Shader
////////////////////////////////////////////////////////////////////////////////
PixelInputType DeferredVertexShader(VertexInputType input)
{
    PixelInputType output;

	float4 worldPosition;


	// Change the position vector to be 4 units for proper matrix calculations.
    input.position.w = 1.0f;

	// Calculate the position of the vertex against the world, view, and projection matrices.
    output.position = mul(input.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);

	// Store the texture coordinates for the pixel shader.
    output.tex = input.tex;

	// Calculate the normal vector against the world matrix only.
    output.normal.xyz = mul(input.normal.xyz, (float3x3)worldMatrix);

    // Normalize the normal vector.
    output.normal.xyz = normalize(output.normal.xyz);
	// TODO NORMAL.w verwenden
	output.normal.w = 1.0f;

	float3 cameraPosition = float3(0,0,-10);

	// Calculate the position of the vertex in the world.
    worldPosition = mul(input.position, worldMatrix);

	// Determine the viewing direction based on the position of the camera and the position of the vertex in the world.
    output.viewDirection = normalize(cameraPosition.xyz - worldPosition.xyz);

	// Normalize the viewing direction vector.
    output.viewDirection = normalize(output.viewDirection);


	return output;
}