import subprocess
import sys
import logging
import os

# 0. init
MAX_RETRIES = 3
# 1. Initialize Robust Logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger(__name__)

def run_claude_fix(error_log):
    logger.info("🛠️ Claude is taking full control to fix the infrastructure...")

    # ปรับ Instruction ให้ Claude รู้ว่าเขามีอำนาจเต็ม
    instruction = (
        "You are a Principal Software Architect with full write access. "
        "Analyze the Ansible/Molecule error. Fix the root cause directly in the files. "
        "Ensure idempotency. If a file (like .vault-pass) is missing, create it or bypass it in config. "
        "Do not explain, just apply the fixes and exit."
    )

    recent_log = "\n".join(error_log.splitlines()[-150:]) # เพิ่มบริบทให้ยาวขึ้น
    full_prompt = f"{instruction}\n\nERROR LOG:\n{recent_log}"

    try:
        # ใช้ --non-interactive เพื่อให้ Claude แก้ไฟล์ได้ทันที
        result = subprocess.run(
            ["claude", "-y", full_prompt],
            text=True,
            capture_output=True 
        )
        
        # แสดงผลลัพธ์ที่ Claude แก้ไข (เอาเฉพาะส่วนที่สำคัญ)
        if result.stdout:
            summary = "\n".join(result.stdout.splitlines()[-3:])
            logger.info(f"📝 Claude Action Summary: {summary}")
            
    except Exception:
        logger.exception("❌ Claude Agent failed to execute.")

def run_molecule_streaming(command, env):
    process = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        env=env
    )

    full_output = []
    for line in process.stdout:
        clean_line = line.strip()
        if clean_line:
            print(f"  [Molecule] {clean_line}") 
            full_output.append(clean_line)

    process.wait()
    return process.returncode, "\n".join(full_output)


def agent_loop():
    # Sanitize Environment
    current_env = os.environ.copy()
    # Remove conflicting Vault variables that lead to the directory-as-file error
    for var in ["ANSIBLE_VAULT_PASSWORD_FILE", "VAULT_PASSWORD_FILE"]:
        current_env.pop(var, None)

    for iteration in range(1, MAX_RETRIES + 1):
        logger.info(f"--- 🚀 Iteration {iteration}/{MAX_RETRIES} ---")
        
        # Ensure the ephemeral directory isn't being confused for a password file
        # Force Ansible to ignore vault if not explicitly required for the test
        current_env["ANSIBLE_VERBOSITY"] = "1"

        rc, output = run_molecule_streaming(["molecule", "test"], current_env)

        if rc == 0:
            logger.info("✅ Converge successful.")
            return # Exit successfully

        logger.error(f"❌ Failure detected. Invoking repair agent...")
        
        # Only attempt fix if we haven't exhausted retries
        if iteration < MAX_RETRIES:
            run_claude_fix(output)
        else:
            logger.critical("Maximum retries reached. Manual intervention required.")
            sys.exit(1)


if __name__ == "__main__":
    try:
        agent_loop()
    except KeyboardInterrupt:
        logger.warning("⚠️ Agent stopped by user.")
        sys.exit(130)
