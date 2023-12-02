最近需要实现一个需求，当我们对一个电池进行测试时中途会产生需要的数据（电压电流功率能量容量等），我们需要将这些数据转化会折线图的形式以便我们更直观观察这个电池测试过程；

在实现这种图表功能这里我们使用了`ScottPlot.WinForms`的库，然后我们模拟一些数据后生成折线图是这样的：
<div align='center'>

![](https://jquil.github.io/file/markdown/note/187/img/Snipaste_2023-12-02_20-27-48.png)
</div>

这样的图形客户看起来就会感觉很混乱，因此我们需要这曲线继续分离，分离之后的效果如下：

<div align='center'>

![](https://jquil.github.io/file/markdown/note/187/img/Snipaste_2023-12-02_20-31-56.png)
</div>

曲线分离的思路其实设置Y轴刻度的最大最小值，接下来进入正题，如何去计算这个最大最小值：

在测试数据中我们造了四条曲线，在分离时我们就是将一块区分平分四份也就是对应四块区域，每条曲线占一块区域；

对于这么一条曲线，我们需要将它放在第一块区域：
<div align='center'>

![](https://jquil.github.io/file/markdown/note/187/img/Snipaste_2023-12-02_20-54-20.png)
</div>

它的max=25，min=-25，那么我们通过max-min可以得出max与min之间的距离distance=50；我们可以看出这条曲线在它对应的区域内是有一个上下边距的；

这里我们就设定边距padding=distance/10，现在我们就可以得出这块区域的高度=padding_top + padding_bottom + distance = 60，那么整体高度就是240；

既然我们要将它放在第一块区域，那么就很容易计算出y轴的最大值= max + padding_top = 30，y轴最小值也可以很简单的就计算出来：min - padding_bottom - 3*block_height = -25-5-180=-210；


当上面的方法并不适用在直线上：
<div align='center'>

![](https://jquil.github.io/file/markdown/note/187/img/Snipaste_2023-12-02_21-16-41.png)
</div>


因为一条直线在一块区域内是处于一个居中的位置，它将一块区域一分为二，那么我们就可以认为一块区域它的高度就是2，同样还是很简单就计算出这条直线在y轴上的最大值就是1，最小值就是-7；


思路有了，然后我们使用代码实现曲线分离的功能：
```csharp
private void SplitCurve(params Axis[] array_axis) {
    if (array_axis == null || array_axis.Length == 0)
        return;
    for(var i = 0; i < array_axis.Length; i++)
    {
        var axis = array_axis[i];
        var plottable = formsPlot1.Plot.GetSettings().Plottables.Where(it => it.YAxisIndex == axis.AxisIndex).FirstOrDefault();
        if (plottable == null)
            continue;
        foreach(var it in array_axis)
        {
            it.LockLimits(it.AxisIndex != axis.AxisIndex);
        }
        if(plottable is SignalPlot signal)
        {
            var max = signal.Ys.Max();
            var min = signal.Ys.Min();
            var distance = max - min;
            if(distance == 0)
            {
                var block_height = 2;
                var total_height = array_axis.Length * block_height;
                max = block_height * i + 1;
                min = max - total_height;
            }
            else
            {
                var padding = distance / 5;
                var block_height = padding * 2 + distance;
                var total_height = array_axis.Length * block_height;
                max = max + padding + (block_height * i);
                min = min - padding - (block_height * (array_axis.Length - 1 - i));
            }
            formsPlot1.Plot.SetAxisLimits(yMin:min,yMax:max,yAxisIndex:axis.AxisIndex);
        }
    }
    foreach (var it in array_axis)
    {
        it.LockLimits();
    }
}
```