#!/usr/local/bin/perl
print "Content-Type: text/html\n\n";
require "readform.pl";

&ReadForm(*admit);
#改密碼 
#$admit{'account'}
#$admit{'password_old'}
#$admit{'password_new'}
#$admit{'password_new2'}

$account = $admit{'account'};
$password_old = $admit{'password_old'};
$password_new = $admit{'password_new'};
$password_new2 = $admit{'password_new2'};
unless($account && $password_old && $password_new && $password_new2)
{
print "有欄位沒填寫";exit(0);
}

if($account =~ /root|wheel/ || !($account =~ /^[\w\d]{2,15}$/) || !($password_old =~ /^[\w\d]{2,12}$/))
{
print "error";exit(0);
}

if($password_new ne $password_new2)
{
print "請重新輸入密碼";exit(0);
}

unless ($password_new =~ /^[\w]{5,15}$/)
{
        print "新帳號密碼格式有問題!!，密碼最少5碼,至多15碼,請修正!!!";
        exit(0);
}
sleep 3;
$now=`date`;
open(FC,">>/root/www/cgi-bin/everytry.log");
print FC "帳號 $account :$now";
close FC;
#檢查帳號存在
$pass = 0;
#check acc
open (FP2,"/etc/master.passwd") ;
        while($t=<FP2>)
        {
                chomp($t);
                next if($t=~/^#/);
                (@data) = split(/:/,$t,10);
                if($data[0] eq $account)
                {
                        $pass = 1;
                        break;
                }
        }
close(FP2);

 if($pass==0){print "失敗,無此帳號，或帳號已被鎖住";exit 0;}



#pop3 認證
$pass=0;
$auth=`/root/www/cgi-bin/pop3 ind.ntou.edu.tw $account $password_old`;
$pass=1 if $auth =~ /^正確/;
$auth=`/root/www/cgi-bin/pop3 ind.ntou.edu.tw $account $password_old`;
$pass=1 if $auth =~ /^正確/;
if($pass==0){
print "舊密碼輸入錯誤<br>";
exit(0);
}
$pass = 0;
#check acc
open (FP2,"/etc/master.passwd") ;
        while($t=<FP2>)
        {
		chomp($t);
		next if($t=~/^#/);
                (@data) = split(/:/,$t,10);
                if($data[0] eq $account)
                {
			$pass = 1;
			break;
                }
        }
close(FP2);

exit(0) if($pass==0);


	open(FDP,">/root/www/cgi-bin/tmp");
	print FDP "$password_new\n";
	$chpw="/usr/sbin/pw usermod -n $account -h fd";
	`$chpw < tmp`;
	close(FDP);
	$cmd="/bin/rm -f /root/www/cgi-bin/tmp";
	`$cmd`;

open(FP,">>/root/www/cgi-bin/changelog");
print FP "帳號為 $account 更改密碼";
print FP " 時間是:$now";
close(FP);

print "
<meta http-equiv=\"refresh\" content=\"2;URL=http://140.121.80.15\">";






