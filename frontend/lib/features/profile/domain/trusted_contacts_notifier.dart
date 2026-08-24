import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/domain/auth_notifier.dart';

class TrustedContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? linkedUserId;

  TrustedContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.linkedUserId,
  });

  factory TrustedContact.fromMap(Map<String, dynamic> map) {
    return TrustedContact(
      id: map['id'],
      name: map['contact_name'],
      phoneNumber: map['contact_phone_number'],
      linkedUserId: map['linked_user_id'],
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
    final userId = _ref.read(authProvider).user?.id;
    if (userId == null) return;

    state = const AsyncValue.loading();
    try {
      final data = await _supabase
          .from('trusted_contacts')
          .select()
          .eq('owner_user_id', userId);
      
      final contacts = (data as List)
          .map((m) => TrustedContact.fromMap(m))
          .toList();
          
      state = AsyncValue.data(contacts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addContact(String name, String phone) async {
    try {
      // Use the RPC function we created earlier that links users automatically
      await _supabase.rpc('add_trusted_contact_linked', params: {
        'p_name': name,
        'p_phone': phone,
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
