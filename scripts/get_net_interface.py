import ipaddress
import netifaces

def find_interface_by_ip(ip_address):
    try:
        ip = ipaddress.ip_address(ip_address)
    except ValueError:
        print("Invalid IP address")
        return None
    
    interfaces = netifaces.interfaces()
    for interface in interfaces:
        try:
            addrs = netifaces.ifaddresses(interface)
            for family in (netifaces.AF_INET, netifaces.AF_INET6):
                if family in addrs:
                    for addr in addrs[family]:
                        if ip == ipaddress.ip_address(addr['addr']):
                            return interface
    return None

ip_address = "192.168.1.100"
interface_name = find_interface_by_ip(ip_address)
if interface_name:
    print(f"Interface name for IP {ip_address} is: {interface_name}")
else:
    print(f"No interface found for IP {ip_address}")
