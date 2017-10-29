////////////////////////////////////////////////////////////////////////////////
// Filename: multitexture.vs
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
	int texnumber : TEXNUMBER;
};

struct PixelInputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
	float3 viewDirection : TEXCOORD1;
	int texnumber : TEXNUMBER;
    float2 pos : POSITION;
	float pos2 : POSITION2;
	float3 world_pos : POSITION3;
	float3 camera_pos : POSITION4;
};

// Represents the vertex positions for our triangle strips
static const float4 vertexUVPos[4] =
{
    { 0.0, 1.0, +1.0, +1.0 },
    { 0.0, 0.0, -1.0, +1.0 },
    { 1.0, 1.0, +1.0, -1.0 },
    { 1.0, 1.0, -1.0, -1.0 }
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
PixelInputType MultiTextureVertexShader(VertexInputType input, uint vertexID : SV_VertexID)
{
    PixelInputType output;
	float4 worldPosition;

	output.pos = input.position.xz;
	// for skydome
	output.pos2 = input.position.y;
	// Change the position vector to be 4 units for proper matrix calculations.
    input.position.w = 1.0f;


	// Update the position of the vertices based on the data for this particular instance.
	// Tree
	if (input.texnumber == 31)
	{
		// Calculate the position of the vertex against the world matrix, such that the tree is at his current position.
        output.position = mul(input.position, worldMatrix);

		output.position = ComputePosition(float3(output.position.x - input.position.x, output.position.y - input.position.y, output.position.z - input.position.z), 3.5f, 3.0f, vertexUVPos[vertexID].zw);

		// Move the Tree, such that it stands on the ground.
		output.position.y += 3.0f;
	}
	else
	{
	    // Calculate the position of the vertex against the world matrix.
        output.position = mul(input.position, worldMatrix);
	}

	// Calculate the position of the vertex against the world, view, and projection matrices.
	output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);

	// Store the texture coordinates for the pixel shader.
	output.tex = input.tex;

	output.texnumber = input.texnumber;

	output.normal = normalize(mul(input.normal, (float3x3)worldMatrix));

	// Calculate the position of the vertex in the world.
    worldPosition = mul(input.position, worldMatrix);

    // Determine the viewing direction based on the position of the camera and the position of the vertex in the world.
    output.viewDirection = camera_position.xyz - worldPosition.xyz;

    // Normalize the viewing direction vector.
    output.viewDirection = normalize(output.viewDirection);

	output.world_pos = worldPosition;
	output.camera_pos = camera_position;

    return output;
}