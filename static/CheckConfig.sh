
# Attention! These checks can be tricked if e.g. a value is set to 3 and the other value is set to -2 the sum is still 1...
err_msg=""

temp=$((${DBMS[MariaDB]} + ${DBMS[PostgreSQL]}))
if [ "${temp}" -ne 1 ]; then
	err_msg="${err_msg}... DBMS is an exclusive-or setting. You have to set exact one value to 1\n"
fi

temp=$((${Webserver[Apache2]} + ${Webserver[NGINX]}))
if [ "${temp}" -ne "1" ]; then
	err_msg="${err_msg}... Webserver is an exclusive-or setting. You have to set exact one value to 1\n"
fi

temp=$((${Office[OnlyOffice]} + ${Office[Collabora]}))
if [ "${temp}" -ne "1" ]; then
	err_msg="${err_msg}... Office is an exclusive-or setting. You have to set exact one value to 1\n"
fi

temp=$((${Communication[Talk]} + ${Communication[SpreedMe]}))
if [ "${temp}" -ne "1" ]; then
	err_msg="${err_msg}... Communication is an exclusive-or setting. You have to set exact one value to 1\n"
fi

if [ "$(whoami)" = "root" ]; then
	err_msg="${err_msg}... You can not run this script as user root\n"
fi

temp=$((sudo -v) 2>&1)
if ! [ -z "$temp" ]; then
	err_msg="${err_msg}... $temp\n"
	echo "if: $temp"
fi

## More checks tbd...

if ! [ -z "$err_msg" ]; then
	msg_box "$err_msg"
	exit
fi
