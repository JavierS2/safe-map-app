import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_colors.dart';
import '../../../config/routes.dart';
import '../../../config/route_history.dart';
import 'package:safe_map_application/providers/auth_provider.dart';

class ReportHeader extends StatelessWidget {
  final String title;

  const ReportHeader({super.key, this.title = 'Crea Tu Reporte'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Row(
        children: [
          // Botón atrás
          IconButton(
            onPressed: () {
              // 1) If there is something to pop in the navigator stack, do it.
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                return;
              }

              // 2) Otherwise try to navigate to the last meaningful route
              // recorded by the route observer (if any).
                final current = ModalRoute.of(context)?.settings.name;
                final prev = appRouteObserver.previousMeaningfulRoute(current) ??
                  (appRouteObserver.lastRoute != null && appRouteObserver.lastRoute != current
                    ? appRouteObserver.lastRoute
                    : null);
              if (prev != null && prev.isNotEmpty && prev != current) {
                Navigator.pushReplacementNamed(context, prev);
                return;
              }

              // 3) Final fallback: go to app home.
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
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
                          offset: Offset(0, 2),
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
                                  offset: Offset(0, 2),
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
    );
  }
}
