import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:flutter/material.dart';

class OrderItemData {
  final String id;
  final String storeName;
  final String customerName;
  final String address;
  final String itemsCount;
  final String amount;
  final String status; // 'Assigned', 'Delivered', 'Cancelled'
  final String dateGroup; // 'Today', 'Yesterday', '22 July 2026'
  final String time;

  const OrderItemData({
    required this.id,
    required this.storeName,
    required this.customerName,
    required this.address,
    required this.itemsCount,
    required this.amount,
    required this.status,
    required this.dateGroup,
    required this.time,
  });
}

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Selected Order ID (null means showing the grouped list view)
  String? _selectedOrderId;
  
  // Selected Filter Tab ('All', 'Active', 'Completed')
  String _selectedFilter = 'All';

  final List<OrderItemData> _allOrders = const [
    OrderItemData(
      id: '#ORD-12548',
      storeName: 'Green Basket Store',
      customerName: 'Rohit Sharma',
      address: 'Shivaji Nagar, Kolhapur',
      itemsCount: '12 Items',
      amount: '₹860',
      status: 'Assigned',
      dateGroup: 'Today',
      time: '10:30 AM',
    ),
    OrderItemData(
      id: '#ORD-12547',
      storeName: 'Fresh Veggies Corner',
      customerName: 'Aniket Deshmukh',
      address: 'Rajarampuri 5th Lane, Kolhapur',
      itemsCount: '4 Items',
      amount: '₹290',
      status: 'Assigned',
      dateGroup: 'Today',
      time: '08:45 AM',
    ),
    OrderItemData(
      id: '#ORD-12542',
      storeName: 'Fresh Mart Grocery',
      customerName: 'Priya Patel',
      address: 'Tarabai Park, Kolhapur',
      itemsCount: '6 Items',
      amount: '₹450',
      status: 'Delivered',
      dateGroup: 'Yesterday',
      time: '05:20 PM',
    ),
    OrderItemData(
      id: '#ORD-12540',
      storeName: 'Daily Needs Superstore',
      customerName: 'Suresh Patil',
      address: 'Shahupuri, Kolhapur',
      itemsCount: '9 Items',
      amount: '₹620',
      status: 'Delivered',
      dateGroup: 'Yesterday',
      time: '02:10 PM',
    ),
    OrderItemData(
      id: '#ORD-12530',
      storeName: 'City Supermarket',
      customerName: 'Amit Shah',
      address: 'Nagala Park, Kolhapur',
      itemsCount: '8 Items',
      amount: '₹520',
      status: 'Delivered',
      dateGroup: '22 July 2026',
      time: '06:40 PM',
    ),
  ];

  List<OrderItemData> get _filteredOrders {
    if (_selectedFilter == 'Active') {
      return _allOrders.where((o) => o.status == 'Assigned').toList();
    } else if (_selectedFilter == 'Completed') {
      return _allOrders.where((o) => o.status == 'Delivered').toList();
    }
    return _allOrders;
  }

  // Group filtered orders by dateGroup key while preserving order
  Map<String, List<OrderItemData>> get _groupedOrders {
    final Map<String, List<OrderItemData>> groups = {};
    for (final order in _filteredOrders) {
      groups.putIfAbsent(order.dateGroup, () => []).add(order);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = _allOrders.isNotEmpty;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFFF9F5), // soft cream background
      body: !hasData
          ? SizedBox.expand(
              child: Image.asset(
                'assets/images/no_order_bg.png',
                fit: BoxFit.cover,
              ),
            )
          : _selectedOrderId != null
              ? _buildOrderDetailView()
              : _buildGroupedOrdersListView(),
    );
  }

  // ── GROUPED ORDERS LIST VIEW ─────────────────────────────────────────────
  Widget _buildGroupedOrdersListView() {
    final groupedMap = _groupedOrders;

    return SafeArea(
      child: Column(
        children: [
          // Screen Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Orders',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D121F),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2E6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_filteredOrders.length} Orders',
                        style: const TextStyle(
                          color: Color(0xFFFA6624),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                12.hS,
                // Status Filter Segmented Control
                Row(
                  children: [
                    _buildFilterChip('All'),
                    8.wS,
                    _buildFilterChip('Active'),
                    8.wS,
                    _buildFilterChip('Completed'),
                  ],
                ),
              ],
            ),
          ),

          // Date-Grouped Orders List
          Expanded(
            child: groupedMap.isEmpty
                ? Center(
                    child: Text(
                      'No orders found',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: groupedMap.keys.length,
                    itemBuilder: (context, index) {
                      final dateHeader = groupedMap.keys.elementAt(index);
                      final ordersInGroup = groupedMap[dateHeader]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Group Heading
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 8, left: 4),
                            child: Row(
                              children: [
                                Icon(
                                  dateHeader == 'Today'
                                      ? Icons.today_rounded
                                      : dateHeader == 'Yesterday'
                                          ? Icons.history_rounded
                                          : Icons.calendar_today_rounded,
                                  size: 16,
                                  color: const Color(0xFFFA6624),
                                ),
                                6.wS,
                                Text(
                                  dateHeader,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D121F),
                                  ),
                                ),
                                8.wS,
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${ordersInGroup.length}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Order Item Cards
                          ...ordersInGroup.map((order) => _buildOrderSummaryCard(order)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterName) {
    final bool isSelected = _selectedFilter == filterName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterName;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFA6624) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          filterName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(OrderItemData order) {
    final bool isAssigned = order.status == 'Assigned';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOrderId = order.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Order ID & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.id,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D121F),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAssigned ? const Color(0xFFFFF2E6) : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: isAssigned ? const Color(0xFFFA6624) : const Color(0xFF2E7D32),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            10.hS,
            const Divider(height: 1, color: Color(0xFFF5F5F5)),
            10.hS,

            // Store Info & Items Row
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF2E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.store_rounded, color: Color(0xFFFA6624), size: 20),
                ),
                12.wS,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.storeName,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      2.hS,
                      Text(
                        '${order.itemsCount} • ${order.amount}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFFA6624), size: 24),
              ],
            ),
            10.hS,

            // Customer & Address Row
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Color(0xFFFA6624), size: 16),
                6.wS,
                Expanded(
                  child: Text(
                    '${order.customerName} - ${order.address}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  order.time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── DETAILED ASSIGNED ORDER VIEW ─────────────────────────────────────────
  Widget _buildOrderDetailView() {
    return Positioned.fill(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Orange Header block with circle overlap & Back Button
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
                      34.hS,
                      Text(
                        _selectedOrderId ?? '#ORD-12548',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      20.hS, // offset for circle
                    ],
                  ),
                ),

                // Back Button on Top Left Corner
                Positioned(
                  top: 40,
                  left: 16,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedOrderId = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
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

            65.hS, // spacing for overlap circle

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

            20.hS,

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
                            4.hS,
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
                        14.wS,
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
                                        2.hS,
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
                              38.hS, // match vertical custom dotted line spacing
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
                                        2.hS,
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

                  16.hS,

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

                  20.hS,

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

                  10.hS,

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

                  16.hS,

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
                        10.wS,
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

                  24.hS,

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
                      12.wS,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Accept Order',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                6.wS,
                                const Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  32.hS,
                ],
              ),
            ),
          ],
        ),
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
          6.hS,
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          2.hS,
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
          14.wS,
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
                2.hS,
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
