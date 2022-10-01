import requests
import threading
import time
import os

def firstRequestFunc(url):
    for i in range(1000):
        x = requests.get(url)

def secondRequestFunc(url):
    for i in range(500):
        requests.get(url)

    time.sleep(60)
    for i in range(1000):
        requests.get(url)


if __name__ == "__main__":
    try:
        threads = []

        firstRequest = threading.Thread(target=firstRequestFunc, args=["http://"+os.environ['URL']+"/cluster1"])
        secondRequest = threading.Thread(target=secondRequestFunc, args=["http://"+os.environ['URL']+"/cluster2"])
        
        threads.append(firstRequest)
        threads.append(secondRequest)

        firstRequest.start()
        secondRequest.start()

        for t in threads:
            t.join()

        
    except:
        print("Error while trying to start threads")
