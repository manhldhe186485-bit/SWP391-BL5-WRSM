package com.warranty.util;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Utility class for importing Excel files
 */
public class ExcelUtil {

    /**
     * Read Excel file and convert to list of maps
     * Each map represents a row with column name as key
     */
    public static List<Map<String, Object>> readExcelFile(InputStream inputStream, String[] columnNames) 
            throws IOException {
        
        List<Map<String, Object>> dataList = new ArrayList<>();
        
        try (Workbook workbook = new XSSFWorkbook(inputStream)) {
            Sheet sheet = workbook.getSheetAt(0);
            
            // Skip header row (assuming first row is header)
            int startRow = 1;
            
            for (int i = startRow; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                
                Map<String, Object> rowData = new HashMap<>();
                boolean hasData = false;
                
                for (int j = 0; j < columnNames.length && j < row.getLastCellNum(); j++) {
                    Cell cell = row.getCell(j);
                    Object cellValue = getCellValue(cell);
                    
                    if (cellValue != null && !cellValue.toString().trim().isEmpty()) {
                        hasData = true;
                    }
                    
                    rowData.put(columnNames[j], cellValue);
                }
                
                if (hasData) {
                    dataList.add(rowData);
                }
            }
        }
        
        return dataList;
    }

    /**
     * Get cell value based on cell type
     */
    private static Object getCellValue(Cell cell) {
        if (cell == null) {
            return null;
        }

        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue().trim();
                
            case NUMERIC:
                if (org.apache.poi.ss.usermodel.DateUtil.isCellDateFormatted(cell)) {
                    return new Date(cell.getDateCellValue().getTime());
                } else {
                    double numericValue = cell.getNumericCellValue();
                    // Check if it's a whole number
                    if (numericValue == Math.floor(numericValue)) {
                        return (long) numericValue;
                    }
                    return BigDecimal.valueOf(numericValue);
                }
                
            case BOOLEAN:
                return cell.getBooleanCellValue();
                
            case FORMULA:
                try {
                    return cell.getNumericCellValue();
                } catch (Exception e) {
                    return cell.getStringCellValue();
                }
                
            case BLANK:
                return null;
                
            default:
                return cell.toString();
        }
    }

    /**
     * Convert object to string safely
     */
    public static String getString(Map<String, Object> map, String key) {
        Object value = map.get(key);
        return value != null ? value.toString().trim() : null;
    }

    /**
     * Convert object to Date safely
     */
    public static Date getDate(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value instanceof Date) {
            return (Date) value;
        } else if (value instanceof java.util.Date) {
            return new Date(((java.util.Date) value).getTime());
        }
        return null;
    }

    /**
     * Convert object to BigDecimal safely
     */
    public static BigDecimal getBigDecimal(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value instanceof BigDecimal) {
            return (BigDecimal) value;
        } else if (value instanceof Number) {
            return BigDecimal.valueOf(((Number) value).doubleValue());
        }
        return null;
    }

    /**
     * Convert object to Integer safely
     */
    public static Integer getInteger(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        return null;
    }
}
