import requests

for i in range(1, 50):
    response = requests.get(f'https://draft.premierleague.com/api/league/{i}/details').json()
    if response['league']['draft_status'] != 'pre' and response['league']['scoring'] == 'h':
        print(i)
