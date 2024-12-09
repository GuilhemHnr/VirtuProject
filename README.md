# Virtualization Project
Both tasks can be executed using the bash script `./Task_0X/setup.sh` (in sudo mode for Task_02).  
Successful outputs for both tasks can be found in `logs_setup_task0X.txt`.
## Task 01
This task needed installation of multiple packages (`conntrack crictl cri-dockerd`).  
In the first attempt, I tried to run minikube with no driver: `minikube start --driver=none`. This created issue, and it appeared I needed docker as driver to run the project. The next attempt didn't worked out as minikube don't allowed to change driver this easlily if already started.  
Exploring solution on internet, I found the following issue https://github.com/kubernetes/minikube/issues/9399 which lead me to add the option `--delete-on-failure`.
Then on the next attempt, I got an issue with the backend pod stucked in CrashLoopBackOff.  
Without changes, another tried was succesful, and validated with the following screenshot:
![Task02 Screenshot](./screenshot_task02.png)

## Task 02
This task was a bit more complicated. I tried to run the linked project, but encountered some configuration issues, after doing changes, and try different configurations using the latest version of the project, I finally chose to totally switch to the lastest version. It then ran, the only issue is that my `setup.sh` cannot work on the first try as some containers take too much time to set up, which lead the start of the container `rfsim5g-oai-nr-ue` to fail.  
I also tried to parameters DNS to allow to ping `www.lemonde.fr` however this wasn't successful. Hence, I opted for the second option to ping `192.168.72.135` as suggested by the project's [readme](https://gitlab.eurecom.fr/oai/openairinterface5g/-/tree/develop/ci-scripts/yaml_files/5g_rfsimulator#31-check-your-internet-connectivity).
Then, I got to run this project with success.