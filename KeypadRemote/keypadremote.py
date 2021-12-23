#!/usr/bin/env python3
# -*- coding: utf-8 -*-


'''
KeypadRemote F8ASB 2020 // information sur F8ASB.COM
Possibilité de faire des QSY avec un clavier numerique USB
Developpé pour les non-voyants

73 de F8ASB Juan
'''

import settings as s
import fonctions as f

import keyboard
import time

def main():
    global touch
    global qsy
    
    print("KeypadRemote Version:"+s.version)
    
    while True:
        s.key=keyboard.read_key()
        time.sleep(0.5)
        
        if s.key in s.touches:
            print("Touche:" +s.key)
            f.confirmtouch(s.touches[s.key]['salon']) 
  
if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        pass

