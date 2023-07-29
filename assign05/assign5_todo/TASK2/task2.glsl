const float PI = 3.1415926536;
const vec3 BACKGROUND_COLOR = vec3(1.0, 1.0, 0.3);
const float FOVY = 50.0 * PI / 180.0;
const float DEFAULT_TMIN = 10.0e-4;
const float DEFAULT_TMAX = 10.0e6;
const int NUM_ITERATIONS = 2;
const int NUM_LIGHTS = 2;
const int NUM_MATERIALS = 30;
const int NUM_PLANES = 6;
const int NUM_CYLINDERS = 4;
const int NUM_SPHERES = 8;
const int NUM_TRIANGLES = 12;
const int NUM_BOXS = 9;

const float PRELUDE_TIME = 11.0;

const float SIN_30 = 0.5;
const float COS_30 = 0.86602540378;

float blockNum = 4.0;
float blockLength = 0.45;

struct Ray_t {
    vec3 o;  // Ray Origin.
    vec3 d;  // Ray Direction. A unit vector.
};

struct Plane_t {
    // The plane equation is Ax + By + Cz + D = 0.
    float A, B, C, D;
    int materialID;
};

struct Sphere_t {
    vec3 center;
    float radius;
    int materialID;
};

struct Cylinder_t {
    vec3 center;
    float radius;
    float height;
    int materialID;
};

struct Triangle_t {
    vec3 v0, v1, v2;
    int materialID;
};

struct Light_t {
    vec3 position;  // Point light 3D position.
    vec3 I_a;       // For Ambient.
    vec3 I_source;  // For Diffuse and Specular.
};

struct Material_t {
    vec3 k_a;   // Ambient coefficient.
    vec3 k_d;   // Diffuse coefficient.
    vec3 k_r;   // Reflected specular coefficient.
    vec3 k_rg;  // Global reflection coefficient.
    float n;    // The specular reflection exponent. Ranges from 0.0 to 128.0.
};

struct Box_t {
    vec3 radius;
    int materialID;
    mat4 M;   // Transform Matrix
};

Plane_t Plane[NUM_PLANES];
Sphere_t Sphere[NUM_SPHERES];
Cylinder_t Cylinder[NUM_CYLINDERS];
Triangle_t Diamond[NUM_TRIANGLES];
Light_t Light[NUM_LIGHTS];
Material_t Material[NUM_MATERIALS];
Box_t Box[NUM_BOXS];
Box_t Platform;
Sphere_t Ball;

mat4 GenerateTransformMatrix(vec3 tranlate, float theta) {
    return mat4(vec4(cos(theta / 180.0 * PI), 0, sin(theta / 180.0 * PI), 0), vec4(0, 1, 0, 0), vec4(-sin(theta / 180.0 * PI), 0, cos(theta / 180.0 * PI), 0), vec4(0, 0, 0, 1)) * mat4(vec4(1, 0, 0, 0), vec4(0, 1, 0, 0), vec4(0, 0, 1, 0), vec4(tranlate, 1));
}

