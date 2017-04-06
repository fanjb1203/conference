Truffle版本是3.1.2

https://github.com创建库

本地/home/app（app是我自己放代码的目录，自己可以随便创建）下：
从git拉去代码：git clone https://github.com/fanjb1203/conference.git
cd conference
mkdir migrations
mkdir contracts
从其他项目copy truffle.js到conference文件夹
从其他项目copy Migrations.sol到conference/contracts文件夹
从其他项目copy 1_initial_migration.js 到conference/migrations
编译：truffle compile，没错误继续


目录contracts下新建智能合约：Conference.sol
目录conference/migrations 创建文件：2_deploy_contracts.js
编译：truffle compile，没错误继续

目录conference下：mkdir test
在test目录下添加conference.js
truffle test 测试没有错误继续

build(truffle升级到3.0以后，我不知道怎么部署web应用，暂时把html、js等放在此目录)
在build目录下添加conference.js, conference.html
创建dist目录，并添加如下js
hooked-web3-provider.min.js  jquery.min.js  lightwallet.min.js  truffle-contract.js  truffle-contract.min.js  web3.js  web3.js.map  web3-light.js  web3-light.min.js  web3.min.js

conference.html：买票，退票，创建钱包
