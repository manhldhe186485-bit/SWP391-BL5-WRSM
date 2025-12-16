package com.warranty.util;

import java.sql.Date;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Calendar;

/**
 * Utility class for date operations
 */
public class DateUtil {

    /**
     * Add months to a date
     */
    public static Date addMonths(Date date, int months) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        calendar.add(Calendar.MONTH, months);
        return new Date(calendar.getTimeInMillis());
    }

    /**
     * Check if a date is expired (before today)
     */
    public static boolean isExpired(Date date) {
        LocalDate localDate = date.toLocalDate();
        LocalDate today = LocalDate.now();
        return localDate.isBefore(today);
    }

    /**
     * Check if a date is within warranty period
     */
    public static boolean isWithinWarranty(Date warrantyEndDate) {
        return !isExpired(warrantyEndDate);
    }

    /**
     * Format date to string
     */
    public static String formatDate(Date date, String pattern) {
        if (date == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat(pattern);
        return sdf.format(date);
    }

    /**
     * Get current SQL date
     */
    public static Date getCurrentSqlDate() {
        return new Date(System.currentTimeMillis());
    }

    /**
     * Convert LocalDate to SQL Date
     */
    public static Date toSqlDate(LocalDate localDate) {
        return Date.valueOf(localDate);
    }
}
