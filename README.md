## Vagrant dev box for Php, Ruby and Angular

Apache serves out of /vagrant/public - after vagrant up open http://10.2.2.3/ from your host browser

### Install demo Angular app
Vagrant ssh and do
```
cd /vagrant/public && git clone https://github.com/angular/angular-phonecat.git
cd angular-phonecat
```

### Start Node server
```
npm start &
```
On your host, open http://10.2.2.3:8000/app

### Protractor / Selenium tests
```
npm run protractor
```

### Manual Selenium server
```
webdriver-manager start
```
Open http://10.2.2.3:4444/wd/hub

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
+    "start": "http-server -p 8000",

     "pretest": "npm install",
     "test": "karma start test/karma.conf.js",
```