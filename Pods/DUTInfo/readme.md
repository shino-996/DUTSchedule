大连理工大学相关校园网站信息的抓取，swift 4 编写，使用了 PromiseKit 进行异步调用，以及 Fuzi 解析 HTML.

# 可以抓到的信息

- 本学期课程表
- 本学期考试安排
- 本学期成绩
- 玉兰卡及网络支付账户余额
- 校园网各种信息

# 抓取的网站

- [教务处][teach]（校园网访问）

- [校园门户][portal]（外网可访问）

# 账户和密码

- 学号

    9位数的学号，只试过本科生的

- 教务处密码

    默认是身份证号后6位，就是选课时用的那个密码

- 校园门户密码

    默认也是身份证号后6位

# 使用方法

目前还没有提交到 cocoapod, 所以需要在 pod 后面额外添加本项目 github 地址, 比如:

``` ruby
platform :ios, '9.0'
use_frameworks!
swift_version = '4.0'

target 'DUTInfoDemo' do
  pod 'DUTInfo', :git => 'https://github.com/shino-996/DUTInfo.git'
end
```

因为项目本身使用 [Fuzi][fuzi] 和 [PromiseKit][promisekit] 开发, 安装此 pod 同时也会安装这两个 pod.

[teach]: http://zhjw.dlut.edu.cn
[portal]: https://portal.dlut.edu.cn
[fuzi]: https://github.com/cezheng/Fuzi
[promisekit]: https://github.com/mxcl/PromiseKit