CACHING_URL="cache-service.nginx-pypi-cache.svc.cluster.local"
pip config set global.index-url http://${CACHING_URL}/pypi/simple
pip config set global.extra-index-url "https://pypi.tuna.tsinghua.edu.cn/simple"
pip config set global.trusted-host "${CACHING_URL} pypi.tuna.tsinghua.edu.cn"


