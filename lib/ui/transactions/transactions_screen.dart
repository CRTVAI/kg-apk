import 'package:cargo/controllers/transaction_controller.dart';
import 'package:cargo/models/transaction_response.dart';
import 'package:cargo/ui/styles/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionController _transactionController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _lockAndClearFinance();
  }

  @override
  void dispose() {
    _lockAndClearFinance();
    _refreshController.dispose();
    super.dispose();
  }

  void _clearProtectedData() {
    _transactionController.transactionResponse.value = null;
    _transactionController.historyList.clear();
    _transactionController.filterHistoryList.clear();
    _transactionController.paymentData.clear();
    _transactionController.indexNo.value = 1;
    _transactionController.kLoadingData.value = false;
  }

  void _lockAndClearFinance() {
    _transactionController.kIsPasswordPassed.value = false;
    _transactionController.kIsPasswordVisible.value = false;
    _transactionController.passwordController.clear();
    _clearProtectedData();
  }

  Future<void> _unlockFinance() async {
    if (_transactionController.passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your financial password')),
      );
      return;
    }

    _transactionController.kIsPasswordPassed.value = false;
    _clearProtectedData();
    await _transactionController.checkPassword();

    if (!_transactionController.kIsPasswordPassed.value) return;

    await _transactionController.getTransactionData(
      isRefresh: true,
      firstTime: true,
    );
  }

  num _asNumber(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _money(dynamic value) {
    final number = _asNumber(value);
    final formatted = number.toStringAsFixed(2);
    return '\$${formatted.endsWith('.00') ? formatted.substring(0, formatted.length - 3) : formatted}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance'),
        actions: [
          Obx(
            () => _transactionController.kIsPasswordPassed.isTrue
                ? IconButton(
                    tooltip: 'Refresh financial data',
                    onPressed: () {
                      _transactionController.getTransactionData(
                        isRefresh: true,
                        firstTime: true,
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _transactionController.kIsPasswordPassed.isTrue
                ? _FinanceDashboard(
                    key: const ValueKey('finance-dashboard'),
                    controller: _transactionController,
                    refreshController: _refreshController,
                    money: _money,
                    asNumber: _asNumber,
                  )
                : _FinanceUnlock(
                    key: const ValueKey('finance-unlock'),
                    controller: _transactionController,
                    onUnlock: _unlockFinance,
                  ),
          ),
        ),
      ),
    );
  }
}

class _FinanceUnlock extends StatelessWidget {
  const _FinanceUnlock({
    super.key,
    required this.controller,
    required this.onUnlock,
  });

  final TransactionController controller;
  final Future<void> Function() onUnlock;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(.09),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 32,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Financial access',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter your financial password to view balances and transaction history.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.muted,
                          ),
                    ),
                    const SizedBox(height: 22),
                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                        obscureText: !controller.kIsPasswordVisible.value,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          if (controller.kIsPasswordChecking.isFalse) {
                            onUnlock();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Financial password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: controller.kIsPasswordVisible.isTrue
                                ? 'Hide password'
                                : 'Show password',
                            onPressed: controller.kIsPasswordVisible.toggle,
                            icon: Icon(
                              controller.kIsPasswordVisible.isTrue
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.kIsPasswordChecking.isTrue
                            ? null
                            : onUnlock,
                        icon: controller.kIsPasswordChecking.isTrue
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.lock_open_rounded),
                        label: Text(
                          controller.kIsPasswordChecking.isTrue
                              ? 'Checking...'
                              : 'Unlock finance',
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 16,
                          color: AppTheme.muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Protected financial information',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FinanceDashboard extends StatelessWidget {
  const _FinanceDashboard({
    super.key,
    required this.controller,
    required this.refreshController,
    required this.money,
    required this.asNumber,
  });

  final TransactionController controller;
  final RefreshController refreshController;
  final String Function(dynamic value) money;
  final num Function(dynamic value) asNumber;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final response = controller.transactionResponse.value;
      final data = response?.transactionData;

      if (data == null && controller.kLoadingData.isTrue) {
        return const Center(child: CircularProgressIndicator());
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LastTransactionHero(
              amount: money(data?.lastTransactionAmount),
              loading: controller.kLoadingData.isTrue,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppTheme.success,
                    label: 'Balance',
                    value: money(data?.balance),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.schedule_rounded,
                    iconColor: AppTheme.warning,
                    label: 'Due payments',
                    value: money(data?.duePayments),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PaymentLimitCard(
              spent: asNumber(data?.duePayments),
              limit: asNumber(data?.duePaymentsLimit),
              money: money,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Transaction history',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${data?.totalTransactions ?? controller.filterHistoryList.length} total',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: controller.filterHistoryList.isEmpty
                  ? const _EmptyTransactions()
                  : SmartRefresher(
                      controller: refreshController,
                      enablePullUp: true,
                      onRefresh: () {
                        controller.refreshTransactionData(refreshController);
                      },
                      onLoading: () {
                        controller.loadMoreTransactionData(refreshController);
                      },
                      header: const WaterDropHeader(
                        waterDropColor: AppTheme.primary,
                      ),
                      footer: CustomFooter(
                        builder: (context, mode) {
                          if (mode == LoadStatus.loading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return const SizedBox(height: 44);
                        },
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: controller.filterHistoryList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _TransactionCard(
                            history: controller.filterHistoryList[index],
                            money: money,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

class _LastTransactionHero extends StatelessWidget {
  const _LastTransactionHero({
    required this.amount,
    required this.loading,
  });

  final String amount;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest transaction',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(.78),
                      ),
                ),
                const SizedBox(height: 5),
                AnimatedOpacity(
                  opacity: loading ? .5 : 1,
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    amount,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 34,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentLimitCard extends StatelessWidget {
  const _PaymentLimitCard({
    required this.spent,
    required this.limit,
    required this.money,
  });

  final num spent;
  final num limit;
  final String Function(dynamic value) money;

  @override
  Widget build(BuildContext context) {
    final ratio = limit <= 0 ? 0.0 : (spent / limit).clamp(0, 1).toDouble();
    final overLimit = limit > 0 && spent > limit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Due payment limit',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${(ratio * 100).round()}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: overLimit ? AppTheme.danger : AppTheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${money(spent)} used of ${money(limit)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.muted,
                  ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 9,
                backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation(
                  overLimit ? AppTheme.danger : AppTheme.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.history,
    required this.money,
  });

  final TransactionHistory history;
  final String Function(dynamic value) money;

  @override
  Widget build(BuildContext context) {
    final vin = history.vehicle?.vin?.toString().trim() ?? '';
    final type = history.type?.toString().trim() ?? '';
    final amount = history.totalAmount ?? history.amount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(.08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vin.isEmpty ? 'Transaction #${history.id ?? '-'}' : vin,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.isEmpty
                        ? 'Reference #${history.id ?? history.vehicleId ?? '-'}'
                        : type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              money(amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppTheme.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Pull down to check for new activity.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales, this.color);

  final String year;
  final int sales;
  final Color color;
}
