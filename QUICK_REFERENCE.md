# 🚀 Quick Reference Card

## 🔔 Send Notification (30 sec)

```
1. Menu → Admin Panel → Notification Settings
2. Enter Title & Message
3. Tap "Send Now"
✅ Done! All users notified
```

---

## ⏰ Schedule Daily Reminder (1 min)

```
1. Admin Panel → Notification Settings
2. Daily Reminder → Change Time
3. Select Time → Update
✅ Users get daily reminders!
```

---

## 🎯 User Settings

```
Menu → Notifications
- Toggle ON/OFF
- Change Time
- Test Notification
```

---

## 🧪 Test Notifications

### Test When App Open
```
Admin Panel → Notification Settings → Test Notification
```

### Test When App Closed
```
1. Close app completely
2. Admin Panel (on another device) → Send Test
3. Check notification appears ✅
```

---

## 📁 Key Files

- **Service:** `lib/services/notification_service.dart`
- **Admin:** `lib/screens/admin/notification_settings_screen.dart`
- **User:** `lib/screens/notification_preferences_screen.dart`
- **Docs:** `NOTIFICATIONS_COMPLETE.md`

---

## 🐛 Not Working?

1. Check permissions: Settings → Apps → Love Stories → Notifications ✅
2. Check in-app: Menu → Notifications → Toggle ON ✅
3. Rebuild app: `flutter clean && flutter run` ✅

---

## 💡 Quick Commands

```bash
# Rebuild app
flutter clean && flutter run

# Get dependencies
flutter pub get

# Check for issues
flutter doctor
```

---

## 📊 Features

✅ Work when app closed
✅ Daily reminders
✅ Weekly alerts
✅ Instant notifications
✅ User control
✅ Test functionality

---

**Read full docs:** `NOTIFICATIONS_COMPLETE.md` 📚
