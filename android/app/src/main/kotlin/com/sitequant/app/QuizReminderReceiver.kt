package com.sitequant.app

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import java.util.Calendar

object QuizReminderScheduler {
    const val action = "com.sitequant.app.WEEKLY_QUIZ"
    const val openAction = "com.sitequant.app.OPEN_QUIZ"
    private const val requestCode = 4107
    private const val preferencesName = "quiz_reminder"
    private const val enabledKey = "enabled"

    fun schedule(context: Context) {
        cancel(context)
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setInexactRepeating(
            AlarmManager.RTC_WAKEUP,
            nextTriggerMillis(),
            AlarmManager.INTERVAL_DAY * 7,
            reminderIntent(context),
        )
        context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit().putBoolean(enabledKey, true).apply()
    }

    fun cancel(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(reminderIntent(context))
        reminderIntent(context).cancel()
        context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
            .edit().putBoolean(enabledKey, false).apply()
    }

    fun rescheduleIfEnabled(context: Context) {
        if (context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
                .getBoolean(enabledKey, false)
        ) schedule(context)
    }

    private fun reminderIntent(context: Context) = PendingIntent.getBroadcast(
        context,
        requestCode,
        Intent(context, QuizReminderReceiver::class.java).setAction(action),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    private fun nextTriggerMillis(): Long {
        val trigger = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 7)
            set(Calendar.HOUR_OF_DAY, 18)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        return trigger.timeInMillis
    }
}

class QuizReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != QuizReminderScheduler.action) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
                PackageManager.PERMISSION_GRANTED
        ) return

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(
                    "weekly_quiz",
                    "Weekly Quiz Reminder",
                    NotificationManager.IMPORTANCE_DEFAULT,
                ),
            )
        }
        val openIntent = Intent(context, MainActivity::class.java).apply {
            action = QuizReminderScheduler.openAction
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val contentIntent = PendingIntent.getActivity(
            context,
            4108,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notification = NotificationCompat.Builder(context, "weekly_quiz")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("Time for your weekly quiz 🏗️")
            .setContentText("Take 10 questions and test your construction knowledge.")
            .setAutoCancel(true)
            .setContentIntent(contentIntent)
            .build()
        manager.notify(4107, notification)
    }
}

class QuizReminderBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED) {
            QuizReminderScheduler.rescheduleIfEnabled(context)
        }
    }
}
