---
name: linux-sysadmin
description: >-
  Diagnose and operate Linux hosts, services, packages, permissions, SELinux, firewalls, and SSH.
  Use for host-level work that is not primarily an application-specific or container task.
  Triggers: 'linux-sysadmin', 'sysadmin', 'systemd', 'journalctl', 'selinux', 'firewall', 'linux host', 'ssh server'.
---

# linux-sysadmin

## Workflow

1. Gather diagnostics for the reported symptom and complete relevant log
   interval. Do not run every example below for an isolated service issue.
2. Determine whether the failure is host-level or primarily belongs to a
   specialized application, container, or cross-system infrastructure skill.
3. For an authorized fix, identify impact and recent changes, then prepare
   rollback for the files, packages, units, or firewall rules being changed.
4. Implement the smallest host-level fix and validate runtime behavior, remote
   access, security policy, and boot persistence.

## Diagnostics

```bash
cat /etc/os-release
uname -a
uptime
free -h
df -h
lsblk
systemctl status <unit>
journalctl -xeu <unit>
ss -tulpn
getenforce
firewall-cmd --list-all
ufw status verbose
```

## Safety Rules

- Never disable SELinux or firewalls as a default fix.
- Prefer systemd drop-ins over editing packaged unit files.
- Preserve ownership, permissions, ACLs, mount options, and labels.

### Remote Execution & SSH Safety
- **Client Multiplexing**: When executing multiple SSH commands to a remote host, establish a master connection (`ControlMaster auto`, `ControlPath ~/.ssh/sockets/%r@%h-%p`, `ControlPersist 10m`) to eliminate handshake latency. Close with `ssh -O exit -o ControlPath=... <host>` upon completion.
- **Server Changes & Rollback**: Before modifying OpenSSH configs (`sshd_config` or `sshd_config.d/`), validate syntax with `sshd -t`, verify effective settings with `sshd -T`, and test a new independent connection before closing existing sessions.
- **Connection Exemptions**: For high-concurrency servers with `PerSourcePenalties`, place client IP in `PerSourcePenaltyExemptList` within `/etc/ssh/sshd_config.d/00-exemptions.conf` (chmod 600).

## Validation

- The affected service runs and its boot configuration is correct. Reboot only
  when authorized; distinguish inspection from a verified reboot test.
- Logs show no new errors.
- Expected ports listen and unexpected ports do not.
- SSH access still works.
- SELinux and firewall state match the intended policy.
