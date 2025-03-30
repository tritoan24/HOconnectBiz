// Tạo file: android/app/src/main/java/com/hoconnectbiz/app/NotificationServiceExtension.java
package com.hoconnectbiz.app;

import com.onesignal.OSNotificationReceivedEvent;
import com.onesignal.OneSignal.OSRemoteNotificationReceivedHandler;

public class NotificationServiceExtension implements OSRemoteNotificationReceivedHandler {
    @Override
    public void remoteNotificationReceived(OSNotificationReceivedEvent event) {
        // Tùy chỉnh thông báo nếu cần
        // Ví dụ: thêm action buttons, thay đổi sound...

        // Không gọi complete() để ngăn thông báo hiển thị
        // event.complete(null);

        // Hoặc gọi complete() để cho phép thông báo hiển thị
        event.complete(event.getNotification());
    }
}