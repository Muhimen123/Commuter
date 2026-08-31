import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Test RPC sharing functions using client instance', () async {
    final client = SupabaseClient(
      'https://ouxasngydymysrhyfxuq.supabase.co',
      'sb_publishable_dxULb5_hC4yjLgJ51k44uQ_RZwxS9zu',
    );

    // 1. Start Sharing
    // PostgREST often has issues with named parameters in RPC calls.
    // Try sending parameters as a positional list if it fails,
    // or ensure the parameter names match EXACTLY the function definition.
    // The error shows it sees the function, but not the param matching.
    
    // Let's try sending all params to match the signature exactly.
    final result = await client.rpc('start_sharing_location', params: {
      'p_sharer_user_id': '00000000-0000-0000-0000-000000000001',
      'p_journey_id': '710dfeb3-3145-42b4-aff7-c0e9b4c2b55c',
      'p_recipient_user_id': null,
      'p_trusted_contact_id': null,
    });
    
    print('Started sharing: $result');
    expect(result, isNotNull);

    // 2. Stop Sharing
    final shareId = result['id'];
    final stopResult = await client.rpc('stop_sharing_location', params: {
      'p_share_id': shareId,
    });

    print('Stopped sharing: $stopResult');
    expect(stopResult['is_active'], false);
  });
}
