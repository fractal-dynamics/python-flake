import requests
def main():
    url = 'https://dog.ceo/api/breeds/list/all'

    # Make a GET request to the URL
    response = requests.get(url)

    # If the request was successful (i.e., the status code is 200),
    # print the response content
    if response.status_code == 200:
        data = response.json()
        print(data['message'])
    else:
        print('Error:', response.status_code)
