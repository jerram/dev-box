## Vagrant dev box for Php, Ruby and Angular
```
vagrant up
# Give it a while
```

Apache serves out of /vagrant/public - after vagrant up open http://10.2.2.3/ or http://localhost:8080/ from your host browser

If apache is not running

```
# host
vagrant ssh
# client
sudo /etc/init.d/apache2 restart
```

### Install demo Angular app
Vagrant ssh and do
```
cd /vagrant/public && git clone https://github.com/angular/angular-phonecat.git
cd angular-phonecat
```

### Start Node server
```
npm start
# Bower may ask about uploading stats, once this installs ctrl-c and rerun with
npm start &
```
On your host, open http://localhost:8000/app

### Run Chromedriver and Selenium install
```
sudo npm run update-webdriver
```

### Karma tests
Set the location of the headless Chrome for Karma
```
export CHROME_BIN=/usr/bin/chromium-browser
```

Run Karma
```
npm test
```

### Protractor / Selenium tests
```
npm run protractor
```

Manually start Selenium server if you want to run browser tests other than Chrome
```
webdriver-manager start &
```
Open http://localhost:4444/wd/hub


### Accessing your dev box from your mobile

* check your guest server is available from the guest
```
curl localhost
```

* check your guest server is available from the host via port forwarding
```
curl localhost:8080
curl 192.168.0.22:8080 # insert your host IP address here
```

* check your guest is reachable from a device on the same wifi via host with port forwarding
```
# Point your mobile browser to your host ip address
192.168.0.22:8080
```

* or your angular app via Node server
```
192.168.0.22:8000/app # insert your dev host IP address here
```

* Great success

### Issues
Cant load Node server from host browser
```
# Set http-server to listen on all addresses
diff --git a/package.json b/package.json
index 5035daf..928fe81 100644
--- a/package.json
+++ b/package.json
@@ -17,7 +17,7 @@
     "postinstall": "bower install",

     "prestart": "npm install",
-    "start": "http-server -a localhost -p 8000",
+    "start": "http-server -a 0.0.0.0 -p 8000",

     "pretest": "npm install",
     "test": "karma start test/karma.conf.js",
```

npm start fails with EACCES
```
#Probably root owns /home/vagrant/tmp/
#Either rerun command as root or remove /home/vagrant/tmp/ and try again
sudo npm start
# Node http server may be buggy when running as root, after first run (and install) ctrl-c and rerun not as root
```
