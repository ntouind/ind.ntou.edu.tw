#!/usr/local/bin/perl -w

# patched by medicalwei due to safety concerns.

use String::ShellQuote;

print "Content-Type: text/html\n\n";
require "readform.pl";
&ReadForm(*admit);

$pop3="/root/www/cgi-bin/pop3";

#$admit{'name'};	描述姓名
#$admit{'number'}	使用者學號
#$admit{'s_pw'}		使用者校務行政密碼
#$admit{'ind_ac'}	帳號
#$admit{'ind_pw1'}	密碼
#$admit{'ind_pw2'}	密碼再次確認
$stu_name=$admit{'name'};
$stu_kind=$admit{'RadioGroup'};
$stu_id=$admit{'number'};
$stu_pw=$admit{'s_pw'};
$ind_id=$admit{'ind_ac'};
$ind_pw=$admit{'ind_pw1'};
$ind_pw2=$admit{'ind_pw2'};
#確認非空值

&errmsg("有欄位沒填寫") unless($stu_kind && $stu_id && $stu_pw && $ind_id && $ind_pw && $ind_pw2 && $stu_name);

#把空白去掉
$stu_id=~s/[^\d\w]//gi;
$ind_id=~s/[^\d\w]//gi;
#去除怪符號
$stu_name=~s/[\s\$\@\<>]//gi;

#確認帳號格式 3-12碼
&errmsg("帳號格式有問題") if ($ind_id&&!($ind_id =~ /^[a-z][a-z0-9]{2,11}$/));
&errmsg("帳號名稱不合法") if ($ind_id =~ /fuck|adm|sysop|administrator/);
#兩次密碼輸入要一樣,格式要符合
&errmsg("密碼請重新輸入") if($ind_pw ne $ind_pw2 || !($ind_pw =~/^[\w\d\,\.\/]{5,12}$/));

&errmsg("姓名/備註 長度太長") unless($stu_name =~ /^.{0,40}$/);
sleep 3;


#check 身份
$stu_id=lc($stu_id); #轉換成小寫
$ind_id=lc($ind_id); #轉換成小寫

&errmsg("身份不符合，不符合大學部學號") if($stu_kind==1 && !($stu_id=~/^b(\d{8}|\d{3}\w\d{4})$/));
&errmsg("身份不符合，不符合研究生學號") if($stu_kind==2 && !($stu_id=~/^[dm][\d]{8}$/));
&errmsg("身份不符合，不符合夜校生學號") if($stu_kind==3 && !($stu_id=~/^n[\d]{8}$/));
&errmsg("身份不符合，不符合進修部學號") if($stu_kind==4 && !($stu_id=~/^e[\d\w]{8}$/));
&errmsg("身份不符合，不符合教職員學號") if($stu_kind==5 && ($stu_id=~/^((e[\d\w]{8})|(n[\d]{8})|([dm][\d]{8})|(b(\d{8}|\d{3}\w\d{4})))$/));

$now=`date`;
open(FC,">>/root/www/cgi-bin/everytry.log");
print FC "學號 $stu_id 嘗試申請帳號 :$now";
close FC;


#校務行政密碼認證
$pass=0;

# 避免傳入參數可以控制系統，使用 shell_quote Perl Module 處理參數
$stu_id = shell_quote($stu_id);
$stu_pw = shell_quote($stu_pw);

$auth = `$pop3 mail.ntou.edu.tw $stu_id $stu_pw`;
$pass=1 if ($auth =~ /認證通過/);
&errmsg("海大郵局(校務行政)帳號或密碼錯誤") unless($pass);
print "海大郵局(校務行政)帳號認證成功\<br>";



#check帳號存在
$admit{'number'}=lc($admit{'number'}); #轉換成小寫
open FP,"</etc/master.passwd" or die $!;
while(<FP>)
{
next unless($_);
next if($_=~/^#/);
&errmsg($stu_id."已申請過了") if($_=~ /$stu_id/i) ;
$id=(split(/:/))[0];	#第一行 也就是帳號
&errmsg($ind_id."帳號已存在") if($ind_id eq $id) ;
}
close FP;

#教職員的目錄不一樣
$dir="/home/err";
if($stu_kind<=4){
		$sdir="/home/class".substr($stu_id,1,2);
		$dir=$sdir."/$stu_id";
		$group="student";
		mkdir $sdir unless(-e $sdir);
}
elsif($stu_kind==5){$dir="/home/faculty/$stu_id";$group ="faculty";}

$shell = "/bin/tcsh";
system("pw", "useradd", "-n", $ind_id, "-d", $dir, "-g", $group, "-s", $shell);
system("mkdir", $dir);
system("chown", "-R", "$ind_id:$group", $dir);
system("edquota", "-p", "maan" ,$ind_id);


$tmp="/root/tmp";
open(FDP,">$tmp");
print FDP "$ind_pw\n";

$chpw="/usr/sbin/pw usermod -n $ind_id -h fd";
`$chpw < $tmp`;
close(FDP);

$cmd="/bin/rm -f $tmp";
`$cmd`;


open(FC,">>/root/www/cgi-bin/addaccount.log");
print FC "學號 $stu_id ，描述 ：$stu_name，申請帳號$ind_id 成功\ $now";
close FC;

print <<EOT;
學號：$stu_id<br>
姓名:$stu_name<br>
帳號：$ind_id<br>
目錄:$dir<br><br>
網頁空間大小:50MB<br>
申請成功\!!!<br>
<br>
有任何問題請mail給 <a href="http://140.121.80.15/admin.html">ind管理員</a>
EOT
exit(0);





sub errmsg
{
        print shift;
        exit(0);
}
