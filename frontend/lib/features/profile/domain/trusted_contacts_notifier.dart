import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/features/auth/domain/auth_notifier.dart';

class TrustedContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? linkedUserId;
  final String status;
  final bool isIncoming;

  TrustedContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.linkedUserId,
    required this.status,
    this.isIncoming = false,
  });

  factory TrustedContact.fromMap(Map<String, dynamic> map, String currentUserId) {
    // If current user is the owner, this is an outgoing contact/invite
    final bool isOwner = map['owner_user_id'] == currentUserId;
    
    // If I'm the owner, 'contact_name' is the other person's name.
    // If I'm NOT the owner (recipient), 'contact_name' is MY name in the other person's DB row,
    // so we must use the joined 'users' (owner) data to get the sender's name.
    String displayName = map['contact_name'] ?? 'Unknown';
    if (!isOwner && map['users'] != null) {
      displayName = map['users']['full_name'] ?? displayName;
    }

    return TrustedContact(
      id: map['id'],
      name: displayName,
      phoneNumber: map['contact_phone_number'] ?? '',
      linkedUserId: map['linked_user_id'],
      status: map['status'] ?? 'accepted',
      isIncoming: !isOwner,
    );
  }
}

class TrustedContactsNotifier extends StateNotifier<AsyncValue<List<TrustedContact>>> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Ref _ref;
  RealtimeChannel? _subscription;

  TrustedContactsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadContacts();
  }

  Future<void> loadContacts() async {
    final userId = _ref.read(authProvider).valueOrNull?.id;
    if (userId == null) return;

    if (_subscription == null) _listenToChanges(userId);

    try {
      // Query joins with 'users' (aliased by foreign key) to get the sender's real name for incoming requests
      final data = await _supabase
          .from('trusted_contacts')
          .select('*, users:owner_user_id(full_name)')
          .or('owner_user_id.eq.$userId,linked_user_id.eq.$userId');
      
      final contacts = (data as List)
          .map((m) => TrustedContact.fromMap(m, userId))
          .where((c) => c.status != 'rejected')
          .toList();
          
      state = AsyncValue.data(contacts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _listenToChanges(String userId) {
    _subscription = _supabase
        .channel('public:trusted_contacts')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'trusted_contacts',
          callback: (_) => loadContacts(),
        )
        .subscribe();
  }

  Future<void> sendInvite(String phone) async {
    try {
      await _supabase.rpc('send_contact_invite', params: {'p_phone': phone});
      await loadContacts();
    } catch (e) {
      rethrow;
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

  /// Cancels a pending outgoing request
  Future<void> cancelInvite(String inviteId) async {
    try {
      await _supabase.from('trusted_contacts').delete().eq('id', inviteId).eq('status', 'pending');
      await loadContacts();
    } catch (e) {
      // Handle error
    }
  }

  /// Mutually removes a contact
  Future<void> deleteContact(String id) async {
    try {
      await _supabase.rpc('remove_trusted_contact', params: {'p_contact_id': id});
      await loadContacts();
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}

final trustedContactsProvider = StateNotifierProvider<TrustedContactsNotifier, AsyncValue<List<TrustedContact>>>((ref) {
  return TrustedContactsNotifier(ref);
});
