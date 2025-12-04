import ipaddress
import psutil
import socket

def get_nic_name():
    net_io_stats = psutil.net_if_addrs()
    interfaces_with_192_ips = {}

    for interface, addrs in net_io_stats.items():
        for addr in addrs:
            if addr.family == socket.AF_INET:
                try:
                    ip = ipaddress.ip_address(addr.address)
                except ValueError:
                    continue
                if ip.is_private and ip.network.network_address == ipaddress.IPv4Network('192.0.0.0/8').network_address:
                    interfaces_with_192_ips[interface] = addr.address

    return interfaces_with_192_ips

interfaces = get_nic_name()
for interface, ip in interfaces.items():
    print(f"Interface: {interface}, IP Address: {ip}")