void InitScene() {
    Plane[0].A = 0.0;
    Plane[0].B = 1.0;
    Plane[0].C = 0.0;
    Plane[0].D = 0.0;
    Plane[0].materialID = 3;

    Plane[1].A = 0.0;
    Plane[1].B = 0.0;
    Plane[1].C = 1.0;
    Plane[1].D = 5.0;
    Plane[1].materialID = 3;

    //box plane
    Plane[2].A = 1.0;
    Plane[2].B = 0.0;
    Plane[2].C = 0.0;
    Plane[2].D = 5.0;
    Plane[2].materialID = 4;

    Plane[3].A = 0.0;
    Plane[3].B = 0.0;
    Plane[3].C = 1.0;
    Plane[3].D = -5.0;
    Plane[3].materialID = 5;

    Plane[4].A = 1.0;
    Plane[4].B = 0.0;
    Plane[4].C = 0.0;
    Plane[4].D = -5.0;
    Plane[4].materialID = 2;

    Plane[5].A = 0.0;
    Plane[5].B = 1.0;
    Plane[5].C = 0.0;
    Plane[5].D = -9.0;
    Plane[5].materialID = 3;

    Cylinder[0].center = vec3(4.0, -0.5, 4.0);
    Cylinder[0].radius = 0.3;
    Cylinder[0].height = 10.0;
    Cylinder[0].materialID = 3;

    Cylinder[1].center = vec3(-4.0, -0.5, 4.0);
    Cylinder[1].radius = 0.3;
    Cylinder[1].height = 10.0;
    Cylinder[1].materialID = 3;

    Cylinder[2].center = vec3(4.0, -0.5, -4.0);
    Cylinder[2].radius = 0.3;
    Cylinder[2].height = 10.0;
    Cylinder[2].materialID = 3;

    Cylinder[3].center = vec3(-4.0, -0.5, -4.0);
    Cylinder[3].radius = 0.3;
    Cylinder[3].height = 10.0;
    Cylinder[3].materialID = 3;

    mat4 tranform_matrix = GenerateTransformMatrix(vec3(0.0, 0.0, 0.0), 0.0);
    Platform.radius = vec3(0.8, 0.8, 0.8);
    Platform.materialID = 4;
    Platform.M = tranform_matrix;

    Ball.center = vec3(0.0, 3.25 + abs(0.5 * sin(iTime)), 0.0);
    Ball.radius = 0.4;
    Ball.materialID = 1;

    //mid
    tranform_matrix = GenerateTransformMatrix(vec3(5.0, -2.5, 2.0), 90.0);
    float height = texture(iChannel0, vec2(0.07, 0.25)).x * 2.0;
    Box[0].radius = vec3(0.5, 0.51, height);
    Box[0].materialID = 6;
    Box[0].M = tranform_matrix;

    //center
    tranform_matrix = GenerateTransformMatrix(vec3(5.0, -2.5, 0.0), 90.0);
    height = (texture(iChannel0, vec2(0.01, 0.25)).x - 0.8) * 8.0;
    Box[1].radius = vec3(0.5, 0.51, height);
    Box[1].materialID = 7;
    Box[1].M = tranform_matrix;

    //mid
    tranform_matrix = GenerateTransformMatrix(vec3(5.0, -2.5, -2.0), 90.0);
    height = texture(iChannel0, vec2(0.07, 0.25)).x * 2.0;
    Box[2].radius = vec3(0.5, 0.51, height);
    Box[2].materialID = 8;
    Box[2].M = tranform_matrix;

    //coner
    tranform_matrix = GenerateTransformMatrix(vec3(5.0, -4.5, 2.0), 90.0);
    height = texture(iChannel0, vec2(0.30, 0.25)).x * 2.0;
    Box[3].radius = vec3(0.5, 0.51, height);
    Box[3].materialID = 9;
    Box[3].M = tranform_matrix;

    //mid
    tranform_matrix = GenerateTransformMatrix(vec3(5.0, -4.5, 0.0), 90.0);
    height = texture(iChannel0, vec2(0.07, 0.25)).x * 2.0;
    Box[4].radius = vec3(0.5, 0.51, height);
    Box[4].materialID = 10;
    Box[4].M = tranform_matrix;

    //coner
    tranform_matrix = GenerateTransformMatrix(vec3(5.0, -4.5, -2.0), 90.0);
    height = texture(iChannel0, vec2(0.30, 0.25)).x * 2.0;
    Box[5].radius = vec3(0.5, 0.51, height);
    Box[5].materialID = 11;
    Box[5].M = tranform_matrix;

    //coner
    tranform_matrix = GenerateTransformMatrix(vec3(5.0, -0.5, 2.0), 90.0);
    height = texture(iChannel0, vec2(0.30, 0.25)).x * 2.0;
    Box[6].radius = vec3(0.5, 0.51, height);
    Box[6].materialID = 12;
    Box[6].M = tranform_matrix;

    //mid
    tranform_matrix = GenerateTransformMatrix(vec3(5.0, -0.5, 0.0), 90.0);
    height = texture(iChannel0, vec2(0.07, 0.25)).x * 2.0;
    Box[7].radius = vec3(0.5, 0.51, height);
    Box[7].materialID = 13;
    Box[7].M = tranform_matrix;

    //coner
    tranform_matrix = GenerateTransformMatrix(vec3(5.0, -0.5, -2.0), 90.0);
    height = texture(iChannel0, vec2(0.30, 0.25)).x * 2.0;
    Box[8].radius = vec3(0.5, 0.51, height);
    Box[8].materialID = 14;
    Box[8].M = tranform_matrix;

    Diamond[0].v0 = vec3(0.0, 1.0, 0.0);
    Diamond[0].v1 = vec3(0.6 * SIN_30, 2.8, 0.6 * COS_30);
    Diamond[0].v2 = vec3(-0.6 * SIN_30, 2.8, 0.6 * COS_30);
    Diamond[1].v0 = vec3(0.0, 1.0, 0.0);
    Diamond[1].v1 = vec3(0.6 * SIN_30, 2.8, 0.6 * COS_30);
    Diamond[1].v2 = vec3(0.6, 2.8, 0.0);
    Diamond[2].v0 = vec3(0.0, 1.0, 0.0);
    Diamond[2].v1 = vec3(-0.6 * SIN_30, 2.8, 0.6 * COS_30);
    Diamond[2].v2 = vec3(-0.6, 2.8, 0.0);
    Diamond[3].v0 = vec3(0.0, 1.0, 0.0);
    Diamond[3].v1 = vec3(0.6 * SIN_30, 2.8, -0.6 * COS_30);
    Diamond[3].v2 = vec3(-0.6 * SIN_30, 2.8, -0.6 * COS_30);
    Diamond[4].v0 = vec3(0.0, 1.0, 0.0);
    Diamond[4].v1 = vec3(0.6 * SIN_30, 2.8, -0.6 * COS_30);
    Diamond[4].v2 = vec3(0.6, 2.8, 0.0);
    Diamond[5].v0 = vec3(0.0, 1.0, 0.0);
    Diamond[5].v1 = vec3(-0.6 * SIN_30, 2.8, -0.6 * COS_30);
    Diamond[5].v2 = vec3(-0.6, 2.8, 0.0);

    Diamond[6].v0 = vec3(0.0, 2.8, 0.0);
    Diamond[6].v1 = vec3(0.6 * SIN_30, 2.8, 0.6 * COS_30);
    Diamond[6].v2 = vec3(-0.6 * SIN_30, 2.8, 0.6 * COS_30);
    Diamond[7].v0 = vec3(0.0, 2.8, 0.0);
    Diamond[7].v1 = vec3(0.6 * SIN_30, 2.8, 0.6 * COS_30);
    Diamond[7].v2 = vec3(0.6, 2.8, 0.0);
    Diamond[8].v0 = vec3(0.0, 2.8, 0.0);
    Diamond[8].v1 = vec3(-0.6 * SIN_30, 2.8, 0.6 * COS_30);
    Diamond[8].v2 = vec3(-0.6, 2.8, 0.0);
    Diamond[9].v0 = vec3(0.0, 2.8, 0.0);
    Diamond[9].v1 = vec3(0.6 * SIN_30, 2.8, -0.6 * COS_30);
    Diamond[9].v2 = vec3(-0.6 * SIN_30, 2.8, -0.6 * COS_30);
    Diamond[10].v0 = vec3(0.0, 2.8, 0.0);
    Diamond[10].v1 = vec3(0.6 * SIN_30, 2.8, -0.6 * COS_30);
    Diamond[10].v2 = vec3(0.6, 2.8, 0.0);
    Diamond[11].v0 = vec3(0.0, 2.8, 0.0);
    Diamond[11].v1 = vec3(-0.6 * SIN_30, 2.8, -0.6 * COS_30);
    Diamond[11].v2 = vec3(-0.6, 2.8, 0.0);

    for(int i = 0; i < NUM_TRIANGLES; i++) {
        Diamond[i].materialID = 1;
    }

    Sphere[0].center = vec3(0.7 + abs(cos(iTime)), 3.5 - 2.2 * abs(cos(iTime)), 0.0);
    Sphere[1].center = vec3(-0.7 - abs(cos(iTime)), 3.5 - 2.2 * abs(cos(iTime)), 0.0);
    Sphere[2].center = vec3(0.0, 3.5 - 2.2 * abs(cos(iTime)), 0.7 + abs(cos(iTime)));
    Sphere[3].center = vec3(0.0, 3.5 - 2.2 * abs(cos(iTime)), -0.7 - abs(cos(iTime)));
    Sphere[4].center = vec3(0.7 + abs(cos(iTime)), 3.5 - 2.2 * abs(cos(iTime)), 0.7 + abs(cos(iTime)));
    Sphere[5].center = vec3(-0.7 - abs(cos(iTime)), 3.5 - 2.2 * abs(cos(iTime)), 0.7 + abs(cos(iTime)));
    Sphere[6].center = vec3(0.7 + abs(cos(iTime)), 3.5 - 2.2 * abs(cos(iTime)), -0.7 - abs(cos(iTime)));
    Sphere[7].center = vec3(-0.7 - abs(cos(iTime)), 3.5 - 2.2 * abs(cos(iTime)), -0.7 - abs(cos(iTime)));

    for(int i = 0; i < NUM_SPHERES; i++) {
        Sphere[i].radius = 0.2;
        Sphere[i].materialID = i + 20;
    }

    //red
    Material[0].k_d = vec3(0.6, 0.2, 0.2);
    Material[0].k_a = 0.2 * Material[0].k_d;
    Material[0].k_r = 2.0 * Material[0].k_d;
    Material[0].k_rg = 0.5 * Material[0].k_r;
    Material[0].n = 64.0;

    //silver
    Material[1].k_d = vec3(0.5, 0.5, 0.5);
    Material[1].k_a = 0.2 * Material[1].k_d;
    Material[1].k_r = 2.0 * Material[1].k_d;
    Material[1].k_rg = 0.5 * Material[1].k_r;
    Material[1].n = 64.0;

    //mirror
    Material[2].k_d = vec3(0.0, 0.2, 0.2);
    Material[2].k_a = 0.4 * Material[2].k_d;
    Material[2].k_r = 3.0 * Material[2].k_d;
    Material[2].k_rg = 0.2 * Material[2].k_r;
    Material[2].n = 64.0;

    //Special Material
    Material[3].k_d = vec3(0.5, 0.5, 0.5);
    Material[3].k_a = 0.2 * Material[1].k_d;
    Material[3].k_r = 2.0 * Material[1].k_d;
    Material[3].k_rg = 0.1 * Material[1].k_r;
    Material[3].n = 64.0;

    Material[4].k_d = vec3(0.0, 0.0, 0.0);
    Material[4].k_a = vec3(0.25164, 0.60648, 0.22648);
    Material[4].k_r = vec3(0.90, 0.91, 0.99);
    Material[4].k_rg = vec3(0.3);
    Material[4].n = 1.0;

    Material[5].k_d = vec3(0.0);
    Material[5].k_a = vec3(0.0);
    Material[5].k_r = vec3(0.0);
    Material[5].k_rg = vec3(0.0);
    Material[5].n = 0.0;

    Material[6].k_d = vec3(0.0, 0.0, 1.0);
    Material[6].k_a = 0.2 * Material[2].k_d;
    Material[6].k_r = 2.0 * Material[2].k_d;
    Material[6].k_rg = 0.5 * Material[2].k_r;
    Material[6].n = 64.0;

    Material[7].k_d = vec3(0.0, 1.0, 0.0);
    Material[7].k_a = 0.2 * Material[2].k_d;
    Material[7].k_r = 2.0 * Material[2].k_d;
    Material[7].k_rg = 0.5 * Material[2].k_r;
    Material[7].n = 64.0;

    Material[8].k_d = vec3(1.0, 0.0, 0.0);
    Material[8].k_a = 0.2 * Material[2].k_d;
    Material[8].k_r = 2.0 * Material[2].k_d;
    Material[8].k_rg = 0.5 * Material[2].k_r;
    Material[8].n = 64.0;

    Material[9].k_d = vec3(1.0, 0.0, 1.0);
    Material[9].k_a = 0.2 * Material[2].k_d;
    Material[9].k_r = 2.0 * Material[2].k_d;
    Material[9].k_rg = 0.5 * Material[2].k_r;
    Material[9].n = 64.0;

    Material[10].k_d = vec3(1.0, 1.0, 0.0);
    Material[10].k_a = 0.2 * Material[2].k_d;
    Material[10].k_r = 2.0 * Material[2].k_d;
    Material[10].k_rg = 0.5 * Material[2].k_r;
    Material[10].n = 64.0;

    Material[11].k_d = vec3(0.2, 0.6, 0.8);
    Material[11].k_a = 0.2 * Material[2].k_d;
    Material[11].k_r = 2.0 * Material[2].k_d;
    Material[11].k_rg = 0.5 * Material[2].k_r;
    Material[11].n = 64.0;

    Material[12].k_d = vec3(0.0, 1.0, 1.0);
    Material[12].k_a = 0.2 * Material[2].k_d;
    Material[12].k_r = 2.0 * Material[2].k_d;
    Material[12].k_rg = 0.5 * Material[2].k_r;
    Material[12].n = 64.0;

    Material[13].k_d = vec3(0.8, 0.4, 0.5);
    Material[13].k_a = 0.2 * Material[2].k_d;
    Material[13].k_r = 2.0 * Material[2].k_d;
    Material[13].k_rg = 0.5 * Material[2].k_r;
    Material[13].n = 64.0;

    Material[14].k_d = vec3(0.3, 0.6, 0.2);
    Material[14].k_a = 0.2 * Material[2].k_d;
    Material[14].k_r = 2.0 * Material[2].k_d;
    Material[14].k_rg = 0.5 * Material[2].k_r;
    Material[14].n = 64.0;

    Material[15].k_d = vec3(1.0);
    Material[15].k_a = vec3(1.0);
    Material[15].k_r = vec3(1.0);
    Material[15].k_rg = vec3(1.0);
    Material[15].n = 64.0;

    Material[20].k_d = vec3(1.5, 0.5, 0.5);
    Material[20].k_a = 0.2 * Material[20].k_d;
    Material[20].k_r = 2.0 * Material[20].k_d;
    Material[20].k_rg = 0.5 * Material[20].k_r;
    Material[20].n = 64.0;

    Material[21].k_d = vec3(0.614240, 0.041360, 0.041360);
    Material[21].k_a = vec3(0.174500, 0.011750, 0.011750);
    Material[21].k_r = vec3(0.727811, 0.626959, 0.626959);
    Material[21].k_rg = vec3(0.550000, 0.550000, 0.550000);
    Material[21].n = 128.0;

    Material[22].k_d = vec3(0.371200, 0.008640, 0.371200);
    Material[22].k_a = vec3(0.053750, 0.001250, 0.053750);
    Material[22].k_r = vec3(0.614240, 0.041360, 0.041360);
    Material[22].k_rg = vec3(0.550000, 0.550000, 0.550000);
    Material[22].n = 128.0;

    Material[23].k_d = vec3(0.45, 0.568627, 0.113725);
    Material[23].k_a = vec3(0.329412, 0.223529, 0.027451);
    Material[23].k_r = vec3(0.992157, 0.941176, 0.807843);
    Material[23].k_rg = 0.4 * Material[23].k_r;
    Material[23].n = 27.0;

    Material[24].k_d = vec3(0.8, 0.45, 0.1);
    Material[24].k_a = vec3(0.24725, 0.1995, 0.0745);
    Material[24].k_r = vec3(0.7, 0.4, 0.1);
    Material[24].k_rg = vec3(0.550000, 0.550000, 0.550000);
    Material[24].n = 51.2;

    Material[25].k_d = vec3(0.021500, 0.045500, 0.098000);
    Material[25].k_a = vec3(0.002000, 0.004250, 0.009000);
    Material[25].k_r = vec3(0.089000, 0.183000, 0.316000);
    Material[25].k_rg = vec3(0.200000, 0.200000, 0.200000);
    Material[25].n = 256.0;

    Material[26].k_d = vec3(0.021500, 0.174500, 0.021500);
    Material[26].k_a = vec3(0.002000, 0.017000, 0.002000);
    Material[26].k_r = vec3(0.075680, 0.614240, 0.075680);
    Material[26].k_rg = vec3(0.200000, 0.200000, 0.200000);
    Material[26].n = 256.0;

    Material[27].k_d = vec3(0.001440, 0.662400, 0.630240);
    Material[27].k_a = vec3(0.000250, 0.114000, 0.108000);
    Material[27].k_r = vec3(0.001440, 0.662400, 0.630240);
    Material[27].k_rg = vec3(0.550000, 0.550000, 0.550000);
    Material[27].n = 128.0;

    // Light 0.
    Light[0].position = vec3(0.0, 8.0, 0.0);
    Light[0].I_a = vec3(0.1, 0.1, 0.1);
    Light[0].I_source = vec3(1.0, 1.0, 1.0);

    // Light 1.
    Light[1].position = vec3(-4.0, 8.0, 0.0);
    Light[1].I_a = vec3(0.1, 0.1, 0.1);
    Light[1].I_source = vec3(1.0, 1.0, 1.0);
}

