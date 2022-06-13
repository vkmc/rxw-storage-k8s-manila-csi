#!/usr/bin/env bash

########################
# include the magic
########################
. demo-magic.sh


########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
# TYPE_SPEED=20

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
# DEMO_PROMPT="${GREEN}➜ ${CYAN}\W "
DEMO_PROMPT="[\u@\h:\w]\$ "

# text color
# DEMO_CMD_COLOR=$BLACK

# hide the evidence
clear

# pe "asciinema rec"
# pe "clear"

# StorageClass
p "# inspect storage class"
pei "oc get storageclasses -o yaml --field-selector='metadata.name=csi-manila-default'"
p "# in openstack we can check that the share-type exists"
pei "manila type-list"


# PV, PVC
p "# create pvc"
pei "oc create -f demo/manila-csi-rwx-pvc.yaml"
pei "oc get pvc"
p "# check that the pvc is bound to a pv"
pei "oc get pv"
p "# in openstack we can check that we created the share"
pei "manila list"

# Create pods
p "# create our three fs system writer pods"
# pe "cat demo/writer-one.yaml"
# wait
# pe "cat demo/writer-two-same-node.yaml"
# wait
# pe "cat demo/writer-three-different-node.yaml"
# wait
pei "oc create -f demo/writer-one.yaml"
pei "oc create -f demo/writer-two-same-node.yaml"
pei "oc create -f demo/writer-three-different-node.yaml"
p "# check they are running"
pei "oc get pod"

# Do stuff with pods
p "# all three pods have mounted the same shared volume at /mnt/test"
pei "for i in one two three; do echo writer-\$i:; oc exec writer-\$i -- mount | grep /mnt; done"
p "# all three pods see the same three files being written into the shared volume"
pei "for i in one two three; do echo writer-\$i:; oc exec writer-\$i -- ls /mnt/test; done"
p "# from any pod you can see the files being written by other pods in real time"
pe "oc exec writer-three -- tail -f /mnt/test/writer-one"

# Clean up
# p "# clean up"
# pe "for i in one two three; do oc delete pod writer-\$i; done; oc delete pvc mypvc"
# p ""
