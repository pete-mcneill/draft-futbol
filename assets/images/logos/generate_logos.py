import requests
import shutil
teams = [
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
            "code": 90,
            "id": 6,
            "name": "Burnley",
            "pulse_id": 43,
            "short_name": "BUR"
        },
        {
            "code": 8,
            "id": 7,
            "name": "Chelsea",
            "pulse_id": 4,
            "short_name": "CHE"
        },
        {
            "code": 31,
            "id": 8,
            "name": "Crystal Palace",
            "pulse_id": 6,
            "short_name": "CRY"
        },
        {
            "code": 11,
            "id": 9,
            "name": "Everton",
            "pulse_id": 7,
            "short_name": "EVE"
        },
        {
            "code": 54,
            "id": 10,
            "name": "Fulham",
            "pulse_id": 34,
            "short_name": "FUL"
        },
        {
            "code": 14,
            "id": 11,
            "name": "Liverpool",
            "pulse_id": 10,
            "short_name": "LIV"
        },
        {
            "code": 102,
            "id": 12,
            "name": "Luton",
            "pulse_id": 163,
            "short_name": "LUT"
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
            "code": 49,
            "id": 17,
            "name": "Sheffield Utd",
            "pulse_id": 18,
            "short_name": "SHU"
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

for team in teams:
    r = requests.get(f'https://resources.premierleague.com/premierleague/badges/70/t{team["code"]}.png', stream=True)
    if r.status_code == 200:
        with open(f'./assets/images/logos/{team["code"]}.png', 'wb') as f:
            r.raw.decode_content = True
            shutil.copyfileobj(r.raw, f) 
    # r = requests.get(f'https://fantasy.premierleague.com/dist/img/shirts/standard/shirt_{team["code"]}_1-110.webp', stream=True)
    # if r.status_code == 200:
    #     with open(f'./assets/images/kits/{team["code"]}-keeper.png', 'wb') as f:
    #         r.raw.decode_content = True
    #         shutil.copyfileobj(r.raw, f) 

