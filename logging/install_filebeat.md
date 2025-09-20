## download agent
```
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.11.0-amd64.deb
```

## install agent
```
sudo dpkg -i filebeat-8.*-amd64.deb
```

## clean conf 
```
sudo nano /etc/filebeat/filebeat.yml
```

## add conf
```
  GNU nano 7.2                    /etc/filebeat/filebeat.yml                              
logging.level: debug
logging.selectors: ["input", "crawler"]

filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/*.log
      - /var/log/syslog
    fields:
      hostname: "node-1"
    scan_frequency: 30s
    close_eof: false

output.logstash:
  hosts: ["192.168.100.80:5044"]

setup.kibana:
  host: "http://192.168.100.80:5601"
```

## start
```
sudo systemctl start filebeat
```

## restart
```
sudo systemctl restart filebeat
```