import 'package:flutter/material.dart';
import 'package:multipiai_flutter/screens/login_screen.dart';
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
    _processInitialData();
    _initStore();
  }

    void _processInitialData() {
  for (var agent in widget.initialData) {
    final String? id = agent['agent_id']?.toString();
    final String? name = agent['agent_name']?.toString();

    if (id != null && id.isNotEmpty) {
      _agentIds.add(id);
    }

    if (name != null && name.isNotEmpty) {
      _agentNames.add(name);
    }
  }

  if (_agentIds.isNotEmpty) {
    _activeAgentId = _agentIds.first;
    _store.agents
      ..clear()
      ..addAll(_agentIds);
  }
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

  Future<void> _logout(BuildContext context) async {
  await _store.clearAll(); // clear chats / local data

  if (!mounted) return;

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const PhoneLoginPage()),
    (_) => false,
  );
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
        onLogout: () => _logout(context),
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