//Signed Distance Function of segment shape
float udSegment(in vec2 p, in vec2 a, in vec2 b) {
    vec2 ba = b - a;
    vec2 pa = p - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - h * ba);
}

//Signed Distance Function of horsehoe shape
float sdHorseshoe(in vec2 p, in vec2 c, in float r, in vec2 w) {
    p.x = abs(p.x);
    float l = length(p);
    p = mat2(-c.x, c.y, c.y, c.x) * p;
    p = vec2((p.y > 0.0 || p.x > 0.0) ? p.x : l * sign(-c.x), (p.x > 0.0) ? p.y : l);
    p = vec2(p.x, abs(p.y - r)) - w;
    return length(max(p, 0.0)) + min(0.0, max(p.x, p.y));
}

//Signed Distance Function of Letter 'N'
float N_sdf(in vec2 p) {
    vec2 offset = vec2(-2.0, 0.0);
    float d = udSegment(p - offset, vec2(-0.6, 1.0), vec2(-0.6, 3.0)) - 0.1;
    float d1 = udSegment(p - offset, vec2(-0.6, 3.0), vec2(0.6, 1.0)) - 0.1;
    float d2 = udSegment(p - offset, vec2(0.6, 1.0), vec2(0.6, 3.0)) - 0.1;
    return min(d2, min(d, d1));
}

