import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/domain/entities/event_entity.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/pages/settlement/mixins/create_settlement_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/settlement/mixins/create_settlement_state_mixin.dart';

class CreateSettlementPage extends BasePage {
  final EventEntity event;

  const CreateSettlementPage({
    super.key,
    required this.event,
  });

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('정산 생성'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    );
  }

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createSettlementStateNotifierProvider);
    final eventMixin = ref.read(createSettlementEventProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventInfo(),
          const SizedBox(height: 24),
          _buildAccountForm(state, eventMixin),
          const SizedBox(height: 24),
          _buildAmountForm(state, eventMixin),
          const SizedBox(height: 24),
          _buildReceiptSection(state, eventMixin),
          const SizedBox(height: 32),
          _buildCreateButton(state, eventMixin),
        ],
      ),
    );
  }

  Widget _buildEventInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '벙 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '참여자: ${event.participantIds.length}명',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountForm(CreateSettlementState state, CreateSettlementEvent eventMixin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '계좌 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: state.accountHolderController,
          decoration: const InputDecoration(
            labelText: '예금주명',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          onChanged: eventMixin.onAccountHolderChanged,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: state.bankNameController,
          decoration: const InputDecoration(
            labelText: '은행명',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance),
          ),
          onChanged: eventMixin.onBankNameChanged,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: state.accountNumberController,
          decoration: const InputDecoration(
            labelText: '계좌번호',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.credit_card),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: eventMixin.onAccountNumberChanged,
        ),
      ],
    );
  }

  Widget _buildAmountForm(CreateSettlementState state, CreateSettlementEvent eventMixin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '정산 금액',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: state.totalAmountController,
          decoration: const InputDecoration(
            labelText: '총 비용',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.attach_money),
            suffixText: '원',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: eventMixin.onTotalAmountChanged,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1인당 정산 금액',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.getPerPersonAmount(event.participantIds.length) > 0
                    ? '${state.getPerPersonAmount(event.participantIds.length).toStringAsFixed(0)}원'
                    : '총 비용을 입력해주세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      state.getPerPersonAmount(event.participantIds.length) > 0 ? Colors.blue[800] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptSection(CreateSettlementState state, CreateSettlementEvent eventMixin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '영수증 첨부',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(선택사항)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.receiptImages.isNotEmpty) ...[
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.receiptImages.length,
              itemBuilder: (context, index) {
                final image = state.receiptImages[index];
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(image.path),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => eventMixin.removeReceiptImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        OutlinedButton.icon(
          onPressed: eventMixin.pickReceiptImage,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('영수증 추가'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(CreateSettlementState state, CreateSettlementEvent eventMixin) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.isValid && !state.isLoading ? () => eventMixin.createSettlement(event) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: state.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '정산 생성',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
