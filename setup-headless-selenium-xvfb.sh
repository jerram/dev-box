#!/bin/bash
#
# Bash script to setup headless Selenium (uses Xvfb and Chrome)

if [ `id -u` -ne 0 ]; then
  echo "You need root privileges to run this script"
  exit 1
fi

# Install Google Chrome, Chromedriver:
sudo apt-get -y install libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4
sudo apt-get -y install chromium-browser # chromium-chromedriver

# Dependencies to make "headless" chrome/selenium work:
sudo apt-get -y install xvfb gtk2-engines-pixbuf
sudo apt-get -y install xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable

# Optional but nifty: For capturing screenshots of Xvfb display:
sudo apt-get -y install imagemagick x11-apps

sudo npm install -g protractor
sudo npm install -g chromedriver
sudo webdriver-manager update
sudo ln /usr/local/lib/node_modules/protractor/selenium/chromedriver /usr/bin/chromedriver

make_xvfb () {
	cat <<'EOF'
#!/bin/bash
#
# Xvfb init script for Debian-based distros.
#
# The display number used must match the DISPLAY environment variable used
# for other applications that will use Xvfb. e.g. ':10'.
#
# From: https://github.com/gmonfort/xvfb-init/blob/master/Xvfb
#
### BEGIN INIT INFO
# Provides:          xvfb
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/stop custom Xvfb
# Description:       Enable service provided by xvfb
### END INIT INFO

NAME=Xvfb
DESC="$NAME - X Virtual Frame Buffer"
SCRIPTNAME=/etc/init.d/$NAME
XVFB=/usr/bin/Xvfb
PIDFILE=/var/run/${NAME}.pid

# Using -extension RANDR doesn't seem to work anymore. Firefox complains
# about not finding extension RANDR whether or not you include it here.
# Fortunately this is a non-fatal warning and doesn't stop Firefox from working.
XVFB_ARGS=":10 -extension RANDR -noreset -ac -screen 0 1280x1024x16"

set -e

if [ `id -u` -ne 0 ]; then
  echo "You need root privileges to run this script"
  exit 1
fi

[ -x $XVFB ] || exit 0

. /lib/lsb/init-functions

[ -r /etc/default/Xvfb ] && . /etc/default/Xvfb

case "$1" in
  start)
    log_daemon_msg "Starting $DESC" "$NAME"
    if start-stop-daemon --start --quiet --oknodo --pidfile $PIDFILE \
          --background --make-pidfile --exec $XVFB -- $XVFB_ARGS ; then
      log_end_msg 0
    else
      log_end_msg 1
    fi
    log_end_msg $?
    ;;

  stop)
    log_daemon_msg "Stopping $DESC" "$NAME"
    start-stop-daemon --stop --quiet --oknodo --pidfile $PIDFILE --retry 5
    if [ $? -eq 0 ] && [ -f $PIDFILE ]; then
      /bin/rm -rf $PIDFILE
    fi
    log_end_msg $?
    ;;

  restart|force-reload)
    log_daemon_msg "Restarting $DESC" "$NAME"
    $0 stop && sleep 2 && $0 start
    ;;

  status)
    status_of_proc -p $PIDFILE $XVFB $NAME && exit 0 || exit $?
    ;;

  *)
    log_action_msg "Usage: ${SCRIPTNAME} {start|stop|status|restart|force-reload}"
    exit 2
    ;;
esac
exit 0
EOF
}


# Make sure that Xvfb starts everytime the box/vm is booted:
echo "Setting X virtual framebuffer (Xvfb) to start in background..."
make_xvfb > /etc/init.d/xvfb
sudo chown root:root /etc/init.d/xvfb
sudo chmod a+x /etc/init.d/xvfb
sudo update-rc.d xvfb defaults
sudo /etc/init.d/xvfb start
# and send to /home/vagrant/.bash_aliases
echo "export DISPLAY=:10" >> /home/vagrant/.bashrc
export DISPLAY=:10

# Optionally, capture screenshots using the command:
#xwd -root -display :10 | convert xwd:- screenshot.png