#/usr/bin/bash

function cpu_usage()
{
    mpstat | tail -1 | awk '{ print 100 - $12 }'
}

function memory_usage()
{
    free | head -2 | tail -1 | awk '{ printf("%d\n", $3 * 100 / $2) }'
}

echo "System check : CPU usage $(cpu_usage)%, memory usage $(memory_usage)%"

if [ $(cpu_usage) -gt 80 ]; then
    echo "CPU usage is high, top processes are:"
    ps -eo pid,cmd,%cpu --sort=-%cpu | head
fi

if [ $(memory_usage) -gt 80 ]; then
    echo "Memory usage is high, top processes are:"
    ps -eo pid,cmd,%mem --sort=-%mem | head
fi
