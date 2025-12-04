import psutil
import socket

def get_nic_name():
    ips = {}
    for nic, addrs in psutil.net_if_addrs().items():
        ip_list = []
        
        for addr in addrs:
            if addr.family == socket.AF_INET and addr.address.startswith("192."):
                return nic, addr.address
    return None

if __name__ == "__main__":
    nic, ip = get_nic_name()
    print("{}:{}".format(nic, ip))
