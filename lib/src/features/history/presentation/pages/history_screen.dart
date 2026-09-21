import 'package:delivery_boy_app/src/configs/injector/injector_conf.dart';
import 'package:delivery_boy_app/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/history/bloc/today_delivered_history_bloc/today_delivered_history_bloc.dart';
import 'package:delivery_boy_app/src/features/history/presentation/widgets/today_delivered_order_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TodayDeliveredHistoryBloc>()
        ..add(const TodayDeliveredHistoryGetEvent(page: 1)),
      child: const _HistoryScreenContent(),
    );
  }
}

class _HistoryScreenContent extends StatefulWidget {
  const _HistoryScreenContent();

  @override
  State<_HistoryScreenContent> createState() => _HistoryScreenContentState();
}

class _HistoryScreenContentState extends State<_HistoryScreenContent> {
  late final ScrollController _scrollController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= (maxScroll - 200)) {
      final state = context.read<TodayDeliveredHistoryBloc>().state;
      if (!state.hasReachedMax && !state.loadingMore) {
        _currentPage = state.currentPage + 1;
        context.read<TodayDeliveredHistoryBloc>().add(
              TodayDeliveredHistoryGetEvent(page: _currentPage),
            );
      }
    }
  }

  Future<void> _onRefresh() async {
    _currentPage = 1;
    context.read<TodayDeliveredHistoryBloc>().add(
          const TodayDeliveredHistoryGetEvent(page: 1, isRefresh: true),
        );
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColor.darkOrange,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Text(
                'drawer_order_history'.tr().isNotEmpty
                    ? 'drawer_order_history'.tr()
                    : 'Order History',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<TodayDeliveredHistoryBloc, TodayDeliveredHistoryState>(
        builder: (context, state) {
          if (state is TodayDeliveredHistoryLoadingState && state.orders == null) {
            return _buildShimmerList();
          }

          if (state is TodayDeliveredHistoryFailureState &&
              (state.orders == null || state.orders!.isEmpty)) {
            return _buildErrorState(state.message);
          }

          final orders = state.orders ?? [];

          if (orders.isEmpty) {
            return _buildEmptyState();
          }

          final int totalDelivered =
              state.response?.pagination?.total ?? orders.length;

          return RefreshIndicator(
            color: AppColor.darkOrange,
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: orders.length + 1 + (state.loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Header item: summary count
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Delivered Orders",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D121F),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$totalDelivered Orders',
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final orderIndex = index - 1;

                // Loading more indicator at the bottom
                if (orderIndex >= orders.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColor.darkOrange,
                        ),
                      ),
                    ),
                  );
                }

                final order = orders[orderIndex];
                return TodayDeliveredOrderCardWidget(order: order);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: AppColor.darkOrange,
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColor.orangeTint.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_turned_in_outlined,
                  size: 64,
                  color: AppColor.darkOrange,
                ),
              ),
              20.hS,
              const Text(
                'No Delivered Orders Today',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D121F),
                ),
              ),
              8.hS,
              Text(
                'Orders you deliver today will be listed here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              24.hS,
              ElevatedButton.icon(
                onPressed: _onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.darkOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return RefreshIndicator(
      color: AppColor.darkOrange,
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColor.bright_red,
              ),
              12.hS,
              Text(
                message.isNotEmpty ? message : 'Something went wrong',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              16.hS,
              ElevatedButton(
                onPressed: _onRefresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.darkOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: List.generate(4, (index) => _buildShimmerCard()),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 90,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 80,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          10.hS,
          const Divider(height: 1, color: Colors.white),
          10.hS,
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              12.wS,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 130,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    4.hS,
                    Container(
                      width: 90,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          10.hS,
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          12.hS,
          const Divider(height: 1, color: Colors.white),
          10.hS,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 70,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
