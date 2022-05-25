# 作者：Jmc

# 自定义参数
$ideaDir = 'C:\Program Files\JetBrains\IntelliJ IDEA 2022.1.1\bin'
$qqDir = 'C:\Program Files\Tencent\QQ\Bin'
$potPlayerDir = 'C:\Program Files\PotPlayer64'

$nacosDir = 'C:\Program Files\Nacos\bin'
$nginxDir = 'C:\Program Files\Nginx'
$jMeterDir = 'C:\Program Files\JMeter\bin'

$courseDir = 'G:\Courses\技术\Rust'


# 强制用管理员权限执行命令
$isAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
if (-not $isAdmin) {
    # 执行本脚本的命令，参数部分传入第一个参数
    $cmd = "powershell -File $PSCommandPath " + $(if ($args[0] -ne $null) { [int64] $args[0] } else { "" })

    # 用管理员权限重新执行本脚本
    Start-Process wt -Verb RunAs -ArgumentList $cmd
    exit
}

# 启动exe进程
# params:
#    exeDir: exe文件所在目录
#    exeName: exe文件的名称
#    exeArgs: exe文件参数
function startExe($exeDir, $exeName, $exeArgs = " ")
{
    kill -name $exeName 2>$null
    cd $exeDir
    start $exeName $exeArgs
}

# 通过pid获取进程执行的命令行
# params:
#    id: 进程id
function getCommandLineByPid($id) {
    return (Get-CimInstance Win32_Process -Filter "ProcessId = $id").CommandLine
}

# 杀死Java进程
# 因为jps无法正常检测管理员模式打开的java进程，因此用进程命令行监控并杀死
# params:
#     name: 进程命令行中含有的关键名
function killJavaProc($name)
{
    # 遍历java进程的id
    foreach ($id in ((ps -name java 2>$null).id)) {
        # 获取其命令行，如果含有关键名就杀死进程
        if ((getCommandLineByPid $id | findstr /i $name) -ne $null) {
            kill $id 2>$null
        }
    }
}

$tips = @"
请输入要额外执行的应用，用空格隔开，直接回车表示全部执行
1.PotPlayer
2.Nacos
3.Nginx
4.JMeter

"@

$select = (Read-Host $tips).Trim().Split(' ')

# 如果idea还没启动
if ((ps -name idea64 2>$null) -eq $null) {
    # 必开Idea，QQ
    startExe $ideaDir idea64
    startExe $qqDir QQ
}

# 最少一个元素，且为''
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
            Write-Error "无此选项："
        }
    }
}
