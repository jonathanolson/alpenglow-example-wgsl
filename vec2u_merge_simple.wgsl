@group(0) @binding(0)
var<storage, read> a: array<vec2u, 1300>;
@group(0) @binding(1)
var<storage, read> b: array<vec2u, 1000>;
@group(0) @binding(2)
var<storage, read_write> c: array<vec2u, 2300>;
@compute @workgroup_size(64)
fn main(
  @builtin(global_invocation_id) global_id: vec3u,
  @builtin(local_invocation_id) local_id: vec3u,
  @builtin(workgroup_id) workgroup_id: vec3u
) {
  /*** begin merge_simple ***/
  {
    let max_output = 1300u + 1000u;
    let start_output = min( max_output, global_id.x * 8u );
    let end_output = min( max_output, start_output + 8u );
    if ( start_output != end_output ) {
      /*** begin get_corank ***/
      var start_a = min( start_output, 1300u );
      {
        var gc_j = start_output - start_a;
        var gc_i_low: u32 = select( start_output - 1000u, 0u, start_output <= 1000u );
        var gc_j_low = select( start_output - 1300u, 0u, start_output <= 1300u );
        var gc_delta: u32;
        var oops_count_corank = 0u;
        while ( true ) {
          oops_count_corank++;
          if ( oops_count_corank > 0xffu ) {
            break;
          }
          if ( start_a > 0u && gc_j < 1000u && ( a[ start_a - 1u ].x > b[ gc_j ].x || ( a[ start_a - 1u ].x == b[ gc_j ].x && a[ start_a - 1u ].y > b[ gc_j ].y ) ) ) {
            gc_delta = ( start_a - gc_i_low + 1u ) >> 1u;
            gc_j_low = gc_j;
            gc_j = gc_j + gc_delta;
            start_a = start_a - gc_delta;
          }
          else if ( gc_j > 0u && start_a < 1300u && ( a[ start_a ].x <= b[ gc_j - 1u ].x && ( a[ start_a ].x != b[ gc_j - 1u ].x || a[ start_a ].y <= b[ gc_j - 1u ].y ) ) ) {
            gc_delta = ( gc_j - gc_j_low + 1u ) >> 1u;
            gc_i_low = start_a;
            start_a = start_a + gc_delta;
            gc_j = gc_j - gc_delta;
          }
          else {
            break;
          }
        }
      }
      /*** end get_corank ***/
      /*** begin get_corank ***/
      var end_a = min( end_output, 1300u );
      {
        var gc_j = end_output - end_a;
        var gc_i_low: u32 = select( end_output - 1000u, 0u, end_output <= 1000u );
        var gc_j_low = select( end_output - 1300u, 0u, end_output <= 1300u );
        var gc_delta: u32;
        var oops_count_corank = 0u;
        while ( true ) {
          oops_count_corank++;
          if ( oops_count_corank > 0xffu ) {
            break;
          }
          if ( end_a > 0u && gc_j < 1000u && ( a[ end_a - 1u ].x > b[ gc_j ].x || ( a[ end_a - 1u ].x == b[ gc_j ].x && a[ end_a - 1u ].y > b[ gc_j ].y ) ) ) {
            gc_delta = ( end_a - gc_i_low + 1u ) >> 1u;
            gc_j_low = gc_j;
            gc_j = gc_j + gc_delta;
            end_a = end_a - gc_delta;
          }
          else if ( gc_j > 0u && end_a < 1300u && ( a[ end_a ].x <= b[ gc_j - 1u ].x && ( a[ end_a ].x != b[ gc_j - 1u ].x || a[ end_a ].y <= b[ gc_j - 1u ].y ) ) ) {
            gc_delta = ( gc_j - gc_j_low + 1u ) >> 1u;
            gc_i_low = end_a;
            end_a = end_a + gc_delta;
            gc_j = gc_j - gc_delta;
          }
          else {
            break;
          }
        }
      }
      /*** end get_corank ***/
      let start_b = start_output - start_a;
      let end_b = end_output - end_a;
      let span_a = end_a - start_a;
      let span_b = end_b - start_b;
      /*** begin merge_sequential ***/
      {
        var ms_i = 0u;
        var ms_j = 0u;
        var ms_k = 0u;
        var oops_count = 0u;
        while ( ms_i < span_a && ms_j < span_b ) {
          oops_count++;
          if ( oops_count > 0xffu ) {
            break;
          }
          if ( select( select( select( select( 0i, 1i, a[ start_a + ms_i ].y > b[ start_b + ms_j ].y ), -1i, a[ start_a + ms_i ].y < b[ start_b + ms_j ].y ), 1i, a[ start_a + ms_i ].x > b[ start_b + ms_j ].x ), -1i, a[ start_a + ms_i ].x < b[ start_b + ms_j ].x ) <= 0i ) {
            c[ start_output + ms_k ] = a[ start_a + ms_i ];
            ms_i++;
          }
          else {
            c[ start_output + ms_k ] = b[ start_b + ms_j ];
            ms_j++;
          }
          ms_k++;
        }
        while ( ms_i < span_a ) {
          oops_count++;
          if ( oops_count > 0xffu ) {
            break;
          }
          c[ start_output + ms_k ] = a[ start_a + ms_i ];
          ms_i++;
          ms_k++;
        }
        while ( ms_j < span_b ) {
          oops_count++;
          if ( oops_count > 0xffu ) {
            break;
          }
          c[ start_output + ms_k ] = b[ start_b + ms_j ];
          ms_j++;
          ms_k++;
        }
      }
      /*** end merge_sequential ***/
    }
  }
  /*** end merge_simple ***/
}
