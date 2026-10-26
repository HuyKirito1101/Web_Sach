package vn.iotstar.websach.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;
import java.util.Map;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VendorRevenueAnalyticsDTO {
    private int selectedYear;
    private int selectedMonth;
    private double totalYearRevenue;
    private double yearlyTotalRevenue;
    private double currentMonthTotal;
    private List<Integer> availableYears;
    private List<Double> yearlyMonths;
    private List<Double> monthlyRevenues;
    private Map<Integer, List<Double>> monthlyData;
    private Map<Integer, List<Double>> dailyRevenuesByMonth;
}
