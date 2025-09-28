import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:our_bung_play/presentation/base/base_page.dart';
import 'package:our_bung_play/presentation/pages/event/mixins/event_event_mixin.dart';
import 'package:our_bung_play/presentation/pages/event/mixins/event_state_mixin.dart';
import 'package:our_bung_play/presentation/providers/channel_providers.dart';
import 'package:our_bung_play/shared/components/f_app_bar.dart';
import 'package:our_bung_play/shared/components/f_scaffold.dart';
import 'package:our_bung_play/shared/components/f_text_area.dart';
import 'package:our_bung_play/shared/components/f_text_field.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';

/// 벙 생성 페이지 - 새로운 벙(이벤트)을 생성하는 화면
class CreateEventPage extends BasePage with EventStateMixin, EventEventMixin {
  const CreateEventPage({super.key});

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    return const _CreateEventContent();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    final isLoading = isEventCreating(ref);

    return AppBar(
      title: const Text('벙 만들기'),
      actions: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          TextButton(
            onPressed: () => _onSaveTapped(context, ref),
            child: const Text(
              '저장',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  void _onSaveTapped(BuildContext context, WidgetRef ref) {
    // Form validation and submission will be handled by _CreateEventContent
    // This will be called from the content widget
  }
}

class _CreateEventContent extends HookConsumerWidget with EventStateMixin, EventEventMixin {
  const _CreateEventContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the globally selected channel
    final selectedChannel = ref.watch(selectedChannelProvider);

    if (selectedChannel == null) {
      // This can happen if the page is accessed before the channel is selected.
      final userChannelsAsync = ref.watch(userChannelsProvider);
      return userChannelsAsync.when(
        data: (channels) {
          if (channels.isEmpty) {
            return _buildNoChannelError(context);
          }
          // If channels exist but none is selected yet, show loading.
          // The HomePage should have already set this, so this is a fallback.
          return const Center(child: CircularProgressIndicator.adaptive());
        },
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, stackTrace) => _buildErrorState(context, '채널 정보를 불러올 수 없습니다.'),
      );
    } else {
      // If a channel is selected, build the form.
      return _buildCreateEventForm(context, ref, selectedChannel.id);
    }
  }

  Widget _buildNoChannelError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 24),
            Text(
              '모임에 참여해주세요',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '벙을 만들려면 먼저 모임에 참여해야 합니다.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 24),
            Text(
              '오류 발생',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateEventForm(BuildContext context, WidgetRef ref, String currentChannelId) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final locationController = useTextEditingController();
    final maxParticipantsController = useTextEditingController(text: '10');

    final selectedDate = useState<DateTime?>(null);
    final selectedTime = useState<TimeOfDay?>(null);
    final requiresSettlement = useState<bool>(false);

    // 벙 생성 상태 감시
    final isCreating = isEventCreating(ref);
    final creationError = getEventCreationError(ref);

    // 에러 표시
    useEffect(() {
      if (creationError != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(creationError),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
      return null;
    }, [creationError]);

    return FScaffold(
      appBar: FAppBar.back(
        context,
        title: '벙 만들기',
        backgroundColor: FColors.current.lightGreen,
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 벙 제목
              FTextField.contained(
                controller: titleController,
                hintText: '벙 제목을 입력하세요',
                label: '벙 제목',
                isRequired: true,
                prefixIcon: const Icon(Icons.title),
                maxLength: 15,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '벙 제목을 입력해주세요';
                  }
                  if (value.trim().length < 2) {
                    return '벙 제목은 2글자 이상 입력해주세요';
                  }
                  return null;
                },
              ),
              const Gap(24),

              // 벙 설명
              FTextArea.contained(
                controller: descriptionController,
                hintText: '벙에 대한 자세한 설명을 입력하세요',
                label: '벙 설명',
                isRequired: true,
                // maxLines: 4,
                maxLength: 200,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '벙 설명을 입력해주세요';
                  }
                  if (value.trim().length < 10) {
                    return '벙 설명은 10글자 이상 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 날짜 선택
              FormField<DateTime>(
                validator: (value) {
                  if (selectedDate.value == null) {
                    return '날짜를 선택해주세요';
                  }
                  if (selectedDate.value!.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                    return '과거 날짜는 선택할 수 없습니다';
                  }
                  return null;
                },
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _selectDate(context, selectedDate),
                      child: IgnorePointer(
                        child: FTextField.contained(
                          controller: TextEditingController(
                            text: selectedDate.value != null
                                ? '${selectedDate.value!.year}년 ${selectedDate.value!.month}월 ${selectedDate.value!.day}일'
                                : '',
                          ),
                          hintText: '날짜를 선택하세요',
                          label: '날짜',
                          isRequired: true,
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 시간 선택
              FormField<TimeOfDay>(
                validator: (value) {
                  if (selectedTime.value == null) {
                    return '시간을 선택해주세요';
                  }
                  return null;
                },
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _selectTime(context, selectedTime),
                      child: IgnorePointer(
                        child: FTextField.contained(
                          controller: TextEditingController(
                            text: selectedTime.value != null
                                ? '${selectedTime.value!.hour.toString().padLeft(2, '0')}:${selectedTime.value!.minute.toString().padLeft(2, '0')}'
                                : '',
                          ),
                          hintText: '시간을 선택하세요',
                          label: '시간',
                          isRequired: true,
                          prefixIcon: const Icon(Icons.access_time),
                        ),
                      ),
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Gap(24),

              // 장소
              FTextField.contained(
                controller: locationController,
                hintText: '만날 장소를 입력하세요',
                label: '장소',
                isRequired: true,
                prefixIcon: const Icon(Icons.location_on),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '장소를 입력해주세요';
                  }
                  if (value.trim().length < 2) {
                    return '장소는 2글자 이상 입력해주세요';
                  }
                  return null;
                },
              ),
              const Gap(24),

              // 최대 인원
              FTextField.contained(
                controller: maxParticipantsController,
                hintText: '최대 참여 인원을 입력하세요',
                label: '최대 인원',
                isRequired: true,
                prefixIcon: const Icon(Icons.people),
                suffixIcon: const Text('명'),
                textInputType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '최대 인원을 입력해주세요';
                  }
                  final maxParticipants = int.tryParse(value.trim());
                  if (maxParticipants == null) {
                    return '올바른 숫자를 입력해주세요';
                  }
                  if (maxParticipants < 2) {
                    return '최대 인원은 2명 이상이어야 합니다';
                  }
                  if (maxParticipants > 100) {
                    return '최대 인원은 100명 이하여야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 정산 필요 여부
              _buildSectionTitle(context, '정산 설정'),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: SwitchListTile(
                  title: const Text(
                    '정산 필요',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    '벙 완료 후 비용 정산이 필요한 경우 체크하세요\n정산이 필요한 벙은 수동으로 완료 처리해야 합니다',
                  ),
                  value: requiresSettlement.value,
                  onChanged: (value) {
                    requiresSettlement.value = value;
                  },
                  secondary: Icon(
                    requiresSettlement.value ? Icons.account_balance_wallet : Icons.money_off,
                    color: requiresSettlement.value ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 생성 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isCreating
                      ? null
                      : () => _onCreateEventTapped(
                            context,
                            ref,
                            formKey,
                            currentChannelId,
                            titleController,
                            descriptionController,
                            locationController,
                            maxParticipantsController,
                            selectedDate.value,
                            selectedTime.value,
                            requiresSettlement.value,
                          ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '벙 만들기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // 필수 입력 안내
              const Text(
                '* 표시된 항목은 필수 입력 사항입니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Future<void> _selectDate(BuildContext context, ValueNotifier<DateTime?> selectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> _selectTime(BuildContext context, ValueNotifier<TimeOfDay?> selectedTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? TimeOfDay.now(),
    );
    if (picked != null) {
      selectedTime.value = picked;
    }
  }

  Future<void> _onCreateEventTapped(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    String currentChannelId,
    TextEditingController titleController,
    TextEditingController descriptionController,
    TextEditingController locationController,
    TextEditingController maxParticipantsController,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    bool requiresSettlement,
  ) async {
    // 폼 유효성 검사
    if (!formKey.currentState!.validate()) {
      return;
    }

    // 채널 ID 확인 (이미 _buildCreateEventForm에서 검증됨)
    if (currentChannelId.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('채널 정보를 찾을 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 날짜와 시간 결합
    final scheduledAt = DateTime(
      selectedDate!.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime!.hour,
      selectedTime.minute,
    );

    // 과거 시간 체크
    if (scheduledAt.isBefore(DateTime.now())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('과거 시간으로는 벙을 생성할 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final maxParticipants = int.parse(maxParticipantsController.text.trim());

    // 벙 생성 실행
    final success = await createEvent(
      ref,
      context,
      channelId: currentChannelId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      scheduledAt: scheduledAt,
      location: locationController.text.trim(),
      maxParticipants: maxParticipants,
      requiresSettlement: requiresSettlement,
    );

    if (success != null && context.mounted) {
      // 성공 시 이전 화면으로 돌아가기
      context.pop();
    }
  }
}
