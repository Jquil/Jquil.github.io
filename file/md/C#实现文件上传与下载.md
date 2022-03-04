# 前言

在工作中，文件的上传与下载也是比较常见的需求，在这里也简单记录一下实现过程；


# 上传文件

之前我们有写过这么一篇记录「[前后端关于Excel的导入与导出](https://jqwong.cn/#/show?type=article&fileId=140)」，文章中没有前后台交互的；

那我们这里就简单实现一下交互过程，前台将文件上传到后台，由后台解析文件并将数据返回给前台显示；

效果和之前也是一样的，如下所示：

<div align='center'>

![](https://static.jqwong.cn/20220226001.gif)
</div>

上传文件时的触发方法有所不同：
```
<script>
export default {
  name: 'HelloWorld',
  data () {
    return {
      data:[]
    }
  },
  methods:{
    onChange(file){
      let formData = new FormData()
      formData.append("file",file.raw)
      this.$axios({
         method: "POST",
         url: "http://localhost:62764/upload",
         headers: {
           'Content-Type': "multipart/form-data",
         },
         transformRequest: [function(){
             return formData;
         }],
         data: formData,
         params: formData,
      })
      .then(res => {
        this.data = res.data
      })
      .catch(error => {
        console.log(error)
      })
    }
  }
}
</script>
```

涉及到上传文件我们需要封装成FormData格式，把文件添加进去，再Post到后台处理；

再看看后台处理：
```
namespace WebApplication.Controllers
{
    public class FileController : ApiController
    {
        [Route("upload")]
        [HttpPost]
        public IHttpActionResult Upload()
        {
            var files   = HttpContext.Current.Request.Files;
            List<Person> data = new List<Person>();
            if (files[0] != null) {
                // 假裝解析完成
                for(int i = 0; i < 20; i++)
                {
                    data.Add(new Person() { name=$"王{i+1}",sex = i % 2== 0 ? "男" : "女",age = i+1});
                }
            }
            return Json<List<Person>>(data);
        }

        class Person {
            public string name { get; set; }
            public string sex { get; set; }
            public int age { get; set; }
        }
    }
}
```

通过`HttpContext.Current.Request.Files`拿到请求中的文件，如果需要将上传文件保存在本地，只需要通过以下方法即可：
```
files[0].SaveAs(filename); // D:\\demo\\demo.txt
```


我们再来封存一个保存文件的方法：
```

```



# 文件下载

关于文件的下载，这里将主要展示以下两种实现：

【1】本地文件的下载

【2】Excel的导出（本地不存在该文件）


流的方式 本地文件方式

```
namespace WebApplication.Controllers
{
    public class FileController : ApiController
    {
        [HttpGet,Route("download")]
        public HttpResponseMessage Download()
        {
            // 替换文件名以及文件路径即可；
            string file = "132.md";
            string path = $"{AppDomain.CurrentDomain.BaseDirectory}File\\{file}";

            FileStream stream = new FileStream(path, FileMode.Open);
            HttpResponseMessage response = new HttpResponseMessage(HttpStatusCode.OK);
            response.Content = new StreamContent(stream);
            response.Content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
            response.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
            {
                FileName = HttpUtility.UrlEncode(file)
            };
            response.Headers.Add("Access-Control-Expose-Headers", "FileName");
            response.Headers.Add("FileName", HttpUtility.UrlEncode(file));
            return response;
        }
    }
}
```

```
HttpContext curContext = HttpContext.Current;
curContext.Response.AddHeader("Content-Disposition",
"attachment;filename=" + HttpUtility.UrlEncode(DateTime.Now.ToString("yyyyMMddHHmmss") + ".xlsx", Encoding.UTF8));
MemoryStream ms = getStream();
if (ms != null)
{
    curContext.Response.BinaryWrite(ms.ToArray());
}
ms.Close();
ms.Dispose();
curContext.Response.End();
```


# 小结

[1] [axios传 file文件 （多文件上传）](read://https_blog.csdn.net/?url=https%3A%2F%2Fblog.csdn.net%2Fsiwangdexie_copy%2Farticle%2Fdetails%2F109565599)

[2] [C#进阶系列——WebApi 接口参数不再困惑：传参详解 ](https://www.cnblogs.com/landeanfen/p/5337072.html)

[3] [C#进阶系列——WebApi 接口返回值不困惑：返回值类型详解 ](https://www.cnblogs.com/landeanfen/p/5501487.html)

[4] [NPOI 导入导出和Excel版本，错误文件扩展名和文件的格式不匹配](https://blog.csdn.net/xuexiaodong009/article/details/83084751)

[5] [使用HttpRequest.Files 获取上传文件，实现上传附件功能](read://https_www.cnblogs.com/?url=https%3A%2F%2Fwww.cnblogs.com%2Fshixl%2Fp%2F7280149.html)