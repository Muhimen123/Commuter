import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/features/auth/domain/auth_notifier.dart';

class TrustedContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? linkedUserId;
  final String status; // 'pending', 'accepted', 'rejected'
  final bool isIncoming; // True if current user is the recipient

  TrustedContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.linkedUserId,
    required this.status,
    this.isIncoming = false,
  });

  factory TrustedContact.fromMap(Map<String, dynamic> map, String currentUserId) {
    return TrustedContact(
      id: map['id'],
      name: map['contact_name'],
      phoneNumber: map['contact_phone_number'],
      linkedUserId: map['linked_user_id'],
      status: map['status'] ?? 'accepted',
      isIncoming: map['linked_user_id'] == currentUserId && map['owner_user_id'] != currentUserId,
    );
  }
}

class TrustedContactsNotifier extends StateNotifier<AsyncValue<List<TrustedContact>>> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Ref _ref;

  TrustedContactsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadContacts();
  }

  Future<void> loadContacts() async {
    final userId = _ref.read(authProvider).valueOrNull?.id;
    if (userId == null) return;

    state = const AsyncValue.loading();
    try {
      // Fetch both outgoing and incoming contacts/invites
      final data = await _supabase
          .from('trusted_contacts')
          .select()
          .or('owner_user_id.eq.$userId,linked_user_id.eq.$userId');
      
      final contacts = (data as List)
          .map((m) => TrustedContact.fromMap(m, userId))
          .where((c) => c.status != 'rejected' && c.linkedUserId != userId) // Filter out rejected and self
          .toList();
          
      state = AsyncValue.data(contacts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendInvite(String phone) async {
    try {
      await _supabase.rpc('send_contact_invite', params: {
        'p_phone': phone,
      });
      await loadContacts();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> respondToInvite(String inviteId, bool accept) async {
    try {
      await _supabase.rpc('respond_to_invite', params: {
        'p_invite_id': inviteId,
        'p_accept': accept,
      });
      await loadContacts();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      await _supabase.from('trusted_contacts').delete().eq('id', id);
      await loadContacts();
    } catch (e) {
      // Handle error
    }
  }
}

final trustedContactsProvider = StateNotifierProvider<TrustedContactsNotifier, AsyncValue<List<TrustedContact>>>((ref) {
  return TrustedContactsNotifier(ref);
});
