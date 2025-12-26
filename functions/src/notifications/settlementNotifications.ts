import * as admin from "firebase-admin";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import {
  NotificationPayload,
  saveNotification,
  sendNotificationToUsers,
} from "../utils/fcmUtils";

const db = admin.firestore();

/**
 * Payment status enum matching Flutter's PaymentStatus
 */
enum PaymentStatus {
  pending = "pending",
  completed = "completed",
  overdue = "overdue",
}

/**
 * Settlement status enum matching Flutter's SettlementStatus
 */
enum SettlementStatus {
  pending = "pending",
  completed = "completed",
}

/**
 * Trigger: Settlement Created
 */
export const onSettlementCreated = onDocumentCreated(
  "settlements/{settlementId}",
  async (event) => {
    const settlementData = event.data?.data();
    if (!settlementData) return;

    const settlementId = event.params.settlementId;
    const eventId = settlementData.eventId as string;
    const organizerId = settlementData.organizerId as string;
    const totalAmount = settlementData.totalAmount as number;
    const participantAmounts = settlementData.participantAmounts as Record<string, number>;

    const eventDoc = await db.collection("events").doc(eventId).get();
    const eventTitle = eventDoc.data()?.title || "벙";

    const participantIds = Object.keys(participantAmounts).filter((id) => id !== organizerId);

    const payload: NotificationPayload = {
      title: "정산이 생성되었습니다 💰",
      body: `${eventTitle} - 총 ${totalAmount.toLocaleString()}원`,
      data: { type: "settlementCreated", settlementId, eventId },
    };

    const result = await sendNotificationToUsers(participantIds, payload);
    console.log(`Settlement created: ${result.successCount} success, ${result.failureCount} failed`);
    await saveNotification("", participantIds, "settlementCreated", payload);
  },
);

/**
 * Trigger: Payment Status Changed
 */
export const onPaymentStatusChanged = onDocumentUpdated(
  "settlements/{settlementId}",
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    if (!beforeData || !afterData) return;

    const beforePaymentStatus = beforeData.paymentStatus as Record<string, PaymentStatus>;
    const afterPaymentStatus = afterData.paymentStatus as Record<string, PaymentStatus>;

    const settlementId = event.params.settlementId;
    const organizerId = afterData.organizerId as string;
    const eventId = afterData.eventId as string;
    const participantAmounts = afterData.participantAmounts as Record<string, number>;

    const eventDoc = await db.collection("events").doc(eventId).get();
    const eventTitle = eventDoc.data()?.title || "벙";
    console.log(`Processing payment changes for: ${eventTitle}`);

    for (const [participantId, status] of Object.entries(afterPaymentStatus)) {
      const previousStatus = beforePaymentStatus[participantId];

      if (previousStatus !== PaymentStatus.completed && status === PaymentStatus.completed) {
        const userDoc = await db.collection("users").doc(participantId).get();
        const participantName = userDoc.data()?.displayName || "참여자";
        const amount = participantAmounts[participantId] || 0;

        const payload: NotificationPayload = {
          title: "입금 확인 완료 ✅",
          body: `${participantName}님이 ${amount.toLocaleString()}원을 입금했습니다`,
          data: { type: "paymentReceived", settlementId, eventId, participantId },
        };

        await sendNotificationToUsers([organizerId], payload);
        console.log(`Payment received notification sent for ${participantName}`);
      }
    }
  },
);

/**
 * Trigger: Settlement Completed
 */
export const onSettlementCompleted = onDocumentUpdated(
  "settlements/{settlementId}",
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    if (!beforeData || !afterData) return;

    const beforeStatus = beforeData.status as SettlementStatus;
    const afterStatus = afterData.status as SettlementStatus;
    if (beforeStatus === afterStatus || afterStatus !== SettlementStatus.completed) return;

    const settlementId = event.params.settlementId;
    const eventId = afterData.eventId as string;
    const participantAmounts = afterData.participantAmounts as Record<string, number>;

    const eventDoc = await db.collection("events").doc(eventId).get();
    const eventTitle = eventDoc.data()?.title || "벙";

    const participantIds = Object.keys(participantAmounts);

    const payload: NotificationPayload = {
      title: "정산이 완료되었습니다 🎉",
      body: `${eventTitle} 정산이 완료되었습니다`,
      data: { type: "settlementCompleted", settlementId, eventId },
    };

    const result = await sendNotificationToUsers(participantIds, payload);
    console.log(`Settlement completed: ${result.successCount} success, ${result.failureCount} failed`);
    await saveNotification("", participantIds, "settlementCompleted", payload);
  },
);
