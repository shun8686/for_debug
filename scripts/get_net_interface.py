import netifaces
import socket

def find_interface_by_ip(ip_address):
    ip_binary = socket.inet_pton(socket.AF_INET, ip_address)
    
    for interface in netifaces.interfaces():
        addresses = netifaces.ifaddresses(interface)
        if netifaces.AF_INET in addresses:
            for addr in addresses[netifaces.AF_INET]:

                iface_ip_binary = socket.inet_pton(socket.AF_INET, addr['addr'])
                if ip_binary == iface_ip_binary:
                    return interface
    return None

def get_host_ip():
    for interface in netifaces.interfaces():
        addr = netifaces.ifaddresses(interface)
        if netifaces.AF_INET in addr:
            print(addr[netifaces.AF_INET][0]['addr'])

ip_address = "192.168.0.102"
interface_name = find_interface_by_ip(ip_address)
if interface_name:
    print(f"The interface for IP {ip_address} is: {interface_name}")
else:
    print(f"No interface found for IP {ip_address}")





