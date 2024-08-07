import os
import json

data = {
    "picks": [
        {
            "element": 352,
            "position": 1,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 290,
            "position": 2,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 585,
            "position": 3,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 342,
            "position": 4,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 504,
            "position": 5,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 353,
            "position": 6,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 108,
            "position": 7,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 501,
            "position": 8,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 303,
            "position": 9,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 119,
            "position": 10,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 211,
            "position": 11,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 520,
            "position": 12,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 197,
            "position": 13,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 519,
            "position": 14,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        },
        {
            "element": 8,
            "position": 15,
            "is_captain": False,
            "is_vice_captain": False,
            "multiplier": 1
        }
    ],
    "entry_history": {},
    "subs": []
}

rootdir = 'stub_server/mock-api/squads'

for subdir, dirs, files in os.walk(rootdir):
    for file in files:
        if file == '86631.json':
            with open(os.path.join(subdir, file), 'w') as f:
                json.dump(data, f)  
