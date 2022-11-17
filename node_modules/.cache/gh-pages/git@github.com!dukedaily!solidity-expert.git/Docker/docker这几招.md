# 镜像相关：

1. 下载：docker pull golang
2. 搜索：docker search golang
3. 改名：docker tag golang:1.11 golang-duke:1.11
4. 保存：docker save -o golang.tar golang:1.11
5. 导入：docker load < golang.tar
6. 删除：docker rmi golang:1.11
7. 历史：docker history golang:1.11
8. 详细：docker inspect golang:1.11
9. 容器创建镜像：
   1. docker commit <容器id> nginx_test:1.0 //此时镜像生成
   2. docker save -o nginx_test.tar nginx_test:1.0 //此时存储到本地


# 容器相关：

## 创建容器：

1. 先创建：docker create -it --name duke-ubuntu ubuntu /bin/bash  //后面的名字在启动的时候会执行， 如果未指定，会默认执行镜像内置的命令
2. 再启动：docker start -ia duke-ubuntu  //创建之后， 能否再start的时候进入交互模式，关键在于create 后面的it，如果没加上，start之后会立刻退出
3. 其他：exit退出之后，容器关闭

## 启动容器：

1. 运行一次退出删除：docker run --rm --name duke-golang golang:1.11 /bin/ls
2. 运行后进行交互：docker run -it --name duke-golang golang:1.11 /bin/bash
3. 运行后台运行：  docker run -it -d --name duke-golang golang:1.11 /bin/bash   //启动之后，在后台运行，别忘了-it，后面的命令可选
4. 访问后台容器：  docker exec -it duke-golang /bin/bash  //后面的命令别忘了

## 容器启动关闭重启：

1. 暂停：docker pause duke-golang //名字或id
2. 恢复：docker unpause duke-golang
3. 重启：docker restart duke-golang
4. 关闭：docker kill duke-golang
5. 删除：docker rm duke-golang
6. 强删：docker rm -f duke-golang
7. 批量删除所有，慎用：docker rm `docker ps -aq`

## 重要参数：

1. -i:交互
2. -t:终端
3. -a:attach //start时使用
4. -e 配置环境变量 key=value
5. -v 挂载数据卷
6. \- -privileged：root权限运行docker

## 其他操作：

1. 查看日志：docker logs duke-golang
2. 重命名：docker rename duke-golang duke-new-golang
3. 屏幕太小时，格式化输出：可以在.bashrc中增加别名解决：alias dps="docker ps -a --format 'table {{.ID}} {{.Names}}\t{{.Status}}\t{{.Command}}\t{{.Ports}}'"

# 数据卷相关：

## 直接拷贝：

1. docker cp 宿主机目录/文件 容器名/容器Id:容器路径（双向的）
2. docker cp ./Dockerfile duke-golang:/Dockerfile

## 挂载数据卷：（手动指定目录）

1. docker run -itd --name test -v 宿主机的路径:容器的路径 ubuntu bash
2. docker run -it --name duke-golang111 -v /tmp/testfolder:/testfolder golang:1.12.6 /bin/bash
3. 注意，宿主机尽量先创建文件夹，一般先从容器端写数据是限制的，共享不过来

## 数据卷容器：（为了容器具共享）

1. 创建一个数据卷容器：docker create -v /data --name v1-test1 nginx
2. 新建一个容器X，并挂载：docker run --volumes-from 4693558c49e8 -tid --name vc-test1 nginx /bin/bash
3. 新建一个容器Y，并挂载：docker run --volumes-from 4693558c49e8 -tid --name vc-test2 nginx /bin/bash，此时三者共享数据
4. 如果在启动X,Y的时候，再在本地进行挂载，则实现数据备份：
5. 创建备份：docker run --rm --volumes-from 4693558c49e8 -v /home/itcast/backup/:/data/ nginx tar zcPf /backup/data.tar.gz /data
6. 恢复备份：docker run --rm --volumes-from 4693558c49e8 -v /home/itcast/backup/:/data/ nginx tar xPf /backup/data.tar.gz -C /newdata

