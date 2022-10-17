import requests
import threading
import time
import os
import sys

def firstRequestFunc(url):
    """
    sends 1000 requests to url.
    requests are threaded to speed up the process

    :param url: url to send the requests to
    """
    print("first thread starting 1000 requests", flush=True)
    thread_requests(url, 1000)
    print("first thread completed 1000 requests", flush=True)

    print("first thread complete", flush=True)

def secondRequestFunc(url):
    """
    sends 500 requests to url, 
    sleeps for 60 seconds
    then sends 1000 requests to url.
    requests are threaded to speed up the process

    :param url: url to send the requests to
    """
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
    """
    send a number of threaded requests to the url

    :param url: url to send the requests to
    :param count: number of requests to send
    """
    threads = []

    # create threads
    for i in range(count):
        threads.append(threading.Thread(target=request, args=[url]))

    # start threads
    for thread in threads:
        thread.start()

    # wait for threads to finish
    for thread in threads:
        thread.join()

def request(url):
    """
    send a request to a url

    :param url: url to send the request to
    """
    requests.get(url)


if __name__ == "__main__":
    try:
        threads = []
        start = time.time()
        url = sys.argv[1] if sys.argv[1] else os.environ['URL'] # get the url from env variables or system args

        # create a thread for each cluster
        firstRequest = threading.Thread(target=firstRequestFunc, args=["http://"+url+"/cluster1"])
        secondRequest = threading.Thread(target=secondRequestFunc, args=["http://"+url+"/cluster2"])

        threads.append(firstRequest)
        threads.append(secondRequest)

        # start threads
        firstRequest.start()
        secondRequest.start()

        # wait for both threads to finish
        for t in threads:
            t.join()

        print("total run time (s): " + str(time.time() - start))
        
    except BaseException as err:
        print(err)