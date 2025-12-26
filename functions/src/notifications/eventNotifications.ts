import * as admin from "firebase-admin";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import {
  NotificationPayload,
  saveNotification,
  sendNotificationToChannel,
  sendNotificationToUsers,
} from "../utils/fcmUtils";

const db = admin.firestore();

/**
 * Event status enum matching Flutter's EventStatus
 */
enum EventStatus {
  scheduled = "scheduled",
  closed = "closed",
  ongoing = "ongoing",
  settlement = "settlement",
  completed = "completed",
  cancelled = "cancelled",
}

/**
 * Trigger: Event Created
 */
export const onEventCreated = onDocumentCreated(
  "events/{eventId}",
  async (event) => {
    const eventData = event.data?.data();
    if (!eventData) return;

    const eventId = event.params.eventId;
    const channelId = eventData.channelId as string;
    const title = eventData.title as string;
    const scheduledAt = eventData.scheduledAt as admin.firestore.Timestamp;
    const organizerId = eventData.organizerId as string;

    const scheduledDate = scheduledAt.toDate();
    const formattedDate = `${scheduledDate.getMonth() + 1}/${scheduledDate.getDate()} ` +
      `${scheduledDate.getHours()}:${String(scheduledDate.getMinutes()).padStart(2, "0")}`;

    const payload: NotificationPayload = {
      title: "새로운 벙이 생성되었습니다! 🎉",
      body: `${title} - ${formattedDate}`,
      data: { type: "eventCreated", eventId, channelId },
    };

    const result = await sendNotificationToChannel(channelId, payload, [organizerId]);
    console.log(`Event created: ${result.successCount} success, ${result.failureCount} failed`);
    await saveNotification(channelId, [], "eventCreated", payload);
  },
);

/**
 * Trigger: Event Status Changed
 */
export const onEventStatusChanged = onDocumentUpdated(
  "events/{eventId}",
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    if (!beforeData || !afterData) return;

    const oldStatus = beforeData.status as EventStatus;
    const newStatus = afterData.status as EventStatus;
    if (oldStatus === newStatus) return;

    const eventId = event.params.eventId;
    const channelId = afterData.channelId as string;
    const title = afterData.title as string;
    const participantIds = afterData.participantIds as string[] || [];
    const organizerId = afterData.organizerId as string;

    let payload: NotificationPayload | null = null;
    let recipientIds: string[] = [];

    switch (newStatus) {
    case EventStatus.closed:
      payload = {
        title: "벙 모집이 마감되었습니다",
        body: title,
        data: { type: "eventClosed", eventId, channelId },
      };
      await sendNotificationToChannel(channelId, payload, [organizerId]);
      break;

    case EventStatus.settlement:
      payload = {
        title: "정산이 시작되었습니다",
        body: `${title} - 정산 정보를 확인해주세요`,
        data: { type: "settlementCreated", eventId },
      };
      recipientIds = participantIds.filter((id: string) => id !== organizerId);
      await sendNotificationToUsers(recipientIds, payload);
      break;

    case EventStatus.completed:
      payload = {
        title: "벙이 완료되었습니다 ✅",
        body: title,
        data: { type: "eventCompleted", eventId },
      };
      recipientIds = participantIds;
      await sendNotificationToUsers(recipientIds, payload);
      break;

    case EventStatus.cancelled:
      payload = {
        title: "벙이 취소되었습니다",
        body: `${title}이(가) 취소되었습니다`,
        data: { type: "eventCancelled", eventId },
      };
      recipientIds = participantIds.filter((id: string) => id !== organizerId);
      await sendNotificationToUsers(recipientIds, payload);
      break;

    default:
      return;
    }

    if (payload && recipientIds.length > 0) {
      console.log(`Event ${newStatus} sent to ${recipientIds.length} users`);
      await saveNotification(channelId, recipientIds, newStatus, payload);
    }
  },
);

/**
 * Trigger: Participant Joined Event
 */
export const onParticipantJoined = onDocumentUpdated(
  "events/{eventId}",
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    if (!beforeData || !afterData) return;

    const beforeParticipants = beforeData.participantIds as string[] || [];
    const afterParticipants = afterData.participantIds as string[] || [];
    if (afterParticipants.length <= beforeParticipants.length) return;

    const newParticipantIds = afterParticipants.filter(
      (id: string) => !beforeParticipants.includes(id),
    );
    if (newParticipantIds.length === 0) return;

    const eventId = event.params.eventId;
    const organizerId = afterData.organizerId as string;
    const title = afterData.title as string;

    for (const participantId of newParticipantIds) {
      const userDoc = await db.collection("users").doc(participantId).get();
      const participantName = userDoc.data()?.displayName || "새로운 참여자";

      const payload: NotificationPayload = {
        title: "새로운 참여자가 있습니다! 👋",
        body: `${participantName}님이 ${title}에 참여했습니다`,
        data: { type: "eventJoined", eventId, participantId },
      };

      await sendNotificationToUsers([organizerId], payload);
    }
  },
);

/**
 * Trigger: Participant Left Event
 */
export const onParticipantLeft = onDocumentUpdated(
  "events/{eventId}",
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    if (!beforeData || !afterData) return;

    const beforeParticipants = beforeData.participantIds as string[] || [];
    const afterParticipants = afterData.participantIds as string[] || [];
    if (afterParticipants.length >= beforeParticipants.length) return;

    const removedParticipantIds = beforeParticipants.filter(
      (id: string) => !afterParticipants.includes(id),
    );
    if (removedParticipantIds.length === 0) return;

    const eventId = event.params.eventId;
    const organizerId = afterData.organizerId as string;
    const title = afterData.title as string;

    for (const participantId of removedParticipantIds) {
      if (participantId === organizerId) continue;

      const userDoc = await db.collection("users").doc(participantId).get();
      const participantName = userDoc.data()?.displayName || "참여자";

      const payload: NotificationPayload = {
        title: "참여 취소 알림",
        body: `${participantName}님이 ${title} 참여를 취소했습니다`,
        data: { type: "eventLeft", eventId, participantId },
      };

      await sendNotificationToUsers([organizerId], payload);
    }
  },
);
