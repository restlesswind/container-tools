Summary:

A script to provision static local persistent volumes with the specific size on a single host
Usage: ./pv-utils.sh command dir numVols [size]
 - command: create, delete
 - dir: an existing directory where the block devices and volumes will be created
 - numVols: number of volumes to be created
 - size: size of the volumes in MiB. Not required if command is delete


Prerequisites:

- Kubernetes installation
- Existing local-storage storage class (default).
  If not, it can be manually created using the provided local-storage.yml
- Enough disk space on your system for the extra volumes to be created

Steps:

- Create a directory (if it doesn't exist) for the volumes (/opt/dev/disks in the example)
- Copy the create-pv.sh and pv-template.yml to a directory (/opt/dev/ for example)
- Optional: modify the pv-template.yml content if needed

- Run:
./pv-utils.sh create /opt/dev/disks 3 100

- Test:
# kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                                          STORAGECLASS          REASON   AGE
my-local-pv-1                              100Mi      RWO            Retain           Available                                                                  local-storage                  15s
my-local-pv-2                              100Mi      RWO            Retain           Available                                                                  local-storage                  14s
my-local-pv-3                              100Mi      RWO            Retain           Available                                                                  local-storage                  12s

- Clean up:
./pv-utils.sh delete /opt/dev/disks 3
