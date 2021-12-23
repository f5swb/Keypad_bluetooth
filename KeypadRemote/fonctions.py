#!/usr/bin/env python3
# -*- coding: utf-8 -*-


'''
KeypadRemote F8ASB 2020 // information sur F8ASB.COM
Possibilité de faire des QSY avec un clavier numerique USB
Developpé pour les non-voyants

73 de F8ASB Juan
'''

import settings as s
import os

def confirmtouch(salon):
    global touch
    global qsy
    
    if s.touches[s.key]['dtmfconfirm']!="0":

        if s.qsy!=salon:
            s.qsy=salon
            print("Voulez vous vraiment faire qsy sur: "+salon) 
            print("code envoyé: "+s.touches[s.key]['dtmfconfirm'])
            dtmf(str(s.touches[s.key]['dtmfconfirm']))
        else:
            s.touch=1           

        if s.touch == 1 and s.qsy==salon:
            print("Confirmation QSY: "+salon)
            s.touch=0
            s.qsy="NO"
            print("code envoyé: "+s.touches[s.key]['dtmf'])
            dtmf(str(s.touches[s.key]['dtmf']))
    
    if s.touches[s.key]['dtmfconfirm']=="0":
        #if s.touch == 0 and s.qsy==salon:
        print("QSY Direct: "+salon)
        s.touch=0
        s.qsy="NO"
        print("code DTMF envoyé: "+s.touches[s.key]['dtmf'])
        dtmf(str(s.touches[s.key]['dtmf']))


#********************** 
#* GESTION ENVOI DTMF *
#**********************  

def dtmf(code):

    cmd=('echo "'+str(code)+'#" > '+str(s.path_dtmf))
    os.system(cmd)