/**
 * Firebase Cloud Functions for FCM Notifications
 * Our Bung Play - Community Management App
 */
import { setGlobalOptions } from "firebase-functions/v2";

// 서울 리전 설정 (한국 사용자 대상)
setGlobalOptions({ region: "asia-northeast3" });

// Event Notifications
export {
  onEventCreated,
  onEventStatusChanged,
  onParticipantJoined,
  onParticipantLeft,
} from "./notifications/eventNotifications";

// Settlement Notifications
export {
  onPaymentStatusChanged,
  onSettlementCompleted,
  onSettlementCreated,
} from "./notifications/settlementNotifications";

