#!/bin/bash

set -euxo pipefail
dnf -y update
dnf -y install nginx
systemctl enable nginx
cat > /usr/share/nginx/html/index.html << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head><title>Lab 01</title></head>
<body>
<h1> It works! </h1>
<p> This page was provisioned via EC2 User Data script. </p>
</body>
</html>
HTML
systemctl start nginx

# End of file user-data.sh

    
