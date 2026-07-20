import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_boy_app/src/routes/app_route_path.dart';

class DrawerWidget extends StatefulWidget {
  final String activeItem;
  const DrawerWidget({super.key, this.activeItem = 'orders'});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late String _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.activeItem;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.85,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColor.white, // cream
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.4,
              colors: [
                AppColor.orangeTint, // soft glowing light-orange tint
                AppColor.white, // cream
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative background elements (skyline, dotted path, dots)
              Positioned.fill(
                child: CustomPaint(
                  painter: DrawerDecorationsPainter(),
                ),
              ),
              
              // Main Drawer Content
              SafeArea(
                child: Column(
                  children: [
                    24.hS,
                    
                    // Large profile photo placeholder with thick orange border and shadow
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.orangeTint2,
                          border: Border.all(color: AppColor.darkOrange, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.darkOrange.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_pin_rounded,
                          size: 52,
                          color: AppColor.darkOrange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Rider Name
                    const Text(
                      'Rider Name',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Total Earnings Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColor.darkOrange, AppColor.primaryLight2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.darkOrange.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'drawer_total_earnings'.tr(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Text(
                                  '₹24,580',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Divider
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Divider(
                        color: Color(0xFFFFD3BD),
                        thickness: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Menu Items
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildMenuItem(
                            title: 'drawer_orders'.tr(),
                            icon: Icons.shopping_bag_rounded,
                            id: 'orders',
                            onTap: () {
                              setState(() {
                                _selectedItem = 'orders';
                              });
                              Navigator.pop(context);
                              context.go(AppRoute.orders.path);
                            },
                          ),
                          _buildMenuItem(
                            title: 'drawer_delivered'.tr(),
                            icon: Icons.check_circle_rounded,
                            id: 'delivered',
                            onTap: () {
                              setState(() {
                                _selectedItem = 'delivered';
                              });
                              Navigator.pop(context);
                              context.go(AppRoute.delivered.path);
                            },
                          ),
                          _buildMenuItem(
                            title: 'drawer_cancelled'.tr(),
                            icon: Icons.cancel_rounded,
                            id: 'cancelled',
                            onTap: () {
                              setState(() {
                                _selectedItem = 'cancelled';
                              });
                              Navigator.pop(context);
                              context.go(AppRoute.cancelled.path);
                            },
                          ),
                          _buildMenuItem(
                            title: 'drawer_rejected'.tr(),
                            icon: Icons.remove_circle_rounded,
                            id: 'rejected',
                            onTap: () {
                              setState(() {
                                _selectedItem = 'rejected';
                              });
                              Navigator.pop(context);
                              context.go(AppRoute.rejected.path);
                            },
                          ),
                          _buildMenuItem(
                            title: 'drawer_profile'.tr(),
                            icon: Icons.person_rounded,
                            id: 'profile',
                            onTap: () {
                              setState(() {
                                _selectedItem = 'profile';
                              });
                              Navigator.pop(context);
                              context.go(AppRoute.profile.path);
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Logout button with soft orange outline
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 20.0),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showLogoutConfirmationDialog(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColor.darkOrange,
                          side: const BorderSide(color: AppColor.darkOrange, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: Text(
                          'drawer_logout'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required String id,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedItem == id;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColor.darkOrange, AppColor.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            highlightColor: AppColor.darkOrange.withValues(alpha: 0.05),
            splashColor: AppColor.darkOrange.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : AppColor.darkOrange,
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColor.darkOrange.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'drawer_logout'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('drawer_logout_confirm'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'drawer_logout_no'.tr(),
                style: const TextStyle(color: AppColor.slateGrey, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate back to Login Screen
                context.go(AppRoute.login.path);
              },
              child: Text(
                'drawer_logout_yes'.tr(),
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DrawerDecorationsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // --- 1. City Skyline Silhouette ---
    final skylinePaint = Paint()
      ..color = AppColor.darkOrange.withValues(alpha: 0.04) // Very faint orange
      ..style = PaintingStyle.fill;

    final skylinePath = Path();
    skylinePath.moveTo(0, size.height);
    
    double currentX = 0;
    final heights = [45.0, 70.0, 35.0, 95.0, 50.0, 80.0, 60.0, 110.0, 55.0, 75.0];
    final widths = [30.0, 45.0, 25.0, 40.0, 35.0, 50.0, 30.0, 45.0, 35.0, 40.0];
    
    for (int i = 0; i < heights.length; i++) {
      double w = widths[i];
      double h = heights[i];
      if (currentX + w > size.width) {
        w = size.width - currentX;
      }
      skylinePath.lineTo(currentX, size.height - h);
      skylinePath.lineTo(currentX + w, size.height - h);
      skylinePath.lineTo(currentX + w, size.height);
      currentX += w;
      if (currentX >= size.width) break;
    }
    skylinePath.close();
    canvas.drawPath(skylinePath, skylinePaint);

    // --- 2. Dotted path and pin (like a rider path) ---
    // We will draw a dotted curved path starting from mid-left to mid-right
    final routePath = Path();
    routePath.moveTo(20, size.height * 0.45);
    routePath.cubicTo(
      size.width * 0.25, size.height * 0.40,
      size.width * 0.50, size.height * 0.55,
      size.width * 0.75, size.height * 0.48,
    );
    
    // Draw dotted path manually
    final pathMetrics = routePath.computeMetrics();
    for (var metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 1.5, Paint()..color = AppColor.darkOrange.withValues(alpha: 0.25));
        }
        distance += 8.0; // gap size + dot size
      }
    }

    // Draw small pin at the end of the path
    if (pathMetrics.isNotEmpty) {
      final lastTangent = pathMetrics.first.getTangentForOffset(pathMetrics.first.length * 0.75);
      if (lastTangent != null) {
        final pinCenter = lastTangent.position;
        final pinPaint = Paint()
          ..color = AppColor.darkOrange.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill;
          
        // Draw pin shape
        final pinPath = Path();
        pinPath.moveTo(pinCenter.dx, pinCenter.dy);
        pinPath.cubicTo(
          pinCenter.dx - 6, pinCenter.dy - 12,
          pinCenter.dx - 6, pinCenter.dy - 18,
          pinCenter.dx, pinCenter.dy - 18,
        );
        pinPath.cubicTo(
          pinCenter.dx + 6, pinCenter.dy - 18,
          pinCenter.dx + 6, pinCenter.dy - 12,
          pinCenter.dx, pinCenter.dy,
        );
        canvas.drawPath(pinPath, pinPaint);
        canvas.drawCircle(Offset(pinCenter.dx, pinCenter.dy - 13), 2.5, Paint()..color = Colors.white.withValues(alpha: 0.8));
      }
    }

    // --- 3. Tiny floating orange dots ---
    final dotPaint1 = Paint()..color = AppColor.darkOrange.withValues(alpha: 0.08);
    final dotPaint2 = Paint()..color = AppColor.darkOrange.withValues(alpha: 0.05);

    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.22), 3, dotPaint1);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.18), 4, dotPaint2);
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.35), 2.5, dotPaint1);
    canvas.drawCircle(Offset(size.width * 0.10, size.height * 0.60), 3.5, dotPaint2);
    canvas.drawCircle(Offset(size.width * 0.90, size.height * 0.75), 3, dotPaint1);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.88), 4.5, dotPaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
