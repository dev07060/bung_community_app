import 'package:flutter/material.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';

Color getStatusColor(EventStatus status) {
  switch (status) {
    case EventStatus.scheduled:
      return Colors.blue;
    case EventStatus.closed:
      return Colors.orange;
    case EventStatus.ongoing:
      return Colors.green;
    case EventStatus.settlement:
      return Colors.purple;
    case EventStatus.completed:
      return Colors.grey;
    case EventStatus.cancelled:
      return Colors.red;
  }
}
