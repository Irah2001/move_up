import 'package:flutter/material.dart';
import 'package:move_up/constants/app_colors.dart';
import 'package:move_up/services/ai_service.dart';
import 'package:move_up/services/training_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'from': 'user', 'text': text, 'time': DateTime.now().toIso8601String()});
      _controller.clear();
      _loading = true;
    });

    try {
      final resp = await AIService.chat(message: text, context: 'training');
      setState(() {
        _messages.add({'from': 'ai', 'text': resp, 'time': DateTime.now().toIso8601String()});
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({'from': 'ai', 'text': 'Erreur: $e', 'time': DateTime.now().toIso8601String()});
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _generateAndSaveProgram() async {
    // example params; in a real UI we'd collect these
    final params = {
      'objectives': ['muscle'],
      'level': 'intermédiaire',
      'durationPerWeek': 3,
      'availableEquipment': ['haltères']
    };

    setState(() => _loading = true);
    try {
      final result = await AIService.generateTraining(params);
      final program = result['training'] ?? result;

      // offer to save
      final save = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Programme généré'),
          content: Text(program.toString()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sauvegarder')),
          ],
        ),
      );

      if (save == true) {
        await TrainingService.saveGeneratedProgram(userId: 'user_1', program: program as Map<String, dynamic>);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Programme sauvegardé')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach IA'), backgroundColor: AppColors.primaryDark),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isUser = m['from'] == 'user';
                final text = m['text'] ?? '';
                final time = m['time'] != null ? DateTime.tryParse(m['time']!) : null;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        const CircleAvatar(radius: 16, child: Icon(Icons.smart_toy, size: 18)),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.accentGreen : AppColors.grey700,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: Radius.circular(isUser ? 12 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(text, style: const TextStyle(color: AppColors.white)),
                              const SizedBox(height: 6),
                              if (time != null)
                                Text(
                                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 10),
                                  textAlign: TextAlign.right,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (isUser) const SizedBox(width: 8),
                      if (isUser) const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.grey700,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              onSubmitted: (_) => _send(),
                              textInputAction: TextInputAction.send,
                              decoration: const InputDecoration(
                                hintText: 'Pose ta question',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (_controller.text.isNotEmpty) IconButton(onPressed: () { setState(() { _controller.clear(); }); }, icon: const Icon(Icons.close, size: 18)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.accentGreen,
                    child: IconButton(
                      color: AppColors.primaryDark,
                      icon: const Icon(Icons.send),
                      onPressed: _loading ? null : _send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.accentGreen.withOpacity(0.85),
                    child: IconButton(
                      color: AppColors.primaryDark,
                      icon: const Icon(Icons.fitness_center),
                      onPressed: _loading ? null : _generateAndSaveProgram,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
