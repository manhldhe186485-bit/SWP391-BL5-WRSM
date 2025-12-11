package com.warranty.util;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Random;

/**
 * Utility class for generating unique numbers/codes
 */
public class NumberGenerator {
    
    private static final Random random = new Random();

    /**
     * Generate unique ticket number
     * Format: TK-YYYYMMDD-XXXX
     */
    public static String generateTicketNumber() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        String datePart = sdf.format(new Date());
        int randomPart = 1000 + random.nextInt(9000);
        return "TK-" + datePart + "-" + randomPart;
    }

    /**
     * Generate unique parts request number
     * Format: PR-YYYYMMDD-XXXX
     */
    public static String generatePartsRequestNumber() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        String datePart = sdf.format(new Date());
        int randomPart = 1000 + random.nextInt(9000);
        return "PR-" + datePart + "-" + randomPart;
    }

    /**
     * Generate customer code
     * Format: CUST-XXXXXX
     */
    public static String generateCustomerCode() {
        int randomPart = 100000 + random.nextInt(900000);
        return "CUST-" + randomPart;
    }

    /**
     * Generate product code
     * Format: PROD-XXXXXX
     */
    public static String generateProductCode() {
        int randomPart = 100000 + random.nextInt(900000);
        return "PROD-" + randomPart;
    }

    /**
     * Generate item code
     * Format: ITEM-XXXXXX
     */
    public static String generateItemCode() {
        int randomPart = 100000 + random.nextInt(900000);
        return "ITEM-" + randomPart;
    }
}
