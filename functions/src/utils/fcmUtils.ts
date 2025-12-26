import * as admin from "firebase-admin";
import { Message } from "firebase-admin/messaging";

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Notification payload interface
 */
export interface NotificationPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}

/**
 * Get all FCM tokens for a list of user IDs
 */
export async function getUserTokens(userIds: string[]): Promise<string[]> {
  const tokens: string[] = [];

  for (const userId of userIds) {
    try {
      const userDoc = await db.collection("users").doc(userId).get();
      if (userDoc.exists) {
        const data = userDoc.data();

        // New fcmTokens Map structure (multi-device)
        const fcmTokensMap = data?.fcmTokens as Record<string, unknown> | undefined;
        if (fcmTokensMap && Object.keys(fcmTokensMap).length > 0) {
          tokens.push(...Object.keys(fcmTokensMap));
        } else {
          // Legacy fcmToken field
          const fcmToken = data?.fcmToken as string | undefined;
          if (fcmToken) {
            tokens.push(fcmToken);
          }
        }
      }
    } catch (error) {
      console.error(`Failed to get tokens for user ${userId}:`, error);
    }
  }

  return tokens;
}

/**
 * Get all active member IDs from a channel
 */
export async function getChannelMemberIds(channelId: string): Promise<string[]> {
  try {
    const channelDoc = await db.collection("channels").doc(channelId).get();
    if (!channelDoc.exists) {
      return [];
    }

    const data = channelDoc.data();
    const activeMembers = data?.activeMembers as Array<{ userId: string }> | undefined;

    if (activeMembers && activeMembers.length > 0) {
      return activeMembers.map((member) => member.userId);
    }

    return [];
  } catch (error) {
    console.error(`Failed to get channel members for ${channelId}:`, error);
    return [];
  }
}

/**
 * Send FCM notifications to a list of tokens
 */
export async function sendNotificationToTokens(
  tokens: string[],
  payload: NotificationPayload,
): Promise<{ successCount: number; failureCount: number }> {
  if (tokens.length === 0) {
    return { successCount: 0, failureCount: 0 };
  }

  const messages: Message[] = tokens.map((token) => ({
    token,
    notification: {
      title: payload.title,
      body: payload.body,
    },
    data: payload.data,
    android: {
      priority: "high" as const,
      notification: {
        sound: "default",
        channelId: "default_channel",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          badge: 1,
        },
      },
    },
  }));

  try {
    const response = await messaging.sendEach(messages);
    console.log(`Sent ${response.successCount} messages, ${response.failureCount} failed`);

    // Clean up invalid tokens
    const tokensToRemove: string[] = [];
    response.responses.forEach((resp, idx) => {
      if (!resp.success) {
        const error = resp.error;
        if (
          error?.code === "messaging/invalid-registration-token" ||
          error?.code === "messaging/registration-token-not-registered"
        ) {
          tokensToRemove.push(tokens[idx]);
        }
      }
    });

    // Remove invalid tokens from database (async, don't wait)
    if (tokensToRemove.length > 0) {
      removeInvalidTokens(tokensToRemove).catch(console.error);
    }

    return {
      successCount: response.successCount,
      failureCount: response.failureCount,
    };
  } catch (error) {
    console.error("Failed to send notifications:", error);
    return { successCount: 0, failureCount: tokens.length };
  }
}

/**
 * Send notification to specific users
 */
export async function sendNotificationToUsers(
  userIds: string[],
  payload: NotificationPayload,
): Promise<{ successCount: number; failureCount: number }> {
  const tokens = await getUserTokens(userIds);
  return sendNotificationToTokens(tokens, payload);
}

/**
 * Send notification to all channel members
 */
export async function sendNotificationToChannel(
  channelId: string,
  payload: NotificationPayload,
  excludeUserIds: string[] = [],
): Promise<{ successCount: number; failureCount: number }> {
  const memberIds = await getChannelMemberIds(channelId);
  const filteredMemberIds = memberIds.filter((id) => !excludeUserIds.includes(id));
  return sendNotificationToUsers(filteredMemberIds, payload);
}

/**
 * Remove invalid tokens from database
 */
async function removeInvalidTokens(tokens: string[]): Promise<void> {
  console.log(`Removing ${tokens.length} invalid tokens`);

  // Get all users and remove invalid tokens
  const usersSnapshot = await db.collection("users").get();

  for (const userDoc of usersSnapshot.docs) {
    const data = userDoc.data();
    const fcmTokensMap = data?.fcmTokens as Record<string, unknown> | undefined;

    if (fcmTokensMap) {
      const tokensToDelete = Object.keys(fcmTokensMap).filter((t) => tokens.includes(t));
      if (tokensToDelete.length > 0) {
        const updates: Record<string, admin.firestore.FieldValue> = {};
        tokensToDelete.forEach((t) => {
          updates[`fcmTokens.${t}`] = admin.firestore.FieldValue.delete();
        });
        await userDoc.ref.update(updates);
      }
    }
  }
}

/**
 * Save notification to Firestore for history
 */
export async function saveNotification(
  channelId: string,
  recipientIds: string[],
  type: string,
  payload: NotificationPayload,
): Promise<string> {
  const notificationRef = db.collection("notifications").doc();

  await notificationRef.set({
    id: notificationRef.id,
    channelId,
    recipientIds,
    type,
    title: payload.title,
    message: payload.body,
    data: payload.data || {},
    status: "sent",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return notificationRef.id;
}