//Signed Distance Function of Letter 'U'
float U_sdf(in vec2 p) {
    float d = udSegment(p, vec2(-0.6, 1.6), vec2(-0.6, 3.0)) - 0.1;
    float d1 = sdHorseshoe(p - vec2(0.0, 1.6), vec2(cos(1.6), sin(1.6)), 0.6, vec2(0.1, 0.1));
    float d2 = udSegment(p, vec2(0.6, 1.6), vec2(0.6, 3.0)) - 0.1;
    return min(d2, min(d, d1));
}

////Signed Distance Function of Letter 'S'
float S_sdf(in vec2 p) {
    vec2 offset = vec2(2.0, 0.0);
    float d1 = udSegment(p - offset, vec2(-0.6, 1.0), vec2(0.2, 1.0)) - 0.1;
    float d2 = udSegment(p - offset, vec2(-0.2, 3.0), vec2(0.6, 3.0)) - 0.1;
    float d3 = udSegment(p - offset, vec2(-0.2, 2.0), vec2(0.2, 2.0)) - 0.1;
    float d4 = sdHorseshoe(p.yx - offset.yx - vec2(2.5, -0.2), vec2(cos(1.6), sin(1.6)), 0.5, vec2(0.1, 0.1));
    float d5 = sdHorseshoe(-p.yx + offset.yx - vec2(-1.5, -0.2), vec2(cos(1.6), sin(1.6)), 0.5, vec2(0.1, 0.1));
    return min(d1, min(d2, min(d3, min(d4, d5))));
}

bool IntersectNUS(in vec2 p) {
    return N_sdf(p) < 0.0 || U_sdf(p) < 0.0 || S_sdf(p) < 0.0;
}

bool IntersectPlane(
    in Plane_t pln,
    in Ray_t ray,
    in float tmin,
    in float tmax,
    out float t,
    out vec3 hitPos,
    out vec3 hitNormal
) {
    vec3 N = vec3(pln.A, pln.B, pln.C);
    float NRd = dot(N, ray.d);
    float NRo = dot(N, ray.o);
    float t0 = (-pln.D - NRo) / NRd;
    if(t0 < tmin || t0 > tmax)
        return false;
    t = t0;
    hitPos = ray.o + t0 * ray.d;
    hitNormal = normalize(N);
    return true;
}

bool IntersectPlane(in Plane_t pln, in Ray_t ray, in float tmin, in float tmax) {
    vec3 N = vec3(pln.A, pln.B, pln.C);
    float NRd = dot(N, ray.d);
    float NRo = dot(N, ray.o);
    float t0 = (-pln.D - NRo) / NRd;
    if(t0 < tmin || t0 > tmax)
        return false;
    return true;
}

bool IntersectSphere(
    in Sphere_t sph,
    in Ray_t ray,
    in float tmin,
    in float tmax,
    out float t,
    out vec3 hitPos,
    out vec3 hitNormal
) {
    vec3 oc = ray.o - sph.center;
    float a = dot(ray.d, ray.d);
    float half_b = dot(oc, ray.d);
    float c = dot(oc, oc) - sph.radius * sph.radius;
    float discr = half_b * half_b - a * c;
    if(discr >= 0.0) {
        float sqrtd = sqrt(discr);
        t = (-half_b - sqrtd) / a;
        hitPos = ray.o + t * ray.d;
        vec3 normal = normalize(hitPos - sph.center);
        hitNormal = normal;
        return (t >= tmin && t <= tmax);
    }
    return false;
}

bool IntersectSphere(in Sphere_t sph, in Ray_t ray, in float tmin, in float tmax) {
    vec3 oc = ray.o - sph.center;
    float a = dot(ray.d, ray.d);
    float half_b = dot(oc, ray.d);
    float c = dot(oc, oc) - sph.radius * sph.radius;
    float discr = half_b * half_b - a * c;
    if(discr >= 0.0) {
        float sqrtd = sqrt(discr);
        float t1 = (-half_b - sqrtd) / a;
        float t2 = (-half_b + sqrtd) / a;
        return ((t1 >= tmin && t1 <= tmax) || (t2 >= tmin && t2 <= tmax));
    }
    return false;
}

