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
  Map<String, dynamic>? _pendingProgram; // Programme en attente de validation

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    // Message d'accueil
    _messages.add({
      'from': 'ai',
      'text': 'Salut ! Je suis ton coach IA. Dis-moi tes objectifs et je te créerai un programme personnalisé. 💪',
      'time': DateTime.now().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'from': 'user', 'text': text, 'time': DateTime.now().toIso8601String()});
      _controller.clear();
      _loading = true;
    });
    _scrollToBottom();

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

  void _showCreateTrainingDialog() {
    String objective = 'muscle';
    String level = 'débutant';
    int daysPerWeek = 3;
    List<String> equipment = ['poids du corps'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.grey700,
          title: const Text('Créer un programme', style: TextStyle(color: AppColors.accentGreen)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Objectif:', style: TextStyle(color: Colors.white70)),
                DropdownButton<String>(
                  value: objective,
                  dropdownColor: AppColors.grey700,
                  style: const TextStyle(color: Colors.white),
                  items: ['muscle', 'perte de poids', 'endurance', 'force', 'souplesse']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => objective = v!),
                ),
                const SizedBox(height: 12),
                const Text('Niveau:', style: TextStyle(color: Colors.white70)),
                DropdownButton<String>(
                  value: level,
                  dropdownColor: AppColors.grey700,
                  style: const TextStyle(color: Colors.white),
                  items: ['débutant', 'intermédiaire', 'avancé']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => level = v!),
                ),
                const SizedBox(height: 12),
                const Text('Jours par semaine:', style: TextStyle(color: Colors.white70)),
                Slider(
                  value: daysPerWeek.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  label: '$daysPerWeek jours',
                  activeColor: AppColors.accentGreen,
                  onChanged: (v) => setDialogState(() => daysPerWeek = v.toInt()),
                ),
                const SizedBox(height: 12),
                const Text('Équipement:', style: TextStyle(color: Colors.white70)),
                Wrap(
                  spacing: 8,
                  children: ['poids du corps', 'haltères', 'barre', 'machines', 'élastiques'].map((eq) {
                    final selected = equipment.contains(eq);
                    return FilterChip(
                      label: Text(eq, style: TextStyle(color: selected ? AppColors.primaryDark : Colors.white)),
                      selected: selected,
                      selectedColor: AppColors.accentGreen,
                      backgroundColor: AppColors.primaryDark,
                      onSelected: (sel) {
                        setDialogState(() {
                          if (sel) {
                            equipment.add(eq);
                          } else {
                            equipment.remove(eq);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen),
              onPressed: () {
                Navigator.pop(ctx);
                _generateProgram(objective, level, daysPerWeek, equipment);
              },
              child: const Text('Générer', style: TextStyle(color: AppColors.primaryDark)),
            ),
          ],
        ),
      ),
    );
  }

  void _generateProgram(String objective, String level, int daysPerWeek, List<String> equipment) async {
    setState(() {
      _messages.add({
        'from': 'user',
        'text': 'Génère-moi un programme: $objective, niveau $level, $daysPerWeek jours/semaine',
        'time': DateTime.now().toIso8601String(),
      });
      _loading = true;
    });
    _scrollToBottom();

    try {
      final params = {
        'objectives': [objective],
        'level': level,
        'durationPerWeek': daysPerWeek,
        'availableEquipment': equipment,
      };
      final result = await AIService.generateTraining(params);
      final program = result['training'] ?? result;

      setState(() {
        _pendingProgram = program is Map<String, dynamic> ? program : null;
        _messages.add({
          'from': 'ai',
          'text': '✅ Programme généré ! Objectif: $objective, Niveau: $level, $daysPerWeek jours/semaine.\n\nVeux-tu valider et sauvegarder ce programme ?',
          'time': DateTime.now().toIso8601String(),
        });
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({'from': 'ai', 'text': 'Erreur lors de la génération: $e', 'time': DateTime.now().toIso8601String()});
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _validateAndSaveProgram() async {
    if (_pendingProgram == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun programme à sauvegarder. Génère d\'abord un programme.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await TrainingService.saveGeneratedProgram(
        userId: 'user_1',
        program: _pendingProgram!,
      );
      setState(() {
        _messages.add({
          'from': 'ai',
          'text': '🎉 Programme sauvegardé avec succès ! Tu peux le retrouver dans "Mes entraînements".',
          'time': DateTime.now().toIso8601String(),
        });
        _pendingProgram = null;
      });
      _scrollToBottom();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Programme sauvegardé !')),
      );
    } catch (e) {
      setState(() {
        _messages.add({'from': 'ai', 'text': 'Erreur lors de la sauvegarde: $e', 'time': DateTime.now().toIso8601String()});
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach IA'),
        backgroundColor: AppColors.primaryDark,
        elevation: 2,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey[800]),
          // Chat Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.smart_toy,
                          size: 56,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Commence une conversation',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final m = _messages[i];
                      final isUser = m['from'] == 'user';
                      final text = m['text'] ?? '';
                      final time = m['time'] != null ? DateTime.tryParse(m['time']!) : null;

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment:
                                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isUser)
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.accentGreen.withOpacity(0.3),
                                  child: const Icon(
                                    Icons.smart_toy,
                                    size: 20,
                                    color: AppColors.accentGreen,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? AppColors.accentGreen
                                        : AppColors.grey700.withOpacity(0.7),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(14),
                                      topRight: const Radius.circular(14),
                                      bottomLeft: Radius.circular(isUser ? 14 : 4),
                                      bottomRight: Radius.circular(isUser ? 4 : 14),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        text,
                                        style: TextStyle(
                                          color: isUser ? AppColors.primaryDark : Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (time != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            color: isUser
                                                ? Colors.black.withOpacity(0.5)
                                                : Colors.grey[400],
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              if (isUser) const SizedBox(width: 8),
                              if (isUser)
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.accentGreen.withOpacity(0.8),
                                  child: const Icon(
                                    Icons.person,
                                    size: 20,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGreen.withOpacity(0.6)),
              ),
            ),
          // Input Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.grey700.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: AppColors.accentGreen.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  onSubmitted: (_) => _send(),
                                  textInputAction: TextInputAction.send,
                                  decoration: const InputDecoration(
                                    hintText: 'Pose ta question...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(fontSize: 14),
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              if (_controller.text.isNotEmpty)
                                IconButton(
                                  onPressed: () {
                                    _controller.clear();
                                  },
                                  icon: const Icon(Icons.close, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Send Button
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentGreen,
                              AppColors.accentGreen.withOpacity(0.85),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGreen.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, size: 20),
                          color: AppColors.primaryDark,
                          onPressed: _loading ? null : _send,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Generate Program Button
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentGreen.withOpacity(0.7),
                              AppColors.accentGreen.withOpacity(0.55),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGreen.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.fitness_center, size: 20),
                          color: AppColors.primaryDark,
                          onPressed: _loading ? null : _showCreateTrainingDialog,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                        ),
                      ),
                      // Validate Program Button (if pending)
                      if (_pendingProgram != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green,
                                Colors.green.withOpacity(0.8),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.check, size: 20),
                            color: Colors.white,
                            onPressed: _loading ? null : _validateAndSaveProgram,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                          ),
                        ),
                      ],
                    ],
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
