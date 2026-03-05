import os
import re

def get_valid_network_interface():
    """
    K8s container optimized: Get enp196s0f* interface (target valid nic)
    No external commands, no IP parsing (container network namespace isolation)
    """
    # Target interface prefix (your valid nic: enp196s0f0/enp196s0f1)
    target_prefix = "enp196s0f"
    # Exclude virtual interfaces
    exclude_prefixes = ["lo", "docker", "tunl", "cali", "veth", "br-", "virbr", "eth0@if", "kube-"]

    # Read interfaces from /proc/net/dev (container's network namespace)
    proc_net_dev = "/proc/net/dev"
    if not os.path.exists(proc_net_dev):
        print("Error: /proc/net/dev not found")
        return None

    target_interfaces = []
    all_non_virtual = []

    with open(proc_net_dev, "r") as f:
        lines = f.readlines()[2:]  # Skip header
        for line in lines:
            line = line.strip()
            if not line:
                continue
            # Extract interface name
            ifname = re.split(r'\s+', line, maxsplit=1)[0].rstrip(':')
            
            # Skip virtual interfaces
            if any(ifname.startswith(p) for p in exclude_prefixes):
                continue
            
            # Collect all non-virtual interfaces
            all_non_virtual.append(ifname)
            
            # Collect target interfaces (enp196s0f*)
            if ifname.startswith(target_prefix):
                target_interfaces.append(ifname)

    # Priority 1: Return target interface (enp196s0f0/enp196s0f1)
    if target_interfaces:
        # Prefer enp196s0f0 if exists, else first in list
        if "enp196s0f0" in target_interfaces:
            return "enp196s0f0"
        return target_interfaces[0]
    
    # Priority 2: Return first non-virtual interface (fallback)
    if all_non_virtual:
        return all_non_virtual[0]
    
    return None

if __name__ == "__main__":
    nic_name = get_valid_network_interface()
    if nic_name:
        print(nic_name)  # Only print pure interface name
    else:
        print("No valid network interface found")