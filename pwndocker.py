#! C:\Users\She11c4T\Python\Python38 python
import argparse
import os
import sys
import base64
parser = argparse.ArgumentParser()

def parseInit():
    parser.add_argument("-s","--stop", help="stop a container", default=None)
    parser.add_argument("-hn","--hostname", help="the hostname of docker", default=None)
    parser.add_argument("-n","--name", help="the name of docker container", default=None)
    parser.add_argument("-p","--port", help="the port of docker binding to host", default=0,type=int)
    parser.add_argument("-f","--folder",help="the file folder mounted to docker", default=None)



def main():
    parseInit()
    args = parser.parse_args()
    if len(sys.argv)== 1:
        print("Use --help or -h to get help.")
        sys.exit()
    stopcontainer = args.stop
    hostname = args.hostname
    dockername = args.name
    port = args.port
    folder = args.folder

    #停止容器
    if stopcontainer!=None:
        cmd = "docker container stop "+ stopcontainer
        print(cmd)
        os.system(cmd)
        sys.exit()

    cmd = "docker run -d --rm"
    if hostname!=None:
        cmd += " -h "+hostname
    else:
        print("[*]No hostname,but I don't care.'")


    if dockername == None:
        dockername = base64.b64encode( os.urandom(6)).decode()
        print("[*]Container name(random gen):"+dockername)
    cmd += " --name "+dockername



    if port!=0:
        cmd += " -p "+str(port)+":"+str(port)
    else:
        print("[*]No port given,I will not bind it to any port.")


    if folder!=None:
        if  os.path.isdir(folder):
            cmd += " -v "+os.path.realpath(folder)+":/ctf/work"
        else:
            print("[x]File path error,it will not be mounted to container")
    else:
        print("[x]File path error,it will not be mounted to container")

    cmd += " --cap-add=SYS_PTRACE ma5ker/pwndocker"
    print(cmd)
    retcode = os.system(cmd)
    retcode = retcode >> 8
    if retcode!=0:
        print("[x]FATAL ERROR in Creating container.")
        sys.exit()
    print("[+]Creating container success")
    cmd = "docker exec -it "+dockername+" /bin/bash"
    print("[+]Get container shell: "+cmd)
    os.system(cmd)

if __name__=="__main__":
    main()

#docker run -d --rm -h ${ctf_name} --name ${ctf_name} -v $(pwd)/${ctf_name}:/ctf/work -p 23946:23946 --cap-add=SYS_PTRACE skysider/pwndocker
#docker exec -it ${ctf_name} /bin/bash