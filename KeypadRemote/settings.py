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
    'insert': {
        'salon': 'rrf',
        'dtmfconfirm': '196',
     	'dtmf': '96',
        },
    'end': {
        'salon': 'tec',
        'dtmfconfirm': '198',
        'dtmf': '98',
        },
    'down': {
        'salon': 'int',
        'dtmfconfirm': '199',
        'dtmf': '99',
        },
    'page down': {
        'salon': 'bav',
        'dtmfconfirm': '1100',
        'dtmf': '100',
        },
    '+': {
        'salon': 'met',
        'dtmfconfirm': '1104',
        'dtmf': '*51',
        },
    '-': {
        'salon': 'ip',
        'dtmfconfirm': '1105',
        'dtmf': '93',
       }, 
    'left': {
        'salon': 'loc',
        'dtmfconfirm': '1101',
        'dtmf': '101',
        },
    'home': {
        'salon': 'exp',
        'dtmfconfirm': '1102',
        'dtmf': '102',
        },
    'right': {
        'salon': 'fon',
        'dtmfconfirm': '197',
        'dtmf': '97',
        },
    'up': {
        'salon': 'default',
        'dtmfconfirm': '195',
        'dtmf': '95',
        },
    'page up': {
        'salon': 'reg',
        'dtmfconfirm': '1103',
        'dtmf': '104',
        },
    'enter': {
        'salon': 'CMD',
        'dtmfconfirm': '0',
        'dtmf': '88',
        },
        }
