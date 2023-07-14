import requests

for i in range(51, 200):
    response = requests.get(f'https://draft.premierleague.com//api/draft/league/{i}/trades').json()
    if response.get('trades') is not None  and len(response['trades']) != 0:
        print(i)
