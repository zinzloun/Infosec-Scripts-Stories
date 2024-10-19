# PIP dependency confusion
## Theory
![conf](confusion.png)

https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610
## Lab setup
- Debian GNU/Linux 12 (bookworm) x64
- Python 3.11.2 
- Python virtualenv
- pip 23.0.1

## POC
We are going to use [pip-install-test package](https://pypi.org/project/pip-install-test), the current version is 0.5.
First of all activate a virtual enviroment:

    python3 -m venv dep-conf
    source dep-conf/bin/activate
    (dep-conf) user@debian-Work:~$ 

Proceed to install the test package:

     pip install pip-install-test -vv
     ...
     Successfully installed pip-install-test-0.5

To perform our attack we must set a local pip repo. This is a very easy task: https://packaging.python.org/en/latest/guides/hosting-your-own-index
Here I'm going just to create the required folder structure, then I will use Python built-in web server to host the malicious package. My root web folder structure is the following:

    piprepo.local/
    └── pip-install-test
        └── pip-install-test-0.6.tar.gz

You can download the package from this repo.

  
    
