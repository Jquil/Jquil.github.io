当我们想要在字符串中匹配字串时，最容易想到的就是暴力破解；但有一种算法更加效率，kmp算法；

它的思想就是利用已经匹配成功的字符，算出最长公共前后缀，然后实现子串与主串的对齐；

<div align='center'>

![](https://jquil.github.io/file/markdown/note/185/img/1.png)
</div>

例如上面这张图，当匹配到'C'匹配失败时，由于前面的'ABAB'已经匹配成功了，我们可以算出它的公共最长前后缀是'AB'，我们就让子串对齐主串，像这样：

<div align='center'>

![](https://jquil.github.io/file/markdown/note/185/img/2.png)
</div>

对齐之后我们继续匹配下一个字符即可，这个效率就比暴力破解高效多了；

当匹配到错误字符时，我们可以通过next数组去查询'可以跳过字符数'使之对齐，接下来我们还是以'ABABC'为子串分步解析next数组的生成：

```csharp
namespace ConsoleApp
{
    public class KmpHelper
    {
        public int[] PartialMatchTable(string child) {
            var len = child.Length;
            var next = new List<int>();
            var builder = new StringBuilder();
            var array = child.ToCharArray();
            var list1 = new List<string>();
            var list2 = new List<string>();
            foreach(var ch in array)
            {
                builder.Append(ch);
                var str = builder.ToString();
                var s1 = str.Remove(str.Length - 1, 1);
                var s2 = str.Remove(0, 1);
                if (string.IsNullOrEmpty(s1) || string.IsNullOrEmpty(s2))
                {
                    next.Add(0);
                }
                else
                {
                    list1.Add(s1);
                    for (var i = 0; i < list2.Count; i++)
                        list2[i] = $"{list2[i]}{ch}";
                    list2.Insert(0, ch.ToString());
                    if (list1.Count != list2.Count)
                        throw new Exception("parse error!");
                    var pairs = new Dictionary<string, int>();
                    for(var i = 0; i < list1.Count; i++)
                    {
                        if (list1[i] == list2[i])
                        {
                            var key = list1[i];
                            if (pairs.ContainsKey(key))
                                pairs[key]++;
                            else
                                pairs.Add(key, 1);
                        }
                    }
                    if (pairs.Any())
                        next.Add(pairs.Max().Key.Length);
                    else
                        next.Add(0);

                }
                Console.WriteLine($"str={str},prefix=[{string.Join(",",list1)}],suffix=[{string.Join(",", list2)}],code={next.Last()}");
            }
            return next.ToArray();
        }
    }
}
```

主函数调用该函数输出结果：
<div align='center'>

![](https://jquil.github.io/file/markdown/note/185/img/3.png)
</div>

这里的code代表着最长公共前后缀的字符长度，因此子串对应next数组如下：
<div align='center'>

![](https://jquil.github.io/file/markdown/note/185/img/4.png)
</div>

上面获取next数组的方法可以继续优化：首先我们可以确定子串中第一个字符和第二个的字符前后缀是不相等，因此在next中对应位置一定是0；

我们只需要一次遍历就可以计算出最长公共前后缀，它的思想同样是利用已知信息；

我们从子串第三个字符开始遍历，定义一个游标`cursor`从0开始，两者不断匹配是否相等，当匹配失败时我们需要再去判断是否存在更短的公共前后缀；

<div align='center'>

![](https://jquil.github.io/file/markdown/note/185/img/5.gif)
</div>

```csharp
namespace ConsoleApp
{
    public class KmpHelper
    {
        public int[] PartialMatchTable(string child) {
            var len = child.Length;
            var next = new int[len];
            if (len > 1)
                next[0] = 0;
            if (len > 2)
                next[1] = 0;
            var index = 2;
            var cursor = 0;
            while(index < len)
            {
                var ch1 = child[index];
                var ch2 = child[cursor];
                if(ch1 == ch2)
                {
                    cursor++;
                    next[index] = cursor;
                }
                else
                {
                    if(cursor != 0)
                    {
                        var tmp = next[cursor - 1];
                        if (tmp != 0)
                        {
                            next[index] = child[tmp] == ch1 ? ++tmp : 0;
                        }
                        cursor = 0;
                    }
                }
                index++;
            }
            return next;
        }
    }
}
```


附上完整代码：
```csharp
namespace ConsoleApp
{
    public class KmpHelper
    {
        public int[] Match(string master, string child) {
            var next = PartialMatchTable(child);
            var data = new List<int>();
            var len = master.Length;
            var cursor = 0;
            for(var i = 0; i < len; i++)
            {
                var ch1 = master[i];
                var ch2 = child[cursor];
                if(ch1 == ch2)
                {
                    if (cursor == child.Length - 1)
                    {
                        cursor = 0;
                        data.Add(i - child.Length + 1);
                    }
                    else
                    {
                        cursor++;
                    }
                }
                else
                {
                    if(cursor != 0)
                    {
                        cursor = next[cursor - 1];
                        i--;
                    }
                }
            }
            return data.ToArray();
        }
        public int[] PartialMatchTable(string child) {
            var len = child.Length;
            var next = new int[len];
            if (len > 1)
                next[0] = 0;
            if (len > 2)
                next[1] = 0;
            var index = 2;
            var cursor = 0;
            while(index < len)
            {
                var ch1 = child[index];
                var ch2 = child[cursor];
                if(ch1 == ch2)
                {
                    cursor++;
                    next[index] = cursor;
                }
                else
                {
                    if(cursor != 0)
                    {
                        var tmp = next[cursor - 1];
                        if (tmp != 0)
                        {
                            next[index] = child[tmp] == ch1 ? ++tmp : 0;
                        }
                        cursor = 0;
                    }
                }
                index++;
            }
            return next;
        }
    }
}
```


回顾kmp算法整个实现过程，我认为它的思想是“利用已知信息，提高程序执行效率”，而它的实现就是通过寻找最长公共前后缀，当匹配失败时通过查表实现字符对齐；

而后面next数组的生成，同样也是利用这种思想帮助我们改进的程序执行效率；


最后附上学习文章：

[1] [字符串匹配的KMP算法](https://www.ruanyifeng.com/blog/2013/05/Knuth%E2%80%93Morris%E2%80%93Pratt_algorithm.html)

[2] [最浅显易懂的 KMP 算法讲解](https://www.bilibili.com/video/BV1AY4y157yL)

