# ���ߣ�Jmc

# �Զ������
$ideaDir = 'C:\Program Files\JetBrains\IntelliJ IDEA 2022.1.1\bin'
$qqDir = 'C:\Program Files\Tencent\QQ\Bin'
$potPlayerDir = 'C:\Program Files\PotPlayer64'

$nacosDir = 'C:\Program Files\Nacos\bin'
$nginxDir = 'C:\Program Files\Nginx'
$jMeterDir = 'C:\Program Files\JMeter\bin'

$courseDir = 'G:\Courses\����\Rust'


# ǿ���ù���ԱȨ��ִ������
$isAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
if (-not $isAdmin) {
    # ִ�б��ű�������������ִ����һ������
    $cmd = "powershell -File $PSCommandPath " + $(if ($args[0] -ne $null) { [int64] $args[0] } else { "" })

    # �ù���ԱȨ������ִ�б��ű�
    Start-Process wt -Verb RunAs -ArgumentList $cmd
    exit
}

# ����exe����
# params:
#    exeDir: exe�ļ�����Ŀ¼
#    exeName: exe�ļ�������
#    exeArgs: exe�ļ�����
function startExe($exeDir, $exeName, $exeArgs = " ")
{
    kill -name $exeName 2>$null
    cd $exeDir
    start $exeName $exeArgs
}

# ͨ��pid��ȡ����ִ�е�������
# params:
#    id: ����id
function getCommandLineByPid($id) {
    return (Get-CimInstance Win32_Process -Filter "ProcessId = $id").CommandLine
}

# ɱ��Java����
# ��Ϊjps�޷�����������Աģʽ�򿪵�java���̣�����ý��������м�ز�ɱ��
# params:
#     name: �����������к��еĹؼ���
function killJavaProc($name)
{
    # ����java���̵�id
    foreach ($id in ((ps -name java 2>$null).id)) {
        # ��ȡ�������У�������йؼ�����ɱ������
        if ((getCommandLineByPid $id | findstr /i $name) -ne $null) {
            kill $id 2>$null
        }
    }
}

$tips = @"
������Ҫ����ִ�е�Ӧ�ã��ÿո������ֱ�ӻس���ʾȫ��ִ��
1.PotPlayer
2.Nacos
3.Nginx
4.JMeter

"@

$select = (Read-Host $tips).Trim().Split(' ')

# ���idea��û����
if ((ps -name idea64 2>$null) -eq $null) {
    # �ؿ�Idea��QQ
    startExe $ideaDir idea64
    startExe $qqDir QQ
}

# ����һ��Ԫ�أ���Ϊ''
if ($select[0].Length -eq 0)
{
    startExe $potPlayerDir PotPlayerMini64 $courseDir

    killJavaProc nacos
    startExe $nacosDir startup.cmd

    startExe $nginxDir restart.bat

    killJavaProc jmeter
    startExe $jMeterDir jmeter.bat
    return
}

foreach ($i in $select)
{
    switch ($i)
    {
        1
        {
            startExe $potPlayerDir PotPlayerMini64 $courseDir
        }


        2
        {
            killJavaProc nacos
            startExe $nacosDir startup.cmd
        }

        3
        {
            startExe $nginxDir restart.bat
        }

        4
        {
            killJavaProc jmeter
            startExe $jMeterDir jmeter.bat
        }


        Default
        {
            Write-Error "�޴�ѡ�"
        }
    }
}
