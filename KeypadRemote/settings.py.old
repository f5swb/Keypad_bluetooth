#!/usr/bin/env python3
# -*- coding: utf-8 -*-


'''
KeypadRemote F8ASB 2020 // information sur F8ASB.COM
Possibilité de faire des QSY avec un clavier numerique USB
Developpé pour les non-voyants

73 de F8ASB Juan
'''

# Version

version = '1.0.0'

#Variables par defaut

touch=0
qsy = "NO"
key=""

#Chemins

path_dtmf = "/tmp/dtmf_uhf"
'''
Configuration des touches
Les touches selon les claviers peuvent être:
. // backspace //num lock // ÷ // × // -
Il suffira de modifier le nom de la touche, voir exemple avec enter ci-dessous

'''
touches = {
    '0': {
        'salon': 'rrf',
        'dtmfconfirm': '196',
     	'dtmf': '96',
        },
    '1': {
        'salon': 'tec',
        'dtmfconfirm': '198',
        'dtmf': '98',
        },
    '2': {
        'salon': 'int',
        'dtmfconfirm': '199',
        'dtmf': '99',
        },
    '3': {
        'salon': 'bav',
        'dtmfconfirm': '1100',
        'dtmf': '100',
        },
    '4': {
        'salon': 'loc',
        'dtmfconfirm': '1101',
        'dtmf': '101',
        },
    '5': {
        'salon': 'exp',
        'dtmfconfirm': '1102',
        'dtmf': '102',
        },
    '6': {
        'salon': 'fon',
        'dtmfconfirm': '197',
        'dtmf': '97',
        },
    '7': {
        'salon': 'default',
        'dtmfconfirm': '195',
        'dtmf': '95',
        },
    'enter': {
        'salon': 'CMD',
        'dtmfconfirm': '0',
        'dtmf': '00',
        },
        }