import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ai_conversation.dart';
import '../models/cat.dart';
import '../models/health_record.dart';
import 'supabase_service.dart';

/// AI Health Assistant — stretch feature.
///
/// Architecture: Flutter → Supabase Edge Function (`ai-health-assistant`) →
/// AI provider → Edge Function → Flutter. The AI API key lives only in the
/// Edge Function's server-side secrets; it never reaches this client.
///
/// If the Edge Function isn't deployed/reachable yet, [ask] falls back to a
/// deterministic mock so the chat screen still works end-to-end for
/// demonstration. The public API is identical either way, so swapping in a
/// real provider later means changing `_callEdgeFunction`, not the chat UI.
class AiService {
  final SupabaseClient _client = SupabaseService.client;
  final Random _rand = Random();

  static const String disclaimer =
      "This is general information, not a veterinary diagnosis. For urgent "
      "or specific concerns, please contact your vet.";

  String get _uid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw 'You must be logged in.';
    return uid;
  }

  Future<List<AiConversation>> getConversations(String catId) async {
    try {
      final rows = await _client
          .from('ai_conversations')
          .select()
          .eq('cat_id', catId)
          .eq('user_id', _uid)
          .order('created_at', ascending: true);
      return (rows as List)
          .map((r) => AiConversation.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Conversation history failing to load shouldn't block asking a new
      // question, so surface an empty history rather than throwing.
      return [];
    }
  }

  /// Sends [question] for [cat], optionally summarizing [records] for
  /// context, saves the exchange to `ai_conversations`, and returns the
  /// saved conversation.
  Future<AiConversation> ask({
    required Cat cat,
    required String question,
    List<HealthRecord> records = const [],
  }) async {
    final answer = await _callEdgeFunction(
      cat: cat,
      question: question,
      records: records,
    );

    try {
      final row = await _client
          .from('ai_conversations')
          .insert(AiConversation(
            id: '',
            catId: cat.id,
            userId: _uid,
            question: question,
            aiResponse: answer,
            createdAt: DateTime.now(),
          ).toInsertMap())
          .select()
          .single();
      return AiConversation.fromMap(row);
    } catch (e) {
      // Saving failed, but the person still asked a question and deserves an
      // answer — return an unsaved conversation instead of throwing.
      return AiConversation(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        catId: cat.id,
        userId: _uid,
        question: question,
        aiResponse: answer,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<String> _callEdgeFunction({
    required Cat cat,
    required String question,
    required List<HealthRecord> records,
  }) async {
    try {
      final res = await _client.functions.invoke(
        'ai-health-assistant',
        body: {
          'catName': cat.name,
          'breed': cat.breed,
          'question': question,
          'recentRecords': records
              .take(10)
              .map((r) => {
                    'type': r.recordType.label,
                    'date': r.date.toIso8601String().split('T').first,
                    'description': r.description,
                  })
              .toList(),
        },
      );
      final data = res.data;
      if (data is Map && data['answer'] is String) {
        return '${data['answer']}\n\n$disclaimer';
      }
      return _mockAnswer(cat: cat, question: question, records: records);
    } catch (e) {
      // Edge Function not deployed / network unavailable / provider error —
      // degrade gracefully to the mock rather than crashing the chat screen.
      return _mockAnswer(cat: cat, question: question, records: records);
    }
  }

  String _mockAnswer({
    required Cat cat,
    required String question,
    required List<HealthRecord> records,
  }) {
    final q = question.toLowerCase();

    if (q.contains('vaccin')) {
      final upcoming = records
          .where((r) => r.recordType == RecordType.vaccination)
          .toList();
      if (upcoming.isNotEmpty) {
        final latest = upcoming.first;
        return "${cat.name}'s most recent vaccination on record is "
            "${latest.description ?? 'a vaccination'} "
            "(${latest.date.toIso8601String().split('T').first}). "
            "Check the Reminders tab for the next due date.\n\n$disclaimer";
      }
      return "I don't see any vaccination records for ${cat.name} yet. "
          "Add one from the Health Timeline so I can track it.\n\n$disclaimer";
    }

    if (q.contains('weight') || q.contains('diet') || q.contains('food')) {
      final weights =
          records.where((r) => r.recordType == RecordType.weight).toList();
      if (weights.isNotEmpty) {
        return "${cat.name}'s most recent recorded weight was on "
            "${weights.first.date.toIso8601String().split('T').first}. "
            "A vet can advise on a target weight and feeding plan based on "
            "breed and body condition.\n\n$disclaimer";
      }
      return "I don't have any weight records for ${cat.name} yet. "
          "In general, adult cats do well with consistent portions split "
          "into two or three meals a day.\n\n$disclaimer";
    }

    if (q.contains('summar')) {
      if (records.isEmpty) {
        return "${cat.name} doesn't have any health records yet. Once you "
            "add some to the Health Timeline, I can summarize them "
            "here.\n\n$disclaimer";
      }
      final byType = <String, int>{};
      for (final r in records) {
        byType[r.recordType.label] = (byType[r.recordType.label] ?? 0) + 1;
      }
      final parts =
          byType.entries.map((e) => '${e.value} ${e.key}').join(', ');
      return "${cat.name} has ${records.length} record(s) on file: "
          "$parts.\n\n$disclaimer";
    }

    // Generic fallback so the demo never feels stuck.
    final openers = [
      "That's a good question about ${cat.name}.",
      "Here's some general guidance for ${cat.name}.",
      "Thanks for asking about ${cat.name}.",
    ];
    final opener = openers[_rand.nextInt(openers.length)];
    return "$opener I don't have a specific answer for that yet, but you "
        "can ask about vaccinations, weight, or say 'summarize records' to "
        "see what's on file.\n\n$disclaimer";
  }
}
