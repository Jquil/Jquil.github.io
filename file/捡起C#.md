# 前言

读书的时候会学过C#，现在回想起来当时所学的知识，其实好像是有用的(当时都认为没啥用)，并且以前并不知道多态的重要性

但这么久过去，我也不是特别熟悉C#这门语言了。现在刚好有时间，就重新捡起来~

这里关于C#的基础（数据类型，abstract，interface..）就先略过，看看别的没有接触到的操作，例如说：C#数据库的操作

# Database

新建完成一个WinForm项目后，双击窗体，进入编辑：

首先，我们需要引入所需的类：`using System.Data.SqlClient`，然后开始编辑吧


## 连接

```
...
using System.Data.SqlClient;

namespace WindowsFormsApplication2
{
    public partial class Form1 : Form
    {
        // 1
        private const string connStr = "server=192.168.1.26;database=DB-DG20808;Trusted_Connection=SSPI";
        private static SqlConnection conn;

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            // 3
            connnect();
        }

        // 2
        private void connnect() {
            try
            {
                conn = new SqlConnection(connStr);
                conn.Open();
                //MessageBox.Show("OK", "Database Open");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "title");
            }
        }
    }
}
```


数据库的连接分一下几步：

1. 定义连接信息（字符串），以及数据库连接对象

2. 编写一个function，用来连接数据库 => 其实就是构建一个数据库连接对象，然后通过`open（）`打开

3. 在窗体加载的时候去调用该function


## 查询

我们朝c窗体里面放一个DataGridView控件，以及一个Button按钮并设置点击事件

```
// 查询
private void button1_Click(object sender, EventArgs e)
{
    String SQL = "select * from tbPerson";
    SqlDataAdapter adapter = new SqlDataAdapter(SQL,conn);
    DataSet set = new DataSet();
    adapter.Fill(set);
    dataGridView1.DataSource = set.Tables[0];
    dataGridView1.Columns[0].HeaderText = "序号";
    dataGridView1.Columns[0].HeaderText = "姓名";
}
```


效果图如下所示：

<div align='center'>

</div>

看代码不难理解其意思：

1. 构建SQL数据适配器，两个参数（sql语句，数据库连接对象）

2. 通过`SqlDataAdapter.Fill()`填充到集合对象上（DataSet）

3. 设置DataGridView数据来源为：Dataset中的表上


## 其他操作


拖一个Button按钮，用于添加数据
```
// 添加
private void button2_Click(object sender, EventArgs e)
{
    String sql = "insert into tbPerson(name) values('C#666')";
    SqlCommand sc = new SqlCommand(sql,conn);
    try
    {
        int res = sc.ExecuteNonQuery();
        if (res != -1)
        {
            MessageBox.Show("Insert OK", " Database Command");
        }
    }
    catch (Exception ex) {
        MessageBox.Show(ex.ToString());
    }
}
```

emmm，其实的删除，修改都是类似，就不再复述了


## 数据更新

我们刚才添加了一笔数据，但是DataGridView中是没有更新的。我们可以怎么做呢？

傻瓜式地将查询语句拷一份：
```
// 添加
private void button2_Click(object sender, EventArgs e)
{
    String sql = "insert into tbPerson(name) values('C#666')";
    SqlCommand sc = new SqlCommand(sql,conn);
    try
    {
        int res = sc.ExecuteNonQuery();
        if (res != -1)
        {
            MessageBox.Show("Insert OK", " Database Command");
            String SQL = "select * from tbPerson";
            SqlDataAdapter adapter = new SqlDataAdapter(SQL, conn);
            DataSet set = new DataSet();
            adapter.Fill(set);
            dataGridView1.DataSource = set.Tables[0];
        }
    }
    catch (Exception ex) {
        MessageBox.Show(ex.ToString());
    }
}
```


