curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/danxiaonuo/gwf/main/ip/ChinaIp.txt' > conf/overture/china_ip.txt
curl -s -m 3 --retry-delay 3 --retry 3 -k -4 --header 'cache-control: no-cache' --url 'https://raw.githubusercontent.com/danxiaonuo/gwf/main/proxy.txt' > conf/overture/gfwlist.txt