bool IntersectCylinder(in Cylinder_t cyl, in Ray_t ray, in float tmin, in float tmax, out float t, out vec3 hitPos, out vec3 hitNormal) {
    vec2 rayOriInSphere = ray.o.xz - cyl.center.xz;
    float a = dot(ray.d.xz, ray.d.xz);
    float b = 2.0 * dot(ray.d.xz, rayOriInSphere);
    float c = dot(rayOriInSphere, rayOriInSphere) - cyl.radius * cyl.radius;
    float d = b * b - 4.0 * a * c;
    if(d < 0.0)
        return false;
    float t1 = (-1.0 * b + sqrt(d)) / (2.0 * a);
    float t2 = (-1.0 * b - sqrt(d)) / (2.0 * a);
    float finalT;
    bool isSatisfy = false;
    if(t1 >= tmin && t1 <= tmax) {
        isSatisfy = true;
        finalT = t1;
    }
    if(t2 >= tmin && t2 <= tmax) {
        isSatisfy = true;
        finalT = t2;
    }
    if(isSatisfy == false)
        return false;
    t = finalT;
    hitPos = ray.o + finalT * ray.d;
    hitNormal = hitPos - cyl.center;
    if(hitNormal.y - cyl.center.y < 0.0 || hitNormal.y - cyl.center.y > cyl.height)
        return false;
    hitNormal.y = 0.0;
    hitNormal = hitNormal / cyl.radius;
    return true;
}

bool IntersectCylinder(in Cylinder_t cyl, in Ray_t ray, in float tmin, in float tmax) {
    vec2 rayOriInSphere = ray.o.xy - cyl.center.xy;
    float a = dot(ray.d.xy, ray.d.xy);
    float b = 2.0 * dot(ray.d.xy, rayOriInSphere);
    float c = dot(rayOriInSphere, rayOriInSphere) - cyl.radius * cyl.radius;
    float d = b * b - 4.0 * a * c;
    if(d < 0.0)
        return false;
    float t1 = (-1.0 * b + sqrt(d)) / (2.0 * a);
    float t2 = (-1.0 * b - sqrt(d)) / (2.0 * a);
    float finalT;
    bool isSatisfy = false;
    if(t1 >= tmin && t1 <= tmax) {
        isSatisfy = true;
        finalT = t1;
    }
    if(t2 >= tmin && t2 <= tmax) {
        isSatisfy = true;
        finalT = t2;
    }
    if(isSatisfy == false)
        return false;
    return true;
}

bool IntersectBox(in Box_t box, in Ray_t ray, in float tmin, in float tmax, out float t, out vec3 hitPos, out vec3 hitNormal) {
    vec3 sco = (box.M * vec4(ray.o, 1.0)).xyz;
    vec3 scd = normalize((transpose(inverse(box.M)) * vec4(ray.d, 1.0)).xyz);
    vec3 m = 1.0 / scd;
    vec3 n = m * sco;
    vec3 k = abs(m) * box.radius;
    vec3 t1 = -n - k;
    vec3 t2 = -n + k;
    float tN = max(max(t1.y, t1.z), t1.x);
    float tF = min(min(t2.y, t2.z), t2.x);
    if(tN > tF || tF < 0.0)
        return false;
    if(tN < tmin || tN > tmax)
        return false;
    t = tN;
    hitPos = (inverse(box.M) * vec4((sco + t * scd), 1.0)).xyz;
    hitNormal = (transpose(inverse(box.M)) * vec4((-sign(ray.d) * step(t1.zxy, t1.xyz) * step(t1.yzx, t1.xyz)), 1.0)).xyz;
    return true;
}

bool IntersectBox(in Box_t box, in Ray_t ray, in float tmin, in float tmax) {
    vec3 sco = (box.M * vec4(ray.o, 1.0)).xyz;
    vec3 scd = normalize((transpose(inverse(box.M)) * vec4(ray.d, 1.0)).xyz);
    vec3 m = 1.0 / scd;
    vec3 n = m * sco;
    vec3 k = abs(m) * box.radius;
    vec3 t1 = -n - k;
    vec3 t2 = -n + k;
    float tN = max(max(t1.y, t1.z), t1.x);
    float tF = min(min(t2.y, t2.z), t2.x);
    if(tN > tF || tF < 0.0)
        return false;
    if(tN < tmin || tN > tmax)
        return false;
    return true;
}

bool IntersectTriangle(in Triangle_t tri, in Ray_t ray, in float tmin, in float tmax, out float t, out vec3 hitPos, out vec3 hitNormal) {
    vec3 e1 = tri.v1 - tri.v0;
    vec3 e2 = tri.v2 - tri.v0;
    vec3 s = ray.o - tri.v0;
    vec3 s1 = cross(ray.d, e2);
    vec3 s2 = cross(s, e1);
    float s1e1 = dot(s1, e1);
    float s2e2 = dot(s2, e2);
    float s1s = dot(s1, s);
    float s2d = dot(s2, ray.d);
    float s1e1_inv = 1.0 / s1e1;
    float t0 = s2e2 * s1e1_inv;
    float t1 = s1s * s1e1_inv;
    float t2 = s2d * s1e1_inv;
    if(t0 < tmin || t0 > tmax)
        return false;
    if(t1 < 0.0 || t2 < 0.0 || t1 + t2 > 1.0)
        return false;
    t = t0;
    hitPos = ray.o + t0 * ray.d;
    hitNormal = -abs(normalize(cross(e1, e2)));
    return true;
}

bool IntersectTriangle(in Triangle_t tri, in Ray_t ray, in float tmin, in float tmax) {
    vec3 e1 = tri.v1 - tri.v0;
    vec3 e2 = tri.v2 - tri.v0;
    vec3 s = ray.o - tri.v0;
    vec3 s1 = cross(ray.d, e2);
    vec3 s2 = cross(s, e1);
    float s1e1 = dot(s1, e1);
    float s2e2 = dot(s2, e2);
    float s1s = dot(s1, s);
    float s2d = dot(s2, ray.d);
    float s1e1_inv = 1.0 / s1e1;
    float t0 = s2e2 * s1e1_inv;
    float t1 = s1s * s1e1_inv;
    float t2 = s2d * s1e1_inv;
    if(t0 < tmin || t0 > tmax)
        return false;
    if(t1 < 0.0 || t2 < 0.0 || t1 + t2 > 1.0)
        return false;
    return true;
}

vec3 squaresColours(vec2 p) {
    p += vec2(iTime * 0.2);
    vec3 orange = vec3(1.0, 0.4, 0.1) * 2.0;
    vec3 purple = vec3(1.0, 0.2, 0.5) * 0.8;
    float l = pow(0.5 + 0.5 * cos(p.x * 7.0 + cos(p.y) * 8.0) * sin(p.y * 2.0), 4.0) * 2.0;
    vec3 c = pow(l * (mix(orange, purple, 0.5 + 0.5 * cos(p.x * 40.0 + sin(p.y * 10.0) * 3.0)) +
        mix(orange, purple, 0.5 + 0.5 * cos(p.x * 20.0 + sin(p.y * 3.0) * 3.0))), vec3(1.2)) * 0.7;
    c += vec3(1.0, 0.8, 0.4) * pow(0.5 + 0.5 * cos(p.x * 20.0) * sin(p.y * 12.0), 20.0) * 2.0;
    c += vec3(0.1, 0.5 + 0.5 * cos(p * 20.0)) * vec3(0.05, 0.1, 0.4).bgr * 0.7;
    return c;
}

