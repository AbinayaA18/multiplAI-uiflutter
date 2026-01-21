import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';
import '../services/chat_store.dart';
import '../services/api_service.dart';
import '../widgets/chat_message_tile.dart';
import '../widgets/chat_input.dart';
import '../widgets/multipiai_drawer.dart';
import '../widgets/multipiai_app_bar.dart';

class ChatScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialData;
  const ChatScreen({super.key, required this.initialData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatStore _store = ChatStore();
  final List<String> _agentIds = [];
  final List<String> _agentNames = [];
  String _activeAgentId = '';
  bool _loading = true;

  bool _showHeaderSearch = false;
  final TextEditingController _headerSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // final List<String> ids = [];
    // final List<String> names = [];

    // for (var agent in widget.initialData) {
    //   final agentIdList = agent['agent_id'];
    //   final agentNameList = agent['agent_name'];

    //   ids.addAll(agentIdList.map((e) => e.toString()));
    //   names.addAll(agentNameList.map((e) => e.toString()));
    // }

    // if (ids.isNotEmpty) {
    //   _agentIds.addAll(ids);
    //   _agentNames.addAll(names);

    //   _activeAgentId = _agentIds.first;

    //   _store.agents
    //     ..clear()
    //     ..addAll(_agentIds);
    // }
    //   _agentNames.addAll(
    //   widget.initialData.map((agent) => agent['agent_name'].toString())
    // );

    // if (_agentNames.isNotEmpty) {
    //   // _activeAgentId = _agentNames.first;
    //   _store.agents
    //     ..clear()
    //     ..addAll(_agentNames); // you can treat agent_name as identifier
    // }

    // _agentIds.addAll(widget.initialData.map((agent) => agent['agent_id'].toString()));

    // if (_agentIds.isNotEmpty) {
    //   _activeAgentId = _agentIds.first;
    //   _store.agents
    //     ..clear()
    //     ..addAll(_agentIds); // you can treat agent_id as identifier
    // }

    _processInitialData();
    _initStore();
  }

    void _processInitialData() {
    for (var agent in widget.initialData) {
      // Safely get agent_id and agent_name as List<String>
      final ids = safeStringList(agent['agent_id']);
      print(ids);
      final names = safeStringList(agent['agent_name']);
      print(names);

      _agentIds.addAll(ids);
      _agentNames.addAll(names);
    }

    if (_agentIds.isNotEmpty) {
      _activeAgentId = _agentIds.first;
      _store.agents
        ..clear()
        ..addAll(_agentIds);
    }
  }

List<String> safeStringList(dynamic value) {
  if (value == null) return [];

  // If it's already a list, map to string
  if (value is List) return value.map((e) => e.toString()).toList();

  // If it's a JSON string representing a list
  if (value is String) {
    try {
      final parsed = jsonDecode(value);
      if (parsed is List) return parsed.map((e) => e.toString()).toList();
    } catch (e) {
      // not valid JSON, fallback
      return [];
    }
  }

  return [];
}




  Future<void> _initStore() async {
    await _store.load();
    setState(() {
      _loading = false;
    });
  }

  List<dynamic> _safeList(dynamic value) {
    if (value is List) return value;
    return [];
  }


  Future<void> _send(String text) async {
    await _store.addUserMessage(_activeAgentId, text);
    setState(() {}); // refresh after user message

    final reply =
        await ApiService.sendMessage(agentId: _activeAgentId, text: text);
    await _store.addAgentMessage(_activeAgentId, reply);
    setState(() {}); // refresh after agent message
  }

  void _onAgentSelected(String id) {
    setState(() {
      _activeAgentId = id;
    });
  }

  void _handleAddAgent(String name) {
    final id = name.toLowerCase().replaceAll(' ', '_');

    if (_agentIds.contains(id)) return;

    setState(() {
      _agentIds.add(id);
      _agentNames.add(name);
      _store.agents.add(id);
    });
    //print(_agentNames);
  }

  @override
  Widget build(BuildContext context) {
    final messages = _store.messagesForAgent(_activeAgentId);

    return Scaffold(
      drawer: MultipiaiDrawer(
        agentIds: _agentIds,
        agentNames: _agentNames,
        activeAgentId: _activeAgentId,
        onAgentSelected: _onAgentSelected,
        onAddAgent: _handleAddAgent,
      ),
      appBar: MultipiaiAppBar(
        onSearchTap: () {
          setState(() {
            _showHeaderSearch = !_showHeaderSearch;
          });
        },
      ),
      body: Column(
        children: [
          // header search under app bar
          if (_showHeaderSearch)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _headerSearchController,
                decoration: InputDecoration(
                  hintText: 'Search in chats',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF00C271), // green icon
                  ),
                  suffixIcon: _headerSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _headerSearchController.clear();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) {
                  setState(() {}); // later you can filter messages
                },
              ),
            ),

          // THIS Expanded keeps the input bar at the bottom
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return ChatMessageTile(message: messages[index]);
                        },
                      ),
          ),

          // bottom input bar
          ChatInput(onSend: _send),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 40,
              color: Color(0xFF00C271),
            ),
            SizedBox(height: 16),
            Text(
              'Chats in this project\nwill be visible here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