高级一点的，用到一个`SqlCommandBuilder`的类，它可以用来帮助我们自动生成CURD语句
```
// 添加
private void button2_Click(object sender, EventArgs e)
{
    // 1. 获取到新的ID,构建Row并添加
    DataTable tb   = mSet.Tables[0];
    DataRow row    = tb.Rows[tb.Rows.Count - 1];
    int newId      = Convert.ToInt32(row[0]) + 1;
    String newName = "Jq666C#";
    DataRow newRow = tb.NewRow();
    newRow[0] = newId;
    newRow[1] = newName;
    tb.Rows.Add(newRow);

    // 2. 更新数据
    mAdapter.Update(mSet);
    tb.AcceptChanges();
    dataGridView1.DataSource = tb;
}
```

ok，^ ^

# 网络请求

首先引入该两个类：
```
using System.Net;
using System.IO;
```

放置一个Button用于网络请求事件
```
// 网络请求
private void button4_Click(object sender, EventArgs e)
{
    GET();
}

private void GET() {
    String url = "https://www.wanandroid.com/article/list/0/json";
    HttpWebRequest req = (HttpWebRequest)WebRequest.Create(url);
    req.Method = "GET";
    HttpWebResponse res = (HttpWebResponse)req.GetResponse();
    Stream stream = res.GetResponseStream();
    StreamReader reader = new StreamReader(stream,Encoding.UTF8);
    MessageBox.Show(reader.ReadToEnd().ToString());
}
```


这里只实现了GET请求，POST请求也一样，修改`Method`即可。

1. 请求是用：`HttpWebRequest`

2. 响应时是用：`HttpWebResponse`

3. 然后就是读取字节流，转码


其实还有挺多细节没有实现的，例如说Model，转为JSON数组形式...




# 打印文件

在控件集合中有一个栏位叫“打印”，其下有这几个控件：

- PrintDocument
  定义了向打印机发送输出的对象

<div></div>

- PageSetupDialog
  打印页面设置

<div></div>

- PrintPreviewControl
  打印预览格式：窗体中设置预览区域

<div></div>

- PrintPreviewDialog
  打印预览格式：弹窗中设置预览区域

<div></div>

- PrintDialog
  选择打印机开始打印


首先，放置两个按钮：预览按钮、打印按钮，以及拖**PrintDocument，PrintPreviewDialog，PrintDialog**到窗体


双击PrintDocument控件进入编辑模式：
```
// 打印设置
private void printDocument1_PrintPage(object sender, System.Drawing.Printing.PrintPageEventArgs e)
{
    // ------------------------------------------------------------------------------------------------------
    // 绘制标题----------------------------------------------------------------------------------------------
    String title = "中华人民共和国";

    // 标题字体
    Font titleFont = new Font("微软雅黑", 18, FontStyle.Bold);
    
    // 标题尺寸
    SizeF titleSize = e.Graphics.MeasureString(title, titleFont, e.MarginBounds.Width);
    
    // x坐标
    int x = e.MarginBounds.Left;
    
    // y坐标
    int y = Convert.ToInt32(e.MarginBounds.Top - titleSize.Height);
    
    // 边距以内纸张宽度
    int pagerWidth = e.MarginBounds.Width;
    
    // 绘制标题
    e.Graphics.DrawString(title, titleFont, Brushes.Black, x + (pagerWidth - titleSize.Width) / 2, y);
    y += (int)titleSize.Height;


    // ------------------------------------------------------------------------------------------------------
    // 绘制表头----------------------------------------------------------------------------------------------
    // 1. 测量表头所需高度
    int headerHeight = 0;
    int columnSize = dataGridView1.Columns.Count;
    int headerWidth = pagerWidth / columnSize;
    Font headerFont = new Font("微软雅黑", 16, FontStyle.Bold);
    for (int i = 0; i < columnSize; i++) {
        int temp = (int)e.Graphics.MeasureString(dataGridView1.Columns[i].HeaderText,headerFont,headerWidth).Height;
        headerHeight = temp > headerHeight ? temp : headerHeight;
    }
    
    // 2. 开始绘制
    int startX = e.MarginBounds.Left + headerWidth / 2;
    y += headerHeight;
    for (int i = 0; i < columnSize; i++){
        SizeF size = e.Graphics.MeasureString(dataGridView1.Columns[i].HeaderText,headerFont,headerWidth);
        startX -= ((int)size.Width / 2);
        e.Graphics.DrawString(dataGridView1.Columns[i].HeaderText, headerFont, Brushes.Black, startX, y);
        startX += headerWidth;
    }
    y += headerHeight;


    // ------------------------------------------------------------------------------------------------------
    // 绘制数据----------------------------------------------------------------------------------------------
    int dataWidth  = headerWidth;
    int dataHeight = headerHeight;
    int paddingBottom = 5;
    Font dataFont = new Font("微软雅黑", 14, FontStyle.Bold);
    int rowIndex = 0;
    DataGridViewRow row;
    y += paddingBottom;
    while (rowIndex < dataGridView1.RowCount) { 
        row = dataGridView1.Rows[rowIndex];
        startX = e.MarginBounds.Left + dataWidth / 2;
        foreach( DataGridViewCell cell in row.Cells ){
            try{
                SizeF size = e.Graphics.MeasureString(cell.Value.ToString(), dataFont, dataWidth);
                startX -= ((int)size.Width / 2);
                e.Graphics.DrawString(cell.Value.ToString(), dataFont, Brushes.Black, startX, y);
                startX += dataWidth;
            }
            catch (Exception ex) {
                // todo
            }
        }
        rowIndex++;
        y += dataHeight + paddingBottom;
    }
}
```

