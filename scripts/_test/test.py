import subprocess
import os


def run_command(cmd, shell=True):
    try:
        result = subprocess.run(
            cmd, shell=shell, capture_output=True, text=True, check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"execute command error: {e}")
        return None

run_command("source env.sh",True)
print(os.environ['TEST_123'])
