@group(0) @binding(0)
var<storage, read> input: array<vec2u, 9411>;
@group(0) @binding(1)
var<storage, read_write> output: array<vec2u, 148>;
var<workgroup> scratch: array<vec2u, 32>;
@compute @workgroup_size(32)
fn main(
  @builtin(global_invocation_id) global_id: vec3u,
  @builtin(local_invocation_id) local_id: vec3u,
  @builtin(workgroup_id) workgroup_id: vec3u
) {
  if ( local_id.x == 0u ) {
    scratch[ 0u ] = vec2( 0u );
  }
  let rn_length = 6209u;
  var value: vec2u;
  {
    let rn_index = workgroup_id.x * 64u + 0u + local_id.x;
    value = select( vec2( 0u ), input[ rn_index ], rn_index < rn_length );
    if ( local_id.x == 0u ) {
      value = ( scratch[ 0u ] + value - min( scratch[ 0u ].y, value.x ) );
    }
    /*** begin reduce convergent:false ***/
    scratch[ local_id.x ] = value;
    workgroupBarrier();
    if ( local_id.x % 2u == 0u ) {
      value = ( value + scratch[ local_id.x + 1u ] - min( value.y, scratch[ local_id.x + 1u ].x ) );
      scratch[ local_id.x ] = value;
    }
    workgroupBarrier();
    if ( local_id.x % 4u == 0u ) {
      value = ( value + scratch[ local_id.x + 2u ] - min( value.y, scratch[ local_id.x + 2u ].x ) );
      scratch[ local_id.x ] = value;
    }
    workgroupBarrier();
    if ( local_id.x % 8u == 0u ) {
      value = ( value + scratch[ local_id.x + 4u ] - min( value.y, scratch[ local_id.x + 4u ].x ) );
      scratch[ local_id.x ] = value;
    }
    workgroupBarrier();
    if ( local_id.x % 16u == 0u ) {
      value = ( value + scratch[ local_id.x + 8u ] - min( value.y, scratch[ local_id.x + 8u ].x ) );
      scratch[ local_id.x ] = value;
    }
    workgroupBarrier();
    if ( local_id.x % 32u == 0u ) {
      value = ( value + scratch[ local_id.x + 16u ] - min( value.y, scratch[ local_id.x + 16u ].x ) );
    }
    /*** end reduce ***/
    if ( local_id.x == 0u ) {
      scratch[ 0u ] = value;
    }
  }
  {
    let rn_index = workgroup_id.x * 64u + 32u + local_id.x;
    value = select( vec2( 0u ), input[ rn_index ], rn_index < rn_length );
    if ( local_id.x == 0u ) {
      value = ( scratch[ 0u ] + value - min( scratch[ 0u ].y, value.x ) );
    }
    /*** begin reduce convergent:false ***/
    scratch[ local_id.x ] = value;
    workgroupBarrier();
    if ( local_id.x % 2u == 0u ) {
      value = ( value + scratch[ local_id.x + 1u ] - min( value.y, scratch[ local_id.x + 1u ].x ) );
      scratch[ local_id.x ] = value;
    }
    workgroupBarrier();
    if ( local_id.x % 4u == 0u ) {
      value = ( value + scratch[ local_id.x + 2u ] - min( value.y, scratch[ local_id.x + 2u ].x ) );
      scratch[ local_id.x ] = value;
    }
    workgroupBarrier();
    if ( local_id.x % 8u == 0u ) {
      value = ( value + scratch[ local_id.x + 4u ] - min( value.y, scratch[ local_id.x + 4u ].x ) );
      scratch[ local_id.x ] = value;
    }
    workgroupBarrier();
    if ( local_id.x % 16u == 0u ) {
      value = ( value + scratch[ local_id.x + 8u ] - min( value.y, scratch[ local_id.x + 8u ].x ) );
      scratch[ local_id.x ] = value;
    }
    workgroupBarrier();
    if ( local_id.x % 32u == 0u ) {
      value = ( value + scratch[ local_id.x + 16u ] - min( value.y, scratch[ local_id.x + 16u ].x ) );
    }
    /*** end reduce ***/
  }
  if ( local_id.x == 0u ) {
    output[ workgroup_id.x ] = value;
  }
}