vec3 calculateColor(vec2 p, float border) {
    float sm = 0.02;
    vec2 res = vec2(3.5);
    vec2 ip = floor(p * res) / res;
    vec2 fp = fract(p * res);
    float m = 1.0 - max(smoothstep(border - sm, border, abs(fp.x - 0.5)), smoothstep(border - sm, border, abs(fp.y - 0.5)));
    m += 1.0 - smoothstep(0.0, 0.56, distance(fp, vec2(0.5)));
    return m * squaresColours(ip);
}

vec3 PhongLighting(
    in vec3 L,
    in vec3 N,
    in vec3 V,
    in bool inShadow,
    in Material_t mat,
    in Light_t light
) {
    if(inShadow) {
        return light.I_a * mat.k_a;
    } else {
        vec3 R = reflect(-L, N);
        float N_dot_L = max(0.0, dot(N, L));
        float R_dot_V = max(0.0, dot(R, V));
        float R_dot_V_pow_n = (R_dot_V == 0.0) ? 0.0 : pow(R_dot_V, mat.n);

        return light.I_a * mat.k_a +
            light.I_source * (mat.k_d * N_dot_L + mat.k_r * R_dot_V_pow_n);
    }
}

vec3 PhongLighting(
    in vec3 L,
    in vec3 N,
    in vec3 V,
    in bool inShadow,
    in Light_t light,
    vec3 nearest_hitPos,
    int hitWhichPlane
) {
    Material_t mat = Material[1];
    vec2 p;
    if(hitWhichPlane == 0 || hitWhichPlane == 5)
        p = nearest_hitPos.xz;
    else if(hitWhichPlane == 1 || hitWhichPlane == 3)
        p = nearest_hitPos.xy;
    else if(hitWhichPlane == 2 || hitWhichPlane == 4)
        p = nearest_hitPos.yz;
    else if(hitWhichPlane < 0) {
        p.y = nearest_hitPos.y;
        p.x = length(nearest_hitPos.xz);
    }
    p = p / blockNum;
    mat.k_d = calculateColor(p, blockLength);
    mat.k_a = 0.4 * mat.k_d;
    mat.k_r = 3.0 * mat.k_d;
    if(inShadow) {
        return light.I_a * mat.k_a;
    } else {
        vec3 R = reflect(-L, N);
        float N_dot_L = max(0.0, dot(N, L));
        float R_dot_V = max(0.0, dot(R, V));
        float R_dot_V_pow_n = (R_dot_V == 0.0) ? 0.0 : pow(R_dot_V, mat.n);
        return light.I_a * mat.k_a +
            light.I_source * (mat.k_d * N_dot_L + mat.k_r * R_dot_V_pow_n);
    }
}

