#!/bin/bash
yum update -y
yum install httpd -y
systemctl restart httpd
systemctl enable httpd
cd /var/www/html
echo "<html><body><h1> Hello Terraformed $(hostname -f) </h1></body></html>" > index.html

