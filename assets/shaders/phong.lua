return [[

#define NUM_LIGHTS 64

struct Light {
    vec2 position;
    vec3 diffuse;
    float power;
};

extern Light lights[NUM_LIGHTS];
extern vec2 screen;
extern int num_lights;


const float constant = .9;
const float linear = 0.09;
const float quadratic = 0.032;

float round(float x) {
  float val = floor(x);
  float rem = x - val;
  if (rem >= .5) { return val + 1; }
  return val;
}

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px) {

  vec2 screen = vec2(max(screen.x, screen.y));

  vec4 pixel = Texel(tex, uv);
  vec2 norm_screen = px;
  vec3 diffuse = vec3(0);

  for (int i = 0; i < num_lights; i++) {
    Light light = lights[i];

    vec2 norm_pos = light.position;
    float distance = length(norm_pos - norm_screen) * light.power / 600;
    float attenuation = 1.0 / (constant + linear * distance + quadratic * (distance * distance));
    diffuse += light.diffuse * attenuation;
  }

  return color * pixel * vec4(diffuse, 1.0);
} ]]
