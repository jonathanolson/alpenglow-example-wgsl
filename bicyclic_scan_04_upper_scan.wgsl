@group(0) @binding(0)
var<storage, read_write> data: array<vec2u, 9411>;
@group(0) @binding(1)
var<storage, read> scanned_reduction: array<vec2u, 148>;
@group(0) @binding(2)
var<storage, read> double_scanned_reduction: array<vec2u, 3>;
var<workgroup> reduction_value: vec2u;
var<workgroup> scratch: array<vec2u, 64>;
@compute @workgroup_size(32)
fn main(
  @builtin(global_invocation_id) global_id: vec3u,
  @builtin(local_invocation_id) local_id: vec3u,
  @builtin(workgroup_id) workgroup_id: vec3u
) {
  /*** begin scan_comprehensive inclusive ***/
  /*** begin load_multiple ***/
  {
    let base_striped_index = workgroup_id.x * 64u + local_id.x;
    {
      let striped_index = base_striped_index + 0u;
      var lm_val: vec2u;
      if ( striped_index < 6209u ) {
        lm_val = data[ striped_index ];
      }
      else {
        lm_val = vec2( 0u );
      }
      scratch[ striped_index - workgroup_id.x * 64u ] = lm_val;
    }
    {
      let striped_index = base_striped_index + 32u;
      var lm_val: vec2u;
      if ( striped_index < 6209u ) {
        lm_val = data[ striped_index ];
      }
      else {
        lm_val = vec2( 0u );
      }
      scratch[ striped_index - workgroup_id.x * 64u ] = lm_val;
    }
  }
  /*** end load_multiple ***/
  workgroupBarrier();
  /*** begin scan_raked ***/
  /*** begin (sequential scan of tile) ***/
  var value = scratch[ local_id.x * 2u ];
  {
    value = ( value + scratch[ local_id.x * 2u + 1u ] - min( value.y, scratch[ local_id.x * 2u + 1u ].x ) );
    scratch[ local_id.x * 2u + 1u ] = value;
  }
  /*** end (sequential scan of tile) ***/
  workgroupBarrier();
  /*** begin scan direction:left exclusive:false ***/
  if ( local_id.x >= 1u ) {
    value = ( scratch[ ( local_id.x - 1u ) * 2u + 1u ] + value - min( scratch[ ( local_id.x - 1u ) * 2u + 1u ].y, value.x ) );
  }
  workgroupBarrier();
  scratch[ ( local_id.x ) * 2u + 1u ] = value;
  workgroupBarrier();
  if ( local_id.x >= 2u ) {
    value = ( scratch[ ( local_id.x - 2u ) * 2u + 1u ] + value - min( scratch[ ( local_id.x - 2u ) * 2u + 1u ].y, value.x ) );
  }
  workgroupBarrier();
  scratch[ ( local_id.x ) * 2u + 1u ] = value;
  workgroupBarrier();
  if ( local_id.x >= 4u ) {
    value = ( scratch[ ( local_id.x - 4u ) * 2u + 1u ] + value - min( scratch[ ( local_id.x - 4u ) * 2u + 1u ].y, value.x ) );
  }
  workgroupBarrier();
  scratch[ ( local_id.x ) * 2u + 1u ] = value;
  workgroupBarrier();
  if ( local_id.x >= 8u ) {
    value = ( scratch[ ( local_id.x - 8u ) * 2u + 1u ] + value - min( scratch[ ( local_id.x - 8u ) * 2u + 1u ].y, value.x ) );
  }
  workgroupBarrier();
  scratch[ ( local_id.x ) * 2u + 1u ] = value;
  workgroupBarrier();
  if ( local_id.x >= 16u ) {
    value = ( scratch[ ( local_id.x - 16u ) * 2u + 1u ] + value - min( scratch[ ( local_id.x - 16u ) * 2u + 1u ].y, value.x ) );
  }
  workgroupBarrier();
  scratch[ ( local_id.x ) * 2u + 1u ] = value;
  /*** end scan ***/
  workgroupBarrier();
  /*** begin (add scanned values to tile) ***/
  var added_value = select( vec2( 0u ), scratch[ local_id.x * 2u - 1u ], local_id.x > 0 );
  /*** begin (get global added values) ***/
  var workgroup_added_value: vec2u;
  if ( local_id.x == 0u ) {
    var middle_value: vec2u;
    var lower_value: vec2u;
    if ( workgroup_id.x % 64u == 0u ) {
      middle_value = vec2( 0u );
    }
    else {
      middle_value = scanned_reduction[ workgroup_id.x - 1u ];
    }
    let lower_index = workgroup_id.x / 64u;
    if ( lower_index % 64u == 0u ) {
      lower_value = vec2( 0u );
    }
    else {
      lower_value = double_scanned_reduction[ lower_index - 1u ];
    }
    reduction_value = ( lower_value + middle_value - min( lower_value.y, middle_value.x ) );
  }
  workgroupBarrier();
  workgroup_added_value = reduction_value;
  workgroupBarrier();
  {
    let last_value = scratch[ local_id.x * 2u + 1u ];
    var new_last_value: vec2u;
    new_last_value = ( workgroup_added_value + last_value - min( workgroup_added_value.y, last_value.x ) );
    scratch[ local_id.x * 2u + 1u ] = new_last_value;
  }
  added_value = ( workgroup_added_value + added_value - min( workgroup_added_value.y, added_value.x ) );
  /*** end (get global added values) ***/
  {
    let index = local_id.x * 2u + 0u;
    var current_value: vec2u;
    current_value = ( added_value + scratch[ index ] - min( added_value.y, scratch[ index ].x ) );
    scratch[ index ] = current_value;
  }
  /*** end (add scanned values to tile) ***/
  /*** end scan_raked ***/
  workgroupBarrier();
  /*** begin (output write) ***/
  {
    let coalesced_local_index = 0u + local_id.x;
    let coalesced_data_index = workgroup_id.x * 64u + coalesced_local_index;
    if ( coalesced_data_index < 6209u ) {
      data[ coalesced_data_index ] = scratch[ coalesced_local_index ];
    }
  }
  {
    let coalesced_local_index = 32u + local_id.x;
    let coalesced_data_index = workgroup_id.x * 64u + coalesced_local_index;
    if ( coalesced_data_index < 6209u ) {
      data[ coalesced_data_index ] = scratch[ coalesced_local_index ];
    }
  }
  /*** end (output write) ***/
  /*** end scan_comprehensive ***/
}
