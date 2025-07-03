export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8.0 2> /dev/null)
export JAVA_11_HOME=$(/usr/libexec/java_home -v11.0 2> /dev/null)
if [ ! -z $JAVA_8_HOME ];then
  alias java8='export JAVA_HOME=$JAVA_8_HOME'
  export JAVA_HOME=$JAVA_8_HOME
fi
if [ ! -z $JAVA_11_HOME ];then
  alias java11='export JAVA_HOME=$JAVA_11_HOME'
fi

export CLASSPATH=$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar:.
# if [ -d /usr/local/opt/maven/bin ];then
#   export PATH=/usr/local/opt/maven/bin:$PATH
# fi

if [ -d "$HOME/Miduo/apache-maven-3.9.9" ]; then
    export M2_HOME="$HOME/Miduo/apache-maven-3.9.9"
    export PATH="$PATH:$M2_HOME/bin"
fi