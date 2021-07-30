# 前言

之前有看到（但忘记在哪看到）的一个Banner图片过渡动画，最终实现的效果如下：

<div align='center'>

这里贴上效果图

</div>

为了实现这个效果，一共试了三种方法

# V1

一开始打算使用`border-radius`这个属性，就不断让右下角的值变大来实现

但想法是很好的，只是....

<div align='center'>

贴上效果图

</div>

emmmm，终究只是改变右下角的圆角部分...代码如下：
```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<style>
    #img{
        width: 250px;
        transform: scale(1);
        transform-origin: top left;
        transition: transform 0.8s ease-in-out;
    }
</style>
<body>
    <img id="img" src="https://static.jqwong.cn/FhzMz3mFE2kVZ9hwrUW2J91rIF1S"/>
</body>
<script>
    var img = document.getElementById("img")
    var i1 = 0
    
    var interval1 = setInterval(() => {
        i1++
        img.style.borderBottomRightRadius = i1 + "px"
    }, 1);
</script>
</html>
```


# V2


后面打算用`Canvas`来绘制，通过清除来实现过渡效果


<div align='center'>

贴上效果图

</div>

代码如下：
```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<style>
    html,body{
        padding: 0;
        margin: 0;
    }
    canvas{
        width: 250px;
        height: 250px;
        z-index: 999;
    }
    .pos{
        width: 250px;
        height: 250px;
        position: absolute;
        left: 0;
        z-index: -999;
    }
</style>
<body>
    <img src="https://static.jqwong.cn/FpSFAO1PHs3OI-divvnnfjtUFZiE" class="pos"/>
    <canvas id="canvas"></canvas>
</body>
<script>
    var canvas  = document.getElementById("canvas")
    var context = canvas.getContext("2d")
    canvas.width  = 250
    canvas.height = 250
    var img = new Image()
    img.src = "https://static.jqwong.cn/FhzMz3mFE2kVZ9hwrUW2J91rIF1S"
    img.onload = function(){
        context.drawImage(img,0,0)
    }

    canvas.onclick = function(){
        var i = 0
        var interval = setInterval(()=>{
            i+=2
            if(i>900)
                clearInterval(interval)
            stepClear = 1
            clearArc(0,0,i)
        },1)
        //clearArc(0,0,100)
    }

    function clearArc(x,y,radius){//圆心(x,y)，半径radius
        var calcWidth=radius-stepClear;
        var calcHeight=Math.sqrt(radius*radius-calcWidth*calcWidth);
        
        var posX=x-calcWidth;
        var posY=y-calcHeight;
        
        var widthX=2*calcWidth;
        var heightY=2*calcHeight;
        
        if(stepClear<=radius){
            context.clearRect(posX,posY,widthX,heightY);
            stepClear+=1;
            clearArc(x,y,radius);
        }
    }
    var stepClear=1;

    // https://blog.csdn.net/xiongqiangwin1314/article/details/48573245
</script>
</html>
```


效果是实现了，但我觉得这种实现可能，emmmmm，性能不太好

# V3

然后，又将实现思路返回到DOM元素上，这次是通过`background`来实现，渐变颜色

<div align='center'>

贴上效果图
</div>


代码如下：
```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<style>
    html,body,#app{
        padding: 0;
        margin: 0;
        width: 100%;
    }
    #app{
        display: flex;
        flex-direction: column;
        align-items: center;
    }
    .banner{
        width: 250px;
        height: 100px;
        margin-top: 20px;
        position: relative;
    }
    .d{
        width: 100%;
        height: 100%;
        position: absolute;
        background-position: top left;
        background-size: 100% 100%;
    }
    .d>img{
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
</style>
<body>
    <div id="app">
        <div class="banner">
            <div class="d">
                <img src="https://static.jqwong.cn/FpSFAO1PHs3OI-divvnnfjtUFZiE"/>
            </div>
            <div class="d" style="background: url(https://static.jqwong.cn/FhzMz3mFE2kVZ9hwrUW2J91rIF1S);">
                <!-- <img src="https://static.jqwong.cn/FhzMz3mFE2kVZ9hwrUW2J91rIF1S"/> -->
            </div>
        </div>
    </div>
</body>
<script>
    //var d1 = document.getElementById("d1")
    //var i = 0
    
    var sI = 0
    var allD = document.getElementsByClassName("d")
    for(var i = 0; i < allD.length; i++){
        allD[i].onclick = function(){
            var interval = setInterval(()=>{
                sI+=1
                if(sI>300){
                    clearInterval(interval)
                    //sI=0
                }
                console.log(sI)
                this.style.background = "radial-gradient(circle at bottom right, transparent "+sI+"px, #dadada 50%)"
            },1)
        }
    }
    // https://www.w3cplus.com/css3/css-secrets/cutout-corners.html
    // https://www.runoob.com/cssref/func-radial-gradient.html
    
</script>
</html>
```


通过`background`实现渐变背景，但很明显的缺点就是一开始的颜色会覆盖掉图片


# 最终版

CSS中有一个属性：`clipPath`

> MDN：clip-path CSS 属性使用裁剪方式创建元素的可显示区域。区域内的部分显示，区域外的隐藏。

很明显，这个属性正好可以实现我们的需求，并且可以实现出非常有趣的效果


效果图就如文章开头贴出来的一致：

<div align='center'>
最终版效果图
</div>

代码如下：
```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<style>
    img{
        width: 250px;
        height: 100px;
        object-fit: cover;
        position: absolute;
        top: 0;
        left: 0;
    }
    .show{
        z-index: 999 !important;
    }
</style>
<body>
    <div id="app">
        <img src="https://static.jqwong.cn/FhzMz3mFE2kVZ9hwrUW2J91rIF1S" style="z-index: 1;"/>
        <img src="https://static.jqwong.cn/FpSFAO1PHs3OI-divvnnfjtUFZiE"/>
        <img src="https://static.jqwong.cn/FgzK-8OBNI7suiieYNLTEXsBReME"/>
    </div>
</body>
<script>
    var app   = document.getElementById("app")
    var imgs  = app.children
    var index = 0,zIndex = 1
    app.onclick = function(){
        zIndex++
        let i = index == imgs.length - 1 ? 0 : index + 1
        index = i
        imgs[index].setAttribute("style","z-index:"+zIndex+";")
        show(imgs[index])
    }

    function show(el){
        let i = 0
        var interval = setInterval(()=>{
            i++
            if(i>150){
                clearInterval(interval)
            }
            el.style.clipPath = "circle("+i+"% at bottom right)"
        },1)
    }
    // https://www.imooc.com/wenda/detail/319126
    // https://developer.mozilla.org/zh-CN/docs/Web/CSS/clip-path
    // http://www.htmleaf.com/Demo/201512212931.html
    // https://www.html.cn/tool/css-clip-path/

</script>
</html>
```


# 小结

虽然说这个效果不是特别地特别地叼，但实现起来还是费了一段时间

emmm，OK文章先到这里，拜了个拜~