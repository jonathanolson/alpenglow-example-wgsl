@group(0) @binding(0)
var<storage, read_write> addresses: array<u32>;
@compute @workgroup_size(256)
fn main(
  @builtin(global_invocation_id) global_id: vec3u,
  @builtin(local_invocation_id) local_id: vec3u,
  @builtin(workgroup_id) workgroup_id: vec3u
) {
  addresses[ global_id.x ] = select( 0u, 0xffffffffu, global_id.x >= 2u );
}
