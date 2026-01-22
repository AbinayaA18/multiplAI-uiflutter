import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ChatStore {
  static const _storageKey = 'multipiai_messages_v1';

  final List<String> agents = [];

  List<ChatMessage> _messages = [];

  List<ChatMessage> messagesForAgent(String agentId) =>
      _messages.where((m) => m.agentId == agentId).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    final list = jsonDecode(raw) as List<dynamic>;
    _messages = list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _messages.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  Future<void> addUserMessage(String agentId, String text) async {
    _messages.add(
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        agentId: agentId,
        text: text,
        isUser: true,
        createdAt: DateTime.now(),
      ),
    );
    await _save();
  }

  Future<void> addAgentMessage(String agentId, String text) async {
    _messages.add(
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        agentId: agentId,
        text: text,
        isUser: false,
        createdAt: DateTime.now(),
      ),
    );
    await _save();
  }

   Future<void> clearAll() async {
    agents.clear();
    _messages.clear();
  }
}
