

from genericpath import isfile
from os import listdir
from os.path import isfile, join
import shutil
static_teams = [
        {
            "code": 3,
            "id": 1,
            "name": "Arsenal",
            "pulse_id": 1,
            "short_name": "ARS"
        },
        {
            "code": 7,
            "id": 2,
            "name": "Aston Villa",
            "pulse_id": 2,
            "short_name": "AVL"
        },
        {
            "code": 91,
            "id": 3,
            "name": "Bournemouth",
            "pulse_id": 127,
            "short_name": "BOU"
        },
        {
            "code": 94,
            "id": 4,
            "name": "Brentford",
            "pulse_id": 130,
            "short_name": "BRE"
        },
        {
            "code": 36,
            "id": 5,
            "name": "Brighton",
            "pulse_id": 131,
            "short_name": "BHA"
        },
        {
            "code": 8,
            "id": 6,
            "name": "Chelsea",
            "pulse_id": 4,
            "short_name": "CHE"
        },
        {
            "code": 31,
            "id": 7,
            "name": "Crystal Palace",
            "pulse_id": 6,
            "short_name": "CRY"
        },
        {
            "code": 11,
            "id": 8,
            "name": "Everton",
            "pulse_id": 7,
            "short_name": "EVE"
        },
        {
            "code": 54,
            "id": 9,
            "name": "Fulham",
            "pulse_id": 34,
            "short_name": "FUL"
        },
        {
            "code": 13,
            "id": 10,
            "name": "Leicester",
            "pulse_id": 26,
            "short_name": "LEI"
        },
        {
            "code": 2,
            "id": 11,
            "name": "Leeds",
            "pulse_id": 9,
            "short_name": "LEE"
        },
        {
            "code": 14,
            "id": 12,
            "name": "Liverpool",
            "pulse_id": 10,
            "short_name": "LIV"
        },
        {
            "code": 43,
            "id": 13,
            "name": "Man City",
            "pulse_id": 11,
            "short_name": "MCI"
        },
        {
            "code": 1,
            "id": 14,
            "name": "Man Utd",
            "pulse_id": 12,
            "short_name": "MUN"
        },
        {
            "code": 4,
            "id": 15,
            "name": "Newcastle",
            "pulse_id": 23,
            "short_name": "NEW"
        },
        {
            "code": 17,
            "id": 16,
            "name": "Nott'm Forest",
            "pulse_id": 15,
            "short_name": "NFO"
        },
        {
            "code": 20,
            "id": 17,
            "name": "Southampton",
            "pulse_id": 20,
            "short_name": "SOU"
        },
        {
            "code": 6,
            "id": 18,
            "name": "Spurs",
            "pulse_id": 21,
            "short_name": "TOT"
        },
        {
            "code": 21,
            "id": 19,
            "name": "West Ham",
            "pulse_id": 25,
            "short_name": "WHU"
        },
        {
            "code": 39,
            "id": 20,
            "name": "Wolves",
            "pulse_id": 38,
            "short_name": "WOL"
        }
    ]

teams = {
    1: {
        "code": 3,
        "id": 1,
        "name": "Arsenal",
        "short_name": "ARS"
    },
    2: {
        "code": 91,
        "id": 2,
        "name": "Bournemouth",
        "short_name": "BOU"
    },
    3: {
        "code": 36,
        "id": 3,
        "name": "Brighton",
        "short_name": "BHA"
    },
    4: {
        "code": 90,
        "id": 4,
        "name": "Burnley",
        "short_name": "BUR"
    },
    5: {
        "code": 97,
        "id": 5,
        "name": "Cardiff",
        "short_name": "CAR"
    },
    6: {
        "code": 8,
        "id": 6,
        "name": "Chelsea",
        "short_name": "CHE"
    },
    7: {
        "code": 31,
        "id": 7,
        "name": "Crystal Palace",
        "short_name": "CRY"
    },
    8: {
        "code": 11,
        "id": 8,
        "name": "Everton",
        "short_name": "EVE"
    },
    9: {
        "code": 54,
        "id": 9,
        "name": "Fulham",
        "short_name": "FUL"
    },
    10: {
        "code": 38,
        "id": 10,
        "name": "Huddersfield",
        "short_name": "HUD"
    },
    11: {
        "code": 13,
        "id": 11,
        "name": "Leicester",
        "short_name": "LEI"
    },
    12: {
        "code": 14,
        "id": 12,
        "name": "Liverpool",
        "short_name": "LIV"
    },
    13: {
        "code": 43,
        "id": 13,
        "name": "Man City",
        "short_name": "MCI"
    },
    14: {
        "code": 1,
        "id": 14,
        "name": "Man Utd",
        "short_name": "MUN"
    },
    15: {
        "code": 4,
        "id": 15,
        "name": "Newcastle",
        "short_name": "NEW"
    },
    16: {
        "code": 20,
        "id": 16,
        "name": "Southampton",
        "short_name": "SOU"
    },
    17: {
        "code": 6,
        "id": 17,
        "name": "Spurs",
        "short_name": "TOT"
    },
    18: {
        "code": 57,
        "id": 18,
        "name": "Watford",
        "short_name": "WAT"
    },
    19: {
        "code": 21,
        "id": 19,
        "name": "West Ham",
        "short_name": "WHU"
    },
    20: {
        "code": 39,
        "id": 20,
        "name": "Wolves",
        "short_name": "WOL"
    },
    21: {
        "code": 45,
        "id": 14,
        "name": "Norwich",
        "short_name": "NOR"
    },
    22: {
        "code": 49,
        "id": 15,
        "name": "Sheffield Utd",
        "short_name": "SHU"
    },
        23:{
            "code": 94,
            "id": 3,
            "name": "Brentford",
            "pulse_id": 130,
            "short_name": "BRE"
        },
    24:        {
            "code": 2,
            "id": 10,
            "name": "Leeds",
            "pulse_id": 9,
            "short_name": "LEE"
        },
    25:        {
            "code": 7,
            "id": 2,
            "name": "Aston Villa",
            "pulse_id": 2,
            "short_name": "AVL"
        },
    26:    {
        "code": 35,
        "id": 18,
        "name": "West Brom",
        "pulse_id": 36,
        "short_name": "WBA"
    },
}

folder = f'./assets/images/kits'
# folders = os.walk(f'./data/squad_data/21-22/lineups')

# subfolders = [ f.path for f in os.scandir(direct) if f.is_dir() ]
# for folder in subfolders:
files = [f for f in listdir(folder) if isfile(join(folder, f))]

for file in files:
    kit_name = file.split("-")
    kit_type = kit_name[1]
    kit_id = kit_name[0]
    for team in static_teams:
        if team['code'] == int(kit_id):
            for _team in teams.items():
                if _team[1]['name'] == team['name']:
                    print("MATCH")
                    baguley_kit_id = _team[0]

    shutil.copyfile(f"{folder}/{file}", f'./assets/images/historic_kits/{baguley_kit_id}-{kit_type}')

