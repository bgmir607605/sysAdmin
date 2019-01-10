#!/usr/bin/env python3
import time
import os
logs_path = './logs/'

year, month, mday, hour, min, sec, wday, yday, dst = time.localtime()

lastmonth = (month + 11) % 12
fileslist = os.listdir(logs_path)
print('current date: %.4d.%.2d.%.2d'%(year, month, mday))
print('last month:', lastmonth)

lastmonthfiles = []
curmonthfiles = []
for f in fileslist:
    if f.startswith('%.4d-%.2d'%(year, lastmonth)) and 'all' not in f:
        lastmonthfiles.append(f)
    elif f.startswith('%.4d-%.2d'%(year, month)) and 'all' not in f:
        curmonthfiles.append(f)

if len(curmonthfiles) > 1:
    print('Already runned at this month')
    quit()

with open(os.path.join(logs_path, '%.4d-%.2d-all'%(year, lastmonth)), 'w') as outf:
    for f in lastmonthfiles:
        try:
            print('concat %10s'%f, end='...', flush=True)
            with open(os.path.join(logs_path, f), 'r') as inf:
                outf.write(inf.read())
                outf.write('\n')
            print('OK')
        except:
            print('failed')

for f in lastmonthfiles:
    print('DEL %s'%f, end=' ', flush=True)
    os.remove(os.path.join(logs_path, f))
    print('OK')
