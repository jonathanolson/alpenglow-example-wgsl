ComputePipeline.ts:27 @group(0) @binding(0)
var<storage, read> input: array<u32, 131072>;
@group(0) @binding(1)
var<storage, read_write> output: array<u32, 512>;
var<workgroup> scratch: array<u32, 64>;
@compute @workgroup_size(64)
fn main(
  @builtin(global_invocation_id) global_id: vec3u,
  @builtin(local_invocation_id) local_id: vec3u,
  @builtin(workgroup_id) workgroup_id: vec3u
) {
  /*** begin load_reduced ***/
  var value: u32;
  {
    let base_striped_index = workgroup_id.x * 256u + local_id.x;
    {
      let striped_index = base_striped_index + 0u;
      if ( striped_index < ( ( ( ( 131045u ) + 255u ) / 256u ) << 8u ) ) {
        value = input[ striped_index ];
      }
      else {
        value = 0u;
      }
    }
    {
      let striped_index = base_striped_index + 64u;
      if ( striped_index < ( ( ( ( 131045u ) + 255u ) / 256u ) << 8u ) ) {
        let next_value = input[ striped_index ];
        value = ( value + next_value );
      }
    }
    {
      let striped_index = base_striped_index + 128u;
      if ( striped_index < ( ( ( ( 131045u ) + 255u ) / 256u ) << 8u ) ) {
        let next_value = input[ striped_index ];
        value = ( value + next_value );
      }
    }
    {
      let striped_index = base_striped_index + 192u;
      if ( striped_index < ( ( ( ( 131045u ) + 255u ) / 256u ) << 8u ) ) {
        let next_value = input[ striped_index ];
        value = ( value + next_value );
      }
    }
  }
  /*** end load_reduced ***/
  /*** begin reduce convergent:true ***/
  scratch[ local_id.x ] = value;
  workgroupBarrier();
  if ( local_id.x < 32u ) {
    value = ( value + scratch[ local_id.x + 32u ] );
    scratch[ local_id.x ] = value;
  }
  workgroupBarrier();
  if ( local_id.x < 16u ) {
    value = ( value + scratch[ local_id.x + 16u ] );
    scratch[ local_id.x ] = value;
  }
  workgroupBarrier();
  if ( local_id.x < 8u ) {
    value = ( value + scratch[ local_id.x + 8u ] );
    scratch[ local_id.x ] = value;
  }
  workgroupBarrier();
  if ( local_id.x < 4u ) {
    value = ( value + scratch[ local_id.x + 4u ] );
    scratch[ local_id.x ] = value;
  }
  workgroupBarrier();
  if ( local_id.x < 2u ) {
    value = ( value + scratch[ local_id.x + 2u ] );
    scratch[ local_id.x ] = value;
  }
  workgroupBarrier();
  if ( local_id.x < 1u ) {
    value = ( value + scratch[ local_id.x + 1u ] );
  }
  /*** end reduce ***/
  if ( local_id.x == 0u ) {
    output[ workgroup_id.x ] = value;
  }
}
