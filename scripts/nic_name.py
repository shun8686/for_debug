import subprocess
import re
import ipaddress

def get_valid_network_interface():
    """
    Automatically identify the optimal network interface for SGLang multi-machine deployment
    Returns: str - Valid network interface name; None - No valid interface found
    """
    try:
        result = subprocess.check_output(
            ["ip", "addr", "show"],
            encoding="utf-8",
            stderr=subprocess.STDOUT
        )
    except subprocess.CalledProcessError as e:
        print(f"Failed to execute ip command: {e.output}")
        return None

    # Split into interface sections
    interface_sections = re.split(r'\n(?=\d+:\s+[\w@]+:)', result)
    valid_sections = [sec.strip() for sec in interface_sections if sec.strip() and re.match(r'^\d+:\s+[\w@]+:', sec)]

    valid_interfaces = []
    for section in valid_sections:
        # Extract interface name
        name_match = re.search(r'\d+:\s+([\w@]+):', section)
        if not name_match:
            continue
        ifname = name_match.group(1)

        # Skip virtual/local interfaces
        exclude_keywords = ["lo", "docker", "tunl", "cali", "veth", "br-", "virbr"]
        if any(kw in ifname for kw in exclude_keywords):
            continue

        # Extract state info
        state_tags_match = re.search(r'<([^>]+)>', section)
        actual_state_match = re.search(r'state\s+(\w+)', section)
        if not state_tags_match or not actual_state_match:
            continue
        state_tags = state_tags_match.group(1)
        actual_state = actual_state_match.group(1)

        # Check state validity
        if "UP" not in state_tags or actual_state != "UP" or "NO-CARRIER" in state_tags:
            continue

        # Extract IPv4 address
        ip_cidr_match = re.search(r'inet\s+(\d+\.\d+\.\d+\.\d+/\d+)', section)
        if not ip_cidr_match:
            continue
        ip_cidr = ip_cidr_match.group(1)

        # Parse IP and determine priority
        try:
            ip_obj = ipaddress.IPv4Interface(ip_cidr)
            priority = 0 if ip_obj.is_private else 1
            valid_interfaces.append({"name": ifname, "priority": priority})
        except ValueError:
            continue

    if not valid_interfaces:
        return None

    # Select optimal interface (public IP first)
    valid_interfaces.sort(key=lambda x: x["priority"], reverse=True)
    return valid_interfaces[0]["name"]

if __name__ == "__main__":
    nic_name = get_valid_network_interface()
    if nic_name:
        print(nic_name)  # Only print the interface name (pure output)
    else:
        print("No valid network interface found")