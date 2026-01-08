# proxy

#CACHING_URL="cache-service.nginx-pypi-cache.svc.cluster.local"
#sed -Ei "s@(ports|archive).ubuntu.com@${CACHING_URL}:8081@g" /etc/apt/sources.list
#pip config set global.index-url http://${CACHING_URL}/pypi/simple
#pip config set global.extra-index-url "https://pypi.tuna.tsinghua.edu.cn/simple"
#pip config set global.trusted-host "${CACHING_URL} pypi.tuna.tsinghua.edu.cn"

apt update
apt install systemd
apt install systemctl

apt install mysql-server

vi /etc/mysql/my.cnf
[mysqld]
bind-address = 0.0.0.0

systemctl start mysql
systemctl enable mysql

mysql -u root
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Huawei@123';
FLUSH PRIVILEGES;

CREATE USER 'test' IDENTIFIED BY 'Huawei@123';
GRANT ALL ON performance_db.* TO 'test';

CREATE USER 'grafanaReader' IDENTIFIED BY 'Changeme_123';
GRANT SELECT ON performance_db.* TO 'grafanaReader';
FLUSH PRIVILEGES;


# 临时跳过证书验证
tee -a /etc/apt/apt.conf.d/99allow-insecure <<EOF
Acquire::https::apt.grafana.com::Verify-Peer "false";
Acquire::https::apt.grafana.com::Verify-Host "false";
EOF

tee -a /etc/apt/apt.conf.d/99allow-unsigned <<EOF
APT::Get::AllowUnauthenticated "true";
Acquire::AllowInsecureRepositories "true";
Acquire::AllowDowngradeToInsecureRepositories "true";
EOF

# 清空原有配置并写入稳定版源
tee /etc/apt/sources.list.d/grafana.list <<EOF
deb https://apt.grafana.com stable main
EOF

apt update
apt install grafana

#apt update如果报dbus.service错误
#vi /etc/systemd/system/dbus.service
# @/usr/bin/dbus-daemon @dbus-daemon 改成/usr/bin/dbus-daemon
#systemctl daemon-reload

vi /etc/grafana/grafana.ini
# 修改http_pport
chown grafana:grafana /run/grafana

systemctl daemon-reload
systemctl start grafana-server
systemctl status grafana-server
systemctl enable grafana-server.service


# 恢复安全验证
rm /etc/apt/apt.conf.d/99allow-insecure
rm /etc/apt/apt.conf.d/99allow-unsigned