## docker卷，存储卷（自动创建目录）

1. docker volume create my-vol //这个my-vol是宿主机目录的代表
2. docker inspect my-vol //查看这个docker卷在宿主机上的位置
3. docker run -d —name devtest -v my-vol:/app:ro nginx:latest //只读，使用方式
4. docker volume list
5. docker volume rm my-vol

# 网络：

1. 随机端口映射：
   1. -P代表随机端口，不用接参数
   2. docker run -itd -P --name mynginx nginx  // 宿主机端口 -> 容器端口，注意方向
   3. netstat -tunlp	

2. 指定端口映射/指定多端口映射 -> 推荐
3. 宿主机:容器，可以指定ip，可以指定多个端口
   1. docker run -d -p 192.168.8.14:1199:80 --name nginx-2 nginx
   2. docker run -itd -p 80:80 -p 81:81 --name mynginx nginx 


## 创建网络

1. docker network create -d <网络驱动类型> <网络名字>
2. docker network create -d bridge duke-bridge
3. 网络驱动类型：
4. bridge（默认），自己网段
   1. host宿主机，共享网段

   2. none，独立的网络空间，不创建网络信息，无网卡，需要自己添加

   3. user-deined网络：

   4. bridge：自己指定网络172.0.19.1/24
      1. overlay：跨主机网络，swarm
      2. macvlan: 跨主机网络
      3. container：与加入的容器共享网络
5. docker network ls

## 加入指定网络：

1. docker run -it --name test1 --network bridge_test ubuntu bash
2. docker run -itd --name test3 --network host ubuntu bash //host网络
3. —net 可以选择四种类型：bridge/host/none/containe
4. —net和--network相同,--network是新参数

# Dockerfile：

将应用程序打包成镜像的描述文件

## 构成信息：

1. entrypoint，一定会执行，一般会提供一个docker-entrypoint.sh脚本，用于前置执行，
2. cmd会被用户输入的命令覆盖。
3. 用户输入的cmd可以作为参数传递给这个脚本，从而进行一些自定义的参数



这个可以看一下课件里面的demo，运行很顺利，

1. 只有几个命令:FROM, MAINTANIER, RUN, ADD, COPY, WORKDIR, ENV, CMD, ENTRYPOINT, EXPOSE, 
2. 打包镜像：docker build -t duke-beego:v1 .



## docker-compose: 

对镜像容器进行编排

尽量在服务的docker-compose.yml所在目录执行命令

1. 每个服务创建单独的目录，命名就叫：docker-compose.yml
2. 后缀是：.yml，支持的语法是：yaml
3. docker-compose up -d
4. docker-compose down
5. docker-compose ps

对单独服务进行处理：

1. docker-compose start <web1> //web1是一个服务名，仅存在且stop时可以启动
2. docker-compose stop <web1> //同理，仅在存在且start时可以关闭
3. docker-compose rm 
4. 如果不加上后面的服务，则默认对所有服务执行操作

## 其他：

1. docker-compose logs -f //持续查看日志
2. docker-compose exec <web1> /bin/bash //进入容器

# docker swarm 

//创建集群，创建共享网络

1. docker swarm init

2. docker swarm join-token manager //另外一台机器以manager节点加入

3. docker swarm join-token worker //另外一台机器以worker节点加入

4. docker node ls //查看当前节点 ，leader, attachable 备选manager

5. docker network ls //ingress集群管理网络

6. docker network create -d overlay —attachable swarm_test //创建一个共享网络

7. 主动退出网络：docker swarm leave —force (manager节点)

8. 被动退出网络：
   1. manager：先降级，再删除
      1. docker node demote <名字> //docker node ls获取名字

      2. docker node rm <名字> //需要关闭这个节点的docker后台进程，然后在其他节点执行删除

   2. node：docker node rm <名字> //直接删除

9. 图形界面管理swarm：需要下载启动这个镜像
   1. docker pull portainer/portainer && docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer
