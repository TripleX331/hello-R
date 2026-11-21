#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "rpkg.template", header: "")

= 季节分量移除

`RemoveSeasonal(y, t_mmdd)` 按月日等季节索引分组，计算各组均值，并将观测值
减去对应均值：

$ "anomaly" = y - mu_(t_("mmdd")) $

各季节均值按季节索引升序排列。

= 分段回归

分段回归使用公共斜率，不同区间使用独立截距。

== 单断点

`LS_OneBreak(Y, X, Ic)` 中，位置 `Ic` 为第一段末尾：

$
  y_i = beta_0 + beta_1 x_i + beta_2 I(i > I_c) + epsilon_i
$

传入 `Ic = NA` 可拟合没有断点的线性回归。

== 多断点

`LS_MultiBreaks(Y, X, Ips)` 的 `Ips` 是各段的末尾位置，末位必须等于序列长度。
例如 `Ips = c(3, 6)` 表示第一段为位置 1--3，第二段为位置 4--6。

= R 示例

```R
y <- c(10, 12, 20, 22)
t_mmdd <- c(101, 101, 102, 102)
seasonal <- RemoveSeasonal(y, t_mmdd)

x <- 1:6
y2 <- c(1, 2, 3, 7, 8, 9)
one_break <- LS_OneBreak(y2, x, Ic = 3)
```
