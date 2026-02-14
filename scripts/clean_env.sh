#ps -ef | grep -E 'docker/(runc|containerd)' | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
