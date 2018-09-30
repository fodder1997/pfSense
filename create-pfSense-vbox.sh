#!/bin/bash
# Script to create VM with IPCOP ready for installation

VM_NAME=$1
DISK_SIZE=10000
VMS_FOLDER="/home/paul/VirtualBox VMs"
VRE_REMOTE_PORT=5010
VM_ISO=pfSense-CE-2.4.2-RELEASE-amd64.iso

echo "STARTING"
echo "VMS FOLDER ${VMS_FOLDER}"

if [[ "${VM_NAME}"  == "" ]]; then
	echo "Please enter a name for your VM"
	echo "$0 <vmname>"
	exit 1
fi

if [[ ! -d "${VMS_FOLDER}" ]]; then
	echo "Creating ${VMS_FOLDER}"
	mkdir -p "${VMS_FOLDER}"
fi

# Create and register
VBoxManage createvm --name "${VM_NAME}" --register

#Specify the hardware configurations of the VM (e.g., Ubuntu OS type, 1024MB memory, bridged networking, DVD booting).
VBoxManage modifyvm "${VM_NAME}" --memory 1024 --acpi on --boot1 dvd --nic1 bridged --bridgeadapter1 eth0 --ostype Ubuntu --vrde on

#Create a disk image (with size of 10000 MB). Optionally, you can specify disk image format by using "--format [VDI|VMDK|VHD]" option. Without this option, VDI image format will be used by default.
VBoxManage createvdi --filename "${VMS_FOLDER}/${VM_NAME}/${VM_NAME}-disk01.vdi" --size ${DISK_SIZE}

#Add an IDE controller to the VM.
VBoxManage storagectl "${VM_NAME}" --name "IDE Controller" --add ide

#Attach a floppy controller
#VBoxManage storagectl "${VM_NAME}" --add floppy --name "Floppy Controller"

#Attach the previously created disk image as well as CD/DVD drive to the IDE controller. IPCOP installation ISO image is then inserted to the CD/DVD drive.
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium "${VMS_FOLDER}/${VM_NAME}/${VM_NAME}-disk01.vdi"
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium ./${VM_ISO}

#Attach the floppy 
#VBoxManage storageattach "${VM_NAME}" --storagectl "Floppy Controller" --device 0 --port 0 --type fdd --medium "$VIRTUAL_FLOPPY_FILE_FREEDOS"

# Networking
VBoxManage modifyvm "${VM_NAME}" --nic1 bridged --nictype1 Am79C970A --bridgeadapter1 eth0
# eth1 = RED on HOST
VBoxManage modifyvm "${VM_NAME}" --nic2 bridged --nictype2 Am79C970A --bridgeadapter2 eth1 

# Remote Desktop
echo "Setting VRE port" ${VRE_REMOTE_PORT}
VBoxManage modifyvm "${VM_NAME}" --vrdeport ${VRE_REMOTE_PORT} --ioapic on
