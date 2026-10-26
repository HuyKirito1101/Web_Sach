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
public class ShipperIncomeAnalyticsDTO {
    private int selectedYear;
    private int selectedMonth;
    private double totalYearIncome;
    private double currentMonthIncome;
    private List<Integer> availableYears;
    private List<Double> yearlyMonths;
    private Map<Integer, List<Double>> monthlyData;
}
