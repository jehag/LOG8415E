import requests
import threading
import time
import os

def firstRequestFunc(url):
    print("first thread starting 1000 requests", flush=True)
    thread_requests(url, 1000)
    print("first thread completed 1000 requests", flush=True)

    print("first thread complete", flush=True)

def secondRequestFunc(url):
    print("second thread starting 500 requests", flush=True)
    thread_requests(url, 500)
    print("second thread completed 500 requests", flush=True)


    print("second thread sleeping for 60s", flush=True)
    time.sleep(60)
    print("second thread resuming", flush=True)

    print("second thread starting 1000 requests", flush=True)
    thread_requests(url, 1000)
    print("second thread completed 1000 requests", flush=True)

    print("second thread complete", flush=True)

def thread_requests(url, count):
    threads = []

    for i in range(count):
        threads.append(threading.Thread(target=request, args=[url]))

    for thread in threads:
        thread.start()

    for thread in threads:
        thread.join()

def request(url):
    requests.get(url)


if __name__ == "__main__":
    try:
        threads = []
        start = time.time()
        firstRequest = threading.Thread(target=firstRequestFunc, args=["http://"+os.environ['URL']+"/cluster1"])
        secondRequest = threading.Thread(target=secondRequestFunc, args=["http://"+os.environ['URL']+"/cluster2"])

        threads.append(firstRequest)
        threads.append(secondRequest)

        firstRequest.start()
        secondRequest.start()

        for t in threads:
            t.join()

        print("total run time (s): " + str(time.time() - start))
        
    except BaseException as err:
        print("Error while trying to start threads")
        print(err)