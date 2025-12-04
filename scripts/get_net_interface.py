import psutil
import socket

def get_192_ip_interfaces():
    interface_ips = {}

    for interface_name, addrs in psutil.net_if_addrs().items():
        ip_list = []
        for addr in addrs:
            if addr.family == socket.AF_INET and addr.address.startswith("192."):
                ip_list.append(addr.address)
        
        if ip_list:
            interface_ips[interface_name] = ip_list
    
    return interface_ips

if __name__ == "__main__":
    result = get_192_ip_interfaces()
    
    if result:
        print("=== 192.开头IP对应的网卡信息 ===")
        for if_name, ips in result.items():
            print(f"网卡名: {if_name}")
            print(f"  192.开头IP: {', '.join(ips)}")
            print("-" * 50)
    else:
        print("未找到任何192.开头的IPv4地址对应的网卡")