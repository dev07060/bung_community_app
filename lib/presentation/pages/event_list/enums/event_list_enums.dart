/// 벙 정렬 옵션
enum EventSortOption {
  dateAsc('날짜순 (오래된 순)'),
  dateDesc('날짜순 (최신순)'),
  createdDesc('생성순 (최신순)'),
  createdAsc('생성순 (오래된 순)'),
  participantsDesc('참여자순 (많은 순)'),
  participantsAsc('참여자순 (적은 순)');

  const EventSortOption(this.displayName);
  final String displayName;
}
