import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:move_up/constants/profile_theme.dart';
import 'package:move_up/widgets/stat_card.dart';
import 'package:move_up/widgets/progress_goal_card.dart';
import 'package:move_up/services/auth_service.dart';
import 'package:move_up/services/user_service.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String userName = 'MoveUp_User';
  String profileImageUrl = 'https://picsum.photos/200';
  String goal = 'Atteindre 78 kg';
  double progress = 0.75;
  List<Map<String, String>> stats = const [
    {"label": "Entraînements", "value": "124"},
    {"label": "Durée Totale", "value": "50h"},
    {"label": "Calories Brûlées", "value": "20.5K"},
    {"label": "Poids Actuel", "value": "85 kg"},
  ];

  final UserService _userService = UserService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final uid = AuthService().currentUser?.uid;
      if (uid == null) return;
      final data = await _userService.getUserProfile(uid);
      if (data != null) {
        if (!mounted) return;
        setState(() {
          userName = (data['displayName'] as String?) ?? userName;
          profileImageUrl = (data['photoUrl'] as String?) ?? profileImageUrl;
          goal = (data['goal'] as String?) ?? goal;
          progress = (data['progress'] as num?)?.toDouble() ?? progress;
          final dynamic s = data['stats'];
          if (s is List) {
            try {
              stats = List<Map<String, String>>.from(s.map((e) => Map<String, String>.from(e as Map)));
            } catch (_) {}
          }
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load user profile: $e');
    }
  }

  Future<void> _changeAvatar() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connectez-vous pour changer l\'avatar')));
      return;
    }

    try {
      final url = await _userService.pickAndUploadAvatar(uid);
      if (url != null) {
        if (!mounted) return;
        setState(() => profileImageUrl = url);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar mis à jour')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur upload avatar: $e')));
    }
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, String? subtitle, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.redAccent : accentColor),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.redAccent : Colors.white,
          fontSize: 16,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)) : null,
      trailing: isLogout ? null : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () async {
        if (isLogout) {
          final bool? confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: cardColor,
              title: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
              content: const Text('Voulez-vous vraiment vous déconnecter ?', style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
                TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Se déconnecter', style: TextStyle(color: Colors.redAccent))),
              ],
            ),
          );

          if (confirm == true) {
            try {
              await AuthService().signOut();
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la déconnexion: $e')));
            }
          }
        } else {
          switch (title) {
            case 'Journal d\'Entraînement':
              Navigator.pushNamed(context, '/training_journal');
              break;
            case 'Mon Plan d\'Action':
              Navigator.pushNamed(context, '/plan');
              break;
            case 'Abonnement & Facturation':
              Navigator.pushNamed(context, '/billing');
              break;
            default:
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Page non implémentée')));
          }
        }
      },
    );
  }

  Widget _sectionCard({required String title, required Widget child, EdgeInsetsGeometry? padding}) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: accentColor),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _placeholderChart(List<int> values, {bool bars = true}) {
    final max = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((v) {
          final h = (v / (max == 0 ? 1 : max)) * 60 + 10;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (bars)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: h,
                      decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(6)),
                    )
                  else
                    Container(height: 6, color: Colors.white10),
                  const SizedBox(height: 8),
                  Text('M', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(color: Colors.white)),
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.settings, color: accentColor), onPressed: () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          // Header - avatar, name and edit button
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                if (!_scrollController.hasClients) return;
                final newOffset = _scrollController.offset - details.delta.dy;
                final max = _scrollController.position.maxScrollExtent;
                final min = _scrollController.position.minScrollExtent;
                _scrollController.jumpTo(newOffset.clamp(min, max));
              },
              child: Column(
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: accentColor.withOpacity(0.5),
                        child: ClipOval(
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: CachedNetworkImage(
                              imageUrl: profileImageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[800],
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: accentColor)),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[800],
                                child: const Icon(Icons.person, size: 60, color: Colors.white24),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white), onPressed: _changeAvatar),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(userName, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) {
                          final TextEditingController nameController = TextEditingController(text: userName);
                          final TextEditingController imageController = TextEditingController(text: profileImageUrl);
                          return AlertDialog(
                            backgroundColor: cardColor,
                            title: const Text('Modifier le profil', style: TextStyle(color: Colors.white)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await _changeAvatar();
                                    imageController.text = profileImageUrl;
                                  },
                                  icon: const Icon(Icons.photo_camera, color: Colors.black),
                                  label: const Text('Choisir une photo', style: TextStyle(color: Colors.black)),
                                  style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                                ),
                                const SizedBox(height: 8),
                                TextField(controller: nameController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Nom', labelStyle: TextStyle(color: Colors.white70))),
                                const SizedBox(height: 8),
                                TextField(controller: imageController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Image URL', labelStyle: TextStyle(color: Colors.white70))),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
                              TextButton(
                                onPressed: () async {
                                  final String newName = nameController.text.trim();
                                  final String newImage = imageController.text.trim();
                                  setState(() {
                                    if (newName.isNotEmpty) userName = newName;
                                    if (newImage.isNotEmpty) profileImageUrl = newImage;
                                  });
                                  final uid = AuthService().currentUser?.uid;
                                  if (uid != null) {
                                    await _userService.updateUserProfile(uid, {'displayName': userName, 'photoUrl': profileImageUrl});
                                  }
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour')));
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Enregistrer', style: TextStyle(color: accentColor)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.black),
                    label: const Text('Modifier le Profil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), elevation: 5),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Progress card
          ProgressGoalCard(
            goal: goal,
            progress: progress,
            onChanged: (newGoal, newProgress) async {
              setState(() {
                goal = newGoal;
                progress = newProgress;
              });
              final uid = AuthService().currentUser?.uid;
              if (uid != null) {
                await _userService.updateUserProfile(uid, {'goal': goal, 'progress': progress});
              }
            },
          ),

          const SizedBox(height: 16),

          // Inline statistics sections (compact, themed like StatisticsPage)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionCard(
                  title: 'Entraînements',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Aucune donnée', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text('7 derniers jours', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),

                _sectionCard(
                  title: 'Pas',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Moyenne', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(stats.isNotEmpty ? stats[0]['value'] ?? '0' : '0', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _placeholderChart([4000, 5000, 2000, 4500, 11000, 3000, 5200]),
                    ],
                  ),
                ),

                _sectionCard(
                  title: 'Poids',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${stats.length > 0 ? stats.last['value'] : ''}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(height: 40, color: Colors.white10, child: const Center(child: Text('Graphique poids', style: TextStyle(color: Colors.white70)))),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                          child: const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('Mettre à jour mon poids', style: TextStyle(fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ],
                  ),
                ),

                _sectionCard(
                  title: 'Temps au lit',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Aucune donnée', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      _placeholderChart([]),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Text('Vue d\'ensemble et Records', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15.0, mainAxisSpacing: 15.0, childAspectRatio: 1.2),
            itemCount: stats.length,
            itemBuilder: (context, index) => StatCard(label: stats[index]['label']!, value: stats[index]['value']!),
          ),

          const Divider(height: 40, color: Colors.white12),
          _buildListTile(context, 'Journal d\'Entraînement', Icons.history, 'Voir les séances passées'),
          _buildListTile(context, 'Mon Plan d\'Action', Icons.calendar_today, 'Programme en cours : 4 semaines'),
          _buildListTile(context, 'Abonnement & Facturation', Icons.attach_money, 'Prochain paiement : 12/01'),
          const Divider(height: 40, color: Colors.white12),
          _buildListTile(context, 'Déconnexion', Icons.logout, null, isLogout: true),
        ],
      ),
    );
  }
}
