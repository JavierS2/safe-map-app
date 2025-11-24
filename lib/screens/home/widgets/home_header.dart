import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_map_application/config/routes.dart';
import '../../../../theme/app_colors.dart';
import 'package:safe_map_application/providers/auth_provider.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String greeting;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 32,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------- Fila superior (Saludo + notificación) -----------
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        'Hola, Bienvenido/a $userName',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                    const SizedBox(height: 4),
                      Text(
                        greeting,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                  ],
                ),
              ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      final current = ModalRoute.of(context)?.settings.name;
                      if (current == AppRoutes.notification) return;
                      Navigator.of(context).pushNamed(AppRoutes.notification);
                    },
                    child: Builder(builder: (context) {
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      final uid = auth.currentUser?.uid;

                      // If no user, show icon without badge
                      if (uid == null) {
                        return Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.notifications_none,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                        );
                      }

                      final stream = FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('notifications')
                          .where('read', isEqualTo: false)
                          .limit(1)
                          .snapshots();

                      return StreamBuilder<QuerySnapshot>(
                        stream: stream,
                        builder: (context, snap) {
                          final hasUnread = snap.hasData && (snap.data?.docs.isNotEmpty ?? false);
                          return Container(
                            width: 36,
                            height: 36,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.15),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.notifications_none,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                if (hasUnread)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFB3B3),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // ----------- Logo centrado sin borde -----------
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: SizedBox(
                  height: 120,   // ← ¡Logo más grande!
                  width: 120,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'SafeMap',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
