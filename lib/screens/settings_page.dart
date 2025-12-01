// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:move_up/constants/profile_theme.dart';
import 'package:move_up/services/user_service.dart';
import 'package:move_up/services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserService _userService = UserService();

  String _name = '';
  String _gender = 'Masculin';
  DateTime? _birthday;
  String _unit = 'cm/kg';
  double? _height;
  double? _weight;
  String _goal = 'Perdre du poids';
  bool _kneePain = false;
  bool _newsletter = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final uid = AuthService().currentUser?.uid;
      if (uid == null) return;
      final data = await _userService.getUserProfile(uid);
      if (data == null) return;
      if (!mounted) return;

      setState(() {
        _name = (data['displayName'] as String?) ?? _name;
        _gender = (data['gender'] as String?) ?? _gender;
        final b = data['birthday'];
        if (b is String) _birthday = DateTime.tryParse(b);
        if (b is int) _birthday = DateTime.fromMillisecondsSinceEpoch(b);
        _unit = (data['unit'] as String?) ?? _unit;
        final h = data['height'];
        final w = data['weight'];
        if (h != null) _height = (h is num) ? h.toDouble() : double.tryParse(h.toString());
        if (w != null) _weight = (w is num) ? w.toDouble() : double.tryParse(w.toString());
        final goal = data['goal'];
        if (goal is Map) {
          _goal = (goal['type'] as String?) ?? _goal;
          if (goal['kneePain'] != null) _kneePain = goal['kneePain'] as bool;
        }
        _newsletter = (data['newsletter'] as bool?) ?? _newsletter;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load settings: $e');
    }
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final initial = _birthday ?? DateTime(now.year - 25, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Sélectionner la date de naissance',
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(dialogBackgroundColor: cardColor), child: child!),
    );
    if (picked != null && mounted) setState(() => _birthday = picked);
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'Non renseigné';
    return '${d.day.toString().padLeft(2, '0')} ${_monthName(d.month)} ${d.year}';
  }

  String _monthName(int m) {
    const names = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    return names[(m - 1).clamp(0, 11)];
  }

  Future<void> _saveField(String key, dynamic value) async {
    try {
      final uid = AuthService().currentUser?.uid;
      if (uid == null) return;
      await _userService.updateUserProfile(uid, {key: value});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur sauvegarde: $e')));
    }
  }

  Future<void> _saveAll() async {
    setState(() => _isLoading = true);
    try {
      final uid = AuthService().currentUser?.uid;
      if (uid == null) throw 'Utilisateur non connecté';

      final payload = {
        'displayName': _name,
        'gender': _gender,
        'birthday': _birthday?.toIso8601String(),
        'unit': _unit,
        'height': _height,
        'weight': _weight,
        'goal': {'type': _goal, 'targetWeight': null, 'kneePain': _kneePain},
        'newsletter': _newsletter,
      };

      await _userService.updateUserProfile(uid, payload);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paramètres sauvegardés')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _row(String title, String value, {VoidCallback? onTap, bool showChevron = true}) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(value, style: const TextStyle(color: Colors.white)), if (showChevron) const SizedBox(width: 8), if (showChevron) const Icon(Icons.chevron_right, color: Colors.white70)]),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Colors.white12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthService().currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: CircleAvatar(
            backgroundColor: cardColor,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text('Modifier le profil', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Avatar (editable) — big avatar with pencil button overlay like the capture
              SizedBox(
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: cardColor,
                      child: CircleAvatar(radius: 44, backgroundColor: Colors.grey[800], child: const Icon(Icons.person, size: 44, color: Colors.white)),
                    ),
                    Positioned(
                      right: MediaQuery.of(context).size.width * 0.5 - 48,
                      bottom: 14,
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 3))]),
                          child: const Icon(Icons.edit, size: 18, color: accentColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),

              // Card with rows
              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _row('Nom', _name.isEmpty ? '—' : _name, onTap: () async {
                      final v = await showDialog<String?>(context: context, builder: (c) {
                        final ctrl = TextEditingController(text: _name);
                        return AlertDialog(
                          backgroundColor: cardColor,
                          title: const Text('Modifier le nom', style: TextStyle(color: Colors.white)),
                          content: TextField(controller: ctrl, style: const TextStyle(color: Colors.white)),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Annuler', style: TextStyle(color: Colors.white70))),
                            TextButton(onPressed: () => Navigator.of(c).pop(ctrl.text.trim()), child: const Text('OK', style: TextStyle(color: accentColor))),
                          ],
                        );
                      });
                      if (v != null && v.isNotEmpty && mounted) {
                        setState(() => _name = v);
                        await _saveField('displayName', v);
                      }
                    }),

                    _row('Genre', _gender, onTap: () async {
                      final sel = await showDialog<String?>(
                          context: context,
                          builder: (c) => SimpleDialog(
                                backgroundColor: cardColor,
                                children: [
                                  SimpleDialogOption(child: const Text('Masculin', style: TextStyle(color: Colors.white70)), onPressed: () => Navigator.pop(c, 'Masculin')),
                                  SimpleDialogOption(child: const Text('Féminin', style: TextStyle(color: Colors.white70)), onPressed: () => Navigator.pop(c, 'Féminin')),
                                  SimpleDialogOption(child: const Text('Autre', style: TextStyle(color: Colors.white70)), onPressed: () => Navigator.pop(c, 'Autre')),
                                ],
                              ));
                      if (sel != null && mounted) {
                        setState(() => _gender = sel);
                        await _saveField('gender', sel);
                      }
                    }),

                    _row('Anniversaire', _formatDate(_birthday), onTap: _pickBirthday),

                    _row('Unités', _unit, onTap: () async {
                      final sel = await showDialog<String?>(
                          context: context,
                          builder: (c) => SimpleDialog(
                                backgroundColor: cardColor,
                                children: [
                                  SimpleDialogOption(child: const Text('cm/kg', style: TextStyle(color: Colors.white70)), onPressed: () => Navigator.pop(c, 'cm/kg')),
                                  SimpleDialogOption(child: const Text('in/lbs', style: TextStyle(color: Colors.white70)), onPressed: () => Navigator.pop(c, 'in/lbs')),
                                ],
                              ));
                      if (sel != null && mounted) {
                        setState(() => _unit = sel);
                        await _saveField('unit', sel);
                      }
                    }),

                    _row('Taille', _height != null ? '${_height!.toStringAsFixed(0)} ${_unit.split('/').first}' : '—', onTap: () async {
                      final v = await showDialog<String?>(context: context, builder: (c) {
                        final ctrl = TextEditingController(text: _height?.toString() ?? '');
                        return AlertDialog(
                          backgroundColor: cardColor,
                          title: const Text('Modifier la taille', style: TextStyle(color: Colors.white)),
                          content: TextField(controller: ctrl, keyboardType: TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white)),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Annuler', style: TextStyle(color: Colors.white70))),
                            TextButton(onPressed: () => Navigator.of(c).pop(ctrl.text.trim()), child: const Text('OK', style: TextStyle(color: accentColor))),
                          ],
                        );
                      });
                      final parsed = v == null ? null : double.tryParse(v);
                      if (parsed != null && mounted) {
                        setState(() => _height = parsed);
                        await _saveField('height', parsed);
                      }
                    }),

                    _row('Poids', _weight != null ? '${_weight!.toStringAsFixed(1)} ${_unit.split('/').last}' : '—', onTap: () async {
                      final v = await showDialog<String?>(context: context, builder: (c) {
                        final ctrl = TextEditingController(text: _weight?.toString() ?? '');
                        return AlertDialog(
                          backgroundColor: cardColor,
                          title: const Text('Modifier le poids', style: TextStyle(color: Colors.white)),
                          content: TextField(controller: ctrl, keyboardType: TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Colors.white)),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Annuler', style: TextStyle(color: Colors.white70))),
                            TextButton(onPressed: () => Navigator.of(c).pop(ctrl.text.trim()), child: const Text('OK', style: TextStyle(color: accentColor))),
                          ],
                        );
                      });
                      final parsed = v == null ? null : double.tryParse(v);
                      if (parsed != null && mounted) {
                        setState(() => _weight = parsed);
                        await _saveField('weight', parsed);
                      }
                    }),

                    _row('Objectif', _goal, onTap: () async {
                      final sel = await showDialog<String?>(
                          context: context,
                          builder: (c) => SimpleDialog(
                                backgroundColor: cardColor,
                                children: [
                                  SimpleDialogOption(child: const Text('Perdre du poids', style: TextStyle(color: Colors.white70)), onPressed: () => Navigator.pop(c, 'Perdre du poids')),
                                  SimpleDialogOption(child: const Text('Prendre du muscle', style: TextStyle(color: Colors.white70)), onPressed: () => Navigator.pop(c, 'Prendre du muscle')),
                                  SimpleDialogOption(child: const Text('Maintenir', style: TextStyle(color: Colors.white70)), onPressed: () => Navigator.pop(c, 'Maintenir')),
                                  SimpleDialogOption(child: const Text('Améliorer l\'endurance', style: TextStyle(color: Colors.white70)), onPressed: () => Navigator.pop(c, 'Améliorer l\'endurance')),
                                ],
                              ));
                      if (sel != null && mounted) {
                        setState(() => _goal = sel);
                        await _saveField('goal', {'type': sel});
                      }
                    }),

                    // Knee pain row with toggle label
                    ListTile(
                      title: const Text('Douleur au genou', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                      trailing: Text(_kneePain ? 'Oui' : 'Non', style: const TextStyle(color: Colors.white70)),
                      onTap: () async {
                        setState(() => _kneePain = !_kneePain);
                        await _saveField('goal', {'kneePain': _kneePain});
                      },
                    ),
                    const Divider(height: 1, color: Colors.white12),

                    // Newsletter row as switch
                    SwitchListTile(
                      title: const Text('Newsletter', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                      value: _newsletter,
                      onChanged: (v) async {
                        if (!mounted) return;
                        setState(() => _newsletter = v);
                        await _saveField('newsletter', v);
                      },
                      activeColor: accentColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Email and account actions
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Flexible(child: Text(email, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 8),
                      const Icon(Icons.apple, color: Colors.white70),
                    ]),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      TextButton(onPressed: () {}, child: const Text('Annuler l\'abonnement', style: TextStyle(decoration: TextDecoration.underline, color: Colors.white70))),
                      TextButton(onPressed: () {}, child: const Text('Supprimer le compte', style: TextStyle(decoration: TextDecoration.underline, color: Colors.white70))),
                    ])
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAll,
                  style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()) : const Padding(padding: EdgeInsets.symmetric(vertical: 14.0), child: Text('Enregistrer')),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
