@group(0) @binding(0)
var<storage, read_write> data: array<u32, 131072>;
@group(0) @binding(1)
var<storage, read> scanned_reduction: array<u32, 512>;
@group(0) @binding(2)
var<storage, read> double_scanned_reduction: array<u32, 2>;
var<workgroup> reduction_value: u32;
var<workgroup> scratch: array<u32, 256>;
@compute @workgroup_size(64)
fn main(
  @builtin(global_invocation_id) global_id: vec3u,
  @builtin(local_invocation_id) local_id: vec3u,
  @builtin(workgroup_id) workgroup_id: vec3u
) {
  /*** begin scan_comprehensive exclusive ***/
  /*** begin load_multiple ***/
  {
    let base_striped_index = workgroup_id.x * 256u + local_id.x;
    {
      let striped_index = base_striped_index + 0u;
      var lm_val: u32;
      if ( striped_index < ( ( ( ( 131045u ) + 255u ) / 256u ) << 8u ) ) {
        lm_val = data[ striped_index ];
      }
      else {
        lm_val = 0u;
      }
      scratch[ striped_index - workgroup_id.x * 256u ] = lm_val;
    }
    {
      let striped_index = base_striped_index + 64u;
      var lm_val: u32;
      if ( striped_index < ( ( ( ( 131045u ) + 255u ) / 256u ) << 8u ) ) {
        lm_val = data[ striped_index ];
      }
      else {
        lm_val = 0u;
      }
      scratch[ striped_index - workgroup_id.x * 256u ] = lm_val;
    }
    {
      let striped_index = base_striped_index + 128u;
      var lm_val: u32;
      if ( striped_index < ( ( ( ( 131045u ) + 255u ) / 256u ) << 8u ) ) {
        lm_val = data[ striped_index ];
      }
      else {
        lm_val = 0u;
      }
      scratch[ striped_index - workgroup_id.x * 256u ] = lm_val;
    }
    {
      let striped_index = base_striped_index + 192u;
      var lm_val: u32;
      if ( striped_index < ( ( ( ( 131045u ) + 255u ) / 256u ) << 8u ) ) {
        lm_val = data[ striped_index ];
      }
      else {
        lm_val = 0u;
      }
      scratch[ striped_index - workgroup_id.x * 256u ] = lm_val;
    }
  }
  /*** end load_multiple ***/
  workgroupBarrier();
  /*** begin scan_raked ***/
  /*** begin (sequential scan of tile) ***/
  var value = scratch[ local_id.x * 4u ];
  {
    value = ( value + scratch[ local_id.x * 4u + 1u ] );
    scratch[ local_id.x * 4u + 1u ] = value;
  }
  {
    value = ( value + scratch[ local_id.x * 4u + 2u ] );
    scratch[ local_id.x * 4u + 2u ] = value;
  }
  {
    value = ( value + scratch[ local_id.x * 4u + 3u ] );
    scratch[ local_id.x * 4u + 3u ] = value;
  }
  /*** end (sequential scan of tile) ***/
  workgroupBarrier();
  /*** begin scan direction:left exclusive:false ***/
  if ( local_id.x >= 1u ) {
    value = ( scratch[ ( local_id.x - 1u ) * 4u + 3u ] + value );
  }
  workgroupBarrier();
  scratch[ ( local_id.x ) * 4u + 3u ] = value;
  workgroupBarrier();
  if ( local_id.x >= 2u ) {
    value = ( scratch[ ( local_id.x - 2u ) * 4u + 3u ] + value );
  }
  workgroupBarrier();
  scratch[ ( local_id.x ) * 4u + 3u ] = value;
  workgroupBarrier();
  if ( local_id.x >= 4u ) {
    value = ( scratch[ ( local_id.x - 4u ) * 4u + 3u ] + value );
  }
  workgroupBarrier();
  scratch[ ( local_id.x ) * 4u + 3u ] = value;
  workgroupBarrier();
  if ( local_id.x >= 8u ) {
    value = ( scratch[ ( local_id.x - 8u ) * 4u + 3u ] + value );
  }
  workgroupBarrier();
  scratch[ ( local_id.x ) * 4u + 3u ] = value;
  workgroupBarrier();
  if ( local_id.x >= 16u ) {
    value = ( scratch[ ( local_id.x - 16u ) * 4u + 3u ] + value );
  }
  workgroupBarrier();
  scratch[ ( local_id.x ) * 4u + 3u ] = value;
  workgroupBarrier();
  if ( local_id.x >= 32u ) {
    value = ( scratch[ ( local_id.x - 32u ) * 4u + 3u ] + value );
  }
  workgroupBarrier();
  scratch[ ( local_id.x ) * 4u + 3u ] = value;
  /*** end scan ***/
  workgroupBarrier();
  /*** begin (add scanned values to tile) ***/
  var added_value = select( 0u, scratch[ local_id.x * 4u - 1u ], local_id.x > 0 );
  /*** begin (get global added values) ***/
  var workgroup_added_value: u32;
  if ( local_id.x == 0u ) {
    let middle_value = scanned_reduction[ workgroup_id.x ];
    let lower_value = double_scanned_reduction[ workgroup_id.x / 256u ];
    reduction_value = ( lower_value + middle_value );
  }
  workgroupBarrier();
  workgroup_added_value = reduction_value;
  workgroupBarrier();
  {
    let last_value = scratch[ local_id.x * 4u + 3u ];
    var new_last_value: u32;
    new_last_value = ( workgroup_added_value + last_value );
    scratch[ local_id.x * 4u + 3u ] = new_last_value;
  }
  added_value = ( workgroup_added_value + added_value );
  /*** end (get global added values) ***/
  {
    let index = local_id.x * 4u + 0u;
    var current_value: u32;
    current_value = ( added_value + scratch[ index ] );
    scratch[ index ] = current_value;
  }
  {
    let index = local_id.x * 4u + 1u;
    var current_value: u32;
    current_value = ( added_value + scratch[ index ] );
    scratch[ index ] = current_value;
  }
  {
    let index = local_id.x * 4u + 2u;
    var current_value: u32;
    current_value = ( added_value + scratch[ index ] );
    scratch[ index ] = current_value;
  }
  /*** end (add scanned values to tile) ***/
  /*** end scan_raked ***/
  workgroupBarrier();
  /*** begin (output write) ***/
  {
    let coalesced_local_index = 0u + local_id.x;
    let coalesced_data_index = workgroup_id.x * 256u + coalesced_local_index;
    if ( coalesced_data_index < ( ( ( ( 131045u ) + 255u ) / 256u ) << 8u ) ) {
      data[ coalesced_data_index ] = select( workgroup_added_value, scratch[ coalesced_local_index - 1u ], coalesced_local_index > 0u );
    }
  }
  {
    let coalesced_local_index = 64u + local_id.x;
    let coalesced_data_index = workgroup_id.x * 256u + coalesced_local_index;
    if ( coalesced_data_index < ( ( ( ( 131045u ) + 255u ) / 256u ) << 8u ) ) {
      data[ coalesced_data_index ] = select( workgroup_added_value, scratch[ coalesced_local_index - 1u ], coalesced_local_index > 0u );
    }
  }
  {
    let coalesced_local_index = 128u + local_id.x;
    let coalesced_data_index = workgroup_id.x * 256u + coalesced_local_index;
    if ( coalesced_data_index < ( ( ( ( 131045u ) + 255u ) / 256u ) << 8u ) ) {
      data[ coalesced_data_index ] = select( workgroup_added_value, scratch[ coalesced_local_index - 1u ], coalesced_local_index > 0u );
    }
  }
  {
    let coalesced_local_index = 192u + local_id.x;
    let coalesced_data_index = workgroup_id.x * 256u + coalesced_local_index;
    if ( coalesced_data_index < ( ( ( ( 131045u ) + 255u ) / 256u ) << 8u ) ) {
      data[ coalesced_data_index ] = select( workgroup_added_value, scratch[ coalesced_local_index - 1u ], coalesced_local_index > 0u );
    }
  }
  /*** end (output write) ***/
  /*** end scan_comprehensive ***/
}
