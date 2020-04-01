#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import requests
import sys


if len(sys.argv) < 3:
    print('''Usage: 
    python pcurl [url] [output_file]
    ''')
    exit(0)

print(sys.argv[1])
print(sys.argv[2])


def get_curl(url):
    r = requests.get(url=url)       # 最基本的不带参数的get请求
    return r 

def writeToFile(content, file):
    fo = open(file,"wb")
    fo.write(content)
    ensureCloseFile(fo)

def ensureCloseFile(fo):
    try:
        fo.close()
    except:
        return 
    



if __name__ == "__main__":
    request = get_curl(sys.argv[1])    
    writeToFile(request.content, sys.argv[2])
