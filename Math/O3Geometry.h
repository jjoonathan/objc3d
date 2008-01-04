struct O3Point3f {
	float x;
	float y;
	float z;
};

struct O3Triangle3x3f {
	struct O3Point3f v1;
	struct O3Point3f v2;
	struct O3Point3f v3;
};

struct O3Quad4x3f {
	struct O3Point3f v1;
	struct O3Point3f v2;
	struct O3Point3f v3;
	struct O3Point3f v4;
};
