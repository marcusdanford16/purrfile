import 'package:flutter/material.dart';

import '../../models/ai_conversation.dart';
import '../../models/cat.dart';
import '../../models/health_record.dart';
import '../../services/ai_service.dart';
import '../../services/health_record_service.dart';
import '../../utils/app_spacing.dart';
import '../../widgets/cat_avatar.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/date_field.dart';
import '../../widgets/screen_header.dart';

const _suggestedQuestions = [
  'When is my next vaccination due?',
  'Summarize records',
  'Any diet tips?',
];

class AiAssistantScreen extends StatefulWidget {
  final Cat cat;

  const AiAssistantScreen({super.key, required this.cat});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _aiService = AiService();
  final _recordService = HealthRecordService();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  List<AiConversation> _conversations = [];
  List<HealthRecord> _records = [];
  bool _loadingHistory = true;
  bool _sending = false;
  String? _pendingQuestion;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loadingHistory = true);
    final conversations = await _aiService.getConversations(widget.cat.id);
    List<HealthRecord> records = [];
    try {
      records = await _recordService.getRecordsForCat(widget.cat.id);
    } catch (_) {
      // Records are optional context for the assistant — proceed without
      // them rather than blocking the chat screen from opening.
    }
    setState(() {
      _conversations = conversations;
      _records = records;
      _loadingHistory = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? preset]) async {
    final question = (preset ?? _inputController.text).trim();
    if (question.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _pendingQuestion = question;
      _error = null;
      _inputController.clear();
    });
    _scrollToBottom();
    try {
      final convo = await _aiService.ask(
        cat: widget.cat,
        question: question,
        records: _records,
      );
      setState(() => _conversations = [..._conversations, convo]);
      _scrollToBottom();
    } catch (e) {
      // Put the question back so the user doesn't have to retype it.
      _inputController.text = question;
      setState(() => _error = 'Could not get a response. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
          _pendingQuestion = null;
        });
      }
    }
  }

  /// Chat rows before any in-flight message: the greeting when the history
  /// is empty, otherwise one question + one answer per saved conversation.
  int get _baseItemCount =>
      _conversations.isEmpty ? 1 : _conversations.length * 2;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final name = widget.cat.name;

    return Scaffold(
      body: Column(
        children: [
          PurrHeader(
            leading: CatAvatar(cat: widget.cat, size: 44),
            title: 'AI Health Assistant',
            subtitle: name,
          ),
          // Medical disclaimer: always visible, calm, never alarming.
          Container(
            margin: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.sm + 4),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: AppRadius.md,
              border: Border.all(color: scheme.tertiary),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    color: scheme.onTertiaryContainer, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    "This assistant gives general information based on $name's "
                    "records. It doesn't replace professional veterinary advice — for "
                    "urgent or specific concerns, please consult your vet.",
                    style: text.bodySmall
                        ?.copyWith(color: scheme.onTertiaryContainer),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    itemCount: _baseItemCount + (_sending ? 2 : 0),
                    itemBuilder: (context, i) {
                      // The question being sent, then the typing dots.
                      if (i >= _baseItemCount) {
                        return i == _baseItemCount
                            ? ChatBubble(
                                isUser: true,
                                message: _pendingQuestion ?? '',
                              )
                            : const TypingBubble();
                      }
                      if (_conversations.isEmpty) {
                        return ChatBubble(
                          isUser: false,
                          message:
                              "Hi! I'm your AI Health Assistant for $name. Ask me "
                              "about vaccinations, medications, or general care — "
                              "I'll use $name's stored records to help.",
                        );
                      }
                      final convo = _conversations[i ~/ 2];
                      final isQuestion = i.isEven;
                      return ChatBubble(
                        message: isQuestion ? convo.question : convo.aiResponse,
                        isUser: isQuestion,
                      );
                    },
                  ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
              child: FormErrorBox(_error!),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: _suggestedQuestions
                  .map((q) => Padding(
                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                        child: ActionChip(
                          avatar: Icon(Icons.auto_awesome,
                              size: 16, color: scheme.primary),
                          label: Text(q),
                          onPressed: _sending ? null : () => _send(q),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: "Ask anything about your cat's health…",
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg - 4,
                          vertical: AppSpacing.md - 2),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.pill,
                        borderSide: BorderSide(color: scheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.pill,
                        borderSide:
                            BorderSide(color: scheme.primary, width: 2),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.pill,
                        borderSide: BorderSide(color: scheme.outlineVariant),
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                    enabled: !_sending,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  onPressed: _sending ? null : () => _send(),
                  tooltip: 'Send',
                  style: IconButton.styleFrom(
                      minimumSize: const Size.square(52)),
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
