import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/orders/widgets/drawer_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isOnline = true;
  final List<String> _orders = ['Sample Order #1'];
  late final ScrollController _scrollController;
  bool _showButtons = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final double currentOffset = _scrollController.offset;
    
    if (currentOffset <= 10) {
      // Reached the top -> show buttons
      if (!_showButtons) {
        setState(() {
          _showButtons = true;
        });
      }
    } else {
      // Scrolling down/away from top -> hide buttons immediately
      if (_showButtons) {
        setState(() {
          _showButtons = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = _orders.isNotEmpty;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerWidget(),
      backgroundColor: const Color(0xFFFFF9F5), // soft cream background
      body: Stack(
        children: [
          // Content
          if (!hasData)
            // Empty state fullscreen background image
            SizedBox.expand(
              child: Image.asset(
                'assets/images/no_order_bg.png',
                fit: BoxFit.cover,
              ),
            )
          else
            // Detailed Assigned Order View
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // Orange Header block with circle overlap
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFA6624), // Theme Orange
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 34),
                              const Text(
                                '#ORD-12548',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20), // offset for circle
                            ],
                          ),
                        ),
                        
                        // Overlapping circular grocery basket photo placeholder
                        Positioned(
                          bottom: -55,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF2E6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/vege_grocery.png',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 65), // spacing for overlap circle
                    
                    // Single Order Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2E6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Single Order',
                        style: TextStyle(
                          color: Color(0xFFFA6624),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Main Cards Column
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          // Address Details Card (Pickup & Delivery Address Timeline)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Timeline Graphic column
                                Column(
                                  children: [
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFF2E6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.store_rounded, color: Color(0xFFFA6624), size: 14),
                                    ),
                                    CustomPaint(
                                      size: const Size(2, 60),
                                      painter: DottedLinePainter(),
                                    ),
                                    const Icon(Icons.location_on_rounded, color: Color(0xFFFA6624), size: 24),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                // Address details list
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Green Basket Store',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '2.4 km away',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildPhoneCircle(),
                                        ],
                                      ),
                                      const SizedBox(height: 38), // match vertical custom dotted line spacing
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Rohit Sharma',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Shivaji Nagar, Kolhapur\nNear Laxmi Mandir',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 12,
                                                    height: 1.3,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildPhoneCircle(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Summary metrics in columns
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9F3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFFEAD9), width: 1),
                            ),
                            child: Row(
                              children: [
                                _buildMetricItem(Icons.shopping_bag_outlined, '12', 'Items'),
                                _buildDivider(),
                                _buildMetricItem(Icons.account_balance_wallet_outlined, '₹860', 'Amount'),
                                _buildDivider(),
                                _buildMetricItem(Icons.local_atm_rounded, 'Cash on', 'Payment'),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Order Items Section Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Order Items (12)',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'View All',
                                  style: TextStyle(
                                    color: Color(0xFFFA6624),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // Order Items List Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildOrderItemRow('🍅', 'Tomato', '1 kg', 'x 2'),
                                const Divider(height: 16, color: Color(0xFFFBE4D8)),
                                _buildOrderItemRow('🥔', 'Potato', '2 kg', 'x 1'),
                                const Divider(height: 16, color: Color(0xFFFBE4D8)),
                                _buildOrderItemRow('🧀', 'Paneer', '500 g', 'x 1'),
                                const Divider(height: 16, color: Color(0xFFFBE4D8)),
                                _buildOrderItemRow('🥛', 'Milk', '1 ltr', 'x 2'),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Instruction Banner Card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFDF0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFFF2B3), width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.assignment_rounded, color: Color(0xFFFA6624), size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Please collect the items and deliver before the time runs out.',
                                    style: TextStyle(
                                      color: Colors.amber.shade900,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Accept / Release Action Buttons Row
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFFA6624),
                                      side: const BorderSide(color: Color(0xFFFA6624), width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: const Text(
                                      'Release Order',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFA6624),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      elevation: 3,
                                      shadowColor: const Color(0xFFFA6624).withValues(alpha: 0.4),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Accept Order',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(Icons.arrow_forward_rounded, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Menu Button at Top Left Corner to open Drawer
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: AnimatedOpacity(
                opacity: _showButtons ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: AnimatedSlide(
                  offset: _showButtons ? Offset.zero : const Offset(0, -0.3),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: IgnorePointer(
                    ignoring: !_showButtons,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.menu_rounded, color: Color(0xFFFA6624)),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Status Toggle Button at Top Right Corner
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                opacity: _showButtons ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: AnimatedSlide(
                  offset: _showButtons ? Offset.zero : const Offset(0, -0.3),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: IgnorePointer(
                    ignoring: !_showButtons,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColor.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isOnline ? 'home_status_online'.tr() : 'home_status_offline'.tr(),
                              style: TextStyle(
                                color: _isOnline ? const Color(0xFFFA6624) : const Color(0xFF7A869A),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 30, // Compact height for Switch
                              child: Switch(
                                value: _isOnline,
                                onChanged: (value) {
                                  setState(() {
                                    _isOnline = value;
                                  });
                                },
                                activeThumbColor: AppColor.primary,
                                activeTrackColor: AppColor.primaryDark.withValues(alpha: 0.3),
                                inactiveThumbColor: AppColor.gray,
                                inactiveTrackColor: AppColor.white,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFA6624),
        foregroundColor: Colors.white,
        tooltip: 'Toggle Sample Data',
        child: Icon(hasData ? Icons.delete_outline_rounded : Icons.add_rounded),
        onPressed: () {
          setState(() {
            if (hasData) {
              _orders.clear();
            } else {
              _orders.add('Sample Order #1');
            }
          });
        },
      ),
    );
  }

  Widget _buildPhoneCircle() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: const Icon(Icons.phone_rounded, color: Color(0xFFFA6624), size: 16),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFA6624), size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 36,
      width: 1,
      color: const Color(0xFFFFEAD9),
    );
  }

  Widget _buildOrderItemRow(String emoji, String title, String subtitle, String qty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Emoji circle placeholder
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2E6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            qty,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFA6624).withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    const double dashHeight = 4;
    const double dashSpace = 4;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

