#!/bin/sh
# See Documentation to configure this file
# test.cgi

#export JPATHj602=/Users/djw/j602/bin

if [ -e /Users/djw/j602/bin/jconsole ]
then
/Users/djw/j602/bin/jconsole   -jprofile /Library/WebServer/Documents/jweb/cgi/test_noprofile.ijs 
elif [ -e /usr/bin/ijconsole ]
then
/usr/bin/ijconsole  -jprofile /var/www/jweb/cgi/test_noprofile.ijs
else
/home/ubuntu/j602/bin/jconsole -jprofile /var/www/jweb/cgi/test_noprofile.ijs
fi
