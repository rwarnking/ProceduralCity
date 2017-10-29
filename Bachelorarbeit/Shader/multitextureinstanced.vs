////////////////////////////////////////////////////////////////////////////////
// Filename: multitextureinstanced.vs
////////////////////////////////////////////////////////////////////////////////


/////////////
// GLOBALS //
/////////////
cbuffer MatrixBuffer
{
	matrix worldMatrix;
	matrix viewMatrix;
	matrix projectionMatrix;
};

cbuffer CameraBuffer
{
    float3 camera_position;
    float padding;
};


//////////////
// TYPEDEFS //
//////////////
struct VertexInputType
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
	float3 instancePosition : TEXCOORD1;
	int texnumber : TEXNUMBER;
};

struct PixelInputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
	int texnumber : TEXNUMBER;
};

// Represents the vertex positions for our triangle strips
static const float4 vertexUVPos[4] =
{
    { 0.0, 1.0, +1.0, +1.0 },
    { 0.0, 0.0, -1.0, +1.0 },
    { 1.0, 1.0, +1.0, -1.0 },
    { 1.0, 0.0, -1.0, -1.0 }
};


////////////////////////////////////////////////////////////////////////////////
// Methods
////////////////////////////////////////////////////////////////////////////////
float4 ComputePosition(float3 pos, float sizeX, float sizeY, float2 vPos)
{
    // Create billboard (quad always facing the camera)
    float3 toEye = normalize(camera_position.xyz - pos);
    float3 up    = float3(0.0f, 1.0f, 0.0f);
    float3 right = cross(toEye, up);
    up           = cross(toEye, right);
    pos += (right * sizeX * vPos.x) + (up * sizeY * vPos.y);
    return float4(pos, 1);
}


////////////////////////////////////////////////////////////////////////////////
// Vertex Shader
////////////////////////////////////////////////////////////////////////////////
PixelInputType MultiTextureInstancedVertexShader(VertexInputType input, uint vertexID : SV_VertexID, uint instanceID : SV_InstanceID)
{
    PixelInputType output;


	// Change the position vector to be 4 units for proper matrix calculations.
    input.position.w = 1.0f;

	//Rain & Snow
	// Update the position of the vertices based on the data for this particular instance.
	if (input.texnumber == 35 || input.texnumber == 36)
	{
		// Calculate billboarding.
		output.position = ComputePosition(input.instancePosition.xyz, 0.06f, 0.12f, vertexUVPos[vertexID].zw);

		// Calculate the position of the vertex against the world, view, and projection matrices.
        output.position = mul(output.position, worldMatrix);
	}
	// Tree
	else if (input.texnumber == 31)
	{
		// Calculate billboarding.
		output.position = ComputePosition(input.instancePosition.xyz, 3.5f, 3.0f, vertexUVPos[vertexID].zw);

		// Move the Tree, such that it stands on the ground.
		output.position.y += 3.0f;

		output.position = mul(output.position, worldMatrix);
	}
	else
	{
	    input.position.x += input.instancePosition.x;
		input.position.y += input.instancePosition.y;
		input.position.z += input.instancePosition.z;

	    // Calculate the position of the vertex against the world matrix.
        output.position = mul(input.position, worldMatrix);
	}

	// Calculate the position of the vertex against the view and projection matrices.
	output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);

	// Store the texture coordinates for the pixel shader.
	output.tex = input.tex;

	output.texnumber = input.texnumber;

    return output;
}