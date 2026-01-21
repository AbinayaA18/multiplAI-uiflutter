import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Future<void> Function(String) onSend;

  const ChatInput({super.key, required this.onSend});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  static const double _btnSize = 42;

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _controller.clear();

    await widget.onSend(text);

    if (mounted) {
      setState(() => _sending = false);
    }
  }

  // plus menu + voice sheet same as earlier (shortened here)
  void _openPlusMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 8),
            _MenuItem(icon: Icons.attach_file, label: 'Add photos & files'),
            _MenuItem(icon: Icons.brush_outlined, label: 'Create image'),
            _MenuItem(icon: Icons.lightbulb_outline, label: 'Thinking'),
            _MenuItem(icon: Icons.campaign_outlined, label: 'Deep research'),
            _MenuItem(
              icon: Icons.shopping_bag_outlined,
              label: 'Shopping research',
            ),
            Divider(height: 1),
            _MenuItem(icon: Icons.more_horiz, label: 'More'),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _openVoiceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String previewText = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Voice input',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      previewText.isEmpty
                          ? 'Tap and hold the mic to speak.\n(Voice recognition wiring TODO)'
                          : previewText,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onLongPressStart: (_) {
                        setModalState(() {
                          previewText = 'Listening...';
                        });
                      },
                      onLongPressEnd: (_) {
                        setModalState(() {
                          previewText =
                              'Sample recognized text (replace with STT result)';
                        });
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (previewText.isNotEmpty) {
                              _controller.text = previewText;
                              _controller.selection =
                                  TextSelection.fromPosition(
                                TextPosition(offset: _controller.text.length),
                              );
                            }
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Insert to message'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF00C271);

    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            // +
            InkWell(
              onTap: _openPlusMenu,
              borderRadius: BorderRadius.circular(_btnSize / 2),
              child: Container(
                width: _btnSize,
                height: _btnSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(_btnSize / 2),
                ),
                child: const Icon(Icons.add, size: 22, color: Colors.black87),
              ),
            ),
            const SizedBox(width: 8),
            // middle pill (no attach icon)
            Expanded(
              child: Container(
                height: _btnSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(_btnSize / 2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Center(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Message AI Agent',
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // voice
            InkWell(
              onTap: _openVoiceSheet,
              borderRadius: BorderRadius.circular(_btnSize / 2),
              child: Container(
                width: _btnSize,
                height: _btnSize,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.graphic_eq,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // send (GREEN)
            InkWell(
              onTap: _sending ? null : _handleSend,
              borderRadius: BorderRadius.circular(_btnSize / 2),
              child: Container(
                width: _btnSize,
                height: _btnSize,
                decoration: const BoxDecoration(
                  color: green,
                  shape: BoxShape.circle,
                ),
                child: _sending
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20),
      title: Text(label),
      onTap: () => Navigator.of(context).pop(),
    );
  }
}
