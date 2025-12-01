import 'package:flutter/material.dart';
import 'package:move_up/constants/app_colors.dart';
import 'package:move_up/services/ai_service.dart';

class NutritionistChatScreen extends StatefulWidget {
  const NutritionistChatScreen({super.key});

  @override
  State<NutritionistChatScreen> createState() => _NutritionistChatScreenState();
}

class _NutritionistChatScreenState extends State<NutritionistChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  void _addMessage(String from, String text) {
    final time = DateTime.now();
    final timeLabel = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    setState(() => _messages.add({'from': from, 'text': text, 'time': timeLabel}));
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _addMessage('user', text);
    setState(() => _loading = true);

    try {
      final resp = await AIService.chat(message: text, context: 'nutrition');
      _addMessage('ai', resp);
    } catch (e) {
      _addMessage('ai', 'Erreur: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildBubble(Map<String, String> m) {
    final isUser = m['from'] == 'user';
    final bg = isUser ? AppColors.accentGreen : AppColors.grey700;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
          if (!isUser) ...[
          CircleAvatar(child: Icon(Icons.restaurant, color: AppColors.white), backgroundColor: AppColors.primaryDark),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: align,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(m['text'] ?? '', style: TextStyle(color: AppColors.white)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(m['time'] ?? '', style: TextStyle(fontSize: 11, color: AppColors.grey400)),
              ),
            ],
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 8),
          CircleAvatar(child: Icon(Icons.person, color: AppColors.white), backgroundColor: AppColors.primaryDark),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutritionniste IA'),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                itemCount: _messages.length,
                itemBuilder: (context, i) => _buildBubble(_messages[i]),
              ),
            ),
            if (_loading) const LinearProgressIndicator(),
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.grey700,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Pose ta question au nutritionniste...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.primaryDark,
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: _send,
                      icon: Icon(Icons.send, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
