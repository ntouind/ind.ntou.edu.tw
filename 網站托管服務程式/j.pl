#!/usr/local/bin/perl -w

# patched by medicalwei due to safety concerns.

use String::ShellQuote;

print "Content-Type: text/html\n\n";
require "readform.pl";
&ReadForm(*admit);

$pop3="/root/www/cgi-bin/pop3";

#$admit{'name'};	�y�z�m�W
#$admit{'number'}	�ϥΪ̾Ǹ�
#$admit{'s_pw'}		�ϥΪ̮հȦ�F�K�X
#$admit{'ind_ac'}	�b��
#$admit{'ind_pw1'}	�K�X
#$admit{'ind_pw2'}	�K�X�A���T�{
$stu_name=$admit{'name'};
$stu_kind=$admit{'RadioGroup'};
$stu_id=$admit{'number'};
$stu_pw=$admit{'s_pw'};
$ind_id=$admit{'ind_ac'};
$ind_pw=$admit{'ind_pw1'};
$ind_pw2=$admit{'ind_pw2'};
#�T�{�D�ŭ�

&errmsg("�����S��g") unless($stu_kind && $stu_id && $stu_pw && $ind_id && $ind_pw && $ind_pw2 && $stu_name);

#��ťեh��
$stu_id=~s/[^\d\w]//gi;
$ind_id=~s/[^\d\w]//gi;
#�h���ǲŸ�
$stu_name=~s/[\s\$\@\<>]//gi;

#�T�{�b���榡 3-12�X
&errmsg("�b���榡�����D") if ($ind_id&&!($ind_id =~ /^[a-z][a-z0-9]{2,11}$/));
&errmsg("�b���W�٤��X�k") if ($ind_id =~ /fuck|adm|sysop|administrator/);
#�⦸�K�X��J�n�@��,�榡�n�ŦX
&errmsg("�K�X�Э��s��J") if($ind_pw ne $ind_pw2 || !($ind_pw =~/^[\w\d\,\.\/]{5,12}$/));

&errmsg("�m�W/�Ƶ� ���פӪ�") unless($stu_name =~ /^.{0,40}$/);
sleep 3;


#check ����
$stu_id=lc($stu_id); #�ഫ���p�g
$ind_id=lc($ind_id); #�ഫ���p�g

&errmsg("�������ŦX�A���ŦX�j�ǳ��Ǹ�") if($stu_kind==1 && !($stu_id=~/^b(\d{8}|\d{3}\w\d{4})$/));
&errmsg("�������ŦX�A���ŦX��s�;Ǹ�") if($stu_kind==2 && !($stu_id=~/^[dm][\d]{8}$/));
&errmsg("�������ŦX�A���ŦX�]�ե;Ǹ�") if($stu_kind==3 && !($stu_id=~/^n[\d]{8}$/));
&errmsg("�������ŦX�A���ŦX�i�׳��Ǹ�") if($stu_kind==4 && !($stu_id=~/^e[\d\w]{8}$/));
&errmsg("�������ŦX�A���ŦX��¾���Ǹ�") if($stu_kind==5 && ($stu_id=~/^((e[\d\w]{8})|(n[\d]{8})|([dm][\d]{8})|(b(\d{8}|\d{3}\w\d{4})))$/));

$now=`date`;
open(FC,">>/root/www/cgi-bin/everytry.log");
print FC "�Ǹ� $stu_id ���եӽбb�� :$now";
close FC;


#�հȦ�F�K�X�{��
$pass=0;

# �קK�ǤJ�Ѽƥi�H����t�ΡA�ϥ� shell_quote Perl Module �B�z�Ѽ�
$stu_id = shell_quote($stu_id);
$stu_pw = shell_quote($stu_pw);

$auth = `$pop3 mail.ntou.edu.tw $stu_id $stu_pw`;
$pass=1 if ($auth =~ /�{�ҳq�L/);
&errmsg("���j�l��(�հȦ�F)�b���αK�X���~") unless($pass);
print "���j�l��(�հȦ�F)�b���{�Ҧ��\\<br>";



#check�b���s�b
$admit{'number'}=lc($admit{'number'}); #�ഫ���p�g
open FP,"</etc/master.passwd" or die $!;
while(<FP>)
{
next unless($_);
next if($_=~/^#/);
&errmsg($stu_id."�w�ӽйL�F") if($_=~ /$stu_id/i) ;
$id=(split(/:/))[0];	#�Ĥ@�� �]�N�O�b��
&errmsg($ind_id."�b���w�s�b") if($ind_id eq $id) ;
}
close FP;

#��¾�����ؿ����@��
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
print FC "�Ǹ� $stu_id �A�y�z �G$stu_name�A�ӽбb��$ind_id ���\\ $now";
close FC;

print <<EOT;
�Ǹ��G$stu_id<br>
�m�W:$stu_name<br>
�b���G$ind_id<br>
�ؿ�:$dir<br><br>
�����Ŷ��j�p:50MB<br>
�ӽЦ��\\!!!<br>
<br>
��������D��mail�� <a href="http://140.121.80.15/admin.html">ind�޲z��</a>
EOT
exit(0);





sub errmsg
{
        print shift;
        exit(0);
}
