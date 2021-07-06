# 搜索
GET:
> https://c.y.qq.com/soso/fcgi-bin/client_search_cp?&t=0&aggr=1&cr=1&catZhida=1&lossless=0&flag_qc=0&p=1&n=20&w={key}

JSOn数据需要二次处理^ ^

# 歌词
GET:
> http://api.geci.me/en/latest/index.html#indices-and-tables

# 歌曲地址
POST:{mid}
> http://www.douqq.com/qqmusic/qqapi.php

GET:修改{songmid}
> https://u.y.qq.com/cgi-bin/musicu.fcg?format=json&data=%7B%22req_0%22%3A%7B%22module%22%3A%22vkey.GetVkeyServer%22%2C%22method%22%3A%22CgiGetVkey%22%2C%22param%22%3A%7B%22guid%22%3A%22358840384%22%2C%22songmid%22%3A%5B%22{songmid}%22%5D%2C%22songtype%22%3A%5B0%5D%2C%22uin%22%3A%221443481947%22%2C%22loginflag%22%3A1%2C%22platform%22%3A%2220%22%7D%7D%2C%22comm%22%3A%7B%22uin%22%3A%2218585073516%22%2C%22format%22%3A%22json%22%2C%22ct%22%3A24%2C%22cv%22%3A0%7D%7D

# TOP100
GET:
> https://c.y.qq.com/v8/fcg-bin/fcg_v8_toplist_cp.fcg?g_tk=5381&uin=0&format=json&inCharset=utf-8&outCharset=utf-8%C2%ACice=0&platform=h5&needNewCode=1&tpl=3&page=detail&type=top&topid=27&_=15199631229230

JSOn数据需要二次处理^ ^

# 格式
1. 「m4a」　.C400
2. 「mp3_l」>M500
3. 「mp3_h　 M800
4. 「ape」 >　A000
5. 「flac」　　F000
6. 「pic」　 　T002


# 文章

1. [[Python] Python 收费、高品质无损音乐下载【开源】](https://www.52pojie.cn/thread-767941-1-1.html)

1. [QQ音乐API分析之-加密参数分析(sign计算)](https://blog.csdn.net/qq_23594799/article/details/111477320)

1. [2019最新QQ音乐Api](https://blog.csdn.net/qq_41979349/article/details/102458551)