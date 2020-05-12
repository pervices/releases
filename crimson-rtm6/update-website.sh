echo "Updating Website"
systemctl stop crimson-website; 
systemctl stop crimson-server; 
systemctl mask crimson-website; 
systemctl mask crimson-server; 
rm -r /usr/lib/node_modules/crimson-webserver/*;
cp -r crimson-webserver/* /usr/lib/node_modules/crimson-webserver/;
cp node /usr/bin/; 
systemctl unmask crimson-server; 
systemctl unmask crimson-website; 
systemctl start crimson-server; 
systemctl start crimson-website; 

