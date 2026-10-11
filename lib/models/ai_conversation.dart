/// Matches the existing `ai_conversations` table exactly.
class AiConversation {
  final String id;
  final String catId;
  final String userId;
  final String question;
  final String aiResponse;
  final DateTime createdAt;

  const AiConversation({
    required this.id,
    required this.catId,
    required this.userId,
    required this.question,
    required this.aiResponse,
    required this.createdAt,
  });

  factory AiConversation.fromMap(Map<String, dynamic> map) {
    return AiConversation(
      id: map['id'] as String,
      catId: map['cat_id'] as String,
      userId: map['user_id'] as String,
      question: map['question'] as String? ?? '',
      aiResponse: map['ai_response'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'cat_id': catId,
      'user_id': userId,
      'question': question,
      'ai_response': aiResponse,
    };
  }
}
