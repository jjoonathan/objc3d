struct O3Point3f {
	float x;
	float y;
	float z;
};

struct O3Triangle3x3f {
	struct O3Point v1;
	struct O3Point v2;
	struct O3Point v3;
};

struct O3Quad4x3f {
	struct O3Point v1;
	struct O3Point v2;
	struct O3Point v3;
	struct O3Point v4;
};
