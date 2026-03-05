import os
import re

def get_valid_network_interface():
    """
    Automatically identify the optimal network interface for SGLang multi-machine deployment
    Returns: str - Valid network interface name; None - No valid interface found
    """
    # Define virtual interface prefixes to exclude (k8s/docker common)
    exclude_prefixes = [
        "lo", "docker", "tunl", "cali", "veth", "br-", "virbr", 
        "eth0@if", "kube-", "flannel", "weave", "cilium"
    ]

    proc_net_dev = "/proc/net/dev"
    if not os.path.exists(proc_net_dev):
        print("Error: /proc/net/dev not found (not a Linux system)")
        return None

    # Store interfaces with traffic (rx_bytes + tx_bytes > 0)
    interfaces_with_traffic = {}

    with open(proc_net_dev, "r") as f:
        # Skip header lines (first 2 lines)
        lines = f.readlines()[2:]
        for line in lines:
            line = line.strip()
            if not line:
                continue

            # Split interface name and stats (format: "ifname: rx_bytes rx_packets ... tx_bytes ...")
            parts = re.split(r'\s+', line)
            if len(parts) < 10:  # Ensure enough stats fields
                continue

            ifname = parts[0].rstrip(':')
            
            # Skip virtual interfaces
            if any(ifname.startswith(prefix) for prefix in exclude_prefixes):
                continue

            # Get rx/tx bytes (2nd field: rx_bytes, 10th field: tx_bytes)
            try:
                rx_bytes = int(parts[1])
                tx_bytes = int(parts[9])
                total_bytes = rx_bytes + tx_bytes
            except (ValueError, IndexError):
                continue

            # Only keep interfaces with traffic (active link)
            if total_bytes > 0:
                interfaces_with_traffic[ifname] = total_bytes

    # Priority 1: Select interface with most traffic (most active)
    if interfaces_with_traffic:
        # Sort by total bytes (descending) and pick first
        sorted_interfaces = sorted(
            interfaces_with_traffic.items(), 
            key=lambda x: x[1], 
            reverse=True
        )
        return sorted_interfaces[0][0]
    
    # Priority 2: Fallback to first non-virtual interface (no traffic but exists)
    # Re-read to get non-virtual interfaces (even with no traffic)
    all_non_virtual = []
    with open(proc_net_dev, "r") as f:
        lines = f.readlines()[2:]
        for line in lines:
            line = line.strip()
            if not line:
                continue
            ifname = re.split(r'\s+', line)[0].rstrip(':')
            if not any(ifname.startswith(p) for p in exclude_prefixes):
                all_non_virtual.append(ifname)
    
    if all_non_virtual:
        return all_non_virtual[0]
    
    # No valid interface found
    return None

if __name__ == "__main__":
    nic_name = get_valid_network_interface()
    if nic_name:
        print(nic_name)  # Only print pure interface name (no extra text)
    else:
        print("No valid network interface found")