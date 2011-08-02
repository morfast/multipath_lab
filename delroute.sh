#!/bin/bash

#VPNGATE="10.8.0.33"
LOCALGATE="59.77.33.1"

while read line
do
    ip route del ${line} via ${LOCALGATE}
done < routes

