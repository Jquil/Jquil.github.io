# 前言

同样在工作中经常也有这么个需求，需要定时发送邮件，这里记录一下实现过程~


# 实现

新建一个WinForm项目，增加一个Button控件，用来触发 “发送邮件” 事件

首先来了解一下一封邮件的组成，一封邮件含有：

1. 标题

2. 收件人、副本

3. 正文（可以有样式、HTML）

4. 附件


我们新建一个`MyMail.cs`来专门处理邮件相关的功能：

```
namespace WinFormsApp1
{
    class MyMail
    {
        public MyMail instance;

        private SmtpClient smtp;
        private MailAddress address;
        private MailMessage mail;

        public MyMail()
        {
            instance = this;
            init();
        }

        private void init(){
            smtp = new SmtpClient();
            mail = new MailMessage();
            smtp.Credentials = new System.Net.NetworkCredential(mailFrom, mailPwd); // set sendUser's account & password
            smtp.Host = host;                                                       // set smtp host
            mail.from = mailFrom;                                                   // set sendUser's account
            mail.SubjectEncoding = Encoding.UTF8;
        }

        public MyMail setSubject(string subject)
        {
            instance.mail.Subject = subject;
            return instance;
        }

        public MyMail setBody(string body)
        {
            instance.mail.Body = body;
            return instance;
        }

        public MyMail setTo(string[] to)
        {
            for(int i = 0; i < to.Length; i++){
                instance.mail.To.Add(to[i]);
            }
            return instance;
        }

        public MyMail setCC(string[] cc)
        {
            for(int i = 0; i < cc.Length; i++){
                instance.mail.CC.Add(cc[i]);
            }
            return instance;
        }

        public MyMail setAtach(string[] atach)
        {
            Attachment file = null;
            for(int i = 0; i < atach.Length; i++){
                file = new Attachment(atach[i]);
                instance.mail.Attachments.Add(file);
            }
            return instance;
        }

        public MyMail setBodyIsHtml(bool isBodyHtml) {
            instance.mail.IsBodyHtml = isBodyHtml;
            return instance;
        }

        public MyMail setPriority(MailPriority priority){
            instance.mail.Priority = priority;
            return instance;
        }

        public void send()
        {
            smtp.Send(mail);
        }

        [System.Runtime.InteropServices.DllImport("kernel32.dll", SetLastError = true)]
        [return: System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.Bool)]
        static extern bool AllocConsole();

        [System.Runtime.InteropServices.DllImport("Kernel32")]
        public static extern void FreeConsole();

    }
}
```



然后我们去调用实现发邮件~

```

```

<div align='center'>

贴上效果图
</div>


# 定时

现在再加上定时功能，实现定时发邮件~

我们新建一个**Windows服务**项目

1. 双击Service1.cs 添加安装程序

2. 安装完成后，设置serviceInstaller1服务名称为程序名称

3. 设置serviceProcessInstaller1的`Account = LocalSystem`

然后来对`Service1.cs`进行修改

```
namespace WindowService1{
    
    public partial class Service1 : ServiceBase{

        public Service1{
            InitializeComponent();
        }

        protected override void OnStart(string[] args){
            System.Timers.Timer timer = new System.Timers.Timer();
            timer.Enabled  = true;
            timer.Interval = 60000;         // 执行间隔时间,单位为毫秒;此时时间间隔为1分钟  
            timer.Start();
            timer.Elapsed += new System.Timers.ElapsedEventHandler(test); 
        }

        protected override void OnStart(){
            // todo   
        }

        private static void test(object source, ElapsedEventArgs e)
        {

            if (DateTime.Now.Hour == 8 && DateTime.Now.Minute == 30){
                // 发送邮件
            }
        }
    }
}
```

[使用VS2015创建C#Windows服务定时程序](https://blog.csdn.net/dekesun/article/details/88225791)

[解决windows 服务中定时器timer 定时偶尔失效问题](https://blog.csdn.net/aoan5704/article/details/102069998)

[C#使用Timer.Interval指定时间间隔与指定时间执行事件](https://www.cnblogs.com/wusir/p/3636149.html)

# 补充

现在有这么个需求：需要将数据导出为Excel并贴到附件上，这如何实现呢?


其实也是一样的，只要获取导出后的路径就可以了~



[C# 实现邮件发送](https://www.cnblogs.com/akwwl/p/3191713.html)