vec3 CastRay(
    in Ray_t ray,
    out bool hasHit,
    out vec3 hitPos,
    out vec3 hitNormal,
    out vec3 k_rg
) {

    bool hasHitSomething = false;
    float nearest_t = DEFAULT_TMAX;   // The ray parameter t at the nearest hit point.
    vec3 nearest_hitPos;              // 3D position of the nearest hit point.
    vec3 nearest_hitNormal;           // Normal vector at the nearest hit point.
    int nearest_hitMatID;             // MaterialID of the object at the nearest hit point.

    float temp_t;
    vec3 temp_hitPos;
    vec3 temp_hitNormal;
    bool temp_hasHit;

    //which Plane does it hit
    int hitWhichPlane;

    //Intersection with the plane
    for(int i = 0; i < NUM_PLANES; i++) {
        temp_hasHit = IntersectPlane(Plane[i], ray, DEFAULT_TMIN, DEFAULT_TMAX, temp_t, temp_hitPos, temp_hitNormal);
        if(temp_hasHit && temp_t < nearest_t) {
            hasHitSomething = true;
            nearest_t = temp_t;
            nearest_hitPos = temp_hitPos;
            nearest_hitNormal = temp_hitNormal;
            nearest_hitMatID = Plane[i].materialID;
            hitWhichPlane = i;
        }
    }
    //Intersection with the cylinder
    for(int i = 0; i < NUM_CYLINDERS; i++) {
        temp_hasHit = IntersectCylinder(Cylinder[i], ray, DEFAULT_TMIN, DEFAULT_TMAX, temp_t, temp_hitPos, temp_hitNormal);
        if(temp_hasHit && temp_t < nearest_t) {
            hasHitSomething = true;
            nearest_t = temp_t;
            nearest_hitPos = temp_hitPos;
            nearest_hitNormal = temp_hitNormal;
            nearest_hitMatID = Cylinder[i].materialID;
        }
    }

    if(iTime >= PRELUDE_TIME) {
        for(int i = 0; i < NUM_SPHERES; i++) {
            temp_hasHit = IntersectSphere(Sphere[i], ray, DEFAULT_TMIN, DEFAULT_TMAX, temp_t, temp_hitPos, temp_hitNormal);
            if(temp_hasHit && temp_t < nearest_t) {
                hasHitSomething = true;
                nearest_t = temp_t;
                nearest_hitPos = temp_hitPos;
                nearest_hitNormal = temp_hitNormal;
                nearest_hitMatID = Sphere[i].materialID;
            }
        }
        for(int i = 0; i < NUM_BOXS; i++) {
            temp_hasHit = IntersectBox(Box[i], ray, DEFAULT_TMIN, DEFAULT_TMAX, temp_t, temp_hitPos, temp_hitNormal);
            if(temp_hasHit && temp_t < nearest_t) {
                nearest_t = temp_t;
                nearest_hitPos = temp_hitPos;
                nearest_hitNormal = temp_hitNormal;
                nearest_hitMatID = Box[i].materialID;
                hasHitSomething = true;
            }
        }

        for(int i = 0; i < NUM_TRIANGLES; i++) {
            temp_hasHit = IntersectTriangle(Diamond[i], ray, DEFAULT_TMIN, DEFAULT_TMAX, temp_t, temp_hitPos, temp_hitNormal);
            if(temp_hasHit && temp_t < nearest_t) {
                nearest_t = temp_t;
                nearest_hitPos = temp_hitPos;
                nearest_hitNormal = temp_hitNormal;
                nearest_hitMatID = Diamond[i].materialID;
                hasHitSomething = true;
            }
        }

        //Intersection with the platform
        temp_hasHit = IntersectBox(Platform, ray, DEFAULT_TMIN, DEFAULT_TMAX, temp_t, temp_hitPos, temp_hitNormal);
        if(temp_hasHit && temp_t < nearest_t) {
            nearest_t = temp_t;
            nearest_hitPos = temp_hitPos;
            nearest_hitNormal = temp_hitNormal;
            nearest_hitMatID = Platform.materialID;
            hasHitSomething = true;
        }

        temp_hasHit = IntersectSphere(Ball, ray, DEFAULT_TMIN, DEFAULT_TMAX, temp_t, temp_hitPos, temp_hitNormal);
        if(temp_hasHit && temp_t < nearest_t) {
            nearest_t = temp_t;
            nearest_hitPos = temp_hitPos;
            nearest_hitNormal = temp_hitNormal;
            nearest_hitMatID = Ball.materialID;
            hasHitSomething = true;
        }
    }

    // One of the output results.
    hasHit = hasHitSomething;
    if(!hasHitSomething)
        return BACKGROUND_COLOR;
    vec2 p = nearest_hitPos.xy;
    if(hitWhichPlane == 3) {
        if(iTime < 3.0) {
            //N
            if((udSegment(p, vec2(4.0, 2.0), vec2(4.0, 2.0 + iTime * (2.0 / 3.0))) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }
            //U
            else if((udSegment(p, vec2(1.0, 4.0), vec2(1.0, 4.0 - iTime * (1.4 / 3.0))) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }

        } else if(iTime < 6.0 && iTime >= 3.0) {
            //N
            if((udSegment(p, vec2(4.0, 2.0), vec2(4.0, 4.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if((udSegment(p, vec2(4.0, 4.0), vec2(4.0 - (iTime - 3.0) * (2.0 / 3.0), 6.0 - iTime * (2.0 / 3.0))) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }

            //U
            else if((udSegment(p, vec2(1.0, 4.0), vec2(1.0, 2.6)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if(sdHorseshoe(p - vec2(0.4, 2.5), vec2(cos(1.6 * (iTime - 3.0) / 3.0), sin(1.6 * (iTime - 3.0) / 3.0)), 0.6, vec2(0.1, 0.1)) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }
        } else if(iTime >= 6.0 && iTime < 10.0) {
            //N
            if((udSegment(p, vec2(4.0, 2.0), vec2(4.0, 4.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if((udSegment(p, vec2(4.0, 4.0), vec2(2.0, 2.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if((udSegment(p, vec2(2.0, 2.0), vec2(2.0, 2.0 + (iTime - 6.0) / 2.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }
            //U
            else if((udSegment(p, vec2(1.0, 4.0), vec2(1.0, 2.6)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if(sdHorseshoe(p - vec2(0.4, 2.5), vec2(cos(1.6), sin(1.6)), 0.6, vec2(0.1, 0.1)) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if((udSegment(p, vec2(-0.2, 2.6), vec2(-0.2, 2.6 + (iTime - 6.0) * (1.4 / 4.0))) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }
        } else if(iTime >= 10.0 && iTime < PRELUDE_TIME) {
            if((udSegment(p, vec2(4.0, 2.0), vec2(4.0, 4.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if((udSegment(p, vec2(4.0, 4.0), vec2(2.0, 2.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if((udSegment(p, vec2(2.0, 2.0), vec2(2.0, 4.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }
            //U
            else if((udSegment(p, vec2(1.0, 4.0), vec2(1.0, 2.6)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if(sdHorseshoe(p - vec2(0.4, 2.5), vec2(cos(1.6), sin(1.6)), 0.6, vec2(0.1, 0.1)) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if((udSegment(p, vec2(-0.2, 2.6), vec2(-0.2, 4.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }
        } else {
            Material[5].k_d = Material[1].k_d;
            Material[5].k_a = Material[1].k_a;
            Material[5].k_r = Material[1].k_r;
            Material[5].k_rg = Material[1].k_rg;
            Material[5].n = Material[1].n;
        }
    }
    if(hitWhichPlane == 3) {
        if(iTime < 2.0) {
            if((udSegment(p, vec2(-2.5 + iTime * (0.9 / 2.0), 4.0), vec2(-2.5, 4.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }
        } else if(iTime >= 2.0 && iTime < 4.0) {
            if((udSegment(p, vec2(-1.6, 4.0), vec2(-2.5, 4.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if(sdHorseshoe(-p.yx + vec2(3.5, -1.5), vec2(cos(1.6 * (iTime - 2.0) / 2.0), sin(1.6) * (iTime - 2.0) / 2.0), 0.5, vec2(0.1, 0.1)) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }
        } else if(iTime >= 4.0 && iTime < 6.0) {
            if((udSegment(p, vec2(-1.6, 4.0), vec2(-2.5, 4.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if(sdHorseshoe(-p.yx + vec2(3.5, -1.5), vec2(cos(1.6), sin(1.6)), 0.5, vec2(0.1, 0.1)) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if((udSegment(p, vec2(-1.6, 3.0), vec2(-1.6 - (iTime - 4.0) * (0.9 / 2.0), 3.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }
        } else if(iTime >= 6.0 && iTime < 8.0) {
            if((udSegment(p, vec2(-1.6, 4.0), vec2(-2.5, 4.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if(sdHorseshoe(-p.yx + vec2(3.5, -1.5), vec2(cos(1.6), sin(1.6)), 0.5, vec2(0.1, 0.1)) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if((udSegment(p, vec2(-1.6, 3.0), vec2(-2.5, 3.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if(sdHorseshoe(p.yx - vec2(2.5, -2.5), vec2(cos(1.6 * (iTime - 6.0) / 2.0), sin(1.6) * (iTime - 6.0) / 2.0), 0.5, vec2(0.1, 0.1)) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }

        } else if(iTime >= 8.0 && iTime < 10.0) {
            if((udSegment(p, vec2(-1.6, 4.0), vec2(-2.5, 4.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if(sdHorseshoe(-p.yx + vec2(3.5, -1.5), vec2(cos(1.6), sin(1.6)), 0.5, vec2(0.1, 0.1)) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if((udSegment(p, vec2(-1.6, 3.0), vec2(-2.5, 3.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if(sdHorseshoe(p.yx - vec2(2.5,-2.5), vec2(cos(1.6), sin(1.6)), 0.5, vec2(0.1, 0.1))<0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if((udSegment(p, vec2(-2.5, 2.0), vec2(-2.5 + (iTime - 8.0) * (1.2 / 2.0), 2.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }
        } else if(iTime >= 10.0 && iTime < PRELUDE_TIME) {
            if((udSegment(p, vec2(-1.6, 4.0), vec2(-2.5, 4.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if(sdHorseshoe(-p.yx + vec2(3.5, -1.5), vec2(cos(1.6), sin(1.6)), 0.5, vec2(0.1, 0.1)) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if((udSegment(p, vec2(-1.6, 3.0), vec2(-2.5, 3.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if(sdHorseshoe(p.yx - vec2(2.5,-2.5), vec2(cos(1.6), sin(1.6)), 0.5, vec2(0.1, 0.1))<0.0){
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            } else if((udSegment(p, vec2(-2.5, 2.0), vec2(-2.5 + (10.0 - 8.0) * (1.2 / 2.0), 2.0)) - 0.1) < 0.0) {
                nearest_hitNormal = vec3(0.0, 0.0, -1.0);
                Material[5].k_d = vec3(0.6, 0.4, 0.5);
                Material[5].k_a = 0.0 * Material[2].k_d;
                Material[5].k_r = 0.0 * Material[2].k_d;
                Material[5].k_rg = 0.0 * Material[2].k_r;
                Material[5].n = 128.0;
            }
        } else {
            Material[5].k_d = Material[1].k_d;
            Material[5].k_a = Material[1].k_a;
            Material[5].k_r = Material[1].k_r;
            Material[5].k_rg = Material[1].k_rg;
            Material[5].n = Material[1].n;
        }
    }
    if(hitWhichPlane == 4) {
        if(IntersectNUS(nearest_hitPos.zy)) {
            nearest_hitNormal = vec3(-1.0, 0.0, 0.0);
            Material[2].k_d = vec3(.9, 0.8, 0.0);
            Material[2].k_a = 0.0 * Material[2].k_d;
            Material[2].k_r = 0.0 * Material[2].k_d;
            Material[2].k_rg = 0.0 * Material[2].k_r;
            Material[2].n = 128.0;
        }
    }

    vec3 I_local = vec3(0.0);  // Result color will be accumulated here.
    for(int i = 0; i < NUM_LIGHTS; i++) {
        // Check whether it is in shadow
        bool inShadow = false, tempInShadow;
        Ray_t shadowRay;
        shadowRay.o = nearest_hitPos;
        shadowRay.d = normalize(Light[i].position - nearest_hitPos);
        // Since it is a line segement, we need to find the endpoint's t value
        float LineSegmentMin = DEFAULT_TMIN;
        float LineSegmentMax = length(Light[i].position - nearest_hitPos);
        if(iTime >= PRELUDE_TIME) {
            for(int j = 0; j < NUM_SPHERES; j++) {
                if(inShadow)
                    break;
                tempInShadow = IntersectSphere(Sphere[j], shadowRay, LineSegmentMin, LineSegmentMax);
                if(tempInShadow)
                    inShadow = true;
            }
            for(int j = 0; j < NUM_BOXS; j++) {
                if(inShadow)
                    break;
                tempInShadow = IntersectBox(Box[j], shadowRay, LineSegmentMin, LineSegmentMax);
                if(tempInShadow)
                    inShadow = true;
            }
            for(int j = 0; j < NUM_TRIANGLES; j++) {
                if(inShadow)
                    break;
                tempInShadow = IntersectTriangle(Diamond[j], shadowRay, LineSegmentMin, LineSegmentMax);
                if(tempInShadow)
                    inShadow = true;
            }
            tempInShadow = IntersectBox(Platform, shadowRay, LineSegmentMin, LineSegmentMax);
            if(tempInShadow)
                inShadow = true;
            tempInShadow = IntersectSphere(Ball, shadowRay, LineSegmentMin, LineSegmentMax);
            if(tempInShadow)
                inShadow = true;
        }
        for(int j = 0; j < NUM_PLANES; j++) {
            if(inShadow)
                break;
            tempInShadow = IntersectPlane(Plane[j], shadowRay, LineSegmentMin, LineSegmentMax);
            if(tempInShadow)
                inShadow = true;
        }
        for(int j = 0; j < NUM_CYLINDERS; j++) {
            if(inShadow)
                break;
            tempInShadow = IntersectCylinder(Cylinder[j], shadowRay, LineSegmentMin, LineSegmentMax);
            if(tempInShadow)
                inShadow = true;
        }
        // Prepare needed parameters
        vec3 L = normalize(Light[i].position - nearest_hitPos);
        vec3 N = normalize(nearest_hitNormal);
        vec3 V = normalize(-ray.d);
        if(nearest_hitMatID == 3) {
            I_local += PhongLighting(L, N, V, inShadow, Light[i], nearest_hitPos, hitWhichPlane);
        } else {
            I_local += PhongLighting(L, N, V, inShadow, Material[nearest_hitMatID], Light[i]);
        }
    }

    // Populate output results.
    hitPos = nearest_hitPos;
    hitNormal = nearest_hitNormal;
    k_rg = Material[nearest_hitMatID].k_rg;

    return I_local;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    InitScene();

    // Scale pixel 2D position such that its y coordinate is in [-1.0, 1.0].
    vec2 pixel_pos = (2.0 * fragCoord.xy - iResolution.xy) / iResolution.y;

    // Position the camera.
    vec3 cam_pos, cam_lookat, cam_up_vec;
    if(iTime < PRELUDE_TIME) {
        cam_pos = vec3(0, 3.1, -1.5);
        cam_lookat = vec3(0.0, 3.1, 5.0);
        cam_up_vec = vec3(0.0, 1.0, 0.0);
    } else {
        float time = iTime - PRELUDE_TIME;
        if(mod((time / 20.0), 2.0) >= 1.0 && time > 20.0) {
            cam_pos = vec3(3.5 * cos(time * 0.3), 5.0, 3.5 * sin(time * 0.3));
            cam_lookat = vec3(0.0, 2.0 + cos(time), 0.0);
            cam_up_vec = vec3(0.0, 1.0, 0.0);
        } else {
            cam_pos = vec3(0, 5.0, 0);
            cam_lookat = vec3(5.0 * sin(time * 0.3), 2.0, 5.0 * cos(time * 0.3));
            cam_up_vec = vec3(0.0, 1.0, 0.0);
        }
    }
    // Set up camera coordinate frame in world space.
    vec3 cam_z_axis = normalize(cam_pos - cam_lookat);
    vec3 cam_x_axis = normalize(cross(cam_up_vec, cam_z_axis));
    vec3 cam_y_axis = normalize(cross(cam_z_axis, cam_x_axis));

    // Create primary ray.
    float pixel_pos_z = -1.0 / tan(FOVY / 2.0);
    Ray_t pRay;
    pRay.o = cam_pos;
    pRay.d = normalize(pixel_pos.x * cam_x_axis + pixel_pos.y * cam_y_axis + pixel_pos_z * cam_z_axis);

    // Start Ray Tracing.
    // Use iterations to emulate the recursion.

    vec3 I_result = vec3(0.0);
    vec3 compounded_k_rg = vec3(1.0);
    Ray_t nextRay = pRay;
    for(int level = 0; level <= NUM_ITERATIONS; level++) {
        bool hasHit;
        vec3 hitPos, hitNormal, k_rg;
        vec3 I_local = CastRay(nextRay, hasHit, hitPos, hitNormal, k_rg);
        I_result += compounded_k_rg * I_local;
        if(!hasHit)
            break;
        compounded_k_rg *= k_rg;
        nextRay = Ray_t(hitPos, normalize(reflect(nextRay.d, hitNormal)));
    }
    fragColor = vec4(I_result, 1.0);
}