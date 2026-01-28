import 'package:flutter/material.dart';

typedef AgentSelectCallback = void Function(String agentId);
typedef AddAgentCallback = void Function(String agentName);
typedef LogoutCallback = void Function();


class MultipiaiDrawer extends StatefulWidget {
  final List<String> agentIds;
  final List<String> agentNames;
  final String activeAgentId;
  final AgentSelectCallback onAgentSelected;
  final AddAgentCallback onAddAgent;
  final LogoutCallback onLogout;



  const MultipiaiDrawer({
    super.key,
    required this.agentIds,
    required this.agentNames,
    required this.activeAgentId,
    required this.onAgentSelected,
    required this.onAddAgent,
    required this.onLogout,
  });


  @override
  State<MultipiaiDrawer> createState() => _MultipiaiDrawerState();
}

class _AgentItem {
  final String id;
  final String label;
  final IconData icon;
  const _AgentItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class _MultipiaiDrawerState extends State<MultipiaiDrawer> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _iconForAgent(String name) {
    final n = name.toLowerCase();
    if (n.contains('persona')) return Icons.person_outline;
    if (n.contains('finance')) return Icons.account_balance_wallet_outlined;
    if (n.contains('industry')) return Icons.factory_outlined;
    if (n.contains('outlook')) return Icons.trending_up_outlined;
    return Icons.smart_toy_outlined;
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF00C271);
    /// Build agents dynamically from API response
    final List<_AgentItem> agents = List.generate(
      widget.agentIds.length,
      (index) => _AgentItem(
        id: widget.agentIds[index],
        label: widget.agentNames[index],
        icon: _iconForAgent(widget.agentNames[index]),
      ),
    );
    final filtered = agents.where((a) {
      if (_query.isEmpty) return true;
      return a.label.toLowerCase().contains(_query);
    }).toList();

    return Drawer(
      // remove curved side
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // HEADER: logo + title + collapse icon
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/MultiplAI_Logo_single.png',
                    height: 24,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'MultiplAI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        size: 18, color: green), // green icon
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () => _searchController.clear(),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // SECTION LABEL
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'AGENTS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // // "Add Agent" button
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: TextButton.icon(
            //       style: TextButton.styleFrom(
            //         padding:
            //             const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //         minimumSize: Size.zero,
            //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //       ),
            //       onPressed: _showAddAgentDialog,
            //       icon: const Icon(Icons.add, size: 16, color: green),
            //       label: const Text(
            //         'Add Agent',
            //         style: TextStyle(
            //           fontSize: 12,
            //           color: green,
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),

            // AGENT LIST
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(left: 52.0),
                  child: Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                ),
                itemBuilder: (context, index) {
                  final agent = filtered[index];
                  final isActive = agent.id == widget.activeAgentId;

                  return ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: Icon(
                      agent.icon,
                      size: 18,
                      color: green,
                    ),
                    title: Text(
                      agent.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    onTap: () {
                      widget.onAgentSelected(agent.id);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),

            // BOTTOM PROFILE PILL (ONLY HERE)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    // const CircleAvatar(
                    //   radius: 18,
                    //   backgroundColor: Color(0xFFB5F5C8), // light green
                    //   child: Text(
                    //     'JD',
                    //     style: TextStyle(color: Colors.black87),
                    //   ),
                    // ),
                    // const SizedBox(width: 12),
                    // Expanded(
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: const [
                    //       Text(
                    //         'John Doe',
                    //         style: TextStyle(
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //         overflow: TextOverflow.ellipsis,
                    //       ),
                    //       SizedBox(height: 2),
                    //       Text(
                    //         'john@multiplai.com',
                    //         style: TextStyle(
                    //           fontSize: 11,
                    //           color: Colors.grey,
                    //         ),
                    //         overflow: TextOverflow.ellipsis,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(width: 6),
                    // const Icon(Icons.keyboard_arrow_down,
                    //     size: 18, color: Colors.grey),
                    // const Spacer(),
                    const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: _confirmLogout,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(
                          Icons.logout,
                          size: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 Future<void> _showAddAgentDialog() async {
  final controller = TextEditingController();

  final text = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add Agent'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Agent name'),
        onSubmitted: (_) =>
            Navigator.of(ctx).pop(controller.text.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.of(ctx).pop(controller.text.trim()),
          child: const Text('Submit'),
        ),
      ],
    ),
  );

  if (text != null && text.isNotEmpty) {
    widget.onAddAgent(text); // 🔥 delegate to parent
    Navigator.of(context).pop();
  }
}

Future<void> _confirmLogout() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Logout'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    Navigator.of(context).pop(); // close drawer
    widget.onLogout(); // 🔥 notify parent
  }
}


}
