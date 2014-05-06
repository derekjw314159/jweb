#!/bin/sh
# See Documentation to configure this file
# test.cgi

#export JPATHj602=/Users/djw/j602/bin

if [ -e /Users/djw/j602/bin/jconsole ]
then
/Users/djw/j602/bin/jconsole   -jprofile /Library/WebServer/Documents/jweb/cgi/post.ijs 
else
/home/ubuntu/j602/bin/jconsole -jprofile /var/www/jweb/cgi/post.ijs
fi
