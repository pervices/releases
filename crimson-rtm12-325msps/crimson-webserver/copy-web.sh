systemctl stop crimson-website;
scp -r jade@192.168.10.4:~/dmcl/website/web/* .
systemctl restart crimson-website

