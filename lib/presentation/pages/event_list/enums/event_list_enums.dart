/// 벙 정렬 옵션
enum EventSortOption {
  dateAsc('오래된 순'),
  dateDesc('최신순'),
  createdDesc('최신 생성순'),
  createdAsc('오래된 생성순'),
  participantsDesc('참여자 많은 순'),
  participantsAsc('참여자 적은 순');

  const EventSortOption(this.displayName);
  final String displayName;
}

/// 빠른 필터 옵션
enum QuickFilter {
  all('전체'),
  joinable('참여 가능'),
  closed('마감'),
  today('오늘 등록');

  const QuickFilter(this.displayName);
  final String displayName;
}