OK，然后我们为预览按钮、打印按钮添加事件：
```
// 预览
private void button5_Click(object sender, EventArgs e)
{
    printPreviewDialog1.Document = printDocument1;
    printPreviewDialog1.Show();
}

// 打印
private void button6_Click(object sender, EventArgs e)
{
    printDialog1.Document = printDocument1;
    DialogResult dr = printDialog1.ShowDialog();
    if (dr == DialogResult.OK) {
        printDocument1.Print();
    }
}
```


需要注意的是：我们需要先点击查询按钮，将数据查出来了，再去预览和打印~


OK，最后效果图如下所示：

<div align='center'>

贴效果图
</div>

# 窗体的切换

本文的最后，再介绍一下窗体的切换，需求如下：

窗体顶部中有一个标签栏，点击某个标签就切换到该标签所对应的窗体下

为了方便，这里重新新建一个WinForm应用

为窗体放置一个ToolScript，并添加两个Label标签并添加点击事件，然后再放置一个Pannel控件


关键一步：为应用添加两个WinForm窗体win1，win2，并在各窗体下新增一些有标识的控件，并将窗体的`FormBorderStyle`改为None


回到我们的应用中，添加代码

```
namespace WindowsFormsApplication3
{
    public partial class Form1 : Form
    {
        private win1 w1;
        private win2 w2;
        private List<Form> list = new List<Form>();
        public Form1()
        {
            InitializeComponent();
        }
        
        private void Form1_Load(object sender, EventArgs e)
        {
            this.IsMdiContainer = true;
            w1 = new win1();
            w2 = new win2();
            list.Add(w1);
            list.Add(w2);
            initForm();
        }

        private void initForm() {
            for (int i = 0; i < list.Count; i++)
            {
                list[i].MdiParent = this;
                list[i].Parent = panel1;
            }
        }

        private void toolStripLabel1_Click(object sender, EventArgs e)
        {
            show(w1);
        }

        private void toolStripLabel2_Click(object sender, EventArgs e)
        {
            show(w2);
        }

        private void show(Form form) {
            form.Show();
            panel1.Controls.Clear();
            panel1.Controls.Add(form);
        }

    }
}
```

# 小结

本文大概就写这些吧，其实大部分东西都是相通的~

附上学习文章：

[C语言中文网：C#教程](http://c.biancheng.net/)

[SqlCommandBuilder 可批量新增与修改数据](https://www.cnblogs.com/kongbailingluangan/p/5448767.html)

[C#使用NPOI导出Excel](https://jingyan.baidu.com/article/aa6a2c14b6e2da0d4c19c42a.html)

[C#-打印](https://www.cnblogs.com/qq450867541/p/6170651.html)

[C#实现多个子窗体切换效果](https://blog.csdn.net/weixin_44985880/article/details/107341973)

[C#WinForm父级窗体内Panel容器中嵌入子窗体、程序主窗体设计例子](https://www.cnblogs.com/JiYF/p/9031699.html)


文章先到这，拜了个拜~