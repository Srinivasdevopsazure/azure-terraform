**format and partition the data disk**

sudo parted /dev/sdc mklabel gpt
sudo parted /dev/sdc mkpart primary ext4 0% 100%

The first command "sudo parted /dev/sdc mklabel gpt" creates a GUID partition table (GPT) on the data disk at "/dev/sdc". GPT is a standard for the layout of the partition table on a physical storage device, such as a hard drive or solid-state drive, using globally unique identifiers (GUIDs).

The second command "sudo parted /dev/sdc mkpart primary ext4 0% 100%" creates a primary partition on the data disk at "/dev/sdc". The partition type is set to "ext4", which is a popular file system format used for Linux systems. The partition starts at 0% of the disk and takes up 100% of the available disk space.

Note: The "/dev/sdc" disk name is just an example and may be different in your case.
**sudo mkfs.ext4 /dev/sdc1**
The sudo mkfs.ext4 /dev/sdc1 command is used to format the disk partition located at /dev/sdc1 with the ext4 file system. The sudo command runs the following command with superuser (root) privileges. mkfs.ext4 is a tool that creates an ext4 file system on a specified disk partition. In this case, the partition is specified as /dev/sdc1. This command is necessary because you need a file system on a disk before you can mount it and store files on it.

**"null_resource" vs "local-exec" difference**
**null_resource** is a Terraform resource type that represents a resource that doesn't exist in your infrastructure. This resource is mainly used for running scripts, uploading files, and triggering actions.

**local-exec** is a provisioner that allows you to execute a command locally on the machine running Terraform. This provisioner is mainly used to run scripts, commands, or applications as part of your Terraform deployment.

The main difference between these two is that null_resource is a Terraform resource that allows you to execute scripts, run commands, and take actions, while local-exec is a provisioner that is used to execute commands locally on the machine running Terraform.
