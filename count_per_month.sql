SELECT m.month, IFNULL(a.budgets_approved_pmonth, 0) AS budgets_approved_pmonth, IFNULL(b.approved_cancelled_pmonth, 0) AS approved_cancelled_pmonth
FROM (
  SELECT DISTINCT DATE_FORMAT(datetime_execution_budget_approved, '%Y-%m') AS month FROM service_order WHERE YEAR(datetime_execution_budget_approved) = 2022
  UNION
  SELECT DISTINCT DATE_FORMAT(datetime_approved_cancelled, '%Y-%m') AS month FROM service_order WHERE YEAR(datetime_approved_cancelled) = 2022
) AS m
LEFT JOIN (
  SELECT DATE_FORMAT(datetime_execution_budget_approved, '%Y-%m') AS month, COUNT(*) AS budgets_approved_pmonth
  FROM service_order
  WHERE YEAR(datetime_execution_budget_approved) = 2022
  GROUP BY month
) AS a ON m.month = a.month
LEFT JOIN (
  SELECT DATE_FORMAT(datetime_approved_cancelled, '%Y-%m') AS month, COUNT(*) AS approved_cancelled_pmonth
  FROM service_order
  WHERE YEAR(datetime_approved_cancelled) = 2022
  GROUP BY month
) AS b ON m.month = b.month
ORDER BY m.month;
